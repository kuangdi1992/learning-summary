# IO系统

## 目标

弄清楚计算机让外设工作起来的整个过程，以及在整个过程中使用到的内核代码，能做到对整个外设工作过程进行讲解和分析。

## 设备驱动

下图为操作系统进程管理、CPU管理、内存管理和设备管理的总路线图：

![image-20211001001636441](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20211001001636441.png)

在该图中，可以看到进程管理、内存管理、CPU管理通过控制器和总线连接在一起，而且进程管理、CPU管理和内存管理在前面的章节都进行了相关的讲解。今天，来介绍计算机中另一个重要的内容：设备管理，其中的设备主要指IO设备，包括：显示器、键盘和磁盘等。

## 计算机如何让外设工作？

![image-20211001101313513](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20211001101313513.png)

在计算机中，显示器、键盘等属于外设，其中每一类外设都有其对应的寄存器，例如显示器对应的寄存器—显存，对应的控制器—显卡。

1、计算机CPU通过总线控制器和PCI总线向对应外设的控制器的寄存器中进行读写数据，也就是CPU向外设的控制器发出读写命令，向对应外设的控制器中的寄存器写入数据，然后控制器就会根据寄存器中的内容来操作硬件进行工作。【CPU给外设发出一条指令，然后根据多进程图像，CPU回去执行别的任务，指令写入显卡对应的显存中，控制器显卡会按照显存中的指令进行操作。】

2、操作完成后，控制器会向CPU发出中断，告诉CPU指令已经执行完毕。

3、CPU在处理中断的过程中，又会读取相关的数据到内存中。

整个外设的工作过程并没有特别的复杂，但是需要注意有两个核心：

- CPU向控制器中的寄存器读写数据
- 控制器完成真正的工作后，会向CPU发出中断信号

但是在使用外设的时候，需要查寄存器地址、寄存器中内容的格式和语义，不同的公司对这些的设置都不一样。为了使用外设变得简单，操作系统需要给用户提供一个简单的视图：文件视图。

## 文件视图

下面有一段操作外设的程序：

```c
int fd = open("/dev/xxx"); //打开一个外设
for(int i = 0; i < 10; i++){
    write(fd,i,sizeof(int));
}
close(fd);
```

从上面的代码中可以看出：

1、不论什么设备都是open，read，write，close，也就是<font color=red>操作系统为用户提供统一的接口</font>。

2、不同的设备对应不同的设备文件（/dev/xxx）,根据设备文件找到控制器的地址、内容格式等等。

文件视图如下所示：

![image-20211001103810091](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20211001103810091.png)

对于open、read、write系统调用接口，根据里面的设备文件名，进行相应的处理，根据文件名进行解释后，分为键盘命令和磁盘命令，写入到控制器中，进行执行，执行后返回中断。

## 过程

### printf开始

代码：

```c
printf("Host name:%s",name);
```

printf库：先创建缓存buf将格式化的输出都写到那里，然后再执行write(1,buf,...).

### write接口（统一的文件接口）

write接口通过int 0x80中断进入到内核后，执行的是sys_write。

sys_write代码路径为/linux/fs/read_write.c中，代码如下：

```c
//// 写文件系统调用
// 参数fd是文件句柄，buf是用户缓冲区，count是欲写字节数。
int sys_write(unsigned int fd,char * buf,int count)
{
	struct file * file;
	struct m_inode * inode;

    // 同样地，我们首先判断函数参数的有效性。若果进程文件句柄值大于程序最多打开文件数
    // NR_OPEN，或者需要写入的字节数小于0，或者该句柄的文件结构指针为空，则返回出错码
    // 并退出。如果需读取字节数count等于0，则返回0退出。
	if (fd>=NR_OPEN || count <0 || !(file=current->filp[fd]))
		return -EINVAL;
	if (!count)
		return 0;
    // 然后验证存放数据的缓冲区内存限制。并取文件的i节点。用于根据该i节点属性，分别调
    // 用相应的读操作函数。若是管道文件，并且是写管道文件模式，则进行写管道操作，若成
    // 功则返回写入的字节数，否则返回出错码退出。如果是字符设备文件，则进行写字符设备
    // 操作，返回写入的字符数退出。如果是块设备文件，则进行块设备写操作，并返回写入的
    // 字节数退出。若是常规文件，则执行文件写操作，并返回写入的字节数，退出。
	inode=file->f_inode;
	if (inode->i_pipe)
		return (file->f_mode&2)?write_pipe(inode,buf,count):-EIO;
	if (S_ISCHR(inode->i_mode))
		return rw_char(WRITE,inode->i_zone[0],buf,count,&file->f_pos);
	if (S_ISBLK(inode->i_mode))
		return block_write(inode->i_zone[0],&file->f_pos,buf,count);
	if (S_ISREG(inode->i_mode))
		return file_write(inode,file,buf,count);
    // 执行到这里，说明我们无法判断文件的属性。则打印节点文件属性，并返回出错码退出。
	printk("(Write)inode->i_mode=%06o\n\r",inode->i_mode);
	return -EINVAL;
}
```

sys_write是写文件系统调用，其中的参数fd是文件句柄，buf是用户缓冲区，从write(1,buf,...)可以看出，fd被赋值为1，buf和count无法决定往哪个外设写，只有fd=1才能决定往哪个外设写。

#### 问题：fd=1中的1是怎么用的？

```c
file=current->filp[fd]//其中current表示当前进程的PCB，整句表示当前进程PCB中的filp数组中的第1项赋值给file
inode=file->f_inode;//将file中的f_inode赋值给inode
```

file表示文件，1对应了当前数组PCB里面数组的第1项对应了一个文件，意味着打开了一个文件。文件的inode表示了文件的一些信息。

#### 问题：fd=1中的1对应的文件是什么？

从上面的代码可以看出，1是从当前进程的PCB来的，所以需要弄清楚当前进程的PCB是怎么来的。

因为是被current指向，所以是从fork中来的，也就是从父进程拷贝过来的，代码路径为/linux/kernel/fork.c，如下：

```c
// 复制进程
// 该函数的参数进入系统调用中断处理过程开始，直到调用本系统调用处理过程
// 和调用本函数前时逐步压入栈的各寄存器的值。这些在system_call.s程序中
// 逐步压入栈的值(参数)包括：
// 1. CPU执行中断指令压入的用户栈地址ss和esp,标志寄存器eflags和返回地址cs和eip;
// 2. 在刚进入system_call时压入栈的段寄存器ds、es、fs和edx、ecx、ebx；
// 3. 调用sys_call_table中sys_fork函数时压入栈的返回地址(用参数none表示)；
// 4. 在调用copy_process()分配任务数组项号。
int copy_process(int nr,long ebp,long edi,long esi,long gs,long none,
		long ebx,long ecx,long edx,
		long fs,long es,long ds,
		long eip,long cs,long eflags,long esp,long ss)
{
	struct task_struct *p;
	int i;
	struct file *f;

    // 首先为新任务数据结构分配内存。如果内存分配出错，则返回出错码并退出。
    // 然后将新任务结构指针放入任务数组的nr项中。其中nr为任务号，由前面
    // find_empty_process()返回。接着把当前进程任务结构内容复制到刚申请到
    // 的内存页面p开始处。
	p = (struct task_struct *) get_free_page();
	if (!p)
		return -EAGAIN;
	task[nr] = p;
	*p = *current;	/* NOTE! this doesn't copy the supervisor stack */
    // 随后对复制来的进程结构内容进行一些修改，作为新进程的任务结构。先将
    // 进程的状态置为不可中断等待状态，以防止内核调度其执行。然后设置新进程
    // 的进程号pid和父进程号father，并初始化进程运行时间片值等于其priority值
    // 接着复位新进程的信号位图、报警定时值、会话(session)领导标志leader、进程
    // 及其子进程在内核和用户态运行时间统计值，还设置进程开始运行的系统时间start_time.
	p->state = TASK_UNINTERRUPTIBLE;
	p->pid = last_pid;              // 新进程号。也由find_empty_process()得到。
	p->father = current->pid;       // 设置父进程
	p->counter = p->priority;       // 运行时间片值
	p->signal = 0;                  // 信号位图置0
	p->alarm = 0;                   // 报警定时值(滴答数)
	p->leader = 0;		/* process leadership doesn't inherit */
	p->utime = p->stime = 0;        // 用户态时间和和心态运行时间
	p->cutime = p->cstime = 0;      // 子进程用户态和和心态运行时间
	p->start_time = jiffies;        // 进程开始运行时间(当前时间滴答数)
    // 再修改任务状态段TSS数据，由于系统给任务结构p分配了1页新内存，所以(PAGE_SIZE+
    // (long)p)让esp0正好指向该页顶端。ss0:esp0用作程序在内核态执行时的栈。另外，
    // 每个任务在GDT表中都有两个段描述符，一个是任务的TSS段描述符，另一个是任务的LDT
    // 表描述符。下面语句就是把GDT中本任务LDT段描述符和选择符保存在本任务的TSS段中。
    // 当CPU执行切换任务时，会自动从TSS中把LDT段描述符的选择符加载到ldtr寄存器中。
	p->tss.back_link = 0;
	p->tss.esp0 = PAGE_SIZE + (long) p;     // 任务内核态栈指针。
	p->tss.ss0 = 0x10;                      // 内核态栈的段选择符(与内核数据段相同)
	p->tss.eip = eip;                       // 指令代码指针
	p->tss.eflags = eflags;                 // 标志寄存器
	p->tss.eax = 0;                         // 这是当fork()返回时新进程会返回0的原因所在
	p->tss.ecx = ecx;
	p->tss.edx = edx;
	p->tss.ebx = ebx;
	p->tss.esp = esp;
	p->tss.ebp = ebp;
	p->tss.esi = esi;
	p->tss.edi = edi;
	p->tss.es = es & 0xffff;                // 段寄存器仅16位有效
	p->tss.cs = cs & 0xffff;
	p->tss.ss = ss & 0xffff;
	p->tss.ds = ds & 0xffff;
	p->tss.fs = fs & 0xffff;
	p->tss.gs = gs & 0xffff;
	p->tss.ldt = _LDT(nr);                  // 任务局部表描述符的选择符(LDT描述符在GDT中)
	p->tss.trace_bitmap = 0x80000000;       // 高16位有效
    // 如果当前任务使用了协处理器，就保存其上下文。汇编指令clts用于清除控制寄存器CRO中
    // 的任务已交换(TS)标志。每当发生任务切换，CPU都会设置该标志。该标志用于管理数学协
    // 处理器：如果该标志置位，那么每个ESC指令都会被捕获(异常7)。如果协处理器存在标志MP
    // 也同时置位的话，那么WAIT指令也会捕获。因此，如果任务切换发生在一个ESC指令开始执行
    // 之后，则协处理器中的内容就可能需要在执行新的ESC指令之前保存起来。捕获处理句柄会
    // 保存协处理器的内容并复位TS标志。指令fnsave用于把协处理器的所有状态保存到目的操作数
    // 指定的内存区域中。
	if (last_task_used_math == current)
		__asm__("clts ; fnsave %0"::"m" (p->tss.i387));
    // 接下来复制进程页表。即在线性地址空间中设置新任务代码段和数据段描述符中的基址和限长，
    // 并复制页表。如果出错(返回值不是0)，则复位任务数组中相应项并释放为该新任务分配的用于
    // 任务结构的内存页。
	if (copy_mem(nr,p)) {
		task[nr] = NULL;
		free_page((long) p);
		return -EAGAIN;
	}
    // 如果父进程中有文件是打开的，则将对应文件的打开次数增1，因为这里创建的子进程会与父
    // 进程共享这些打开的文件。将当前进程(父进程)的pwd，root和executable引用次数均增1.
    // 与上面同样的道理，子进程也引用了这些i节点。
	for (i=0; i<NR_OPEN;i++)
		if ((f=p->filp[i]))
			f->f_count++;
	if (current->pwd)
		current->pwd->i_count++;
	if (current->root)
		current->root->i_count++;
	if (current->executable)
		current->executable->i_count++;
    // 随后GDT表中设置新任务TSS段和LDT段描述符项。这两个段的限长均被设置成104字节。
    // set_tss_desc()和set_ldt_desc()在system.h中定义。"gdt+(nr<<1)+FIRST_TSS_ENTRY"是
    // 任务nr的TSS描述符项在全局表中的地址。因为每个任务占用GDT表中2项，因此上式中
    // 要包括'(nr<<1)'.程序然后把新进程设置成就绪态。另外在任务切换时，任务寄存器tr由
    // CPU自动加载。最后返回新进程号。
	set_tss_desc(gdt+(nr<<1)+FIRST_TSS_ENTRY,&(p->tss));
	set_ldt_desc(gdt+(nr<<1)+FIRST_LDT_ENTRY,&(p->ldt));
	p->state = TASK_RUNNING;	/* do this last, just in case */
	return last_pid;
}
```

每一个进程都是从父进程拷贝来的，filp表示父进程打开文件的指针，那么如果父进程中有文件是打开的，则将对应文件的打开次数增1，因为这里创建的子进程会与父进程共享这些打开的文件，所以显然是拷贝来的。

#### 问题：哪个进程最开始打开的？

shell进程启动了whoami命令，shell是其父进程，shell启动代码路径：/linux/init/main.c，如下：

```
/ 内核初始化主程序。初始化结束后将以任务0（idle任务即空闲任务）的身份运行。
void main(void)		/* This really IS void, no error here. */
{			...                   // 移到用户模式下执行
	if (!fork()) {		/* we count on this going ok */
		init();                             // 在新建的子进程(任务1)中执行。
		}
}
```

在内核初始化主程序中，会调用init对第一个将要执行的程序(shell)的环境进行初始化，然后以登录shell方式加载该程序并执行。

代码如下：

```c
// 在main()中已经进行了系统初始化，包括内存管理、各种硬件设备和驱动程序。init()函数
// 运行在任务0第1次创建的子进程(任务1)中。它首先对第一个将要执行的程序(shell)的环境
// 进行初始化，然后以登录shell方式加载该程序并执行。
void init(void)
{
	int pid,i;

    // setup()是一个系统调用。用于读取硬盘参数包括分区表信息并加载虚拟盘(若存在的话)
    // 和安装根文件系统设备。该函数用25行上的宏定义，对应函数是sys_setup()，在块设备
    // 子目录kernel/blk_drv/hd.c中。
	setup((void *) &drive_info);        // drive_info结构是2个硬盘参数表
    // 下面以读写访问方式打开设备"/dev/tty0",它对应终端控制台。由于这是第一次打开文件
    // 操作，因此产生的文件句柄号(文件描述符)肯定是0。该句柄是UNIX类操作系统默认的
    // 控制台标准输入句柄stdin。这里再把它以读和写的方式别人打开是为了复制产生标准输出(写)
    // 句柄stdout和标准出错输出句柄stderr。函数前面的"(void)"前缀用于表示强制函数无需返回值。
	(void) open("/dev/tty0",O_RDWR,0);
	(void) dup(0);                      // 复制句柄，产生句柄1号——stdout标准输出设备
	(void) dup(0);                      // 复制句柄，产生句柄2号——stderr标准出错输出设备
    // 打印缓冲区块数和总字节数，每块1024字节，以及主内存区空闲内存字节数
	printf("%d buffers = %d bytes buffer space\n\r",NR_BUFFERS,
		NR_BUFFERS*BLOCK_SIZE);
	printf("Free mem: %d bytes\n\r",memory_end-main_memory_start);
    // 下面fork()用于创建一个子进程(任务2)。对于被创建的子进程，fork()将返回0值，对于
    // 原进程(父进程)则返回子进程的进程号pid。该子进程关闭了句柄0(stdin)、以只读方式打开
    // /etc/rc文件，并使用execve()函数将进程自身替换成/bin/sh程序(即shell程序)，然后
    // 执行/bin/sh程序。然后执行/bin/sh程序。所携带的参数和环境变量分别由argv_rc和envp_rc
    // 数组给出。关闭句柄0并立即打开/etc/rc文件的作用是把标准输入stdin重定向到/etc/rc文件。
    // 这样shell程序/bin/sh就可以运行rc文件中的命令。由于这里的sh的运行方式是非交互的，
    // 因此在执行完rc命令后就会立刻退出，进程2也随之结束。
    // _exit()退出时出错码1 - 操作未许可；2 - 文件或目录不存在。
	if (!(pid=fork())) {
		close(0);
		if (open("/etc/rc",O_RDONLY,0))
			_exit(1);                       // 如果打开文件失败，则退出(lib/_exit.c)
		execve("/bin/sh",argv_rc,envp_rc);  // 替换成/bin/sh程序并执行
		_exit(2);                           // 若execve()执行失败则退出。
	}
    // 下面还是父进程(1)执行语句。wait()等待子进程停止或终止，返回值应是子进程的进程号(pid).
    // 这三句的作用是父进程等待子进程的结束。&i是存放返回状态信息的位置。如果wait()返回值
    // 不等于子进程号，则继续等待。
	if (pid>0)
		while (pid != wait(&i))
			/* nothing */;
    // 如果执行到这里，说明刚创建的子进程的执行已停止或终止了。下面循环中首先再创建
    // 一个子进程，如果出错，则显示“初始化程序创建子进程失败”信息并继续执行。对于所
    // 创建的子进程将关闭所有以前还遗留的句柄(stdin, stdout, stderr),新创建一个会话
    // 并设置进程组号，然后重新打开/dev/tty0作为stdin,并复制成stdout和sdterr.再次
    // 执行系统解释程序/bin/sh。但这次执行所选用的参数和环境数组另选了一套。然后父
    // 进程再次运行wait()等待。如果子进程又停止了执行，则在标准输出上显示出错信息
    // “子进程pid挺直了运行，返回码是i”,然后继续重试下去....，形成一个“大”循环。
    // 此外，wait()的另外一个功能是处理孤儿进程。如果一个进程的父进程先终止了，那么
    // 这个进程的父进程就会被设置为这里的init进程(进程1)，并由init进程负责释放一个
    // 已终止进程的任务数据结构等资源。
	while (1) {
		if ((pid=fork())<0) {
			printf("Fork failed in init\r\n");
			continue;
		}
		if (!pid) {                                 // 新的子进程
			close(0);close(1);close(2);
			setsid();                               // 创建一新的会话期
			(void) open("/dev/tty0",O_RDWR,0);
			(void) dup(0);
			(void) dup(0);
			_exit(execve("/bin/sh",argv,envp));
		}
		while (1)
			if (pid == wait(&i))
				break;
		printf("\n\rchild %d died with code %04x\n\r",pid,i);
		sync();                                     // 同步操作，刷新缓冲区。
	}
    // _exit()和exit()都用于正常终止一个函数。但_exit()直接是一个sys_exit系统调用，
    // 而exit()则通常是普通函数库中的一个函数。它会先执行一些清除操作，例如调用
    // 执行各终止处理程序、关闭所有标准IO等，然后调用sys_exit。
	_exit(0);	/* NOTE! _exit, not exit() */
}
```

代码中的dup函数是用来复制旧的文件描述符inode的，那么上述代码中的

```
(void) open("/dev/tty0",O_RDWR,0);     0
(void) dup(0);     1
(void) dup(0);     2
_exit(execve("/bin/sh",argv,envp));
```

/dev/tty0是表示终端设备，表示打开一个终端设备/dev/tty0作为stdin 为0,并复制成stdout 为1和sdterr 为2（其中也是打开终端设备/dev/tty0），然后再次执行系统解释程序/bin/sh。

### open接口（统一文件接口）

open接口通过int 0x80中断进入到内核后，执行的是sys_open。

open代码路径为/linux/fs/open.c中，代码如下：

```c
// 打开（或创建）文件系统调用。
// 参数filename是文件名，flag是打开文件标志，它可取值：O_RDONLY（只读）、O_WRONLY
// （只写）或O_RDWR(读写)，以及O_EXCL（被创建文件必须不存在）、O_APPEND（在文件
// 尾添加数据）等其他一些标志的组合。如果本调用创建了一个新文件，则mode就用于指
// 定文件的许可属性。这些属性有S_IRWXU（文件宿主具有读、写和执行权限）、S_IRUSR
// （用户具有读文件权限）、S_IRWXG（组成员具有读、写和执行权限）等等。对于新创
// 建的文件，这些属性只应用与将来对文件的访问，创建了只读文件的打开调用也将返回
// 一个可读写的文件句柄。如果调用操作成功，则返回文件句柄(文件描述符)，否则返回出错码。
int sys_open(const char * filename,int flag,int mode)
{
	struct m_inode * inode;
	struct file * f;
	int i,fd;

    // 首先对参数进行处理。将用户设置的文件模式和屏蔽码相与，产生许可的文件模式。
    // 为了为打开文件建立一个文件句柄，需要搜索进程结构中文件结构指针数组，以查
    // 找一个空闲项。空闲项的索引号fd即是文件句柄值。若已经没有空闲项，则返回出错码。
	mode &= 0777 & ~current->umask;
	for(fd=0 ; fd<NR_OPEN ; fd++)
		if (!current->filp[fd])
			break;
	if (fd>=NR_OPEN)
		return -EINVAL;
    // 然后我们设置当前进程的执行时关闭文件句柄(close_on_exec)位图，复位对应的
    // bit位。close_on_exec是一个进程所有文件句柄的bit标志。每个bit位代表一个打
    // 开着的文件描述符，用于确定在调用系统调用execve()时需要关闭的文件句柄。当
    // 程序使用fork()函数创建了一个子进程时，通常会在该子进程中调用execve()函数
    // 加载执行另一个新程序。此时子进程中开始执行新程序。若一个文件句柄在close_on_exec
    // 中的对应bit位被置位，那么在执行execve()时应对应文件句柄将被关闭，否则该
    // 文件句柄将始终处于打开状态。当打开一个文件时，默认情况下文件句柄在子进程
    // 中也处于打开状态。因此这里要复位对应bit位。
	current->close_on_exec &= ~(1<<fd);
    // 然后为打开文件在文件表中寻找一个空闲结构项。我们令f指向文件表数组开始处。
    // 搜索空闲文件结构项(引用计数为0的项)，若已经没有空闲文件表结构项，则返回
    // 出错码。
	f=0+file_table;
	for (i=0 ; i<NR_FILE ; i++,f++)
		if (!f->f_count) break;
	if (i>=NR_FILE)
		return -EINVAL;
    // 此时我们让进程对应文件句柄fd的文件结构指针指向搜索到的文件结构，并令文件
    // 引用计数递增1。然后调用函数open_namei()执行打开操作，若返回值小于0，则说
    // 明出错，于是释放刚申请到的文件结构，返回出错码i。若文件打开操作成功，则
    // inode是已打开文件的i节点指针。
	(current->filp[fd]=f)->f_count++;
	if ((i=open_namei(filename,flag,mode,&inode))<0) {
		current->filp[fd]=NULL;
		f->f_count=0;
		return i;
	}
    // 根据已打开文件的i节点的属性字段，我们可以知道文件的具体类型。对于不同类
    // 型的文件，我们需要操作一些特别的处理。如果打开的是字符设备文件，那么对于
    // 主设备号是4的字符文件(例如/dev/tty0)，如果当前进程是组首领并且当前进程的
    // tty字段小于0(没有终端)，则设置当前进程的tty号为该i节点的子设备号，并设置
    // 当前进程tty对应的tty表项的父进程组号等于当前进程的进程组号。表示为该进程
    // 组（会话期）分配控制终端。对于主设备号是5的字符文件(/dev/tty)，若当前进
    // 程没有tty，则说明出错，于是放回i节点和申请到的文件结构，返回出错码(无许可)。
/* ttys are somewhat special (ttyxx major==4, tty major==5) */
	if (S_ISCHR(inode->i_mode)) {
		if (MAJOR(inode->i_zone[0])==4) {
			if (current->leader && current->tty<0) {
				current->tty = MINOR(inode->i_zone[0]);
				tty_table[current->tty].pgrp = current->pgrp;
			}
		} else if (MAJOR(inode->i_zone[0])==5)
			if (current->tty<0) {
				iput(inode);
				current->filp[fd]=NULL;
				f->f_count=0;
				return -EPERM;
			}
	}
/* Likewise with block-devices: check for floppy_change */
    // 如果打开的是块设备文件，则检查盘片是否更换过。若更换过则需要让高速缓冲区
    // 中该设备的所有缓冲块失败。
	if (S_ISBLK(inode->i_mode))
		check_disk_change(inode->i_zone[0]);
    // 现在我们初始化打开文件的文件结构。设置文件结构属性和标志，置句柄引用计数
    // 为1，并设置i节点字段为打开文件的i节点，初始化文件读写指针为0.最后返回文
    // 件句柄号。
	f->f_mode = inode->i_mode;
	f->f_flags = flag;
	f->f_count = 1;
	f->f_inode = inode;
	f->f_pos = 0;
	return (fd);
}
```

其中最关注的几句和sys_write接口一样，如下所示：

```c
 // 此时我们让进程对应文件句柄fd的文件结构指针指向搜索到的文件结构，并令文件
    // 引用计数递增1。然后调用函数open_namei()执行打开操作，若返回值小于0，则说
    // 明出错，于是释放刚申请到的文件结构，返回出错码i。若文件打开操作成功，则
    // inode是已打开文件的i节点指针。
	(current->filp[fd]=f)->f_count++;
	if ((i=open_namei(filename,flag,mode,&inode))<0) {
		current->filp[fd]=NULL;
		f->f_count=0;
		return i;
	}
	...
	    // 现在我们初始化打开文件的文件结构。设置文件结构属性和标志，置句柄引用计数
    // 为1，并设置i节点字段为打开文件的i节点，初始化文件读写指针为0.最后返回文
    // 件句柄号。
	f->f_mode = inode->i_mode;
	f->f_flags = flag;
	f->f_count = 1;
	f->f_inode = inode;
	f->f_pos = 0;
```

让进程对应文件句柄fd的文件结构指针filp指向搜索到的文件结构f，并令文件引用计数递增1。调用open_namei函数通过filename文件名将文件读进来，其中主要是读入文件的inode，然后将inode赋值给搜索到的文件结构f（其中inode是存放在磁盘上的文件信息）。

根据上面的梳理，可以open(/dev/tty0)得出一个链如下图所示：

![image-20211001232312466](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20211001232312466.png)

当前进程的PCB对应的文件结构指针filp指向1即fd=1，根据current->filp[fd]=f找到file_table中f对应的那块，然后通过f->f_inode=inode指向对应的inode。而PCB1是拷贝过来的，那么我们找到的对应的inode和0号进程对应的inode是一个inode，对应的都是/dev/tty0，然后根据inode的信息，走到对应的路上（磁盘、键盘、显示器等），直到找到汇编指令out等将信息输出在显示屏上。

注意：inode的信息是在open的时候读入的，然后在write的时候通过读入的inode信息来往相应的外设中写数据。

### 继续sys_write

在上面的代码中，可以看到下面的分支：

```c
if (inode->i_pipe)
	return (file->f_mode&2)?write_pipe(inode,buf,count):-EIO;
if (S_ISCHR(inode->i_mode))
	return rw_char(WRITE,inode->i_zone[0],buf,count,&file->f_pos);
if (S_ISBLK(inode->i_mode))
	return block_write(inode->i_zone[0],&file->f_pos,buf,count);
if (S_ISREG(inode->i_mode))
	return file_write(inode,file,buf,count);
```

/dev/tty0的inode中的信息是字符设备，所以会走S_ISCHR分支，然后调用rw_char（读写）函数，找到inode中的设备号inode->i_zone[0]，这个设备号可以用ls -l列出来，如下：主设备号是4，从设备号是0。

![image-20211001215241385](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20211001215241385.png)

### 转到rw_char

代码路径：/linux/fs/char_dev.c，如下：

```c
// 字符设备读写操作函数
// 参数：rw - 读写命令；dev - 设备号；buf - 缓冲区; count - 读写字节数；pos - 读写指针。
// 返回：实际读/写字节数
int rw_char(int rw,int dev, char * buf, int count, off_t * pos)
{
	crw_ptr call_addr;

    // 如果设备号超出系统设备数，则返回出错码。如果该设备没有对应的读/写函数，也
    // 返回出错码。否则调用对应设备的读写操作函数，并返回实际读/写的字节数。
	if (MAJOR(dev)>=NRDEVS)
		return -ENODEV;
	if (!(call_addr=crw_table[MAJOR(dev)]))
		return -ENODEV;
	return call_addr(rw,MINOR(dev),buf,count,pos);
}
```

上述代码中，crw_table是一个函数指针，对应的代码如下：

```c
// 字符设备读写函数指针表
static crw_ptr crw_table[]={
	NULL,		/* nodev */
	rw_memory,	/* /dev/mem etc */
	NULL,		/* /dev/fd */
	NULL,		/* /dev/hd */
	rw_ttyx,	/* /dev/ttyx */
	rw_tty,		/* /dev/tty */
	NULL,		/* /dev/lp */
	NULL};		/* unnamed pipes */
```

因为tty0的主设备号为4，也就是MAJOR(dev)的值是4，对应函数指针表中的值则为rw_tyyx。

### 转到rw_tyyx

代码路径：/linux/fs/char_dev.c，如下：

```c
//// 串口终端读写操作函数。
// 参数：rw - 读写命令；minor - 终端子设备号；buf - 缓冲区；count - 读写字节数
// pos - 读写操作当前指针，对于中断操作，该指针无用
// 返回：实际读写的字节数。若失败则返回出错码。
static int rw_ttyx(int rw,unsigned minor,char * buf,int count,off_t * pos)
{
	return ((rw==READ)?tty_read(minor,buf,count):
		tty_write(minor,buf,count));
}
```

这里return的是一个选择，从上面S_ISCHR传递下来的参数是write，所以后面调用的函数是tyy_write。

### 转到tty_write

实现输出的核心函数。

代码路径如下：/linux/kernel/chr_dev/tty_io.c，如下：

```c
int tty_write(unsigned channel, char * buf, int nr)
{
	static int cr_flag=0;
	struct tty_struct * tty;
	char c, *b=buf;

	if (channel>2 || nr<0) return -1;
	tty = channel + tty_table;   //主要代码:根据tty_table表中的一项找到对应的tty
	while (nr>0) {
		sleep_if_full(&tty->write_q); //tty中有一个write_q是一个写缓冲队列。如果队列满，则执行sleep，进入可中断的睡眠状态。
		if (current->signal)
			break;
		while (nr>0 && !FULL(tty->write_q)) {
			c=get_fs_byte(b); //这里从用户的缓冲区中取出1字节c，*b=buf
			if (O_POST(tty)) {
				if (c=='\r' && O_CRNL(tty))
					c='\n';
				else if (c=='\n' && O_NLRET(tty))
					c='\r';
				if (c=='\n' && !cr_flag && O_NLCR(tty)) {
					cr_flag = 1;
					PUTCH(13,tty->write_q);
					continue;
				}
				if (O_LCUC(tty))
					c=toupper(c);
			}
			b++; nr--; //将用户数据缓冲区指针b前移1字节，欲写字节数减少1字节
			cr_flag = 0; //复位cr_flag标志
			PUTCH(c,tty->write_q); //将c字节放到tty->write_q队列中
		}
		tty->write(tty); //调用函数进行输出，把写队列缓冲区中的字符显示到控制台屏幕或者通过串行端口发送出去，如果当前处理的tty是控制台终端，则tty->write()调用的是con_write();如果tty是串行终端，则是rs_write().
		if (nr>0)
			schedule();
	}
	return (b-buf);
}
```

注意：在往显示器上写之前，应该是先往一个缓冲区中写。因为在CPU和内存中执行的时候速度快，但是在往显示器上写的时候速度会慢很多，这样就会形成一个速度差，为了减少这样的速度差，就需要使用缓冲区。

![image-20211001224356561](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20211001224356561.png)

### 读写外设的最终指令

代码路径：/linux/include/linux/tty.h，如下：

```c
//linux/include/linux/tty.h
struct tty_struct {
	struct termios termios;
	int pgrp;
	int stopped;
	void (*write)(struct tty_struct * tty);
	struct tty_queue read_q;
	struct tty_queue write_q; //write_q队列，对应上面的write_q
	struct tty_queue secondary;
	};
```

那么上面的tty->write对应上面的write函数，那么需要看看tty_struct的初始化：

```c
///linux/kernel/chr_dev/tty_io.c
struct tty_struct tty_table[] = {
	{
		{ICRNL,		/* change incoming CR to NL */
		OPOST|ONLCR,	/* change outgoing NL to CRNL */
		0,
		ISIG | ICANON | ECHO | ECHOCTL | ECHOKE,
		0,		/* console termio */
		INIT_C_CC},
		0,			/* initial pgrp */
		0,			/* initial stopped */
		con_write,
		{0,0,0,0,""},		/* console read-queue */
		{0,0,0,0,""},		/* console write-queue */
		{0,0,0,0,""}		/* console secondary queue */
	},{
		{0, /* no translation */
		0,  /* no translation */
		B2400 | CS8,
		0,
		0,
		INIT_C_CC},
		0,
		0,
		rs_write,
		{0x3f8,0,0,0,""},		/* rs 1 */
		{0x3f8,0,0,0,""},
		{0,0,0,0,""}
	},{
		{0, /* no translation */
		0,  /* no translation */
		B2400 | CS8,
		0,
		0,
		INIT_C_CC},
		0,
		0,
		rs_write,
		{0x2f8,0,0,0,""},		/* rs 2 */
		{0x2f8,0,0,0,""},
		{0,0,0,0,""}
	}
};

```

tty为0，所以执行的是con_write函数，到了这里，就真正开始写显示器了。

### 转到con_write

代码路径：/linux/kernel/chr_dev/console.c，如下：

```c
void con_write(struct tty_struct * tty)
{
	int nr;
	char c;

	nr = CHARS(tty->write_q);
	while (nr--) {
		GETCH(tty->write_q,c); //从写缓冲队列中取出字符c，根据所设置的状态state进行处理。
		switch(state) {
			case 0:
				if (c>31 && c<127) { //如果从写队列中取出的字符不是控制字符也不是扩展字符即普通显示字符，调整光标位置对应的内存指针pos，并将字符c写到显存中pos处，并将光标右移一列，同时将pos对应移动2个字节。
					if (x>=video_num_columns) {
						x -= video_num_columns;
						pos -= video_size_row;
						lf();
					}
					__asm__("movb attr,%%ah\n\t"
						"movw %%ax,%1\n\t"
						::"a" (c),"m" (*(short *)pos)
						); //mov ax,pos，al=c，打印到屏幕上的汇编代码——out
					pos += 2;
					...
}
```

那么到这里就成功的将字符打印到屏幕上。

【写设备驱动，写核心的out指令，然后将相应的函数注册到相关表中，创建/dev/文件，然后将文件和注册的表对应上，就可以根据设备文件的设备号找到注册的表，从而调用相关的函数来执行核心的out指令，从而驱动设备正常使用。】

### mov pos

完成显示中最核心的秘密：mov pos,c(后续补充)