    .text
    .globl	strlen
strlen:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -24(%rbp)
    movq	$0, -8(%rbp)
    jmp	L2
L3:
    addq	$1, -8(%rbp)
L2:
    movq	-24(%rbp), %rdx
    movq	-8(%rbp), %rax
    addq	%rdx, %rax
    movzbl	(%rax), %eax
    testb	%al, %al
    jne	L3
    movq	-8(%rbp), %rax
    popq	%rbp
    ret
    .globl	strcpy
strcpy:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -24(%rbp)
    movq	%rsi, -32(%rbp)
    movq	-24(%rbp), %rax
    movq	%rax, -8(%rbp)
    nop
L6:
    movq	-24(%rbp), %rax
    leaq	1(%rax), %rdx
    movq	%rdx, -24(%rbp)
    movq	-32(%rbp), %rdx
    leaq	1(%rdx), %rcx
    movq	%rcx, -32(%rbp)
    movzbl	(%rdx), %edx
    movb	%dl, (%rax)
    movzbl	(%rax), %eax
    testb	%al, %al
    jne	L6
    movq	-8(%rbp), %rax
    popq	%rbp
    ret
    .globl	strcmp
strcmp:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -8(%rbp)
    movq	%rsi, -16(%rbp)
    jmp	L9
L11:
    addq	$1, -8(%rbp)
    addq	$1, -16(%rbp)
L9:
    movq	-8(%rbp), %rax
    movzbl	(%rax), %eax
    testb	%al, %al
    je	L10
    movq	-8(%rbp), %rax
    movzbl	(%rax), %edx
    movq	-16(%rbp), %rax
    movzbl	(%rax), %eax
    cmpb	%al, %dl
    je	L11
L10:
    movq	-8(%rbp), %rax
    movzbl	(%rax), %eax
    movzbl	%al, %edx
    movq	-16(%rbp), %rax
    movzbl	(%rax), %eax
    movzbl	%al, %eax
    subl	%eax, %edx
    movl	%edx, %eax
    popq	%rbp
    ret
    .globl	strchr
strchr:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -8(%rbp)
    movl	%esi, -12(%rbp)
    jmp	L14
L16:
    movq	-8(%rbp), %rax
    leaq	1(%rax), %rdx
    movq	%rdx, -8(%rbp)
    movzbl	(%rax), %eax
    testb	%al, %al
    jne	L14
    movl	$0, %eax
    jmp	L15
L14:
    movq	-8(%rbp), %rax
    movzbl	(%rax), %eax
    movl	-12(%rbp), %edx
    cmpb	%dl, %al
    jne	L16
    movq	-8(%rbp), %rax
L15:
    popq	%rbp
    ret
    .globl	strncpy
strncpy:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -24(%rbp)
    movq	%rsi, -32(%rbp)
    movq	%rdx, -40(%rbp)
    movq	-24(%rbp), %rax
    movq	%rax, -8(%rbp)
L20:
    movq	-40(%rbp), %rax
    leaq	-1(%rax), %rdx
    movq	%rdx, -40(%rbp)
    testq	%rax, %rax
    jne	L18
    movq	-8(%rbp), %rax
    jmp	L19
L18:
    movq	-24(%rbp), %rax
    leaq	1(%rax), %rdx
    movq	%rdx, -24(%rbp)
    movq	-32(%rbp), %rdx
    leaq	1(%rdx), %rcx
    movq	%rcx, -32(%rbp)
    movzbl	(%rdx), %edx
    movb	%dl, (%rax)
    movzbl	(%rax), %eax
    testb	%al, %al
    jne	L20
    jmp	L21
L22:
    movq	-24(%rbp), %rax
    leaq	1(%rax), %rdx
    movq	%rdx, -24(%rbp)
    movb	$0, (%rax)
L21:
    movq	-40(%rbp), %rax
    leaq	-1(%rax), %rdx
    movq	%rdx, -40(%rbp)
    testq	%rax, %rax
    jne	L22
    movq	-8(%rbp), %rax
L19:
    popq	%rbp
    ret
    .globl	strncmp
strncmp:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -8(%rbp)
    movq	%rsi, -16(%rbp)
    movq	%rdx, -24(%rbp)
    jmp	L24
L26:
    movq	-8(%rbp), %rax
    leaq	1(%rax), %rdx
    movq	%rdx, -8(%rbp)
    movzbl	(%rax), %ecx
    movq	-16(%rbp), %rax
    leaq	1(%rax), %rdx
    movq	%rdx, -16(%rbp)
    movzbl	(%rax), %eax
    cmpb	%al, %cl
    je	L24
    movq	-8(%rbp), %rax
    subq	$1, %rax
    movzbl	(%rax), %eax
    movzbl	%al, %edx
    movq	-16(%rbp), %rax
    subq	$1, %rax
    movzbl	(%rax), %eax
    movzbl	%al, %eax
    subl	%eax, %edx
    movl	%edx, %eax
    jmp	L25
L24:
    movq	-24(%rbp), %rax
    leaq	-1(%rax), %rdx
    movq	%rdx, -24(%rbp)
    testq	%rax, %rax
    jne	L26
    movl	$0, %eax
L25:
    popq	%rbp
    ret
    .globl	memcmp
memcmp:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -24(%rbp)
    movq	%rsi, -32(%rbp)
    movq	%rdx, -40(%rbp)
    movq	-24(%rbp), %rax
    movq	%rax, -16(%rbp)
    movq	-32(%rbp), %rax
    movq	%rax, -8(%rbp)
    jmp	L28
L31:
    movq	-16(%rbp), %rax
    movzbl	(%rax), %edx
    movq	-8(%rbp), %rax
    movzbl	(%rax), %eax
    cmpb	%al, %dl
    je	L29
    movq	-16(%rbp), %rax
    movzbl	(%rax), %eax
    movzbl	%al, %edx
    movq	-8(%rbp), %rax
    movzbl	(%rax), %eax
    movzbl	%al, %eax
    subl	%eax, %edx
    movl	%edx, %eax
    jmp	L30
L29:
    addq	$1, -16(%rbp)
    addq	$1, -8(%rbp)
L28:
    movq	-40(%rbp), %rax
    leaq	-1(%rax), %rdx
    movq	%rdx, -40(%rbp)
    testq	%rax, %rax
    jne	L31
    movl	$0, %eax
L30:
    popq	%rbp
    ret
    .globl	__stack_chk_fail
__stack_chk_fail:
    pushq	%rbp
    movq	%rsp, %rbp
    movq $-1, %rax
    jmp %rax
    
    nop
    popq	%rbp
    ret
    .globl	exit
exit:
    pushq	%rbp
    movq	%rsp, %rbp
    movl	%edi, -4(%rbp)
    movq $-1, %rax
    jmp %rax
    
    nop
    popq	%rbp
    ret
    .globl	abort
abort:
    pushq	%rbp
    movq	%rsp, %rbp
    movq $-1, %rax
    jmp %rax
    
    nop
    popq	%rbp
    ret
    .globl	memset
memset:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -24(%rbp)
    movl	%esi, -28(%rbp)
    movq	%rdx, -40(%rbp)
    movq	-24(%rbp), %rax
    movq	%rax, -8(%rbp)
    jmp	L36
L37:
    movq	-8(%rbp), %rax
    leaq	1(%rax), %rdx
    movq	%rdx, -8(%rbp)
    movl	-28(%rbp), %edx
    movb	%dl, (%rax)
L36:
    movq	-40(%rbp), %rax
    leaq	-1(%rax), %rdx
    movq	%rdx, -40(%rbp)
    testq	%rax, %rax
    jne	L37
    movq	-24(%rbp), %rax
    popq	%rbp
    ret
    .globl	memcpy
memcpy:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -24(%rbp)
    movq	%rsi, -32(%rbp)
    movq	%rdx, -40(%rbp)
    movq	-24(%rbp), %rax
    movq	%rax, -16(%rbp)
    movq	-32(%rbp), %rax
    movq	%rax, -8(%rbp)
    jmp	L40
L41:
    movq	-16(%rbp), %rax
    leaq	1(%rax), %rdx
    movq	%rdx, -16(%rbp)
    movq	-8(%rbp), %rdx
    leaq	1(%rdx), %rcx
    movq	%rcx, -8(%rbp)
    movzbl	(%rdx), %edx
    movb	%dl, (%rax)
L40:
    movq	-40(%rbp), %rax
    leaq	-1(%rax), %rdx
    movq	%rdx, -40(%rbp)
    testq	%rax, %rax
    jne	L41
    movq	-24(%rbp), %rax
    popq	%rbp
    ret
    .globl	malloc
malloc:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -8(%rbp)
    movl	$1000, %eax
    popq	%rbp
    ret
    .globl	calloc
calloc:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -8(%rbp)
    movq	%rsi, -16(%rbp)
    movl	$1000, %eax
    popq	%rbp
    ret
    .globl	free
free:
    pushq	%rbp
    movq	%rsp, %rbp
    movq	%rdi, -8(%rbp)
    nop
    popq	%rbp
    ret
    .globl	isprint
isprint:
    pushq	%rbp
    movq	%rsp, %rbp
    movl	%edi, -4(%rbp)
    cmpl	$96, -4(%rbp)
    jle	L49
    cmpl	$122, -4(%rbp)
    jg	L49
    movl	$1, %eax
    jmp	L50
L49:
    cmpl	$64, -4(%rbp)
    jle	L51
    cmpl	$90, -4(%rbp)
    jg	L51
    movl	$1, %eax
    jmp	L50
L51:
    cmpl	$47, -4(%rbp)
    jle	L52
    cmpl	$57, -4(%rbp)
    jg	L52
    movl	$1, %eax
    jmp	L50
L52:
    movl	$0, %eax
L50:
    popq	%rbp
    ret
    .comm	gi,4,4
    .comm	cond,4,4
    .globl	never_ever
never_ever:
    pushq	%rbp
    movq	%rsp, %rbp
    subq	$16, %rsp
    movl	%edi, -4(%rbp)
    movq	%rsi, -16(%rbp)
    call	abort
mark_cell:
    pushq	%rbp
    movq	%rsp, %rbp
    subq	$16, %rsp
    movq	%rdi, -8(%rbp)
    movq	%rsi, -16(%rbp)
    movl	cond(%rip), %eax
    testl	%eax, %eax
    je	L65
    cmpq	$0, -16(%rbp)
    je	L57
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L57
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L57
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$262144, %eax
    testl	%eax, %eax
    jne	L57
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$1, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
L57:
    cmpq	$0, -16(%rbp)
    je	L58
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L58
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L58
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$131072, %eax
    testl	%eax, %eax
    jne	L58
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$2, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
L58:
    cmpq	$0, -16(%rbp)
    je	L59
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L59
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L59
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$65536, %eax
    testl	%eax, %eax
    jne	L59
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$3, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
L59:
    cmpq	$0, -16(%rbp)
    je	L60
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L60
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L60
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$32768, %eax
    testl	%eax, %eax
    jne	L60
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$4, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
L60:
    cmpq	$0, -16(%rbp)
    je	L61
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L61
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L61
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$16384, %eax
    testl	%eax, %eax
    jne	L61
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$5, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
L61:
    cmpq	$0, -16(%rbp)
    je	L62
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L62
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L62
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$8192, %eax
    testl	%eax, %eax
    jne	L62
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$6, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
L62:
    cmpq	$0, -16(%rbp)
    je	L63
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L63
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L63
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$4096, %eax
    testl	%eax, %eax
    jne	L63
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$7, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
L63:
    cmpq	$0, -16(%rbp)
    je	L64
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L64
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L64
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$2048, %eax
    testl	%eax, %eax
    jne	L64
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$8, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
L64:
    cmpq	$0, -16(%rbp)
    je	L54
    movq	-16(%rbp), %rax
    movq	16(%rax), %rax
    cmpq	$4, %rax
    jne	L54
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    testq	%rax, %rax
    je	L54
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	(%rax), %eax
    andl	$1024, %eax
    testl	%eax, %eax
    jne	L54
    movq	-16(%rbp), %rax
    movq	(%rax), %rax
    movl	gi(%rip), %edx
    addl	$9, %edx
    movq	%rax, %rsi
    movl	%edx, %edi
    call	never_ever
    jmp	L54
L65:
    nop
L54:
    leave
    ret
foo:
    pushq	%rbp
    movq	%rsp, %rbp
    subq	$16, %rsp
    movq	%rdi, -8(%rbp)
    movq	%rsi, -16(%rbp)
    movq	-16(%rbp), %rdx
    movq	-8(%rbp), %rax
    movq	%rdx, %rsi
    movq	%rax, %rdi
    call	mark_cell
    nop
    leave
    ret
getnull:
    pushq	%rbp
    movq	%rsp, %rbp
    movl	$0, %eax
    popq	%rbp
    ret
    .globl	main
.globl _start
_start:
    pushq	%rbp
    movq	%rsp, %rbp
    subq	$16, %rsp
    movl	$1, cond(%rip)
    movl	$0, -4(%rbp)
    jmp	L70
L71:
    call	getnull
    movq	%rax, %rsi
    movl	$gi, %edi
    call	foo
    addl	$1, -4(%rbp)
L70:
    cmpl	$99, -4(%rbp)
    jle	L71
    movl	$0, %eax
    leave
    ret
    .globl	bar_1
bar_1:
    pushq	%rbp
    movq	%rsp, %rbp
    subq	$16, %rsp
    movq	%rdi, -8(%rbp)
    movq	%rsi, -16(%rbp)
    movq	-16(%rbp), %rax
    movq	8(%rax), %rax
    leaq	1(%rax), %rdx
    movq	-16(%rbp), %rax
    movq	%rdx, 8(%rax)
    movq	-16(%rbp), %rdx
    movq	-8(%rbp), %rax
    movq	%rdx, %rsi
    movq	%rax, %rdi
    call	mark_cell
    nop
    leave
    ret
    .globl	bar_2
bar_2:
    pushq	%rbp
    movq	%rsp, %rbp
    subq	$16, %rsp
    movq	%rdi, -8(%rbp)
    movq	%rsi, -16(%rbp)
    movq	-16(%rbp), %rax
    movq	8(%rax), %rax
    leaq	2(%rax), %rdx
    movq	-16(%rbp), %rax
    movq	%rdx, 8(%rax)
    movq	-16(%rbp), %rdx
    movq	-8(%rbp), %rax
    movq	%rdx, %rsi
    movq	%rax, %rdi
    call	mark_cell
    nop
    leave
    ret
