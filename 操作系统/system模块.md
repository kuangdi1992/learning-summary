# SYSTEM模块

## 当前内存映像

在setup.s程序执行结束后，系统模块system被移动到物理地址0x0000开始处，而从0x90000开始处则存放了内核将会使用的一些系统基本参数，示意图如下：

![image-20210902203159674](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210902203159674.png)

所以，在system模块中，第一个执行的是head.s程序。

## head.s

head.s程序在被编译生产目标文件后，与内核其他程序一起被链接成system模块，位于system模块的最开始部分。

system模块被放在磁盘上setup模块后开始的扇区中，从磁盘上第6个扇区开始放置。

从这里开始，内核就完全在保护模式下运行了。

## 代码解读

```
_startup_32:          ;// 以下5行设置各个数据段寄存器。指向gdt数据段描述符项
   mov eax,10h
   mov ds,ax
   mov es,ax
   mov fs,ax
   mov gs,ax
   lss esp,_stack_start   ;// 表示_stack_start -> ss:esp，设置系统堆栈。
                     ;// stack_start 定义在kernel/sched.c，69 行。
   call setup_idt    ;// 调用设置中断描述符表子程序。
   call setup_gdt    ;// 调用设置全局描述符表子程序。
   mov eax,10h          ;// reload all the segment registers
   mov ds,ax        ;// after changing gdt. CS was already
   mov es,ax        ;// reloaded in 'setup_gdt'
   mov fs,ax        ;// 因为修改了gdt，所以需要重新装载所有的段寄存器。
   mov gs,ax        ;// CS 代码段寄存器已经在setup_gdt 中重新加载过了。
```