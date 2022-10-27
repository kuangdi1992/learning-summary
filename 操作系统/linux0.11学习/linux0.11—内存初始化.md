# linux0.11—内存管理（代码）

## 总体介绍

涉及linux0.11内核的内存管理文件共5个，分别是include目录下的linux/mm.h和asm/memory.h头文件，以及包含在mm目录下的Makefile、memory.c和swap.c文件。

memory.c是内存页面管理的核心文件，用于内存的初始化操作、页目录和页表的管理以及内核其他部分对内存的申请处理过程。

swap.c文件主要完成内存缺页时的换入换出。

## 内存分页机制管理

在8086体系结构中，内存的分页机制管理是通过页目录表和页表所组成的二级页表来完成的，其中页目录表和页表的结构是一样的。

页目录项用来寻址一个页表，页表项用来寻址一页物理页。

所以：当指定了一个页目录项和一个页表项时，可以唯一地确定所对应的物理页。

**linux内核中，所有的进程都使用一个页目录表，每个进程有自己的页表。**

### 三个不同的地址

逻辑地址：虚拟地址，在分段结构中常见，由段基址和偏移量组成。

线性地址：经过分段之后转化而来的用于分页之前的地址。

物理地址：用于内存芯片的单元寻址，与处理器和CPU连接的地址总线对应。

8086处理器支持分页，通过CR0寄存器的PG标志位启用。
当PG=1时，启用分页机制，处理器通过分页机制实现线性地址到物理地址的转换。

当PG=0时，禁用分页机制，线性地址直接用作物理地址。

## memory.c文件

memory.c文件定义了Linux内核中内存管理的主要方法，完成了对内存的动态分配和回收以及页面异常的处理。

### free_page函数

free_page()：用来回收内存页，参数是物理地址。该函数会找到物理地址对应的mem_map数组下标，然后对下标对应的项目值进行递减改变。

#### 代码详解

```c
/*
 * 释放物理地址'addr'开始的一页内存。用于函数'free_page_tables()'。
 */
//// 释放物理地址addr 开始的一页面内存。
// 1MB 以下的内存空间用于内核程序和缓冲，不作为分配页面的内存空间。
void free_page(unsigned long addr)
{
	if (addr < LOW_MEM) return;// 如果物理地址addr 小于内存低端（1MB），则返回。
	if (addr >= HIGH_MEMORY)// 如果物理地址addr>=内存最高端，则显示出错信息。
		panic("trying to free nonexistent page");
	addr -= LOW_MEM;// 物理地址减去低端内存位置，再除以4KB，得页面号。
	addr >>= 12;
	if (mem_map[addr]--) return;// 如果对应内存页面映射字节不等于0，则减1 返回。
	mem_map[addr]=0;// 否则置对应页面映射字节为0，并显示出错信息，死机。
	panic("trying to free free page");
}
```

### get_free_page函数

get_free_page()：获取物理空闲页面，并标记为已使用，如果没有空闲页面，就返回0.

#### 代码详解

```c
/*
 * 获取首个(实际上是最后1 个:-)物理空闲页面，并标记为已使用。如果没有空闲页面，
 * 就返回0。
 */
//// 取物理空闲页面。如果已经没有可用内存了，则返回0。
// 输入：%1(ax=0) - 0；%2(LOW_MEM)；%3(cx=PAGING PAGES)；%4(edi=mem_map+PAGING_PAGES-1)。
// 输出：返回%0(ax=页面起始地址)。
// 上面%4 寄存器实际指向mem_map[]内存字节图的最后一个字节。本函数从字节图末端开始向前扫描
// 所有页面标志（页面总数为PAGING_PAGES），若有页面空闲（其内存映像字节为0）则返回页面地址。
// 注意！本函数只是指出在主内存区的一页空闲页面，但并没有映射到某个进程的线性地址去。后面
// 的put_page()函数就是用来作映射的。
unsigned long get_free_page(void)
{
//	unsigned long __res = mem_map+PAGING_PAGES-1;
	__asm {
		pushf
		xor eax, eax
		mov ecx,PAGING_PAGES
//		mov edi,__res 
		mov edi,offset mem_map + PAGING_PAGES - 1
		std
		repne scasb		// 方向位置位，将al(0)与对应(di)每个页面的内容比较，
		jne l1		// 如果没有等于0 的字节，则跳转结束（返回0）。
		mov byte ptr [edi+1],1	// 将对应页面的内存映像位置1。
		sal ecx,12	// 页面数*4K = 相对页面起始地址。
		add ecx,LOW_MEM	// 再加上低端内存地址，即获得页面实际物理起始地址。
		mov edx,ecx	// 将页面实际起始地址 -> edx 寄存器。
		mov ecx,1024	// 寄存器ecx 置计数值1024。
		lea edi,[edx+4092]// 将4092+edx 的位置 -> edi(该页面的末端)。
		rep stosd	// 将edi 所指内存清零（反方向，也即将该页面清零）。
//		mov __res,edx	// 将页面起始地址 -> __res（返回值）。
		mov eax,edx
	l1:	popf
	}
//	return __res;// 返回空闲页面地址（如果无空闲也则返回0）。
}
```

### free_page_tables函数

利用参数计算出要释放几个页，页表在页目录中的位置后，将页表中的1K个物理页调用free_page()进行释放，最后清除对应的页目录项。

#### 代码详解

```c
/*
 * 下面函数释放页表连续的内存块，'exit()'需要该函数。与copy_page_tables()
 * 类似，该函数仅处理4Mb 的内存块。
 */
//// 根据指定的线性地址和限长（页表个数），释放对应内存页表所指定的内存块并置表项空闲。
// 页目录位于物理地址0 开始处，共1024 项，占4K 字节。每个目录项指定一个页表。
// 页表从物理地址0x1000 处开始（紧接着目录空间），每个页表有1024 项，也占4K 内存。
// 每个页表项对应一页物理内存（4K）。目录项和页表项的大小均为4 个字节。
// 参数：from - 起始基地址；size - 释放的长度。
int free_page_tables(unsigned long from,unsigned long size)
{
	unsigned long *pg_table;
	unsigned long * dir, nr;

	if (from & 0x3fffff)// 要释放内存块的地址需以4M 为边界。
		panic("free_page_tables called with wrong alignment");
	if (!from)// 出错，试图释放内核和缓冲所占空间。
		panic("Trying to free up swapper memory space");
	size = (size + 0x3fffff) >> 22;// 计算所占页目录项数(4M 的进位整数倍)，也即所占页表数。
// 下面一句计算起始目录项。对应的目录项号=from>>22，因每项占4 字节，并且由于页目录是从
// 物理地址0 开始，因此实际的目录项指针=目录项号<<2，也即(from>>20)。与上0xffc 确保
// 目录项指针范围有效。
	dir = (unsigned long *) ((from>>20) & 0xffc); /* _pg_dir = 0 */
	for ( ; size-->0 ; dir++) {// size 现在是需要被释放内存的目录项数。
		if (!(1 & *dir))// 如果该目录项无效(P 位=0)，则继续。
			continue;// 目录项的位0(P 位)表示对应页表是否存在。
		pg_table = (unsigned long *) (0xfffff000 & *dir);// 取目录项中页表地址。
		for (nr=0 ; nr<1024 ; nr++) {// 每个页表有1024 个页项。
			if (1 & *pg_table)// 若该页表项有效(P 位=1)，则释放对应内存页。
				free_page(0xfffff000 & *pg_table);
			*pg_table = 0;// 该页表项内容清零。
			pg_table++;// 指向页表中下一项。
		}
		free_page(0xfffff000 & *dir);// 释放该页表所占内存页面。但由于页表在
										// 物理地址1M 以内，所以这句什么都不做。
		*dir = 0;// 对相应页表的目录项清零。
	}
	invalidate();// 刷新页变换高速缓冲。
	return 0;
}
```

`size = (size + 0x3fffff) >> 22;`计算占的页目录项数，是4M的整数倍，>>22表示右移22位也就是除以4M。

`dir = (unsigned long *) ((from>>20) & 0xffc); /* _pg_dir = 0 */`这一句是用来计算起始目录项，对应的目录项号=from>>22，也就是除以4M，但是因为每项占4字节，所以需要先乘以4，也就是<<2左移2位。

### copy_page_tables函数

copy_page_tables()：将父进程的页表复制给了子进程。

该函数中利用from和to的线性地址计算出源目录项和目标目录项的位置，得到原页表项，然后为to申请一个新的物理内存页，将该物理页地址设置到to的页表项，将页表项地址设置到to的目录项中。

最后，将源页表项复制到新申请的物理页，并将页表项设置为只读。

#### 代码详解

```c
 /*
 * 注意！我们并不是仅复制任何内存块- 内存块的地址需要是4Mb 的倍数（正好
 * 一个页目录项对应的内存大小），因为这样处理可使函数很简单。不管怎样，
 * 它仅被fork()使用（fork.c）
 *
 * 注意!!当from==0 时，是在为第一次fork()调用复制内核空间。此时我们
 * 不想复制整个页目录项对应的内存，因为这样做会导致内存严重的浪费- 我们
 * 只复制头160 个页面- 对应640kB。即使是复制这些页面也已经超出我们的需求，
 * 但这不会占用更多的内存- 在低1Mb 内存范围内我们不执行写时复制操作，所以
 * 这些页面可以与内核共享。因此这是nr=xxxx 的特殊情况（nr 在程序中指页面数）。
 */
//// 复制指定线性地址和长度（页表个数）内存对应的页目录项和页表，从而被复制的页目录和
//// 页表对应的原物理内存区被共享使用。
// 复制指定地址和长度的内存对应的页目录项和页表项。需申请页面来存放新页表，原内存区被共享；
// 此后两个进程将共享内存区，直到有一个进程执行写操作时，才分配新的内存页（写时复制机制）。
int copy_page_tables(unsigned long from,unsigned long to,long size)
{
	unsigned long * from_page_table;
	unsigned long * to_page_table;
	unsigned long this_page;
	unsigned long * from_dir, * to_dir;
	unsigned long nr;

	// 源地址和目的地址都需要是在4Mb 的内存边界地址上。否则出错，死机。
	if ((from&0x3fffff) || (to&0x3fffff))
		panic("copy_page_tables called with wrong alignment");
	// 取得源地址和目的地址的目录项(from_dir 和to_dir)。
	from_dir = (unsigned long *) ((from>>20) & 0xffc); /* _pg_dir = 0 */
	to_dir = (unsigned long *) ((to>>20) & 0xffc);
	// 计算要复制的内存块占用的页表数（也即目录项数）。
	size = ((unsigned) (size+0x3fffff)) >> 22;
	// 下面开始对每个占用的页表依次进行复制操作。
	for( ; size-->0 ; from_dir++,to_dir++) {
		if (1 & *to_dir)// 如果目的目录项指定的页表已经存在(P=1)，则出错，死机。
			panic("copy_page_tables: already exist");
		if (!(1 & *from_dir))// 如果此源目录项未被使用，则不用复制对应页表，跳过。
			continue;
		// 取当前源目录项中页表的地址 -> from_page_table。
		from_page_table = (unsigned long *) (0xfffff000 & *from_dir);
// 为目的页表取一页空闲内存，如果返回是0 则说明没有申请到空闲内存页面。返回值=-1，退出。
		if (!(to_page_table = (unsigned long *) get_free_page()))
			return -1;	/* Out of memory, see freeing */
		// 设置目的目录项信息。7 是标志信息，表示(Usr, R/W, Present)。
		*to_dir = ((unsigned long) to_page_table) | 7;
		// 针对当前处理的页表，设置需复制的页面数。
        // 如果是在内核空间，则仅需复制头160 页，否则需要复制1 个页表中的所有1024 页面。
		nr = (from==0)?0xA0:1024;
		// 对于当前页表，开始复制指定数目nr 个内存页面。
		for ( ; nr-- > 0 ; from_page_table++,to_page_table++) {
			this_page = *from_page_table;// 取源页表项内容。
			if (!(1 & this_page))// 如果当前源页面没有使用，则不用复制。
				continue;
// 复位页表项中R/W 标志(置0)。(如果U/S 位是0，则R/W 就没有作用。如果U/S 是1，而R/W 是0，
// 那么运行在用户层的代码就只能读页面。如果U/S 和R/W 都置位，则就有写的权限。)
			this_page &= ~2;
			*to_page_table = this_page;// 将该页表项复制到目的页表中。
// 如果该页表项所指页面的地址在1M 以上，则需要设置内存页面映射数组mem_map[]，于是计算
// 页面号，并以它为索引在页面映射数组相应项中增加引用次数。
			if (this_page > LOW_MEM) {
// 下面这句的含义是令源页表项所指内存页也为只读。因为现在开始有两个进程共用内存区了。
// 若其中一个内存需要进行写操作，则可以通过页异常的写保护处理，为执行写操作的进程分配
// 一页新的空闲页面，也即进行写时复制的操作。
				*from_page_table = this_page;// 令源页表项也只读。
				this_page -= LOW_MEM;
				this_page >>= 12;
				mem_map[this_page]++;
			}
		}
	}
	invalidate();// 刷新页变换高速缓冲。
	return 0;
}
```

在复制内存的时候，取出源地址和目的地址的目录项以及要复制的内存块占用的页表数，然后对每个占用的页表依次进行复制。

该函数复制指定线性地址和长度内存对应的页目录项和页表，从而被复制的页目录和页表对应的原物理内存区被共享使用。

复制指定地址和长度的内存对应的页目录项和页表项，需要申请页面来存放新的页表，原内存区被共享。

此后，两个进程将共享内存区，直到一个进程执行写操作时，才分配新的内存页。

### get_empty_page函数

调用get_free_page()和put_page()先取得一个物理页，再将取得的物理页和线性地址建立起对应关系。

#### 代码详解

```c
// 取得一页空闲内存并映射到指定线性地址处。
// 与get_free_page()不同。get_free_page()仅是申请取得了主内存区的一页物理内存。而该函数不仅是获取到一页物理内存页面，还进一步调用put_page()，将物理页面映射到指定的线性地址处。
void get_empty_page(unsigned long address)
{
	unsigned long tmp;

// 若不能取得一空闲页面，或者不能将页面放置到指定地址处，则显示内存不够的信息。
// 即使执行get_free_page()返回0 也无所谓，因为put_page()中还会对此情况再次申请空闲物理页面的。
	if (!(tmp=get_free_page()) || !put_page(tmp,address)) {
		free_page(tmp);		/* 0 is ok - ignored */
		oom();
	}
}
```

### put_page函数

1、通过参数给的线性地址计算出对应的页目录项和页表项。

2、将物理页地址存入页表项

3、将页表项地址存入目录项，完成从线性地址到物理地址的映射。

#### 代码详解

```c
/*
 * 下面函数将一内存页面放置在指定地址处。它返回页面的物理地址，如果
 * 内存不够(在访问页表或页面时)，则返回0。
 */
//// 把一物理内存页面映射到指定的线性地址处。
// 主要工作是在页目录和页表中设置指定页面的信息。若成功则返回页面地址。
unsigned long put_page(unsigned long page,unsigned long address)
{
	unsigned long tmp, *page_table;

/* 注意!!!这里使用了页目录基址_pg_dir=0 的条件 */

// 如果申请的页面位置低于LOW_MEM(1Mb)或超出系统实际含有内存高端HIGH_MEMORY，则发出警告。
	if (page < LOW_MEM || page >= HIGH_MEMORY)
		printk("Trying to put page %p at %p\n",page,address);
	// 如果申请的页面在内存页面映射字节图中没有置位，则显示警告信息。
	if (mem_map[(page-LOW_MEM)>>12] != 1)
		printk("mem_map disagrees with %p at %p\n",page,address);
	// 计算指定地址在页目录表中对应的目录项指针。
	page_table = (unsigned long *) ((address>>20) & 0xffc);
// 如果该目录项有效(P=1)(也即指定的页表在内存中)，则从中取得指定页表的地址 -> page_table。
	if ((*page_table)&1)
		page_table = (unsigned long *) (0xfffff000 & *page_table);
	else {
// 否则，申请空闲页面给页表使用，并在对应目录项中置相应标志7（User, U/S, R/W）。然后将
// 该页表的地址 -> page_table。
		if (!(tmp=get_free_page()))
			return 0;
		*page_table = tmp|7;
		page_table = (unsigned long *) tmp;
	}
	// 在页表中设置指定地址的物理内存页面的页表项内容。每个页表共可有1024 项(0x3ff)。
	page_table[(address>>12) & 0x3ff] = page | 7;
/* 不需要刷新页变换高速缓冲 */
	return page;// 返回页面地址。
}
```

### do_wp_page函数

处理页面异常的函数，是do_page_fault函数调用的页写保护处理函数。

1、判断地址是否在进程的代码区域

2、若是，则终止程序，然后执行写时复制页面的操作。

#### 代码详解

```c
/*
 * 当用户试图往一个共享页面上写时，该函数处理已存在的内存页面，（写时复制）
 * 它是通过将页面复制到一个新地址上并递减原页面的共享页面计数值实现的。
 *
 * 如果它在代码空间，我们就以段错误信息退出。
 */
//// 页异常中断处理调用的C 函数。写共享页面处理函数。在page.s 程序中被调用。
// 参数error_code 是由CPU 自动产生，address 是页面线性地址。
// 写共享页面时，需复制页面（写时复制）。
void do_wp_page(unsigned long error_code,unsigned long address)
{
#if 0
	if (CODE_SPACE(address))	// 如果地址位于代码空间，则终止执行程序。
		do_exit(SIGSEGV);
#endif
// 处理取消页面保护。参数指定页面在页表中的页表项指针，其计算方法是：
// ((address>>10) & 0xffc)：计算指定地址的页面在页表中的偏移地址；
// (0xfffff000 &((address>>20) &0xffc))：取目录项中页表的地址值，
// 其中((address>>20) &0xffc)计算页面所在页表的目录项指针；
// 两者相加即得指定地址对应页面的页表项指针。这里对共享的页面进行复制。
	un_wp_page(
		(unsigned long *)(((address>>10) & 0xffc) + 
		(0xfffff000 & *((unsigned long *) ((address>>20) &0xffc))))
	);

}
```



