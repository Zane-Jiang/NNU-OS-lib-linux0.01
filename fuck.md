# fuck



 [head.s 1](https://blog.csdn.net/longintchar/article/details/79113612)

### IDTR寄存器

![image-20211216122821831](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216122821831.png)

每个段描述符8字节，总共 IDT值除以8字节即得段的最大长度



###  CR0寄存器

![image-20211216122618964](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216122618964.png)



### [段描述符]([(49条消息) 数据段描述符和代码段描述符（一）——《x86汇编语言：从实模式到保护模式》读书笔记10_车子（chezi）-CSDN博客](https://blog.csdn.net/longintchar/article/details/50489889))



![image-20211216123701922](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216123701922.png)

#### 段选择子

![image-20211216124514321](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216124514321.png)

>TI=0表示描述符在GDT中，TI=1表示描述符在LDT中。描述符索引则表示第几个描述符（从0开始）。
>
>8即二进制的1000，也就是说是GDT表的第1个描述符，即基地址为0的代码段。基地址0+偏移地址0=0，所以jmpi 0,8表示跳转到物理地址0处，这正是内核代码的起始位置，此后内核开始执行了



### 中断门描述符

![image-20211216125146879](C:\Users\86185\AppData\Roaming\Typora\typora-user-images\image-20211216125146879.png)

定义了16位的段选择子和32位的偏移地址，如此，则可跳转到对应中断处理程序的开始位置