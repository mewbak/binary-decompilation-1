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
	.comm	entry,4,1
.globl _start
_start:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	$entry, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	set
	movq	-8(%rbp), %rax
	movzbl	(%rax), %eax
	cmpb	$1, %al
	jne	L10
	movq	-8(%rbp), %rax
	movzbl	1(%rax), %eax
	testb	%al, %al
	jne	L10
	movl	$0, %edi
	call	exit
L10:
	call	abort
set:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movb	$1, (%rax)
	movq	-8(%rbp), %rax
	movb	$0, 1(%rax)
	nop
	popq	%rbp
	ret