# fuck

[head.s 1](https://blog.csdn.net/longintchar/article/details/79113612)

### IDTR 寄存器

![image-20211216122821831](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216122821831.png)

每个段描述符 8 字节，总共 IDT 值除以 8 字节即得段的最大长度

### CR0 寄存器

![image-20211216122618964](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216122618964.png)

### [段描述符]([(49 条消息) 数据段描述符和代码段描述符（一）——《x86 汇编语言：从实模式到保护模式》读书笔记 10\_车子（chezi）-CSDN 博客](https://blog.csdn.net/longintchar/article/details/50489889))

![image-20211216123701922](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216123701922.png)

#### 段选择子

![image-20211216124514321](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216124514321.png)

> TI=0 表示描述符在 GDT 中，TI=1 表示描述符在 LDT 中。描述符索引则表示第几个描述符（从 0 开始）。
>
> 8 即二进制的 1000，也就是说是 GDT 表的第 1 个描述符，即基地址为 0 的代码段。基地址 0+偏移地址 0=0，所以 jmpi 0,8 表示跳转到物理地址 0 处，这正是内核代码的起始位置，此后内核开始执行了

### 中断门描述符

![image-20211216125146879](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216125146879.png)

定义了 16 位的段选择子和 32 位的偏移地址，如此，则可跳转到对应中断处理程序的开始位置

```.roll_screen:
         cmp bx,2000                     ;光标超出屏幕？滚屏
         jl .set_cursor

         mov ax,0xb800
         mov ds,ax
         mov es,ax
         cld
         mov si,0xa0
         mov di,0x00
         mov cx,1920
         rep movsw
         mov bx,3840                     ;清除屏幕最底一行
         mov cx,80
 .cls:
         mov word[es:bx],0x0720
         add bx,2
         loop .cls

         mov bx,1920
```
