// Autogenerated using stratification.
requires "x86-configuration.k"

module VCVTDQ2PS-YMM-M256
  imports X86-CONFIGURATION

  context execinstr(vcvtdq2ps:Opcode HOLE:Mem, R2:Ymm,  .Operands) [result(MemOffset)]
  
  rule <k>
    execinstr (vcvtdq2ps:Opcode memOffset( MemOff:MInt):MemOffset, R2:Ymm,  .Operands) =>
      loadFromMemory( MemOff, 256) ~>
      execinstr (vcvtdq2ps memOffset( MemOff), R2:Ymm,  .Operands)
  ...</k>
    <regstate> RSMap:Map </regstate>
          
  rule <k>
    memLoadValue(Mem256:MInt):MemLoadValue ~> execinstr (vcvtdq2ps:Opcode memOffset( MemOff:MInt):MemOffset, R2:Ymm,  .Operands) =>
      .
  ...</k>
    <regstate>
      RSMap:Map => updateMap(RSMap,
convToRegKeys(R2) |-> concatenateMInt( cvt_int32_to_single(extractMInt( Mem256, 0, 32)), concatenateMInt( cvt_int32_to_single(extractMInt( Mem256, 32, 64)), concatenateMInt( cvt_int32_to_single(extractMInt( Mem256, 64, 96)), concatenateMInt( cvt_int32_to_single(extractMInt( Mem256, 96, 128)), concatenateMInt( cvt_int32_to_single(extractMInt( Mem256, 128, 160)), concatenateMInt( cvt_int32_to_single(extractMInt( Mem256, 160, 192)), concatenateMInt( cvt_int32_to_single(extractMInt( Mem256, 192, 224)), cvt_int32_to_single(extractMInt( Mem256, 224, 256)))))))))
      )
    </regstate>
endmodule
