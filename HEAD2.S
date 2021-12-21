SCRN_SEL	= 0x18
TSS0_SEL	= 0x20
LDT0_SEL	= 0x28
TSS1_SEL	= 0X30
LDT1_SEL	= 0x38
TSS2_SEL    = 0x40
LDT2_SEL    = 0x48
TSS3_SEL    = 0X50
LDT3_SEL    = 0x58
.text
startup_32:
	movl $0x10,%eax
	mov %ax,%ds
	lss init_stack,%esp
	call setup_idt
	call setup_gdt
	movl $0x10,%eax	# reload all the segment registers
	mov %ax,%ds		# after changing gdt. 
	mov %ax,%es
	mov %ax,%fs
	mov %ax,%gs
	lss init_stack,%esp

# setup up timer 8253 chip.
	movb $0x36, %al
	movl $0x43, %edx
	outb %al, %dx
	movl $11930, %eax        # timer frequency 100 HZ 10ms来一个中断
	movl $0x40, %edx
	outb %al, %dx
	movb %ah, %al
	outb %al, %dx

# setup timer & system call interrupt descriptors.安装中断门和陷阱门
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

# unmask the timer interrupt.
#	movl $0x21, %edx
#	inb %dx, %al
#	andb $0xfe, %al
#	outb %al, %dx

# Move to user mode (task 0)开始执行任务0
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
setup_gdt:
	lgdt lgdt_opcode		
	ret
setup_idt:
	lea ignore_int,%edx			//将ignore_int的偏移地址存入edx寄存器
	movl $0x00080000,%eax		//将选择符$0x0008置入eax的高16位
	movw %dx,%ax		/* selector = 0x0008 = cs */	//偏移值的低16位置入eax的低16位  eax-->门描述符低4字节
	movw $0x8E00,%dx	/* interrupt gate - dpl=0, present *///edx-->门描述符高4字节
	lea idt,%edi		//idt中断描述符表地址放入edi
	mov $256,%ecx		//256项
rp_sidt:
	movl %eax,(%edi)	//哑中断门描述符存入表中
	movl %edx,4(%edi)	//+4先存低再存高
	addl $8,%edi		//自增，指向表中下一项
	dec %ecx
	jne rp_sidt
	lidt lidt_opcode	//加载中断描述符表寄存器值
	ret

# -----------------------------------
/*
把ebx存入scr_loc处，更新显示位置
位置由scr_loc处存储的4字节的值指定（实际上取值0~1999），打印后更新位置(计数加1)
*/
write_char:			
	push %gs
	pushl %ebx
	
	mov $SCRN_SEL, %ebx //#SCRN_SEL是显存段的选择子
	mov %bx, %gs		//#gs指向显存段
	movl scr_loc, %ebx	//#scr_loc处存放的是显示位置
	shl $1, %ebx		// #ebx*2，得到偏移，因为一个字符用2个字节来描述
	movb %al, %gs:(%ebx)//#al中是字符的ASCII码，属性用默认的
	shr $1, %ebx		//#还原ebx
	incl %ebx			//#ebx自增1，算出下一个位置
	cmpl $2000, %ebx
	jb 1f				//#若 ebx > 2000 则跳转到1
//	movl $0, %ebx		// #说明ebx==2000,因为位置只有0~1999，所以把ebx置为0
	mov $0x18,%ax
	mov %ax,%ds
	mov %ax,%es
	mov $0x160,%esi
	mov $0x0,%edi
	mov $1920,%cx	
	cld 
	rep 
	movsw
	
	mov $80,%cx
	cld
	rep 
	stosw 
	movl $1920,%ebx

1:  movl %ebx, scr_loc //把ebx存入scr_loc处，更新显示位置
    popl %ebx
    pop %gs
    ret




/***********************************************/
/* This is the default interrupt "handler" :-)哑中断 */
.align 2
ignore_int:
	push %ds
	pushl %eax
	movl $0x10, %eax		
	mov %ax, %ds			//ds指向gdt表中的数据段
	movl $67, %eax            /* print 'C' */
	call write_char			
	popl %eax
	pop %ds
	iret

/* Timer interrupt handler 中断门实现*/ 
.align 2
timer_interrupt:
	push %ds
	pushl %eax
	movl $0x10, %eax
	mov %ax, %ds
	movb $0x20, %al
	outb %al, $0x20
	movl $0, %eax		//此处貌似从1改成了0，下面对应的有一段放在1：里
	cmpl %eax, current
	je 1f
	# 增加部分
	inc %eax
	cmpl %eax, current
	je 2f
	inc %eax
    cmpl %eax, current
	je 3f
    inc %eax
    cmpl %eax, current
    je 4f
1:
    movl $1, current
    ljmp $TSS1_SEL, $0
    jmp 5f
2:
    movl $2, current
    ljmp $TSS2_SEL, $0
    jmp 5f
3:
    movl $3, current
    ljmp $TSS3_SEL, $0
    jmp 5f
4:
    movl $0, current
    ljmp $TSS0_SEL, $0
5:
    popl %eax
    pop %ds
    iret

/* system call handler 陷阱门实现，把AL代表的字符打印到屏幕上*/
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

.align 2
lidt_opcode:			//加载idt寄存器
	.word 256*8-1		# idt contains 256 entries
	.long idt			# This will be rewrite by code. 
lgdt_opcode:
	.word (end_gdt-gdt)-1	# so does gdt 
	.long gdt		# This will be rewrite by code.

	.align 3				# 不仅仅是从这里改变的，伪代码有什么意义？
idt:	.fill 256,8,0		# idt is uninitialized  用0填充256*8个字节

gdt:.quad 0x0000000000000000	/* NULL descriptor */
	.quad 0x00c09a00000007ff	/* 8Mb 0x08, base = 0x00000 */
	.quad 0x00c09200000007ff	/* 8Mb 0x10 */
	.quad 0x00c0920b80000002	/* screen 0x18 - for display */

	.word 0x0068, tss0, 0xe900, 0x0	# TSS0 descr 0x20
	.word 0x0040, ldt0, 0xe200, 0x0	# LDT0 descr 0x28
	.word 0x0068, tss1, 0xe900, 0x0	# TSS1 descr 0x30
	.word 0x0040, ldt1, 0xe200, 0x0	# LDT1 descr 0x38
	# 增加
	.word 0x0068, tss2, 0xe900, 0x0    # TSS2 descr 0x40
    .word 0x0040, ldt2, 0xe200, 0x0    # LDT2 descr 0x48
    .word 0x0068, tss3, 0xe900, 0x0    # TSS3 descr 0x50
    .word 0x0040, ldt3, 0xe200, 0x0    # LDT3 descr 0x58
end_gdt:
	.fill 128,4,0
init_stack:                          # Will be used as user stack for task0.
	.long init_stack
	.word 0x10

/*************************************/
.align 3
ldt0:.quad 0x0000000000000000
	.quad 0x00c0fa00000003ff	# 0x0f, base = 0x00000
	.quad 0x00c0f200000003ff	# 0x17

tss0:.long 0 			/* back link */
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
.align 3
ldt1:.quad 0x0000000000000000
	.quad 0x00c0fa00000003ff	# 0x0f, base = 0x00000
	.quad 0x00c0f200000003ff	# 0x17

tss1:.long 0 			/* back link */
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
.align 3
ldt2:    .quad 0x0000000000000000
    .quad 0x00c0fa00000003ff    # 0x0f, base = 0x00000
    .quad 0x00c0f200000003ff    # 0x17

tss2:    .long 0             /* back link */
    .long krn_stk2, 0x10        /* esp0, ss0 */
    .long 0, 0, 0, 0, 0        /* esp1, ss1, esp2, ss2, cr3 */
    .long task2, 0x200        /* eip, eflags */
    .long 0, 0, 0, 0        /* eax, ecx, edx, ebx */
    .long usr_stk2, 0, 0, 0        /* esp, ebp, esi, edi */
    .long 0x17,0x0f,0x17,0x17,0x17,0x17 /* es, cs, ss, ds, fs, gs */
    .long LDT2_SEL, 0x8000000    /* ldt, trace bitmap */

    .fill 128,4,0
krn_stk2:
/************************************/
.align 3
ldt3:    .quad 0x0000000000000000
    .quad 0x00c0fa00000003ff    # 0x0f, base = 0x00000
    .quad 0x00c0f200000003ff    # 0x17

tss3:    .long 0             /* back link */
    .long krn_stk3, 0x10        /* esp0, ss0 */
    .long 0, 0, 0, 0, 0        /* esp1, ss1, esp2, ss2, cr3 */
    .long task3, 0x200        /* eip, eflags */
    .long 0, 0, 0, 0        /* eax, ecx, edx, ebx */
    .long usr_stk3, 0, 0, 0        /* esp, ebp, esi, edi */
    .long 0x17,0x0f,0x17,0x17,0x17,0x17 /* es, cs, ss, ds, fs, gs */
    .long LDT3_SEL, 0x8000000    /* ldt, trace bitmap */

    .fill 128,4,0
krn_stk3:
/************************************/
task0:
	movl $0x17, %eax
	movw %ax, %ds
	movl $65, %al              /* print 'A' */
	int $0x80
	movl $0xfff, %ecx
1:	loop 1b
	jmp task0 

task1:
	movl $0x17, %eax
	movw %ax, %ds
	movl $66, %al              /* print 'B' */
	int $0x80
	movl $0xfff, %ecx
1:	loop 1b
	jmp task1
# 增加
task2:
    movl $0x17, %eax
    movw %ax, %ds
    movl $68, %eax             /* print 'D' */
	movb $2,%ah
    int $0x80
    movl $0xfff, %ecx
1:    loop 1b
    jmp task2

task3:
    movl $0x17, %eax
    movw %ax, %ds
    movl $69, %eax             /* print 'E' */
	movb $4,%ah
    int $0x80
    movl $0xfff, %ecx
1:    loop 1b
    jmp task3


	.fill 128,4,0 
usr_stk1:
    .fill 128,4,0 
usr_stk2:
    .fill 128,4,0 
usr_stk3:
