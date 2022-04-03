# linux内存管理—Node，Zone，Page

## 开篇

一张经典的图

![image-20211212114213964](F:\git资料\Learning-summary\Picture\linux\image-20211212114213964.png)

Node，Zone，Page是内核中内存管理模块很重要的几个概念。

> Node
>
> - CPU被划分成多个节点Node，内存则被分簇，每个CPU对应一个本地物理内存，即一个CPU-node对应一个内存簇bank，每个内存簇被认为是一个节点。
> - 从内存亲和性出发，看到的表现是地址上的分布，实际上不是从地址出发的定义。
>
> Zone
>
> - 每个物理内存节点node被划分为多个内存管理区域，用于表示不同范围的内存，内核可以使用不同的映射方式映射物理内存。
> - 从地址出发的定义，不论系统上的内存大小是多少，每个Zone的空间是一定的，例如ZONE_DMA一定是16M以下的空间。
>
> Page
>
> - 内存被细分成多个页面帧，页面是最基本的页面分配的单位。

Node

```c
   Memory

                                3G                                   6G
   [           Node0             |                Node1               ]

```

Zone

```
   Memory

                 16M                   4G                            6G
   [   ZONE_DMA   |      ZONE_DMA32     |            ZONE_NORMAL      ]
```

将Node和Zone结合在一起，则为如下

```
   Memory

                 16M                   4G                            6G
   [   ZONE_DMA   |      ZONE_DMA32     |            ZONE_NORMAL      ]
                                3G
   ^                             ^                                    ^
   |<---      Node0          --->|<---          Node1             --->|
```

那么对一个6G内存的系统，内核初始化问的结构如下：

```
   node_data[0]                                                node_data[1]
   +-----------------------------+                             +-----------------------------+        
   |node_id                <---+ |                             |node_id                <---+ |        
   |   (int)                   | |                             |   (int)                   | |        
   +-----------------------------+                             +-----------------------------+    
   |node_zones[MAX_NR_ZONES]   | |    [ZONE_DMA]               |node_zones[MAX_NR_ZONES]   | |    [ZONE_DMA]       
   |   (struct zone)           | |    +---------------+        |   (struct zone)           | |    +---------------+
   |   +-------------------------+    |0              |        |   +-------------------------+    |empty          |
   |   |                       | |    |16M            |        |   |                       | |    |               |
   |   |zone_pgdat         ----+ |    +---------------+        |   |zone_pgdat         ----+ |    +---------------+
   |   |                         |                             |   |                         |        
   |   |                         |    [ZONE_DMA32]             |   |                         |    [ZONE_DMA32]        
   |   |                         |    +---------------+        |   |                         |    +---------------+   
   |   |                         |    |16M            |        |   |                         |    |3G             |   
   |   |                         |    |3G             |        |   |                         |    |4G             |   
   |   |                         |    +---------------+        |   |                         |    +---------------+   
   |   |                         |                             |   |                         |        
   |   |                         |    [ZONE_NORMAL]            |   |                         |    [ZONE_NORMAL]       
   |   |                         |    +---------------+        |   |                         |    +---------------+   
   |   |                         |    |empty          |        |   |                         |    |4G             |   
   |   |                         |    |               |        |   |                         |    |6G             |   
   +---+-------------------------+    +---------------+        +---+-------------------------+    +---------------+
```

图中有几个点值得注意：

- ZONE_DMA和ZONE_DMA32的大小是固定的
- Node0上的ZONE_NORMAL是空的
- Node2上的ZONE_DMA是空的

## Zone

问题：为什么Linux内核将各个物理内存节点分成不同的管理区域Zone？

因为实际的计算机体系结构有硬件的诸多限制，限制了页框可以使用的方式。

Linux内核必须处理8086体系结构的两种硬件约束：

1. ISA总线的直接内存存储DMA处理器，只能对RAM的前16MB进行寻址。
2. 在大容量RAM的现代计算机中，CPU不能直接访问所有的物理地址，因为线性地址空间太小，内核不可能直接映射所有物理内存到线性地址空间。

所以，Linux内存对不同区域的内存需要采用不同的窜了方式和映射方式，因此内核将物理地址分成用zone_t表示的不同地址区域。

### 内存管理区类型zone_type

```c
inculde/linux/mmzone.h
enum zone_type {
#ifdef CONFIG_ZONE_DMA
	/*
	 * ZONE_DMA is used when there are devices that are not able
	 * to do DMA to all of addressable memory (ZONE_NORMAL). Then we
	 * carve out the portion of memory that is needed for these devices.
	 * The range is arch specific.
	 *
	 * Some examples
	 *
	 * Architecture		Limit
	 * ---------------------------
	 * parisc, ia64, sparc	<4G
	 * s390			<2G
	 * arm			Various
	 * alpha		Unlimited or 0-16MB.
	 *
	 * i386, x86_64 and multiple other arches
	 * 			<16M.
	 */
	ZONE_DMA,
#endif
#ifdef CONFIG_ZONE_DMA32
	/*
	 * x86_64 needs two ZONE_DMAs because it supports devices that are
	 * only able to do DMA to the lower 16M but also 32 bit devices that
	 * can only do DMA areas below 4G.
	 */
	ZONE_DMA32,
#endif
	/*
	 * Normal addressable memory is in ZONE_NORMAL. DMA operations can be
	 * performed on pages in ZONE_NORMAL if the DMA devices support
	 * transfers to all addressable memory.
	 */
	ZONE_NORMAL,
#ifdef CONFIG_HIGHMEM
	/*
	 * A memory area that is only addressable by the kernel through
	 * mapping portions into its own address space. This is for example
	 * used by i386 to allow the kernel to address the memory beyond
	 * 900MB. The kernel will set up special mappings (page
	 * table entries on i386) for each page that the kernel needs to
	 * access.
	 */
	ZONE_HIGHMEM,
#endif
	ZONE_MOVABLE,
	__MAX_NR_ZONES
};
```

- ZONE_DMA类型的内存区域在物理内存的低端，主要是ISA设备只能用低端的地址做DMA操作。
- ZONE_NORMAL类型的内存区域直接被内核映射到线性地址空间上面的区域（line address space）。
- ZONE_HIGHMEM将保留给系统使用，是系统中预留的可用内存空间，不能被内核直接映射。
- ZONE_MOVABLE 内核定义了一个伪内存域ZONE_MOVABLE, 在防止物理内存碎片的机制memory migration中需要使用该内存域. 供防止物理内存碎片的极致使用
- ZONE_DEVICE 为支持热插拔设备而分配的Non Volatile Memory非易失性内存
  

## page

页框是系统内存的最小单位。

对内存中的每个页都会创建struct page实例。

```shell
struct page {
	unsigned long flags;		/* Atomic flags, some possibly
					 * updated asynchronously */
	atomic_t _count;		/* Usage count, see below. */
	union {
		atomic_t _mapcount;	/* Count of ptes mapped in mms,
					 * to show when page is mapped
					 * & limit reverse map searches.
					 */
		struct {		/* SLUB */
			u16 inuse;
			u16 objects;
		};
	};
	union {
	    struct {
		unsigned long private;		/* Mapping-private opaque data:
					 	 * usually used for buffer_heads
						 * if PagePrivate set; used for
						 * swp_entry_t if PageSwapCache;
						 * indicates order in the buddy
						 * system if PG_buddy is set.
						 */
		struct address_space *mapping;	/* If low bit clear, points to
						 * inode address_space, or NULL.
						 * If page mapped as anonymous
						 * memory, low bit is set, and
						 * it points to anon_vma object:
						 * see PAGE_MAPPING_ANON below.
						 */
	    };
#if USE_SPLIT_PTLOCKS
	    spinlock_t ptl;
#endif
	    struct kmem_cache *slab;	/* SLUB: Pointer to slab */
	    struct page *first_page;	/* Compound tail pages */
	};
	union {
		pgoff_t index;		/* Our offset within mapping. */
		void *freelist;		/* SLUB: freelist req. slab lock */
	};
	struct list_head lru;		/* Pageout list, eg. active_list
					 * protected by zone->lru_lock !
					 */
	/*
	 * On machines where all RAM is mapped into kernel address space,
	 * we can simply calculate the virtual address. On machines with
	 * highmem some memory is mapped into kernel virtual memory
	 * dynamically, so we need a place to store that address.
	 * Note that this field could be 16 bits on x86 ... ;)
	 *
	 * Architectures with slow multiplication can define
	 * WANT_PAGE_VIRTUAL in asm/page.h
	 */
#if defined(WANT_PAGE_VIRTUAL)
	void *virtual;			/* Kernel virtual address (NULL if
					   not kmapped, ie. highmem) */
#endif /* WANT_PAGE_VIRTUAL */
#ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
	unsigned long debug_flags;	/* Use atomic bitops on this */
#endif

#ifdef CONFIG_KMEMCHECK
	/*
	 * kmemcheck wants to track the status of each byte in a page; this
	 * is a pointer to such a status block. NULL if not tracked.
	 */
	void *shadow;
#endif
};
```

因为内核会为每一个物理页帧创建一个struct page的结构体，因此要保证page结构体足够的小，否则仅struct page就要占用大量的内存。

下面对常用字段作出说明：

**flags**：

     PG_locked：page被锁定，说明有使用者正在操作该page。
     PG_error：状态标志，表示涉及该page的IO操作发生了错误。
     PG_referenced：表示page刚刚被访问过。
     PG_active：page处于inactive LRU链表。PG_active和PG_referenced一起控制该page的活跃程度，这在内存回收时将会非常有用。
     PG_uptodate：表示page的数据已经与后备存储器是同步的，是最新的。
     PG_dirty：与后备存储器中的数据相比，该page的内容已经被修改。
     PG_lru：表示该page处于LRU链表上。
     PG_slab：该page属于slab分配器。
     PG_reserved：设置该标志，防止该page被交换到swap。
     PG_private：如果page中的private成员非空，则需要设置该标志。参考6)对private的解释。
     PG_writeback：page中的数据正在被回写到后备存储器。
     PG_swapcache：表示该page处于swap cache中。
     PG_mappedtodisk：表示page中的数据在后备存储器中有对应。
     PG_reclaim：表示该page要被回收。当PFRA决定要回收某个page后，需要设置该标志。
     PG_swapbacked：该page的后备存储器是swap。
     PG_unevictable：该page被锁住，不能交换，并会出现在LRU_UNEVICTABLE链表中，它包括的几种page：ramdisk或ramfs使用的页、shm_locked、mlock锁定的页。
     PG_mlocked：该page在vma中被锁定，一般是通过系统调用mlock()锁定了一段内存。
**_counts**:

引用计数，表示内核中引用该page的次数，如果要操作该page，引用计数会+1，操作完成-1。当该值为0时，表示没有引用该page的位置，所以该page可以被解除映射，这往往在内存回收时是有用的。