# Linux/Makefile文件

## 功能介绍

Makefile是工具程序make运行时的输入数据文件，在含有Makefile的当前目录中输入make命令，就会依据Makefile文件中的设置对源程序或目标代码文件进行编译、链接或进行安装活动。

在使用make工具程序之前，需要编写Makefile信息文件。Makefile文件描述了整个程序包中各程序之间的关系，并针对每个需要更新的文件给出了具体的控制命令。

## 主要作用

这个Makefile文件的主要作用：指示make程序最终使用独立编译连接成的tools目录中的build执行程序将所有内存编译代码连接和合并成一个可运行的内核映像文件image。

1. 对boot中的bootsect.s、setup.s使用8086汇编器进行编译，分别生产各自的执行模块。
2. 对源代码中的其他所有程序使用GNU的编译器gcc进行编译，并链接模块system。
3. 用build工具将三块组合成一个内核映像文件image。（build是tools/build.c源程序编译而成的）

![image-20210902210036035](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210902210036035.png)

## 代码解读

```
AS86    =as86 -0 -a //8086汇编编译器和连接器
LD86   =ld86 -0

AS =as              //GNU汇编编译器和连接器
LD =ld
LDFLAGS    =-m elf_i386 -Ttext 0 -e startup_32 //GNU链接器运行时用到的选相，具体介绍不详细展开。
CC =gcc -mcpu=i386 $(RAMDISK) //GNU C程序编译器
CFLAGS =-Wall -O2 -fomit-frame-pointer //GCC使用的选项。

CPP    =cpp -nostdinc -Iinclude //gcc的预处理器程序。
ROOT_DEV= #FLOPPY //创建image时使用的默认根文件系统所在的设备。

ARCHIVES=kernel/kernel.o mm/mm.o fs/fs.o //kernel目录、mm目录和fs目录产生的目标代码文件。
DRIVERS =kernel/blk_drv/blk_drv.a kernel/chr_drv/chr_drv.a     //块和字符设备库文件 
MATH	=kernel/math/math.a  //数学运算库文件
LIBS	=lib/lib.a     //lib通用库文件

//下面是make的隐式规则，例如.c.s将所有的.c文件编译生成.s汇编程序等，在这里不一一介绍。
.c.s:
	$(CC) $(CFLAGS) \
	-nostdinc -Iinclude -S -o $*.s $<
.s.o:
	$(AS)  -o $*.o $<
.c.o:
	$(CC) $(CFLAGS) \
	-nostdinc -Iinclude -c -o $*.o $<

all:	Image //创建Image文件

Image: boot/bootsect boot/setup tools/system 
tools/build //说明Image文件由boot目录下的bootsect和setup，以及tools目录下的system和build文件组成。
tools/build boot/bootsect boot/setup tools/kernel $(ROOT_DEV) > Image //表示使用tools中的build工具程序将bootsect、setup、system文件以$(ROOT_DEV)为根文件系统设备组装成Image。
	sync //迫使缓冲块数据立即写盘并更新超级块

disk: Image # 表示disk 这个目标要由Image 产生。
dd bs=8192 if=Image of=/dev/PS0 # dd 为UNIX 标准命令：复制一个文件，根据选项
# 进行转换和格式化。bs=表示一次读/写的字节数。
# if=表示输入的文件，of=表示输出到的文件。
# 这里/dev/PS0 是指第一个软盘驱动器(设备文件)。

tools/build: tools/build.c
	$(CC) $(CFLAGS) \
	-o tools/build tools/build.c

boot/head.o: boot/head.s
	gcc -I./include -traditional -c boot/head.s
	mv head.o boot/

tools/system:	boot/head.o init/main.o \
		$(ARCHIVES) $(DRIVERS) $(MATH) $(LIBS)
	$(LD) $(LDFLAGS) boot/head.o init/main.o \
	$(ARCHIVES) \
	$(DRIVERS) \
	$(MATH) \
	$(LIBS) \
	-o tools/system 
	nm tools/system | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aU] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)'| sort > System.map  
#表示tools目录中的system文件由head.o、main.o等元素生成，最后gld将链接映像重定向存放在System.map文件中。

kernel/math/math.a: # 数学协处理函数文件math.a 由下一行上的命令实现。
(cd kernel/math; make) # 进入kernel/math/目录；运行make 工具程序。

kernel/blk_drv/blk_drv.a: # 块设备函数文件blk_drv.a
(cd kernel/blk_drv; make)

kernel/chr_drv/chr_drv.a: # 字符设备函数文件chr_drv.a
(cd kernel/chr_drv; make)

kernel/kernel.o: # 内核目标模块kernel.o
(cd kernel; make)

mm/mm.o: # 内存管理模块mm.o
(cd mm; make)

fs/fs.o: # 文件系统目标模块fs.o
(cd fs; make)

lib/lib.a: # 库函数lib.a
2.8 linux/Makefile 文件
(cd lib; make)

boot/setup: boot/setup.s # 这里开始的三行是使用8086 汇编和连接器
$(AS86) -o boot/setup.o boot/setup.s # 对setup.s 文件进行编译生成setup 文件。
$(LD86) -s -o boot/setup boot/setup.o # -s 选项表示要去除目标文件中的符号信息。

boot/bootsect: boot/bootsect.s # 同上。生成bootsect.o 磁盘引导块。
$(AS86) -o boot/bootsect.o boot/bootsect.s
$(LD86) -s -o boot/bootsect boot/bootsect.o

tmp.s:	boot/bootsect.s tools/system
	(echo -n "SYSSIZE = (";ls -l tools/system | grep system \
		| cut -c25-31 | tr '\012' ' '; echo "+ 15 ) / 16") > tmp.s
	cat boot/bootsect.s >> tmp.s

clean:
	rm -f Image System.map tmp_make core boot/bootsect boot/setup
	rm -f init/*.o tools/system tools/build boot/*.o
	(cd mm;make clean)
	(cd fs;make clean)
	(cd kernel;make clean)
	(cd lib;make clean)

backup: clean
	(cd .. ; tar cf - linux | compress16 - > backup.Z)
	sync

dep:
	sed '/\#\#\# Dependencies/q' < Makefile > tmp_make
	(for i in init/*.c;do echo -n "init/";$(CPP) -M $$i;done) >> tmp_make
	cp tmp_make Makefile
	(cd fs; make dep)
	(cd kernel; make dep)
	(cd mm; make dep)

### Dependencies:
init/main.o: init/main.c include/unistd.h include/sys/stat.h \
  include/sys/types.h include/sys/times.h include/sys/utsname.h \
  include/utime.h include/time.h include/linux/tty.h include/termios.h \
  include/linux/sched.h include/linux/head.h include/linux/fs.h \
  include/linux/mm.h include/signal.h include/asm/system.h \
  include/asm/io.h include/stddef.h include/stdarg.h include/fcntl.h

```

