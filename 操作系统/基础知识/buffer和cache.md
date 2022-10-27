free命令的输出界面如下：

```shell

# 注意不同版本的free输出可能会有所不同
$ free
              total        used        free      shared  buff/cache   available
Mem:        8169348      263524     6875352         668     1030472     7611064
Swap:             0           0           0
```

在上面的界面中，包含了物理内存Mem和交换分区的具体使用情况，比如总内存、已用内存、缓存、可用内存等。

缓存是Buffer和Cache两部分的总和。两者从字面上理解，Buffer是缓冲区，Cache是缓存，两者都是数据在内存中的临时存储。

#### free数据的来源

用man命令查询free的文档，找到对应指标的详细说明。

```shell
buffers
              Memory used by kernel buffers (Buffers in /proc/meminfo)

cache  Memory used by the page cache and slabs (Cached and SReclaimable in /proc/meminfo)

buff/cache
              Sum of buffers and cache
```

Buffers是内核缓冲区用到的内存，对应/proc/meminfo中的buffers值。

Cache是内核页缓存和slab用到的内存，对应/proc/meminfo中的Cached与SRclaimable之和。

#### proc文件系统

/proc是Linux内核提供的一种特殊文件系统，是用户和内核交互的接口。用户可以从/proc中查询内核的运行状态和配置选项，查询进程的运行状态、统计数据等。

proc 文件系统同时也是很多性能工具的最终数据来源。比如我们刚才看到的 free ，就是通过读取/proc/meminfo，得到内存的使用情况。

执行man proc，可以看到proc文件系统的详细文档。

```shell
Buffers %lu
    Relatively temporary storage for raw disk blocks that shouldn't get tremendously large (20MB or so).

Cached %lu
   In-memory cache for files read from the disk (the page cache).  Doesn't include SwapCached.
...
SReclaimable %lu (since Linux 2.6.19)
    Part of Slab, that might be reclaimed, such as caches.
    
SUnreclaim %lu (since Linux 2.6.19)
    Part of Slab, that cannot be reclaimed on memory pressure.
```

> Buffers 是对原始磁盘块的临时存储，也就是用来缓存磁盘的数据，通常不会特别大（20MB 左右）。这样，内核就可以把分散的写集中起来，统一优化磁盘的写入，比如可以把多次小的写合并成单次大的写等等。
>
> Cached 是从磁盘读取文件的页缓存，也就是用来缓存从文件读取的数据。这样，下次访问这些文件数据时，就可以直接从内存中快速获取，而不需要再次访问缓慢的磁盘。
>
> SReclaimable 是 Slab 的一部分。Slab 包括两部分，其中的可回收部分，用 SReclaimable 记录；而不可回收部分，用 SUnreclaim 记录。

#### 小总结

Buffer 是对磁盘数据的缓存，而 Cache 是文件数据的缓存，它们既会用在读请求中，也会用在写请求中

