strchr:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	nop
	movq	-8(%rbp), %rax
	movzbl	(%rax), %edx
	movl	-12(%rbp), %eax
	cmpb	%al, %dl
	je	L6
	movq	-8(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -8(%rbp)
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	L3
	movl	$0, %eax
	jmp	L1
L3:
	movq	-8(%rbp), %rax
	jmp	L1
L6:
L1:
	popq	%rbp
	ret
strlen:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, -24(%rbp)
	movq	$0, -8(%rbp)
	jmp	L8
L9:
	addq	$1, -8(%rbp)
L8:
	movq	-24(%rbp), %rdx
	movq	-8(%rbp), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	L9
	movq	-8(%rbp), %rax
	popq	%rbp
	ret
strcpy:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, -8(%rbp)
	nop
L12:
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
	jne	L12
	movq	-8(%rbp), %rax
	popq	%rbp
	ret
exit:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	%edi, -4(%rbp)
	movq $-1, %rax
	jmp %rax
	
	popq	%rbp
	ret
abort:
	pushq	%rbp
	movq	%rsp, %rbp
	movq $-1, %rax
	jmp %rax
	
	popq	%rbp
	ret
memset:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, -24(%rbp)
	movl	%esi, -28(%rbp)
	movq	%rdx, -40(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, -8(%rbp)
	jmp	L17
L18:
	movq	-8(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -8(%rbp)
	movl	-28(%rbp), %edx
	movb	%dl, (%rax)
L17:
	movq	-40(%rbp), %rax
	leaq	-1(%rax), %rdx
	movq	%rdx, -40(%rbp)
	testq	%rax, %rax
	jne	L18
	movq	-24(%rbp), %rax
	popq	%rbp
	ret
.globl _start
_start:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movl	$924, -4(%rbp)
	movl	-4(%rbp), %eax
	addl	$2, %eax
	addl	%eax, %eax
	subl	$8, %eax
	shrl	%eax
	movl	%eax, -8(%rbp)
	cmpl	$922, -8(%rbp)
	je	L21
	call	abort
L21:
	movl	-4(%rbp), %eax
	addl	%eax, %eax
	subl	$2, %eax
	shrl	%eax
	movl	%eax, -8(%rbp)
	cmpl	$923, -8(%rbp)
	je	L22
	call	abort
L22:
	movl	-4(%rbp), %eax
	addl	$2, %eax
	addl	%eax, %eax
	subl	$12, %eax
	shrl	%eax
	movl	%eax, -8(%rbp)
	cmpl	$920, -8(%rbp)
	je	L23
	call	abort
L23:
	movl	-4(%rbp), %eax
	addl	$2, %eax
	addl	%eax, %eax
	subl	$12, %eax
	shrl	%eax
	movl	%eax, -8(%rbp)
	cmpl	$920, -8(%rbp)
	je	L24
	call	abort
L24:
	movl	-4(%rbp), %eax
	sall	$2, %eax
	subl	$2, %eax
	shrl	%eax
	movl	%eax, -8(%rbp)
	cmpl	$1847, -8(%rbp)
	je	L25
	call	abort
L25:
	movl	$0, %edi
	call	exit