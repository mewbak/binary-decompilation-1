TEST_BEGIN(ADDPSv128m128_04, 1)
TEST_INPUTS(
    0,
    0x3f800000,
    0x40490fdb,
    0x47c34f80,
    0x3ff0000000000000,
    0x400921fb54442d18,
    0x40f869f000000000.
    0x4141414141414141)

    movq  ARG1_64,  %rax
    movq  %rax, %xmm4
    movdqu %xmm4, -16(%rsp)
    addps -16(%rsp), %xmm0
TEST_END


TEST_BEGIN(VADDPSv128m128_45, 1)
TEST_INPUTS(
    0,
    0x3f800000,
    0x40490fdb,
    0x47c34f80,
    0x3ff0000000000000,
    0x400921fb54442d18,
    0x40f869f000000000.
    0x4141414141414141)

    movq  ARG1_64,  %rax
    movq  %rax, %xmm5
    movdqu %xmm4, -16(%rsp)
    vaddps -16(%rsp), %xmm4, %xmm1
TEST_END

TEST_BEGIN(VADDPSv256m256_45, 1)
TEST_INPUTS(
    0,
    0x3f800000,
    0x40490fdb,
    0x47c34f80,
    0x3ff0000000000000,
    0x400921fb54442d18,
    0x40f869f000000000.
    0x4141414141414141)

    movq  ARG1_64,  %rax
    movq  %rax, %xmm5
    movdqu %xmm4, -32(%rsp)
    vaddps -32(%rsp), %ymm4, %ymm1
TEST_END
