import angr
proj = angr.Project('./instructions/orl_r32_r32/orl_r32_r32.o')
print proj.arch
print proj.entry
print proj.filename
irsb = proj.factory.block(proj.entry).vex
irsb.pp()