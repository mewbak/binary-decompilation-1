#define DEBUG_TYPE "max_stack_height"
#include "max_stack_height.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/raw_ostream.h"

#define RET_ADDRESS_SIZE 8

using namespace llvm;

char max_stack_height::ID = 0;
static RegisterPass<max_stack_height>
    X("ssh", "To Determine the max static stack height (ssh) of a function");

/*******************************************************************
  * Function :   runOnFunction
  * Purpose  :   Entry point for max_stack_height pass
********************************************************************/
bool max_stack_height::runOnFunction(Function &F) {
  Func = &F;

  DEBUG(errs() << "==========================================\n");
  DEBUG(errs() << "Function : " << Func->getName() << "\n");
  DEBUG(errs() << "==========================================\n");

  if (false == initialize_framework()) {
    return false; // Analysis pass
  }
  perform_dfa();

  dump_cfg();
  compute_height();

  cleanup_framework();

  return false; // Analysis pass
}

/*******************************************************************
  * Function :  cleanup_framework
  * Purpose  :  Cleanup the temporary data structures used to 
  *             compute max stack height of Function.
********************************************************************/
void max_stack_height::cleanup_framework() {
  BBMap.clear();
  llvm_alloca_inst_rsp = NULL;
  llvm_alloca_inst_rbp = NULL;
}

/*******************************************************************
  * Function :   perform_dfa
  * Purpose  :   Entry point for DFA
********************************************************************/
void max_stack_height::perform_dfa() {

  perform_const_dfa();

  perform_global_dfa();
}

/*******************************************************************
  * Function :  initialize_framework
  * Purpose  :  Initializes the temporary data-strcutures.
  *             Allocates the data values to each BB.
********************************************************************/
bool max_stack_height::initialize_framework() {

  llvm_alloca_inst_rsp = NULL;
  llvm_alloca_inst_rbp = NULL;

  // For the entry: find the llvm alloca inst for rsp_val, rbp_val
  BasicBlock *EB = &(Func->getEntryBlock());
  AllocaInst *alloca_inst;
  for (auto &I : *EB) {
    if (NULL != (alloca_inst = dyn_cast<AllocaInst>(&I))) {
      if (alloca_inst->getName().equals("RSP_val")) {
        llvm_alloca_inst_rsp = alloca_inst;
      } else if (alloca_inst->getName().equals("RBP_val")) {
        llvm_alloca_inst_rbp = alloca_inst;
      }
    }
  }

  if (NULL == llvm_alloca_inst_rsp || NULL == llvm_alloca_inst_rbp) {
    return false;
  }

  // Allocates the data values to each BB.
  for (Function::iterator BB = Func->begin(), E = Func->end(); BB != E; ++BB) {
    dfa_functions *dfvaInstance =
        new dfa_functions(TOTAL_FUNCTIONS, dfa_values(TOTAL_VALUES, 0));
    BBMap[BB] = dfvaInstance;
  }

  return true;
}

/*******************************************************************
 * Function :   perform_const_dfa
 * Purpose  :   Calculate the local data flow values of GEN[BB]
********************************************************************/
void max_stack_height::perform_const_dfa() {

  dfa_functions *dfvaInstance;
  for (Function::iterator BB = Func->begin(), E = Func->end(); BB != E; ++BB) {
    DEBUG(errs() << "----------------------------------\n");
    DEBUG(errs() << Func->getName() + "::" + BB->getName() << "\n");
    DEBUG(errs() << "----------------------------------\n");
    dfvaInstance = BBMap[BB];
    (*dfvaInstance)[GEN] = calculate_max_height_BB(BB);
  }
}

/*******************************************************************
 * Function :   calculate_max_height_BB
 * Purpose  :  
 *  Each instruction I (which may potentially affect rsp or rbp) within a bb is
 *  tracked (using visitInst) to obtain the follwoing data flow values before,
 *  In[I] and after, Out[I].
 *
 *  1. ACTUAL_ESP (or ACTUAL_EBP) = Actual displacement of 
 *              %rsp (or %rbp). For example, for a statement sub $0x20,%rsp, 
 *              if %esp value is x before the statement, 
 *              then actual_esp becomes x - 32 after it.
 *  2. MAX_DISP_ESP ( or MAX_DISP_EBP) = Offset of the stack 
 *              access w.r.t %rsp (or %rbp). For example, for a statement 
 *              mov -0x4(%rsp),%esi, if %esp value is x before the statement, 
 *              then max_disp_esp becomes x-4 after it.
 *
 *  After the data value propagation among I's, Gen[bb] is computed as follows:
 *    Gen[bb]::actual_esp = Actual displacement of esp across the bb with
 *    initial value of rsp/rbp assumed as 0.
 *    Gen[bb]::max_disp_esp = max (Out[I]::max_disp_esp) for all I in bb.
********************************************************************/
std::vector<height_ty>
max_stack_height::calculate_max_height_BB(BasicBlock *BB) {
  assert(NULL != llvm_alloca_inst_rsp && "BB visited before Entry !!!");

  std::vector<height_ty> ret_val(TOTAL_VALUES, 0);

  // Initialize
  attribs rsp_attribs = {true, false};
  attribs rbp_attribs = {false, false};
  InstMap[llvm_alloca_inst_rsp] = inst_map_val(0, rsp_attribs);
  InstMap[llvm_alloca_inst_rbp] = inst_map_val(0, rbp_attribs);
  max_dis_of_esp = max_dis_of_ebp = 0;

  visit(*BB);

  ret_val[ACTUAL_ESP] = InstMap[llvm_alloca_inst_rsp].first;
  ret_val[ACTUAL_EBP] = InstMap[llvm_alloca_inst_rbp].first;
  ret_val[MAX_DISP_ESP] = max_dis_of_esp;
  ret_val[MAX_DISP_EBP] = max_dis_of_ebp;

  debug_dfa_values("Gen :: ", ret_val);
  // Clean up
  InstMap.clear();
  max_dis_of_esp = max_dis_of_ebp = 0;

  return ret_val;
}


void max_stack_height::visitLoadInst(LoadInst &I) {
  Value *ld_ptr_op = I.getPointerOperand();
  if (InstMap.count(ld_ptr_op)) {
    // InstMap[&I] = InstMap[ld_ptr_op];
    InstMap[&I].first = InstMap[ld_ptr_op].first;
    InstMap[&I].second = InstMap[ld_ptr_op].second;
    debug_local_dfa_info(&I);
  }
}

void max_stack_height::visitStoreInst(StoreInst &I) {
  Value *st_ptr_op = I.getPointerOperand();
  Value *st_val_op = I.getValueOperand();

  if (InstMap.count(st_ptr_op) && InstMap.count(st_val_op)) {
    assert(false == InstMap[st_val_op].second[IS_UNKNOWN] &&
           "Storing an unknown value to rsp/rbp\n");
    InstMap[st_ptr_op].first = InstMap[st_val_op].first;
    debug_local_dfa_info(&I);
  }
}

void max_stack_height::visitExtractValueInst(ExtractValueInst &I) {
  Value *op1 = I.getOperand(0);
  if (InstMap.count(op1)) {
    InstMap[&I].first = InstMap[op1].first;
    InstMap[&I].second = InstMap[op1].second;
    debug_local_dfa_info(&I);
  }
}

void max_stack_height::visitCallInst(CallInst &I) {
  Function *called_func = I.getCalledFunction();
  assert(NULL != called_func && "indirect func call found");

  if (false == called_func->isDeclaration()) {
    InstMap[llvm_alloca_inst_rsp].first += RET_ADDRESS_SIZE;
    debug_local_dfa_info(&I);
  }
}

void max_stack_height::visitIntrinsicInst(IntrinsicInst &I) {

  unsigned ty = I.getIntrinsicID();
  switch (ty) {
  case Intrinsic::sadd_with_overflow:
  case Intrinsic::uadd_with_overflow: {
    visitAddSubHelper(&I, true, I.getOperand(0), I.getOperand(1));
    visitAddSubHelper(&I, true, I.getOperand(1), I.getOperand(0));
    break;
  }
  case Intrinsic::ssub_with_overflow:
  case Intrinsic::usub_with_overflow: {
    visitAddSubHelper(&I, false, I.getOperand(0), I.getOperand(1));
    break;
  }
  default:
    break;
  }
  return;
}

void max_stack_height::visitSub(BinaryOperator &I) {
  visitAddSubHelper(&I, false, I.getOperand(0), I.getOperand(1));
  return;
}

void max_stack_height::visitAdd(BinaryOperator &I) {
  Value *op1 = I.getOperand(0);
  Value *op2 = I.getOperand(1);
  if (InstMap.count(op1) && InstMap.count(op2)) {
    visitAddSubHelper(&I, true, op1, op2);
  } else {
    visitAddSubHelper(&I, true, op1, op2);
    visitAddSubHelper(&I, true, op2, op1);
  }
  return;
}

void max_stack_height::visitAddSubHelper(Instruction *I, bool isAdd, Value *op1,
                                         Value *op2) {

  if (0 == InstMap.count(op1)) {
    return;
  }

  ConstantInt *cosnt_val = NULL;
  height_ty offset = 0;

  if (!(NULL != (cosnt_val = dyn_cast<ConstantInt>(op2)) ||
        InstMap.count(op2))) {
    // op2 is neither  a constant nor available in InstMap
    // This may introduce inaccuracy either in actual esp/ebp
    // or max_dis_of_esp/max_dis_of_ebp
    // The inaccuracy in actual esp/ebp can be handled
    // by check the IS_UNKNOWN during store.
    offset = 0;
    InstMap[I].first = InstMap[op1].first + offset;
    InstMap[I].second = InstMap[op1].second;
    InstMap[I].second[IS_UNKNOWN] = true;

    // To do: Here we may have inaccuracy in  max_dis_of_esp/max_dis_of_ebp
    DEBUG(errs() << "max_dis_of_esp/max_dis_of_ebp may not be accurate\n");

    return;
  }

  if (NULL != (cosnt_val = dyn_cast<ConstantInt>(op2))) {
    offset = cosnt_val->getLimitedValue();
  } else {
    offset = InstMap[op2].first;
  }

  if (isAdd) {
    InstMap[I].first = InstMap[op1].first + offset;
    InstMap[I].second = InstMap[op1].second;
  } else {
    InstMap[I].first = InstMap[op1].first - offset;
    InstMap[I].second = InstMap[op1].second;
  }

  if (InstMap[I].second[IS_ESP]) {
    max_dis_of_esp = std::min(max_dis_of_esp, InstMap[I].first);
  } else {
    max_dis_of_ebp = std::min(max_dis_of_ebp, InstMap[I].first);
  }

  debug_local_dfa_info(I);
  return;
}

/*******************************************************************
 * Function :   perform_global_dfa
 * Purpose  :   Calculating In[bb] and Out[bb]
 *  Meet operator: Calculating In[bb] as a function of Out[pped_bb],
      //For any pair of predecessor pred_bb_x and pred_bb_y
      if ( Out[pred_bb_x]::actual_esp == OUT[pred_bb_y]::actual_esp &&  
          OUT[pred_bb_x]::actual_ebp == OUT[pred_bb_y]::actual_ebp) {
        In[bb]::actual_esp  = Out[pred_bb_x]::actual_esp;
        In[bb]::actual_ebp  = Out[pred_bb_x]::actual_ebp;
        In[bb]::max_disp_esp  = min ( OUT[pred_bb_x]::max_disp_esp, OUT[pred_bb_y]::max_disp_esp)
        In[bb]::max_disp_ebp  = min ( OUT[pred_bb_x]::max_disp_ebp, OUT[pred_bb_y]::max_disp_ebp)
      } else {
        In[bb] = Bottom
      }
    
    Transfer function: Calculating Out[bb] as a function of Gen[bb] and In[bb]
      if(In[bb] == Bottom) {
        Out[bb] =  Bottom;
      } else {
        Out[bb]::actual_esp = In[bb]::actual_esp + Gen[bb]::actual_esp;
        Out[bb]::actual_ebp = In[bb]::actual_ebp + Gen[bb]::actual_ebp;
        Out[bb]::max_disp_esp = min ( In[bb]::actual_esp + Gen[bb]::max_disp_esp, In[bb]::max_disp_esp;
        Out[bb]::max_disp_ebp = min ( In[bb]::actual_ebp + Gen[bb]::max_disp_ebp, In[bb]::max_disp_ebp;
      }
********************************************************************/
void max_stack_height::perform_global_dfa() {

  bool Changed = false;
  dfa_values init_out(TOTAL_VALUES, -3);

  // initialize OUT set of each basic block to top
  for (Function::iterator BB = Func->begin(), E = Func->end(); BB != E; ++BB) {
    dfa_functions *dfvaInstance = BBMap[BB];
    (*dfvaInstance)[OUT] = init_out;
  }

  DEBUG(errs() << "\n\nDFA Analysis: \n");
  do {
    Changed = false;
    ReversePostOrderTraversal<Function *> RPOT(Func);

    for (ReversePostOrderTraversal<Function *>::rpo_iterator I = RPOT.begin(),
                                                             E = RPOT.end();
         I != E; ++I) {
      BasicBlock *BB = *I;
      dfa_functions *dfvaInstance = BBMap[BB];

      DEBUG(errs() << Func->getName() + "::" + BB->getName() + "\n");

      // go over predecessors and take a meet
      dfa_values meetOverPreds = meet_over_preds(BB);

      // 'In' as a function of pred 'Out's
      (*dfvaInstance)[IN] = meetOverPreds;
      dfa_values old_out = (*dfvaInstance)[OUT];

      // 'Out' as a function of 'In'
      transfer_function(dfvaInstance);

      debug_dfa_values("\tOut :: ", (*dfvaInstance)[OUT]);

      dfa_values new_out = (*dfvaInstance)[OUT];
      if (old_out != new_out) {
        Changed = true;
      }
    }
  } while (Changed);
}

dfa_values max_stack_height::meet_over_preds(BasicBlock *BB) {
  dfa_values init_in_entry(TOTAL_VALUES, 0);
  dfa_values top(TOTAL_VALUES, 0);
  dfa_values init_out(TOTAL_VALUES, -3);
  dfa_values bottom(TOTAL_VALUES, -1);

  bool is_entry = true;
  bool first = true;

  // this vector would be initialized accordingly later by the
  // first predecessor while taking a meet over predecessors
  dfa_values meetOverPreds = top;

  for (pred_iterator PI = pred_begin(BB), PE = pred_end(BB); PI != PE; ++PI) {
    is_entry = false;

    dfa_values out_val = (*(BBMap[*PI]))[OUT];
    debug_dfa_values("\tPred :: " + (*PI)->getName().str() + ": ", out_val);

    if (out_val != init_out) {
      if (first) {
        first = false;
        meetOverPreds = out_val;
      } else {
        if ((out_val[ACTUAL_ESP] == meetOverPreds[ACTUAL_ESP]) &&
            (out_val[ACTUAL_EBP] == meetOverPreds[ACTUAL_EBP])) {
          meetOverPreds[MAX_DISP_ESP] =
              std::min(meetOverPreds[MAX_DISP_ESP], out_val[MAX_DISP_ESP]);
          meetOverPreds[MAX_DISP_EBP] =
              std::min(meetOverPreds[MAX_DISP_EBP], out_val[MAX_DISP_EBP]);
        } else {
          meetOverPreds = bottom;
        }
      }
    }
  }
  debug_dfa_values("\tGen :: ", (*BBMap[BB])[GEN]);

  // no predecessor, this is the start block s.
  if (is_entry) {
    meetOverPreds = init_in_entry;
  }

  return meetOverPreds;
}

void max_stack_height::transfer_function(dfa_functions *dfvaInstance) {

  dfa_values bottom(TOTAL_VALUES, -1);

  if ((*dfvaInstance)[IN] == bottom) {
    (*dfvaInstance)[OUT] = bottom;
  } else {
    (*dfvaInstance)[OUT][ACTUAL_ESP] =
        ((*dfvaInstance)[IN][ACTUAL_ESP] + (*dfvaInstance)[GEN][ACTUAL_ESP]);
    (*dfvaInstance)[OUT][ACTUAL_EBP] =
        ((*dfvaInstance)[IN][ACTUAL_EBP] + (*dfvaInstance)[GEN][ACTUAL_EBP]);

    (*dfvaInstance)[OUT][MAX_DISP_ESP] = std::min(
        (*dfvaInstance)[IN][ACTUAL_ESP] + (*dfvaInstance)[GEN][MAX_DISP_ESP],
        (*dfvaInstance)[IN][MAX_DISP_ESP]);
    (*dfvaInstance)[OUT][MAX_DISP_EBP] = std::min(
        (*dfvaInstance)[IN][ACTUAL_EBP] + (*dfvaInstance)[GEN][MAX_DISP_EBP],
        (*dfvaInstance)[IN][MAX_DISP_EBP]);
  }
}

/*******************************************************************
 * Function :   debug_local_dfa_info
 * Purpose  :   print the data structure InstMap
********************************************************************/
void max_stack_height::debug_local_dfa_info(Value *I) {
  DEBUG(errs() << *I << " :::  ");

  if (InstMap.count(I)) {
    DEBUG(errs() << "[I] = " << InstMap[I].first << " : ");
  } else {
    DEBUG(errs() << "[I] = NULL"
                 << " : ");
  }

  dfa_values val = {InstMap[llvm_alloca_inst_rsp].first,
                    InstMap[llvm_alloca_inst_rbp].first, max_dis_of_esp,
                    max_dis_of_ebp};
  debug_dfa_values("Inst :: ", val);
}

/*******************************************************************
 * Function :   debug_dfa_values
 * Purpose  :   print the data flow values.
********************************************************************/
void max_stack_height::debug_dfa_values(std::string msg, dfa_values val) {

  DEBUG(errs() << msg << val[ACTUAL_ESP] << ":" << val[MAX_DISP_ESP] << ":"
               << val[ACTUAL_EBP] << ":" << val[MAX_DISP_EBP] << "\n");
}

/*******************************************************************
 * Function :   print_void
 * Purpose  :   print the data flow functions IN, OUT, GEN
********************************************************************/
void max_stack_height::debug_global_dfa_info() {

  DEBUG(errs() << "----------------------------------\n");
  DEBUG(errs() << "DFA Equations: \n");
  DEBUG(errs() << "----------------------------------\n");
  dfa_functions *dfvaInstance;
  StringRef Fname = Func->getName();

  for (auto &BB : *Func) {
    dfvaInstance = BBMap[&BB];
    StringRef BBname = BB.getName();
    DEBUG(errs() << Fname << "::" << BBname << "\n");
    for (uint32_t i = 0; i < TOTAL_FUNCTIONS; i++) {

      switch (i) {
      case (IN):
        DEBUG(errs() << "  IN  ");
        break;
      case (GEN):
        DEBUG(errs() << "  GEN ");
        break;
      case (OUT):
        DEBUG(errs() << "  OUT ");
        break;
      }
      debug_dfa_values(" ", (*dfvaInstance)[i]);
    }
  }
}

/*******************************************************************
 * Function :   dump_cfg
 * Purpose  :   dump cfg in dot format with data flow info embedded.
********************************************************************/
void max_stack_height::dump_cfg() {

  std::string err_string;
  StringRef fname = Func->getName();
  std::string filename = "cfg." + fname.str() + ".dot";

  raw_fd_ostream dotfile(filename.c_str(), err_string, sys::fs::F_Text);
  dotfile << "digraph graphname { \n";

  // Create Node_count [shape="record" label="BBname"]
  uint64_t count = 0;
  std::map<BasicBlock *, std::string> BB2Names;
  for (auto &BB : *Func) {
    std::string nodename = "Node_" + std::to_string(count);
    dfa_functions *dfvaInstance = BBMap[&BB];

    // Node_0 [ shape="record"
    // label="entry|{0:0:0:0|-136:-136:-8:-80|-136:-136:-8:-80}"]
    // For different style try
    // Node_0 [ shape="record"
    // label="{entry|{0:0:0:0|-136:-136:-8:-80|-136:-136:-8:-80}}"]
    dotfile << nodename << " [ shape=\"record\" label=\"" + BB.getName() << "|{"
            << (*dfvaInstance)[IN][ACTUAL_ESP] << ":"
            << (*dfvaInstance)[IN][MAX_DISP_ESP] << ":"
            << (*dfvaInstance)[IN][ACTUAL_EBP] << ":"
            << (*dfvaInstance)[IN][MAX_DISP_EBP] << "|"
            << (*dfvaInstance)[GEN][ACTUAL_ESP] << ":"
            << (*dfvaInstance)[GEN][MAX_DISP_ESP] << ":"
            << (*dfvaInstance)[GEN][ACTUAL_EBP] << ":"
            << (*dfvaInstance)[GEN][MAX_DISP_EBP] << "|"
            << (*dfvaInstance)[OUT][ACTUAL_ESP] << ":"
            << (*dfvaInstance)[OUT][MAX_DISP_ESP] << ":"
            << (*dfvaInstance)[OUT][ACTUAL_EBP] << ":"
            << (*dfvaInstance)[OUT][MAX_DISP_EBP] << "}"
            << "}\"]\n";

    BB2Names[&BB] = nodename;
    count++;
  }

  dotfile << "\n";

  for (auto &BB : *Func) {
    for (pred_iterator PI = pred_begin(&BB), E = pred_end(&BB); PI != E; ++PI) {
      dotfile << BB2Names[*PI] << " -> " << BB2Names[&BB] << "\n";
    }
  }

  dotfile << "}";
  dotfile.close();
}

/*******************************************************************
 * Function :   compute_height
 * Purpose  : Compute the max statck height
 *  max ( Out[bb]::max_disp_esp, Out[bb]::max_disp_esp ) for  all bb.
********************************************************************/
void max_stack_height::compute_height() {
  height_ty max_dis_esp = 0;
  height_ty max_dis_ebp = 0;

  dfa_functions *dfvaInstance;
  StringRef Fname = Func->getName();
  for (auto &BB : *Func) {
    dfvaInstance = BBMap[&BB];
    max_dis_esp = std::min(max_dis_esp, (*dfvaInstance)[OUT][MAX_DISP_ESP]);
    max_dis_ebp = std::min(max_dis_ebp, (*dfvaInstance)[OUT][MAX_DISP_EBP]);
  }
  stack_height = std::min(max_dis_esp, max_dis_ebp);

  DEBUG(errs() << "Height[ " << Fname << " ] : " << stack_height << "\n");
}