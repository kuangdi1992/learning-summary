# setup.s

## 基本过程

​	setup.s是一个操作系统加载程序，主要利用RPM BIOS中断读取机器系统数据，并将数据保持在0x90000开始的位置（覆盖掉bootsect程序所在的地方），这些参数将被内核中相关程序使用。

​	setup程序将system模块从0x10000-0x8ffff整块向下移动到内存绝对地址0x0000处，然后加载中断描述符表寄存器idtr和全局描述符表寄存器gdtr，以此来进入32位保护模式，并跳转到位于system模块最前面部分的head.s程序继续执行。

![image-20210817222121681](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210817222121681.png)

