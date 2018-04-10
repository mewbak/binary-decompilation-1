import angr
proj = angr.Project('./instructions/movzwl_r32_r16/movzwl_r32_r16.o')
print proj.arch
print proj.entry
print proj.filename
irsb = proj.factory.block(proj.entry).vex
irsb.pp()