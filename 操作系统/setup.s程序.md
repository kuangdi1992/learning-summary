# setup.s

## 基本过程

​	setup.s是一个操作系统加载程序，主要利用RPM BIOS中断读取机器系统数据，并将数据保持在0x90000开始的位置（覆盖掉bootsect程序所在的地方），这些参数将被内核中相关程序使用。

​	setup程序将system模块从0x10000-0x8ffff整块向下移动到内存绝对地址0x0000处，然后加载中断描述符表寄存器idtr和全局描述符表寄存器gdtr，以此来进入32位保护模式，并跳转到位于system模块最前面部分的head.s程序继续执行。

​	setup将完成OS启动前的设置。

![image-20210817222121681](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210817222121681.png)

## start

```
start:

   mov    ax,#INITSEG    
   mov    ds,ax
```

将ds设置成INITSEG(9000)，在setup程序中需要重新设置ds。

```
mov	ah,#0x03	
xor	bh,bh
int	0x10
mov	[0],dx 间接寻址，数据段DS=0x9000，偏移是0，对应内存的绝对地址是0x9000左移4位+0---->0x90000.也就是把dx寄存器的值保存到内存地址0x90000处。
```

这4句代码使用了BIOS 10号中断，截取屏幕当前光标位置，并保存在内存0x90000处。控制台初始化程序会到此处取值。

```
mov ah,#0x88
int    0x15
mov    [2],ax
```

这段代码表示取扩展内存的大小值(KB)，也就表示刚开机的时候需要将操作系统内存大小保存起来，那么这是为什么？

答：操作系统是管理硬件的，当然也会管理内存，要想管理内存，就需要知道内存的大小。机器之间的内存大小也不相同。通过setup的初始化让操作系统知道了内存、硬件等的信息。

利用BIOS 15号中断功能号ah = 0x88取系统所含扩展内存大小并保存到内存0x90002处（和上面0x90000来历一样）。

```
mov ah,#0x0f
int    0x10
mov    [4],bx    
mov    [6],ax
```

这段代码用于获取显卡当前显示模式。

后面的代码会分别获取显示方式并取参数、获取第一个硬盘的信息等。

```
cli        
mov    ax,#0x0000
cld
```

cli表示从这里不允许中断，然后利用mov    ax,#0x0000将处于0x10000开始处的system模块移动到0x00000位置，也就是图中4到5，将从0x10000到0x8ffff的内存数据块(512KB)整块的向内存低处移动了0x10000（64KB）的位置。【疑问：为什么要进行移动呢？】

## do_move

```
mov es,ax    es=0x0000 
add    ax,#0x1000
cmp    ax,#0x9000
jz end_move
mov    ds,ax  ds=0x9000   
sub    di,di  di=0,es:di=0x00000
sub    si,si  si=0,ds:si=0x90000
mov    cx,#0x8000 移动0x8000字（64KB字节）
rep
movsw
jmp    do_move
```

