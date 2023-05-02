## 面试题

**如何优化频繁命令往返造成的性能瓶颈？**

Redis是一种基于客户端-服务端模型以及请求/响应协议的TCP服务。一个请求会遵循以下步骤：

- 客户端向服务端发送命令分四步(发送命令→命令排队→命令执行→返回结果)，并监听Socket返回，通常以阻塞模式等待服务端响应
- 服务端处理命令，并将结果返回给客户端。
- Round Trip Time(简称RTT,数据包往返于两端的时间)

如果同时需要执行大量的命令，就要等待上一条命令应答后再执行，中间多了RTT时间，还频繁调用了系统IO，发送网络请求，同时需要redis调用多次`read`和`write`系统方法，将数据从用户态转移到内核态，这样会对进程上下文有比较大的影响，对性能不好。

因此，可以利用管道来解决。

## 介绍

根据上面的面试题，可以使用管道来解决。

管道可以一次性发送多条命令给服务端，服务端依次处理完毕后，通过一条响应一次性将结果返回，通过减少客户端与`redis`的通信次数来实现降低往返延时时间。

管道的实现原理是`队列`，先进先出的特性保证了数据的顺序性。

![image-20230425213044822](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230425213044822.png)

管道可以看作是批处理命令的优化，类似`Redis`的原生批命令。

## 实例

1、创建txt文件，并且写入redis命令。

```shell
[root@192 myredis]# ll
total 112
drwxr-xr-x. 2 root root    103 Apr 23 08:40 appendonlydir
-rw-r--r--. 1 root root    115 Apr 25 06:33 dump6379.rdb
-rw-r--r--. 1 root root 106578 Apr 23 08:30 redis7.conf
[root@192 myredis]# touch redis.txt
[root@192 myredis]# ll
total 112
drwxr-xr-x. 2 root root    103 Apr 23 08:40 appendonlydir
-rw-r--r--. 1 root root    115 Apr 25 06:33 dump6379.rdb
-rw-r--r--. 1 root root 106578 Apr 23 08:30 redis7.conf
-rw-r--r--. 1 root root      0 Apr 25 06:33 redis.txt
[root@192 myredis]# vi redis.txt 
[root@192 myredis]# cat redis.txt 
set k100 v100
set k200 v200
hset k300 name kd
hset k300 age 30
hset k300 gender man
lpush list 1 2 3 4 5
```

2、执行`cat redis.txt | redis-cli -a 1 --pipe`命令，来执行管道。

```shell
[root@192 myredis]# redis-server redis7.conf 
[root@192 myredis]# cat redis.txt | redis-cli -a 1 --pipe
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
All data transferred. Waiting for the last reply...
Last reply received from server.
errors: 0, replies: 6
```

3、进入`redis`查看结果

```shell
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> get k100
"v100"
127.0.0.1:6379> hget k300 age
"30"
127.0.0.1:6379> hget k300 name
"kd"
```

## 总结

### Pipeline 与原生批量

- 原生批量命令是原子性（如：mset，mget），pipeline是非原子性

- 原生批量命令一次只能执行一种命令，pipeline支持批量执行不同命令

- 原生批命令是服务端实现，而pipeline需要服务端与客户端共同完成

### Pipeline 与事务对比

- 事务具有原子性，管道不具有原子性
- 管道一次性将多条命令发送到服务器，事务是一条一条发的，事务只有在接收到exec命令后才会执行，管道不会
- 执行事务时会阻塞其他命令的执行，而执行管道中的命令时不会

### Pipeline注意事项

- pipeline缓冲的指令只是会依次执行，不保证原子性，如果执行中指令发生异常，将会继续执行后续的指令
- 使用pipeline组装的命令个数不能太多，不然数据量过大客户端阻塞的时间可能过久，同时服务器也被迫回复一个队列答复，占用很多内存
  