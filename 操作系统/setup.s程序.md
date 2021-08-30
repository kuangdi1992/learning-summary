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

cli表示从这里不允许中断。

## do_move 移动system模块到0x00000处

```
mov es,ax    //es=0x0000 
add    ax,#0x1000
cmp    ax,#0x9000
jz end_move		//当ax = 0x9000时移动结束
mov    ds,ax  //ds=0x9000   
sub    di,di  //di=0,es:di=0x00000 目的地址
sub    si,si  //si=0,ds:si=0x90000 源地址
mov    cx,#0x8000 //移动0x8000字（64KB字节）
rep				//ds:si ---->es:di
movsw           //每次移动2
jmp    do_move
```

这段代码的目的：将处于0x10000开始处的system模块移动到0x00000位置，也就是图中4到5，将从0x10000到0x8ffff的内存数据块(512KB)整块的向内存低处移动了0x10000（64KB）的位置。【疑问：为什么要进行移动呢？】

1、从代码实现来看，每次移动2B，每轮重复0x8000次，0x8000*2=0x10000B=64KB，所以共移动8轮。
2、由此可以理解为什么bootsect.s把自己移动到了0x90000？
system模块放置在0x10000处，当时假设 system 模块最大长度不会超过 0x80000 (512KB)，所以从0x10000到0x8ffff都是预留给system模块的，即其末端不会超过内存地址 0x90000，所以 bootsect.s 会把自己移动到0x90000 开始的地方，并把 setup 加载到它的后面。
3、为什么Load system的时候为什么不一次性放在0x00000处？
因为0x00000处开始放的bios中断向量表。现在bios中断已经不需要了，所以可以覆盖了。

## 进入保护模式

```
mov ax,#0x0001 
lmsw   ax    
jmpi   0,8   
```

在这里开始，寻址方式将不再是实模式，而是保护模式。在实模式下，cs16位，ip16位通过左移4位加上ip的方法，也只有20位，相当于1M的空间，肯定是不够的，现在的内存是4G的，所以不能使用实模式寻址。

从16位切到32位模式来进行工作，也就是切换到保护模式来进行工作，也就是CPU内部对16位模式和32位模式的解释程序不一样。

1、CR0 是系统内的控制寄存器之一。控制寄存器是一些特殊的寄存器，它们可以控制CPU的一些重要特性。0位是保护允许位PE(Protedted Enable)，用于启动保护模式，如果PE位置1，则保护模式启动，如果PE=0，则在实模式下运行。

![image-20210830221541443](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20210830221541443.png)

2、lmsw：置处理器状态字。但是只有操作数的低4位被存入CR0，即只有PE,MP,EM和TS被改写，CR0其他位不受影响。<font color=red>此处把cr0的最后一位设置为1，从实模型进入保护模式。</font>
3、为什么有保护模式？
实模式下的寻址方法只能访问1M（20bit）的内存空间，无法满足需要。后来intel有了32位处理器，寻址空间达到4G，保护模式就是32位机。

4、保护模式下的地址翻译

![保护模式地址翻译](C:\Users\kd\Desktop\保护模式地址翻译.png)

从图中可以看出，在保护模式下，根据cs在GDT表中的查找的值+ip来进行地址翻译的，CS也被称作选择子，里面放的是查表的索引。

4、jmpi 0, 8：ip=0，cs=8，按照保护模式，取到的段基址其实是0x0000，那么这句话就是跳转到地址为0x00000的地方开始执行，也就是system模块的开始部分。

由于jmpi 0,8会到GDT表中查找值，所以GDT表中必须有内容可以让查找，所以setup还有下面的代码，填写GDT表的表项：

```
gdt://表项
   .word  0,0,0,0       ! dummy //0 64位

   .word  0x07FF    ! 8Mb - limit=2047 //8(2048*4096=8Mb)
   .word  0x0000    ! base address=0
   .word  0x9A00    ! code read/exec
   .word  0x00C0    ! granularity=4096, 386

   .word  0x07FF    ! 8Mb - limit=2047 (2048*4096=8Mb)
   .word  0x0000    ! base address=0
   .word  0x9200    ! data read/write
   .word  0x00C0    ! granularity=4096, 386

idt_48:
   .word  0        ! idt limit=0
   .word  0,0          ! idt base=0L

gdt_48:
   .word  0x800     ! gdt limit=2048, 256 GDT entries
   .word  512+gdt,0x9    ! gdt base = 0X9xxxx
```

### gdt中的8

![保护模式地址翻译](C:\Users\kd\Desktop\保护模式地址翻译.png)

8对应的表项为：

   .word  0x07FF 
   .word  0x0000 
   .word  0x9A00 
   .word  0x00C0  

对应的GDT表项为：

 ![GDT表项](C:\Users\kd\Desktop\GDT表项.png)

表项中红色的对应的是段基址，那么8对应的段基址为0x00000000，加上ip=0x0，则CS：ip为0x00000.