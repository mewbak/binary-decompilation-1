	.file	"memset.c"
	.text
	.globl	memset
	.type	memset, @function
memset:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	movq	%rdx, -24(%rbp)
	jmp	.L2
.L3:
	movq	-8(%rbp), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	-12(%rbp), %edx
	movb	%dl, (%rax)
.L2:
	movq	-24(%rbp), %rax
	leaq	-1(%rax), %rdx
	movq	%rdx, -24(%rbp)
	testq	%rax, %rax
	jne	.L3
	movq	-8(%rbp), %rax
	popq	%rbp
	ret
	.size	memset, .-memset
	.comm	inside_main,4,4
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$1, inside_main(%rip)
	call	main_test
	movl	$0, inside_main(%rip)
	movl	$0, %eax
	popq	%rbp
	ret
	.size	main, .-main
	.globl	link_error
	.type	link_error, @function
link_error:
	pushq	%rbp
	movq	%rsp, %rbp
	call	abort
	.size	link_error, .-link_error
	.comm	buffer,32,32
	.globl	argc
	.data
	.align 4
	.type	argc, @object
	.size	argc, 4
argc:
	.long	1
	.text
	.globl	main_test
	.type	main_test, @function
main_test:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	argc(%rip), %eax
	movl	$1, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$2, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$3, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$4, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$5, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$6, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$7, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$8, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$9, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$10, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$11, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$12, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$13, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$14, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$15, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$16, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	movl	argc(%rip), %eax
	movl	$17, %edx
	movl	%eax, %esi
	movl	$buffer, %edi
	call	memset
	popq	%rbp
	ret
	.size	main_test, .-main_test
	.ident	"GCC: (Ubuntu 4.9.4-2ubuntu1) 4.9.4"
	.section	.note.GNU-stack,"",@progbits
