#  head.s contains the 32-bit startup code.
#  Two L3 task multitasking. The code of tasks are in kernel area, 
#  just like the Linux. The kernel code is located at 0x10000. 
SCRN_SEL	= 0x18
TSS0_SEL	= 0x20
LDT0_SEL	= 0x28
TSS1_SEL	= 0X30
LDT1_SEL	= 0x38

TSS2_SEL	= 0X40
LDT2_SEL	= 0x48

TSS3_SEL	= 0X50
LDT3_SEL	= 0x58



.code32  # add to sovle some errors
.global startup_32
.text
startup_32:
	movl $0x10,%eax   # 0x10是数据段（在boot.s文件中定义）的选择子
	mov %ax,%ds
#	mov %ax,%es
	lss init_stack,%esp
 #前4个字节是偏移，后2个字节是段选择子，这句代码表示用偏移加载esp，用数据段选择子0x10加载ss.

# setup base fields of descriptors.
	call setup_idt

	call setup_gdt


/*gdt 表改变，需要重新加载所有的段寄存器*/
	movl $0x10,%eax		# reload all the segment registers
	mov %ax,%ds		# after changing gdt. 
	mov %ax,%es
	mov %ax,%fs
	mov %ax,%gs
	lss init_stack,%esp 
	

# setup up timer 8253 chip.
	movb $0x36, %al
	movl $0x43, %edx
	outb %al, %dx
	#movl $11930, %eax        # timer frequency 100 HZ
    movl $0xFFFF,%eax  #down timer slow
	movl $0x40, %edx
	outb %al, %dx
	movb %ah, %al
	outb %al, %dx


# setup timer & system call interrupt descriptors.
	movl $0x00080000, %eax	
	movw $timer_interrupt, %ax
	movw $0x8E00, %dx
	movl $0x08, %ecx              # The PC default timer int.
	lea idt(,%ecx,8), %esi
	movl %eax,(%esi) 
	movl %edx,4(%esi)

	movw $system_interrupt, %ax
	movw $0xef00, %dx
	movl $0x80, %ecx
	lea idt(,%ecx,8), %esi
	movl %eax,(%esi) 
	movl %edx,4(%esi)

#setup up keyboard call interrupt descriptor
	movl $0x00080000, %eax	
	movw $keyboard_interrupt, %ax
	movw $0x8f00, %dx  #中断门
	movl $0x09, %ecx              # The PC default keyboard int.
	lea idt(,%ecx,8), %esi
	movl %eax,(%esi) 
	movl %edx,4(%esi)


# unmask the timer interrupt.
	#movl $0x21, %edx
	#inb %dx, %al
	#andb $0xfe, %al
	#outb %al, %dx

# Move to user mode (task 0)
	pushfl
	andl $0xffffbfff, (%esp)
	popfl
	movl $TSS0_SEL, %eax
	ltr %ax
	movl $LDT0_SEL, %eax
	lldt %ax 
	movl $0, current
	sti
	pushl $0x17
	pushl $init_stack
	pushfl
	pushl $0x0f
	pushl $task0
	iret

/****************************************/
setup_gdt:
	lgdt lgdt_opcode
	ret

setup_idt:
#组装中断描述门 
	lea ignore_int,%edx #偏移值高16位组装
	movl $0x00080000,%eax#段描述符组装
	movw %dx,%ax		/* selector = 0x0008 = cs */ #偏移值低16位组装
	movw $0x8E00,%dx	/* interrupt gate - dpl=0, present */#edx低16位组装
	

	lea idt,%edi
	/*全0的256项中断描述符表*/
	mov $256,%ecx
rp_sidt:
	movl %eax,(%edi)
	/*movl %eax,(%edi)表示把eax的值传送到地址edi处，即用eax填充IDT表的0~3字节；*/
	movl %edx,4(%edi)
	/*movl %edx,4(%edi)表示把edx的值传送到地址[edi+4]处，即用edx填充IDT表的4~7字节；*/
	addl $8,%edi
	dec %ecx
	/*循环填装256个中断门*/
	jne rp_sidt
	lidt lidt_opcode #加载idt寄存器
	ret

# -----------------------------------
write_char:
	cli
	push %gs
	pushl %ebx
    push %es
	pushl %esi
	pushl %edi
    mov $SCRN_SEL,%ebx
	mov %bx,%gs
    mov %bx,%es
	movl scr_loc, %ebx
	shl $1, %ebx
    movw %ax,%gs:(%ebx)
	shr $1, %ebx
	incl %ebx
	cmpl $2000, %ebx
	jb 1f
roll_screen:
	movl $0x00a0,%esi
	movl $0x0000,%edi 
	
	mov $1920,%cx
    push %ds
    movw  %gs,%bx
	mov %bx,%ds
    rep movsw
	pop %ds
    movl $3840,%ebx
	movw $80,%cx
cls:
	movw $0x0720,%gs:(%ebx)
	add $2,%ebx
	loop cls
	movl $1920, %ebx

1:	movl %ebx, scr_loc	
pushl %ecx
	movl $0xff, %ecx
aa:	loop aa

popl %ecx
	popl %edi
	popl %esi
	pop %es
	
	popl %ebx
	pop %gs
	sti
    
	ret

/***********************************************/
/* This is the default interrupt "handler" :-) */
.align 2
ignore_int:
	/*默认中断处理程序*/
	push %ds
	pushl %eax
	movl $0x10, %eax
	mov %ax, %ds
	movl $67, %eax            /* print 'C' */
	call write_char
	popl %eax
	pop %ds
	iret

/* Timer interrupt handler */ 
.align 2
timer_interrupt:
cli
	push %ds
	pushl %ebx
	pushl %eax
	movl $0x10, %eax
	mov %ax, %ds
	
	movb $0x20, %al
	outb %al, $0x20



	movb $0x00,%al
	cmp %al,key
jne key_schedule #key not equal zero,
timer_schedule:
	movl $0, %ebx
	cmpl %ebx, current
	jne 1f
	movl $1,%ebx
	movl %ebx, current
	ljmp $TSS1_SEL, $0
	jmp sche_ret
1:	movl $1, %ebx
	cmpl %ebx, current
	jne 2f
	movl $2,%ebx
	movl %ebx, current
	ljmp $TSS2_SEL, $0
	jmp sche_ret
2:	movl $2, %ebx
	cmpl %ebx, current
	jne 3f
	movl $3,%ebx
	movl %ebx, current
	ljmp $TSS3_SEL, $0
	jmp sche_ret
3:	movl $0,%ebx
	movl %ebx, current
	ljmp $TSS0_SEL, $0
	jmp sche_ret


key_schedule:
	

key_eq_a:	
	movb  0x1E,%al
	cmpb %al,key
	jne key_eq_b
	movb $0,key
	movl $0,%eax
	cmpl %eax,current
	je  sche_ret
	movl $0,current
	ljmp $TSS0_SEL,$0
	jmp sche_ret
key_eq_b:
	movb  0x30,%al
	cmpb %al,key
	jne key_eq_c
	movb $0,key
	movl $1,%eax
	cmpl %eax,current
	je  sche_ret
	movl $1,current
	ljmp $TSS1_SEL,$0
	jmp sche_ret
key_eq_c:
	movb  0x2E,%al
	cmpb %al,key
	jne key_eq_d
	movb $0,key
	movl $2,%eax
	cmpl %eax,current
	je  sche_ret
	movl $2,current
	ljmp $TSS2_SEL,$0
	jmp sche_ret
key_eq_d:
	movb  0x20,%al
	cmpb %al,key
	jne key_eq_other
	movb $0,key
	movl $3,%eax
	cmpl %eax,current
	je  sche_ret
	movl $3,current
	ljmp $TSS3_SEL,$0
	jmp sche_ret
key_eq_other:
	movb $0,key
	jmp timer_schedule
	
sche_ret: 	
	sti
	popl %eax
	popl %ebx
	pop %ds
	iret

/*keyboard_interrupt  call hander*/
.align 2
keyboard_interrupt:
	push %ds
	pushl %edx
	pushl %ecx
	pushl %ebx
	pushl %eax

	movl $0x10, %eax
	mov %ax, %ds
	inb $0x60,%al
	movb  $0x47,%ah
	call write_char
	movb $0x20, %al
	outb %al, $0x20
	popl %eax
	popl %ebx
	popl %ecx
	popl %edx
	pop %ds
	iret

/* system call handler */
.align 2
system_interrupt:
	push %ds
	pushl %edx
	pushl %ecx
	pushl %ebx
	pushl %eax
	movl $0x10, %edx
	mov %dx, %ds
	call write_char
	popl %eax
	popl %ebx
	popl %ecx
	popl %edx
	pop %ds
	iret

/*********************************************/
current:.long 0
scr_loc:.long 0
key:.byte 0

.align 2
lidt_opcode:
	.word 256*8-1		# idt contains 256 entries 限长
	.long idt		# This will be rewrite by code.  起始位置
lgdt_opcode:
	.word (end_gdt-gdt)-1	# so does gdt 
	.long gdt		# This will be rewrite by code.

	.align 8
idt:	.fill 256,8,0		# idt is uninitialized
/*表示产生8*256字节，全部用0填充。IDT最多可有256个描述符，每个描述符占8个字节。*/


#定义了8个段
gdt:	.quad 0x0000000000000000	/* NULL descriptor */
	.quad 0x00c09a00000007ff	/* 8Mb 0x08, base = 0x00000 */
	.quad 0x00c09200000007ff	/* 8Mb 0x10 */
	.quad 0x00c0920b80000002	/* screen 0x18 - for display */

	.word 0x0068, tss0, 0xe900, 0x0	# TSS0 descr 0x20
	.word 0x0040, ldt0, 0xe200, 0x0	# LDT0 descr 0x28
	.word 0x0068, tss1, 0xe900, 0x0	# TSS1 descr 0x30
	.word 0x0040, ldt1, 0xe200, 0x0	# LDT1 descr 0x38
	.word 0x0068, tss2, 0xe900, 0x0	# TSS2 descr 0x40
	.word 0x0040, ldt2, 0xe200, 0x0	# LDT2 descr 0x48
	.word 0x0068, tss3, 0xe900, 0x0	# TSS3 descr 0x50
	.word 0x0040, ldt3, 0xe200, 0x0	# LDT3 descr 0x58
	
		
end_gdt:
	.fill 128,4,0
init_stack:                          # Will be used as user stack for task0.
	.long init_stack
	.word 0x10

/*************************************/
.align 8
ldt0:	.quad 0x0000000000000000
	.quad 0x00c0fa00000003ff	# 0x0f, base = 0x00000
	.quad 0x00c0f200000003ff	# 0x17

tss0:	.long 0 			/* back link */
	.long krn_stk0, 0x10		/* esp0, ss0 */
	.long 0, 0, 0, 0, 0		/* esp1, ss1, esp2, ss2, cr3 */
	.long 0, 0, 0, 0, 0		/* eip, eflags, eax, ecx, edx */
	.long 0, 0, 0, 0, 0		/* ebx esp, ebp, esi, edi */
	.long 0, 0, 0, 0, 0, 0 		/* es, cs, ss, ds, fs, gs */
	.long LDT0_SEL, 0x8000000	/* ldt, trace bitmap */

	.fill 128,4,0
krn_stk0:
#	.long 0

/************************************/
.align 8
ldt1:	.quad 0x0000000000000000
	.quad 0x00c0fa00000003ff	# 0x0f, base = 0x00000
	.quad 0x00c0f200000003ff	# 0x17

tss1:	.long 0 			/* back link */
	.long krn_stk1, 0x10		/* esp0, ss0 */
	.long 0, 0, 0, 0, 0		/* esp1, ss1, esp2, ss2, cr3 */
	.long task1, 0x200		/* eip, eflags */
	.long 0, 0, 0, 0		/* eax, ecx, edx, ebx */
	.long usr_stk1, 0, 0, 0		/* esp, ebp, esi, edi */
	.long 0x17,0x0f,0x17,0x17,0x17,0x17 /* es, cs, ss, ds, fs, gs */
	.long LDT1_SEL, 0x8000000	/* ldt, trace bitmap */

	.fill 128,4,0
krn_stk1:
/************************************/
.align 8
ldt2:	.quad 0x0000000000000000
	.quad 0x00c0fa00000003ff	# 0x0f, base = 0x00000
	.quad 0x00c0f200000003ff	# 0x17

tss2:	.long 0 			/* back link */
	.long krn_stk2, 0x10		/* esp0, ss0 */
	.long 0, 0, 0, 0, 0		/* esp1, ss1, esp2, ss2, cr3 */
	.long task2, 0x200		/* eip, eflags */
	.long 0, 0, 0, 0		/* eax, ecx, edx, ebx */
	.long usr_stk2, 0, 0, 0		/* esp, ebp, esi, edi */
	.long 0x17,0x0f,0x17,0x17,0x17,0x17 /* es, cs, ss, ds, fs, gs */
	.long LDT2_SEL, 0x8000000	/* ldt, trace bitmap */

	.fill 128,4,0
krn_stk2:
/*************************************/
.align 8
ldt3:	.quad 0x0000000000000000
	.quad 0x00c0fa00000003ff	# 0x0f, base = 0x00000
	.quad 0x00c0f200000003ff	# 0x17

tss3:	.long 0 			/* back link */
	.long krn_stk3, 0x10		/* esp0, ss0 */
	.long 0, 0, 0, 0, 0		/* esp1, ss1, esp2, ss2, cr3 */
	.long task3, 0x200		/* eip, eflags */
	.long 0, 0, 0, 0		/* eax, ecx, edx, ebx */
	.long usr_stk3, 0, 0, 0		/* esp, ebp, esi, edi */
	.long 0x17,0x0f,0x17,0x17,0x17,0x17 /* es, cs, ss, ds, fs, gs */
	.long LDT3_SEL, 0x8000000	/* ldt, trace bitmap */

	.fill 128,4,0
krn_stk3:
/************************************/
task0:
	movl $0x17, %eax
	movw %ax, %ds
	movb $65, %al              /* print 'A' */
   	movb $2,%ah #set color
    	int $0x80
	movl $0xffff, %ecx
1:	loop 1b
	jmp task0 
	
task1:
	
	movl $0x17, %eax
	movw %ax, %ds
	movb $66, %al              /* print 'B' */
	movb $5,%ah  #set color
    	int $0x80
	movl $0xffff, %ecx
1:	loop 1b
	jmp task1
	
	.fill 128,4,0 
usr_stk1:

task2:
	movl $0x17,%eax
	movw %ax, %ds
	movb $67, %al              /* print 'C' */
	movb $6,%ah  #set color
    	int $0x80
	movl $0xffff, %ecx
1:	loop 1b
	jmp task2
	
	.fill 128,4,0 
usr_stk2:


task3:
	
	movl $0x17,%eax
	movw %ax, %ds
	movb $68, %al              /* print 'D' */
	movb $7,%ah  #set color
    	int $0x80
	movl $0xffff, %ecx
1:	loop 1b
	jmp task3
	
	.fill 128,4,0 
usr_stk3:



