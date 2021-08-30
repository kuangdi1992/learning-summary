# 操作系统启动过程

## 计算机执行的第一条指令

问题：打开电源后，计算机执行的第一句指令是什么？

对于x86的PC机，刚上电时，有一部分是固化的，基本过程如下：

1. x86 PC刚开机时CPU处于实模式
2. 开机时，CS=0xFFFF；IP=0x0000
3. 寻址0xFFFF0（ROM BIOS映射区---固化在硬件上）
4. 检查RAM、键盘、显示器、软硬磁盘
5. 将磁盘0磁道0扇区（引导扇区）读入0x7c00处，也就是将操作系统引导扇区从磁盘中读入到0x7c00处
6. 设置CS=0x07c0，IP=0x0000，通过寻址，后面将从引导扇区开始执行，也就是从0x7c00处开始执行。

实模式下的寻址CS：IP----->CS左移4位+IP，例如CS=0xFFFF；IP=0x0000则CS左移4位为0xFFFF0，再加上IP，为0xFFFF0，也就是ROM上的BIOS映射区。

![image-20210816221601955](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210816221601955.png)

## 0x7c00处存放的代码

0x7c00处存放的代码是从引导扇区读入的512个字节。

- 引导扇区是启动设备的第一个扇区
- 硬盘的第一个扇区上存放着开启后执行的第一段可控制的程序。

Linux最前面的部分是由8086汇编语言编写的bootsect.s，它将由BIOS读入到内存绝对地址0x7c00(31KB)处，当它被执行的时候会将自己移动到内存绝对地址0x90000(576KB)处，并把启动设备中后2KB字节代码(boot/setup.s)读入到内存0x90200处，而内核的其他部分system模块被读入到从内存地址0x10000(64KB)开始处，因此从机器加点开始顺序执行如图所示：

![image-20210817222121681](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210817222121681.png)

## 引导扇区代码:bootsect.s

引导扇区中的代码是汇编代码。C程序要经过编译，经过编译后会产生不可控制的变化，而汇编中的每一条指令最后都变成了真正的机器指令，可以对它进行完整的控制。

开始设置相关的段地址，如下：

```
BOOTSEG  = 07c0h;// bootsect的原始地址（是段地址，以下同）
INITSEG  = 9000h;// 将bootsect移到这里
SETUPSEG = 9020h;// setup程序从这里开始
SYSSEG   = 1000h;// system模块加载到10000(64kB)处.
```

### start

```
entry _start  告知链接程序，程序从start标号开始执行
_start:
	mov	ax,#BOOTSEG
	mov	ds,ax         //这两句将ds段寄存器置为0x07c0
	mov	ax,#INITSEG
	mov	es,ax         //这两句将es段寄存器置为0x9000
	mov	cx,#256       //设置移动计数值 = 256
	sub	si,si         //源地址为ds:si = 0x07c0:0x0000
	sub	di,di         //目的地址es:di = 0x9000:0x0000
	rep               //重复执行并递减cx的值，直到cx=0
	movw              //movs指令，从内存[si]处移动cx个字到[di]处。
	jmpi	go,INITSEG  //段间跳转，标号go是段内偏移地址
```

jmpi指令之前的几条指令，将0x07c0:0x0000处的256个字移动到0x9000:0x0000处，也就是上面图中从1移动到2.

```
jmpi go，INITSEG ——> go赋值给ip，INITSEG赋值给cs，通过cs:ip将指令跳转到go处执行
```

### go

```
go: mov    ax,cs
   mov    ds,ax
   mov    es,ax
! put stack at 0x9ff00.
   mov    ss,ax
   mov    sp,#0xFF00    ! arbitrary value >>512
```

在这段代码中将es寄存器的值置为cs寄存器的值即INITSEG，0x9000，即现在es=0x9000。

### load_setup

```
load_setup:
   mov    dx,#0x0000    ! drive 0, head 0
   mov    cx,#0x0002    ! sector 2, track 0
   mov    bx,#0x0200    ! address = 512, in INITSEG
   mov    ax,#0x0200+SETUPLEN    ! service 2, nr of sectors
   int    0x13         ! read it
   jnc    ok_load_setup     ! ok - continue
   mov    dx,#0x0000
   mov    ax,#0x0000    ! reset the diskette
   int    0x13
   j  load_setup
```

【小知识】<font color=red>在寄存器中，ah是ax的高8位，al是ax的低8位。</font>

从上述代码中，ah是0x02（读磁盘），al=扇区数量(SETUPLEN=4),ch=0x00(柱面号)，cl=0x02(开始扇区 2)，dh=0x00(磁盘头)，dl=0x00(驱动器号)，而es:bx=内存地址。

那么int 0x13中断之前的代码表示从2号扇区开始读取4个扇区，也就正好是setup所在的扇区。

![image-20210822205008401](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210822205008401.png)

es:bx=0x9000:0x0200，所以内存地址为0x90200.

int 0x13是BIOS中断—读取磁盘的中断，关于中断的内容在下一个章节中介绍。

【总结】上述代码，利用BIOS中断INT 0x13将setup模块从磁盘的第二个扇区开始读到0x90200开始处，共读4个扇区。<font color=red>因此setup模块的开始处是0x90200</font>

### ok_load_setup

```
ok_load_setup:

! Get disk drive parameters, specifically nr of sectors/track

   mov    dl,#0x00
   mov    ax,#0x0800    ! AH=8 is get drive parameters
   int    0x13
   mov    ch,#0x00
   seg cs
   mov    sectors,cx
   mov    ax,#INITSEG
   mov    es,ax   ---这两句将es的值重新设置为0x9000.

! Print some inane message

   mov    ah,#0x03      ! read cursor pos
   xor    bh,bh
   int    0x10       读光标
   
   mov    cx,#24       显示字符串的字符数
   mov    bx,#0x0007    ! page 0, attribute 7 (normal) bh显示页面号，bl=字符属性
   mov    bp,#msg1       es:bp寄存器对指向要显示的字符串
   mov    ax,#0x1301    ! write string, move cursor
   int    0x10        显示字符

! ok, we've written the message, now
! we want to load the system (at 0x10000)

   mov    ax,#SYSSEG
   mov    es,ax     ! segment of 0x010000
   call   read_it   读入system模块，将system模块加载到0x1000开始处，es为输入参数。
   call   kill_motor
```

【INT 0x10】BIOS中断，用来读光标和显示字符到屏幕上，具体用法后续补充。

### msg1

msg1表示屏幕上要显示的字符串。

```
sectors:
   .word 0  //磁道扇区数

msg1:
   .byte 13,10
   .ascii "Loading system ..."
   .byte 13,10,13,10
```

那么，我们要想修改开机时屏幕上显示的字符串，就只需要修改msg1和ok_load_setup中有关代码就可以了，相关实验后续补充。

### read_it

```
read_it:
	mov ax,es
	test ax,#0x0fff
die:	jne die			! es must be at 64kB boundary
	xor bx,bx		! bx is starting address within segment
rp_read:
	mov ax,es
	cmp ax,#ENDSEG		! have we loaded all yet?
	jb ok1_read
	ret
```

### boot_flag

有效引导扇区的标志，仅供BIOS中的程序加载引导扇区时识别使用，必须位于引导扇区的最后两个字节中。

```
boot_flag:
   .word 0xAA55
```

把操作系统读入内存，打出logo，将setup和system读入后将控制权交给setup，从而来执行setup代码。最终跳转指令如下：

```
jmpi    0,SETUPSEG   //cs=SETUPSEG,0x9020,ip=0x0000，所以指令跳转到0x90200处执行，也就是setup开始执行的地址。
```



