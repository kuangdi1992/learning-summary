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
   call setup_idt    ;// 调用设置中断描述符表子程序，初始化idt表
   call setup_gdt    ;// 调用设置全局描述符表子程序，初始化gdt表
   mov eax,10h          ;// reload all the segment registers
   mov ds,ax        ;// after changing gdt. CS was already
   mov es,ax        ;// reloaded in 'setup_gdt'
   mov fs,ax        ;// 因为修改了gdt，所以需要重新装载所有的段寄存器。
   mov gs,ax        ;// CS 代码段寄存器已经在setup_gdt 中重新加载过了。
```

上述代码含义：设置ds、es、fs、gs为setup.s中构造的数据段的选择符0x10，并将堆栈放置在stack_start指向的user_stack数组区，然后使用定义的新中断描述符表和全局段描述表。

```
  1:	incl %eax		# check that A20 really IS enabled
	movl %eax,0x000000	# loop forever if it isn't
	cmpl %eax,0x100000
	je 1b   #1b表示向后backward跳转到标号1去。
```

上面几句代码用于测试A20地址线是否已经开启。

采用的方法是：向内存地址0x000000处写入任意数值，然后看内存地址0x100000(1M)处是否也是这个值，若一直相同则一直比较就会死机，表示A20地址线没有通，内核不能使用1MB以上的内存。

```
movl %cr0,%eax		# check math chip
andl $0x80000011,%eax	# Save PG,PE,ET
orl $2,%eax		# set MP
movl %eax,%cr0
call check_x87
jmp after_page_tables  #跳转到after_page_tables
```

上面的代码用于检查数学协处理器芯片是否存在（不太懂）。

```
setup_idt:
   lea ignore_int,%edx
   movl $0x00080000,%eax #将选择符0x0008放入eax的高16位中 
   movw %dx,%ax      /* selector = 0x0008 = cs */#偏移门的低16位放入eax的低16位中。
   movw $0x8E00,%dx   /* interrupt gate - dpl=0, present */

   lea idt,%edi   #_idt是中断描述符表的地址。
   mov $256,%ecx
rp_sidt:
   movl %eax,(%edi)
   movl %edx,4(%edi)
   addl $8,%edi
   dec %ecx
   jne rp_sidt
   lidt idt_descr
   ret
```

上面的代码是设置中断描述符表子程序setup_idt。

```
setup_gdt:
   lgdt gdt_descr #加载全局描述符表寄存器
   ret
```

上面的代码是设置一个全新的全局描述符表gdt，并加载。

```
after_page_tables:
   pushl $0      # These are the parameters to main :-)
   pushl $0
   pushl $0
   pushl $L6     # return address for main, if it decides to.
   pushl $main   #压入main函数代码的地址。
   jmp setup_paging
```

上面几个是入栈操作，用于为跳转到main.c中的main()函数做准备工作。

栈中内容模拟如下：

![pushl](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/pushl.png)

入栈后，jmp到setup_paging来执行。

```
setup_paging:
   movl $1024*5,%ecx     /* 5 pages - pg_dir+4 page tables */
   xorl %eax,%eax
   xorl %edi,%edi       /* pg_dir is at 0x000 */
   cld;rep;stosl
   
   #下面4句设置页目录表中的项，因为内核共有4个页表所以只需设置4项，页目录项的结构与页表中项的结构一样，4个字节为1项。
   #例如“$pg0+7”表示：0x00001007，是页目录表中的第1项。
   #则第1个页表所在的地址 = 0x00001007 & 0xfffff000 = 0x1000
   #
   movl $pg0+7,pg_dir    /* set present bit/user r/w */
   movl $pg1+7,pg_dir+4      /*  --------- " " --------- */
   movl $pg2+7,pg_dir+8      /*  --------- " " --------- */
   movl $pg3+7,pg_dir+12     /*  --------- " " --------- */
   
   #下面主要填写4个页表中所有项的内容，共有：4(页表) * 1024(项/页表)=4096(项)，也就是说能映射物理内存4096*4kb = 16Mb。
   #每项的内容：当前项所映射的物理内存地址+该页的标志。
   movl $pg3+4092,%edi
   movl $0xfff007,%eax       /*  16Mb - 4096 + 7 (r/w user,p) */
   std
1: stosl        /* fill pages backwards - more efficient :-) */
   subl $0x1000,%eax
   jge 1b
   
   #设置页目录表基址寄存器cr3的值，指向页目录表。cr3中保存的是页目录表的物理地址。
   xorl %eax,%eax    /* pg_dir is at 0x0000 */
   movl %eax,%cr3    /* cr3 - page directory start */
   
   #设置启动使用分页处理。
   movl %cr0,%eax
   orl $0x80000000,%eax
   movl %eax,%cr0    /* set paging (PG) bit */
   ret          /* this also flushes prefetch-queue */
```

这一段代码主要是对内存进行分页处理，并且设置各个页表项的内容。

在代码的末尾，使用返回指令ret，刷新预取指令队列，也就是将上图中压入栈的main程序的地址弹出，并跳转到/init/main.c程序去运行。

### head.s结束的内存映像

跳转到/init/main.c程序去运行，表示head.s程序执行结束，正式完成了内存页目录和页表的设置，并重新设置了内核实际使用的中断描述符表idt和全局描述符表gdt。此时system模块在内存中的详细映像如下：

![image-20210906222150976](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210906222150976.png)