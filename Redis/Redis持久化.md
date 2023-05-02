## 介绍

​		Redis是一个内存数据库，数据保存在内存中，但是我们都知道内存的数据变化是很快的，也容易发生丢失。Redis提供了持久化的机制，分别是RDB(Redis DataBase)和AOF(Append Only File)。

​		既然redis的数据可以保存在磁盘上，那么这个流程是什么样的呢？ 主要有下面五个过程： 

- （1）客户端向服务端发送写操作(数据在客户端的内存中)。 
- （2）数据库服务端接收到写请求的数据(数据在服务端的内存中)。 
- （3）服务端调用write这个系统调用，将数据往磁盘上写(数据在系统内存的缓冲区中)。 
- （4）操作系统将缓冲区中的数据转移到磁盘控制器上(数据在磁盘缓存中)。 
- （5）磁盘控制器将数据写到磁盘的物理介质中(数据真正落到磁盘上)。

![image-20230419225603161](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230419225603161.png)

## RDB方式

RDB持久化：以指定的时间间隔执行数据集的时间点快照。

> - 在指定的时间间隔，执行数据集的时间点快照
> - 实现类似照片记录效果的方式，就是把某一时刻的数据和状态以文件的形式写到磁盘上，也就是快照。这样一来即使故障宕机，快照文件也不会丢失，数据的可靠性也就得到了保证。
> - 这个快照文件就称为RDB文件(dump.rdb)，其中，RDB就是Redis DataBase的缩写。
> - 将内存数据全部保存到磁盘dump.rdb文加中

RDB在恢复时，将硬盘中的快照文件直接读取到内存中。

Redis的数据都在内存中，保存备份时执行的是`全量快照`，即将内存中的所有数据都记录到磁盘中。

### 自动触发

#### 配置方法

redis默认的配置文件redis.conf，其中有一个自动触发RDB持久化的配置：

```shell
Redis7的。
################################ SNAPSHOTTING  ###########################        #####
    413 
    414 # Save the DB to disk.
    415 #
    416 # save <seconds> <changes> [<seconds> <changes> ...]
    417 #
    418 # Redis will save the DB if the given number of seconds elapsed and it
    419 # surpassed the given number of write operations against the DB.
    420 #
    421 # Snapshotting can be completely disabled with a single empty string argum        ent
    422 # as in following example:
    423 #
    424 # save ""
    425 #
    426 # Unless specified otherwise, by default Redis will save the DB:
    427 #   * After 3600 seconds (an hour) if at least 1 change was performed
    428 #   * After 300 seconds (5 minutes) if at least 100 changes were performed
    429 #   * After 60 seconds if at least 10000 changes were performed
    430 #
    431 # You can set these explicitly by uncommenting the following line.
    432 #
    433 # save 3600 1 300 100 60 10000
```

说明：

`save 3600 1 300 100 60 10000`表示一小时内有一次修改，5分钟内有至少100次修改，1分钟内至少有10000次修改，就会自动触发RDB持久化。

#### 自动触发

- 修改save配置为5秒钟2次修改

  ```shell
  # save 3600 1 300 100 60 10000
  save 5 2
  ```

- 修改dump文件保存路径

  ```shell
  # The working directory.
  #
  # The DB will be written inside this directory, with the filename specified
  # above using the 'dbfilename' configuration directive.
  #
  # The Append Only File will also be created inside this directory.
  #
  # Note that you must specify a directory here, not a file name.
  #dir ./
  dir /opt/redis-7.0.10/myredis/dumpfiles
  # 注意该目录一定要存在，不会自动创建
  [root@192 myredis]# ll
  total 108
  drwxr-xr-x. 2 root root      6 Apr 23 06:23 dumpfiles
  ```

- 修改dump文件名字

  ```shell
  # The filename where to dump the DB
  dbfilename dump6379.rdb
  ```

- 查看修改后的值

  ```shell
  [root@192 myredis]# redis-cli -a 1
  Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
  127.0.0.1:6379> config get dir
  1) "dir"
  2) "/opt/redis-7.0.10/myredis/dumpfiles"
  ```

- 5秒钟执行两次set命令，然后查看dumpfiles目录下是否生成文件

  ```shell
  127.0.0.1:6379> set k1 v1
  OK
  127.0.0.1:6379> set k2 v2
  OK
  
  [root@192 dumpfiles]# ll
  total 0
  [root@192 dumpfiles]# ll
  total 4
  -rw-r--r--. 1 root root 108 Apr 23 06:30 dump6379.rdb
  ```

  可知，dumpfiles目录下生成了rdb文件。

- 执行一次set后，等待5秒钟后，查看rdb文件大小

  ```shell
  127.0.0.1:6379> set k3 v3
  OK
  
  [root@192 dumpfiles]# ll
  total 4
  -rw-r--r--. 1 root root 108 Apr 23 06:30 dump6379.rdb
  ```

  可见，rdb文件大小没有任何变化。

- 5秒后，继续执行set命令，然后查看rdb文件大小

  ```shell
  127.0.0.1:6379> set k4 v4
  OK
  
  [root@192 dumpfiles]# ll
  total 4
  -rw-r--r--. 1 root root 122 Apr 23 06:34 dump6379.rdb
  ```

  可见，文件变大，存储成功。

#### 备份恢复

1、将备份文件修改名字，如下：

```shell
ot@192 dumpfiles]# ll
total 4
-rw-r--r--. 1 root root 122 Apr 23 06:34 dump6379.rdb.bak
```

2、使用`flushdb`命令，清空redis，并查看dumpfiles目录。

```shell
127.0.0.1:6379> keys *
1) "k4"
2) "k3"
3) "k2"
4) "k1"
127.0.0.1:6379> flushdb
OK
127.0.0.1:6379> keys *
(empty array)

[root@192 dumpfiles]# ll
total 8
-rw-r--r--. 1 root root  89 Apr 23 06:37 dump6379.rdb
-rw-r--r--. 1 root root 122 Apr 23 06:34 dump6379.rdb.bak
```

可以看到，dumpfiles目录下又生成了rdb文件，说明`当执行类似flushdb/flushall/shutdown这样的提交命令时，redis也会自动触发RDB持久化`。

3、`shutdown`退出后，重新进入redis。

```shell
127.0.0.1:6379> shutdown
not connected> quit
[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> keys *
(empty array)
```

可见，没有恢复。

4、将之前的RDB文件恢复

```shell
[root@192 dumpfiles]# ll
total 8
-rw-r--r--. 1 root root  89 Apr 23 06:42 dump6379.rdb
-rw-r--r--. 1 root root 122 Apr 23 06:34 dump6379.rdb.bak
[root@192 dumpfiles]# rm -rf dump6379.rdb
[root@192 dumpfiles]# mv dump6379.rdb.bak dump6379.rdb
[root@192 dumpfiles]# ll
total 4
-rw-r--r--. 1 root root 122 Apr 23 06:34 dump6379.rdb
```

5、重新进入redis

```shell
[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> keys *
1) "k2"
2) "k1"
3) "k3"
4) "k4"
127.0.0.1:6379> 
```

可以看到已经恢复了。

注意：`不可以将备份文件dump.rdb和生产redis服务器放在同一台机器，必须分开各自存储，以防生产机物理损坏之后备份文件丢失。`

### 手动触发

#### save命令（不建议使用）

save命令是一个同步操作，执行该命令后，RDB持久化是在主进程中进行的，这样会阻塞当前redis服务，直到RDB持久化完成后，客户端才能正常连接redis服务。

![img](https://pics7.baidu.com/feed/314e251f95cad1c86c2b9b3ee2239801c93d5139.jpeg@f_auto?token=93ba47ddc1a5aaa914e8205ee8258099)



#### bgsave命令（默认）

bgsave命令是对save命令的一个优化，是一个异步操作。执行该命令后，redis主进程会通过fork操作创建一个子进程，`RDB持久化是由子进程操作，完成后自动结束。`这个过程中，主进程不阻塞，可以继续接收客户端的访问。因此，redis内部所有涉及RDB持久化的操作都是采用的bgsave方式，save命令基本已经废弃。

![img](https://pics5.baidu.com/feed/a50f4bfbfbedab6448bb7de6522b50cb78311ef4.jpeg@f_auto?token=0fecc296541f7d25597a47612aebd208)

```shell
127.0.0.1:6379> set k5 v5
OK
[root@192 dumpfiles]# ll
total 4
-rw-r--r--. 1 root root 122 Apr 23 06:34 dump6379.rdb

127.0.0.1:6379> bgsave
Background saving started
[root@192 dumpfiles]# ll
total 4
-rw-r--r--. 1 root root 129 Apr 23 06:54 dump6379.rdb

127.0.0.1:6379> lastsave
(integer) 1682258078
# LASTSAVE 命令用于查看 BGSAVE 命令是否执行成功。
```

![img](https://pics3.baidu.com/feed/1b4c510fd9f9d72a83bce36e7337d73c359bbb94.jpeg@f_auto?token=85214bd35fd3d13cf48b3f5f786d3876)

### 优点

RDB 数据持久化适合于大规模的数据恢复，并且还原速度快，如果对数据的完整性不是特别敏感（可能存在最后一次丢失的情况），那么 RDB 持久化方式非常合适。

### 缺点

在 RDB 持久化的过程中，子进程会把 Redis 的所有数据都保存到新建的 dump.rdb 文件中，这是一个既消耗资源又浪费时间的操作。因此 Redis 服务器不能过于频繁地创建 rdb 文件，否则会严重影响服务器的性能。

RDB 持久化的最大不足之处在于，`最后一次持久化的数据可能会出现丢失的情况`。可以这样理解，在持久化进行过程中，服务器突然宕机了，这时存储的数据可能并不完整，比如子进程已经生成了 rdb 文件，但是主进程还没来得及用它覆盖掉原来的旧 rdb 文件，这样就把最后一次持久化的数据丢失了。

如果数据集比较大的时候，fork可以能比较耗时，造成服务器在一段时间内停止处理客户端的请求。

### 数据丢失案例

1、正常录入`k1`和`k2`，并查看RDB文件

```shell
127.0.0.1:6379> set k1 v1
OK
127.0.0.1:6379> set k2 v2
OK
[root@192 dumpfiles]# ll
total 4
-rw-r--r--. 1 root root 108 Apr 23 07:02 dump6379.rdb
```

2、录入`k3`，然后kill -9杀掉redis服务，并查看RDB文件

```shell
127.0.0.1:6379> set k3 v3
OK
127.0.0.1:6379> keys *
1) "k2"
2) "k1"
3) "k3"

[root@192 dumpfiles]# ps -ef | grep redis
root      35233      1  0 06:44 ?        00:00:00 redis-server *:6379
root      35238   2815  0 06:44 pts/0    00:00:00 redis-cli -a 1
root      35563  34926  0 07:02 pts/1    00:00:00 grep --color=auto redis
[root@192 dumpfiles]# kill -9 35233
[root@192 dumpfiles]# ll
total 4
-rw-r--r--. 1 root root 108 Apr 23 07:02 dump6379.rdb #大小没有变化

127.0.0.1:6379> keys * #执行该命令时，显示已经被杀掉了。
Error: Server closed the connection
not connected> quit
```

可以看到，执行完`set k3 v3`后，在内存中存在，但是没有保存到RDB文件中，此时杀掉redis服务后，RDB文件大小并没有变化。

3、重新进入redis，查看

```shell
[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> get k1
"v1"
127.0.0.1:6379> get k2
"v2"
127.0.0.1:6379> get k3
(nil)
```

可以看到，`k3`并没有值，`也就是最后一次操作丢失了`。

### 检查和修复RDB文件

当RDB文件遇到状况时，需要进行检查并且修复。

```shell
[root@192 ~]# cd /usr/local/bin
[root@192 bin]# ll
total 74708
-rwxr-xr-x. 1 root root 54453847 Apr 15 18:24 docker-compose
-rwxr-xr-x. 1 root root  5197776 Apr 16 00:39 redis-benchmark
lrwxrwxrwx. 1 root root       12 Apr 16 00:39 redis-check-aof -> redis-server
lrwxrwxrwx. 1 root root       12 Apr 16 00:39 `redis-check-rdb -> redis-server`
-rwxr-xr-x. 1 root root  5411112 Apr 16 00:39 redis-cli
lrwxrwxrwx. 1 root root       12 Apr 16 00:39 redis-sentinel -> redis-server
-rwxr-xr-x. 1 root root 11429256 Apr 16 00:39 redis-server
```

执行如下命令进行检查和修复：

`redis-check-rdb /opt/redis-7.0.10/myredis/dumpfiles/dump6379.rdb`

```shell
[root@192 bin]# redis-check-rdb /opt/redis-7.0.10/myredis/dumpfiles/dump6379.rdb 
[offset 0] Checking RDB file /opt/redis-7.0.10/myredis/dumpfiles/dump6379.rdb
[offset 27] AUX FIELD redis-ver = '7.0.10'
[offset 41] AUX FIELD redis-bits = '64'
[offset 53] AUX FIELD ctime = '1682258526'
[offset 68] AUX FIELD used-mem = '1054608'
[offset 80] AUX FIELD aof-base = '0'
[offset 82] Selecting DB ID 0
[offset 108] Checksum OK
[offset 108] \o/ RDB looks OK! \o/
[info] 2 keys read
[info] 0 expires
[info] 0 already expired
```

### 禁用快照

#### 动态停止RDB保存规则

`redis-cli config set save ""`

#### 快照禁用

在配置文件中，按照如下修改：

```shell
# Snapshotting can be completely disabled with a single empty string argument
# as in following example:
#
# save ""
```

### 其他配置项

| 配置项                      | 作用                                                         |
| --------------------------- | ------------------------------------------------------------ |
| stop-writes-on-bgsave-error | 默认yes，配置成no，表示不在乎数据不一致，在快照写入失败时，确保redis继续接受新的写请求 |
| rdbcompression              | 默认yes，对于存储到磁盘中的快照，是否进行压缩存储。          |
| rdbchecksum                 | 默认yes，在存储快照后，使用CRC64算法进行数据校验，会增加约10%的性能消耗。 |
| rdb-del-sync-files          | 默认no，在没有持久性的情况下删除复制中使用的RDB文件启用。    |

## AOF方式

全量备份总是耗时的，Redis为我们提供了一种更加高效的持久化方式，即AOF（appendonlyfile）。`此方式工作机制很简单，redis会将每一个收到的写命令都通过write函数追加到aof文件中。默认情况下Redis没有开启AOF方式的持久化。`在redis服务器重启时，会读取并加载aof文件，达到恢复数据的目的。

开启AOF持久化后，每执行一条会更改Redis中的数据的命令，Redis就会将该命令写入硬盘中的AOF文件，这一过程显然会降低Redis的性能，但大部分情况下这个影响是能够接受的，另外使用较快的硬盘可以提高AOF的性能。

### 工作流程

![image-20230423223146356](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230423223146356.png)

1、Client是命令的来源，会有多个源头以及请求命令

2、在这些命令到达Redis Server之后，不是直接写入AOF文件，将这些命令存放到AOF缓存中进行保存，当这些命令达到一定量之后写入磁盘，避免频繁的磁盘IO操作。

3、AOF缓存会根据AOF缓存区同步文件的三种写回策略将命令写入磁盘上的AOF文件。

4、随着写入AOF内容的增加，为避免文件膨胀，会根据规则进行命令的合并（AOF重写），从而起到AOF文件压缩的目的。

5、当Redis Server服务器重启的时候，将从AOF文件载入数据。

### 写回策略

**appendfsync always**

客户端对redis服务器的`每次写操作都写入AOF日志文件`。这种方式是最安全的方式，但每次写操作都进行一次磁盘IO，非常影响redis的性能，所以一般不使用这种方式。

**appendfsync everysec**

每秒刷新一次缓冲区中的数据到AOF文件。这种方式是redis`默认`使用的策略，是考虑数据完整性和性能的这种方案，理论上，这种方式最多只会丢失1秒内的数据。

**appendfsync no**

redis服务器不负责将数据写入到AOF文件中，而是`直接交给操作系统去判断什么时候写入`。这种方式是最快的一种策略，但丢失数据的可能性非常大，因此也是不推荐使用的。

### 配置

配置文件：redis.conf

```shell
# 可以通过修改redis.conf配置文件中的appendonly参数开启
appendonly yes

# Redis6：AOF文件的保存位置和RDB文件的位置相同，都是通过dir参数设置的。
dir /opt/redis-7.0.10/myredis
# Redis7：在dir只下生成一个appendonlydir目录，存放aof文件
dir /opt/redis-7.0.10/myredis
appenddirname "appendonlydir"

# 默认的文件名是appendonly.aof，可以通过appendfilename参数修改
# - appendonly.aof.1.base.rdb as a base file.基础文件
# - appendonly.aof.1.incr.aof, appendonly.aof.2.incr.aof as incremental files.增量文件，写操作命令记录
# - appendonly.aof.manifest as a manifest file.清单文件
appendfilename appendonly.aof

# 写回策略
# appendfsync always
appendfsync everysec
# appendfsync no
```

### 正常恢复

1、启动redis

```shell
127.0.0.1:6379> SHUTDOWN
not connected> quit
[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> 

[root@192 myredis]# ll
total 108
drwxr-xr-x. 2 root root    103 Apr 23 07:51 appendonlydir
drwxr-xr-x. 2 root root     26 Apr 23 07:51 dumpfiles
-rw-r--r--. 1 root root 106580 Apr 23 07:51 redis7.conf
[root@192 myredis]# cd appendonlydir/
[root@192 appendonlydir]# ll
total 8
-rw-r--r--. 1 root root 89 Apr 23 07:51 appendonly.aof.1.base.rdb
-rw-r--r--. 1 root root  0 Apr 23 07:51 appendonly.aof.1.incr.aof
-rw-r--r--. 1 root root 88 Apr 23 07:51 appendonly.aof.manifest
```

2、正常录入`k1,k2,k3`，查看`aof`文件并备份，并删除`RDB`文件排除`rdb`的影响。

```shell
127.0.0.1:6379> set k1 v1
OK
127.0.0.1:6379> set k2 v2
OK

[root@192 myredis]# ll
total 112
drwxr-xr-x. 2 root root    103 Apr 23 07:51 appendonlydir
-rw-r--r--. 1 root root    108 Apr 23 07:53 dump6379.rdb
drwxr-xr-x. 2 root root     26 Apr 23 07:51 dumpfiles
-rw-r--r--. 1 root root 106580 Apr 23 07:51 redis7.conf
[root@192 myredis]# rm -rf dump6379.rdb 
[root@192 myredis]# rm -rf dumpfiles/
[root@192 myredis]# ll
total 108
drwxr-xr-x. 2 root root    103 Apr 23 07:51 appendonlydir
-rw-r--r--. 1 root root 106580 Apr 23 07:51 redis7.conf
[root@192 myredis]# cp -a appendonlydir/ appendonlydir_bak
[root@192 myredis]# ll
total 108
drwxr-xr-x. 2 root root    103 Apr 23 07:51 appendonlydir
drwxr-xr-x. 2 root root    103 Apr 23 07:51 appendonlydir_bak
-rw-r--r--. 1 root root 106580 Apr 23 07:51 redis7.conf
[root@192 myredis]# cd appendonlydir/
[root@192 appendonlydir]# ll
total 12
-rw-r--r--. 1 root root 89 Apr 23 07:51 appendonly.aof.1.base.rdb
-rw-r--r--. 1 root root 81 Apr 23 07:53 appendonly.aof.1.incr.aof
-rw-r--r--. 1 root root 88 Apr 23 07:51 appendonly.aof.manifest
```

3、执行`flushdb`清空，然后删除`rdb`文件，并进行恢复。

```shell
# 执行flushdb
127.0.0.1:6379> flushdb
OK
127.0.0.1:6379> SHUTDOWN
not connected> quit
# 删除rdb文件，排除rdb的干扰
[root@192 myredis]# ll
total 112
drwxr-xr-x. 2 root root    103 Apr 23 07:51 appendonlydir
drwxr-xr-x. 2 root root    103 Apr 23 07:51 appendonlydir_bak
-rw-r--r--. 1 root root     89 Apr 23 08:02 dump6379.rdb
-rw-r--r--. 1 root root 106580 Apr 23 07:51 redis7.conf
[root@192 myredis]# rm -rf dump6379.rdb 
[root@192 myredis]# cd appendonlydir
[root@192 appendonlydir]# ll
total 12
-rw-r--r--. 1 root root 89 Apr 23 07:51 appendonly.aof.1.base.rdb
-rw-r--r--. 1 root root 98 Apr 23 08:02 appendonly.aof.1.incr.aof
-rw-r--r--. 1 root root 88 Apr 23 07:51 appendonly.aof.manifest
# 重启redis，恢复
[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> keys *
(empty array)
```

可见，`flushdb`也是写操作命令，也会写入到`aof`文件中，导致恢复时会恢复到`flushdb`的时候。

4、将`bak`目录恢复，重新恢复

```shell
[root@192 myredis]# mv appendonlydir_bak/ appendonlydir
[root@192 myredis]# ll
total 108
drwxr-xr-x. 2 root root    103 Apr 23 07:51 appendonlydir
-rw-r--r--. 1 root root 106580 Apr 23 07:51 redis7.conf

[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> keys *
1) "k1"
2) "k2"
```

成功。

### 异常恢复

当redis写命令写了一半，redis服务突然down了，这时，aof文件中就会出现一些问题。

1、手动写坏aof文件内容

```shell
$3
set
$2
k4
$2
v4
sadfasdfasdfdasfsadfsdafdsfdgfdhdfh
```

2、重新启动redis

```shell
[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
Could not connect to Redis at 127.0.0.1:6379: Connection refused
not connected> 
```

3、修复`aof`文件

`redis-check-aof --fix appendonly.aof.1.incr.aof `

```shell
[root@192 appendonlydir]# redis-check-aof appendonly.aof.1.incr.aof 
Start checking Old-Style AOF
AOF appendonly.aof.1.incr.aof format error
AOF analyzed: filename=appendonly.aof.1.incr.aof, size=170, ok_up_to=133, ok_up_to_line=32, diff=37
AOF appendonly.aof.1.incr.aof is not valid. Use the --fix option to try fixing it.
[root@192 appendonlydir]# redis-check-aof --fix appendonly.aof.1.incr.aof 
Start checking Old-Style AOF
AOF appendonly.aof.1.incr.aof format error
AOF analyzed: filename=appendonly.aof.1.incr.aof, size=170, ok_up_to=133, ok_up_to_line=32, diff=37
This will shrink the AOF appendonly.aof.1.incr.aof from 170 bytes, with 37 bytes, to 133 bytes
Continue? [y/N]: y
Successfully truncated AOF appendonly.aof.1.incr.aof
```

4、重启redis

```shell
[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> keys *
1) "k4"
2) "k1"
3) "k2"
```

成功。

### 优点

![image-20230423232040318](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230423232040318.png)

### 缺点

![image-20230423232057336](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230423232057336.png)

### 文件重写

既然AOF是通过日志追加的方式来存储redis的写指令，那么当我们对同一个key做多次写操作时，就会产生大量针对同一个key操作的日志指令，导致AOF文件会变得非常大，恢复数据的时候会变得非常慢。因此，redis提供了重写机制来解决这个问题。redis通过重写AOF文件，保存的只是恢复数据的最小指令集。

#### 手动触发重写

`bgrewriteaof`

##### 示例

```shell
127.0.0.1:6379> set k1 11111111111111111111111111111111111
OK
127.0.0.1:6379> set k1 v22
OK
127.0.0.1:6379> BGREWRITEAOF
Background append only file rewriting started

[root@192 appendonlydir]# ll
total 8
-rw-r--r--. 1 root root 53 Apr 23 08:40 appendonly.aof.3.base.aof
-rw-r--r--. 1 root root  0 Apr 23 08:40 appendonly.aof.3.incr.aof
-rw-r--r--. 1 root root 88 Apr 23 08:40 appendonly.aof.manifest

[root@192 appendonlydir]# vi appendonly.aof.3.base.aof 
*2
$6
SELECT
$1
0
*3
$3
SET
$2
k1
$3
v22
```

#### 自动触发重写

配置文件：redis.conf

```shell
auto-aof-rewrite-percentage 100 #当文件的大小达到原先文件大小（上次重写后的文件大小，如果没有重写过，那就是redis服务启动时的文件大小）的两倍。
auto-aof-rewrite-min-size 64mb #文件重写的最小文件大小，即当AOF文件低于64mb时，不会触发重写。【同时满足】
```

##### 示例

1、修改配置，并关闭混合

```shell
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 1kb
aof-use-rdb-preamble no
```

2、去除干扰项

```shell
[root@192 myredis]# ll
total 112
drwxr-xr-x. 2 root root    103 Apr 23 08:13 appendonlydir
-rw-r--r--. 1 root root    115 Apr 23 08:27 dump6379.rdb
-rw-r--r--. 1 root root 106578 Apr 23 08:30 redis7.conf
[root@192 myredis]# rm -rf dump6379.rdb 
[root@192 myredis]# cd appendonlydir/
[root@192 appendonlydir]# ll
total 12
-rw-r--r--. 1 root root  89 Apr 23 07:51 appendonly.aof.1.base.rdb
-rw-r--r--. 1 root root 133 Apr 23 08:16 appendonly.aof.1.incr.aof
-rw-r--r--. 1 root root  88 Apr 23 07:51 appendonly.aof.manifest
[root@192 appendonlydir]# rm -rf *
[root@192 appendonlydir]# ll
total 0
```

3、重新启动redis，查看aof文件

```shell
[root@192 myredis]# redis-server redis7.conf
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> 

[root@192 appendonlydir]# ll
total 4
-rw-r--r--. 1 root root  0 Apr 23 08:31 appendonly.aof.1.base.aof
-rw-r--r--. 1 root root  0 Apr 23 08:31 appendonly.aof.1.incr.aof
-rw-r--r--. 1 root root 88 Apr 23 08:31 appendonly.aof.manifest
```

4、执行`set k1 1`查看`aof`文件是否正常。

```shell
127.0.0.1:6379> set k1 1
OK
127.0.0.1:6379> get k1
"1"

[root@192 appendonlydir]# ll
total 8
-rw-r--r--. 1 root root  0 Apr 23 08:31 appendonly.aof.1.base.aof
-rw-r--r--. 1 root root 51 Apr 23 08:32 appendonly.aof.1.incr.aof
-rw-r--r--. 1 root root 88 Apr 23 08:31 appendonly.aof.manifest
```

5、重复执行`set k1 111111111111111111`操作，直到`aof`文件大小达到1024.

```shell
127.0.0.1:6379> set k1 11111111111111111111111111111111111
OK
127.0.0.1:6379> set k1 11111111111111111111111111111111111
OK
127.0.0.1:6379> set k1 11111111111111111111111111111111111
OK

[root@192 appendonlydir]# ll
total 8
-rw-r--r--. 1 root root   0 Apr 23 08:31 appendonly.aof.1.base.aof
-rw-r--r--. 1 root root 933 Apr 23 08:35 appendonly.aof.1.incr.aof
-rw-r--r--. 1 root root  88 Apr 23 08:31 appendonly.aof.manifest
[root@192 appendonlydir]# cat appendonly.aof.1.incr.aof
……
*3
$3
set
$2
k1
$35
11111111111111111111111111111111111
*3
$3
set
$2
k1
$35
11111111111111111111111111111111111

#继续执行set，查看aof文件
[root@192 appendonlydir]# ll
total 12
-rw-r--r--. 1 root root 86 Apr 23 08:36 appendonly.aof.2.base.aof
-rw-r--r--. 1 root root 86 Apr 23 08:36 appendonly.aof.2.incr.aof
-rw-r--r--. 1 root root 88 Apr 23 08:36 appendonly.aof.manifest
#可见，aof文件变成2了。
```

6、查看`base.aof`的内容

```shell
*2
$6
SELECT
$1
0
*3
$3
SET
$2
k1
$35
11111111111111111111111111111111111
```

只保留了最后一次的命令。

#### 重写流程

（1）bgrewriteaof触发重写，判断是否存在bgsave或者bgrewriteaof正在执行，存在则等待其执行结束再执行；

（2）主进程fork子进程，防止主进程阻塞无法提供服务；

（3）子进程遍历Redis内存快照中数据写入临时AOF文件，同时会将新的写指令写入aof_buf和aof_rewrite_buf两个重写缓冲区，前者是为了写回旧的AOF文件，后者是为了后续刷新到临时AOF文件中，防止快照内存遍历时新的写入操作丢失；

（4）子进程结束临时AOF文件写入后，通知主进程；

（5）主进程会将上面的aof_rewirte_buf缓冲区中的数据写入到子进程生成的临时AOF文件中；

（6）主进程使用临时AOF文件替换旧AOF文件，完成整个重写过程。

![img](https://pic1.zhimg.com/v2-6defb84bad2604344ea06b894b96cfc4_r.jpg)

#### 伪代码

```python
def AOF_REWRITE(tmp_tile_name):
f = create()
# 遍历所有数据库
for db in redisServer.db:
# 如果数据库为空，那么跳过这个数据库
if db.is_empty(): continue
# 写入 SELECT 命令，用于切换数据库
f.write_command("SELECT " + db.number)
# 遍历所有键
for key in db:
# 如果键带有过期时间，并且已经过期，那么跳过这个键
if key.have_expire_time() and key.is_expired(): continue
if key.type == String:
# 用 SET key value 命令来保存字符串键
value = get_value_from_string(key)
f.("SET " + key + value)
elif key.type == List:
# 用 RPUSH key item1 item2 ... itemN 命令来保存列表键
item1, item2, ..., itemN = get_item_from_list(key)
f.("RPUSH " + key + item1 + item2 + ... + itemN)
elif key.type == Set:
# 用 SADD key member1 member2 ... memberN 命令来保存集合键
member1, member2, ..., memberN = get_member_from_set(key)
f.("SADD " + key + member1 + member2 + ... + memberN)
elif key.type == Hash:
# 用 HMSET key field1 value1 field2 value2 ... fieldN valueN 命令来保存哈希键
field1, value1, field2, value2, ..., fieldN, valueN =\
get_field_and_value_from_hash(key)
f.("HMSET " + key + field1 + value1 + field2 + value2 +\
... + fieldN + valueN)
elif key.type == SortedSet:
# 用 ZADD key score1 member1 score2 member2 ... scoreN memberN
# 命令来保存有序集键
score1, member1, score2, member2, ..., scoreN, memberN = \
get_score_and_member_from_sorted_set(key)
f.write_command("ZADD " + key + score1 + member1 + score2 + member2 +\
... + scoreN + memberN)
else:
raise_type_error()
# 如果键带有过期时间，那么用 EXPIREAT key time 命令来保存键的过期时间
if key.have_expire_time():
f.write_command("EXPIREAT " + key + key.expire_time_in_unix_timestamp())
# 关闭文件
f.close()
```

实际为了避免执行命令时造成客户端输入缓冲区溢出，重写程序在处理list hash set zset时，会检查键所包含的元素的个数。

如果元素的数量超过了redis.h/REDIS_AOF_REWRITE_ITEMS_PER_CMD常量的值，那么重写程序会使用多条命令来记录键的值，而不是单使用一条命令。该常量默认值是64，即每条命令设置的元素的个数是最多64个，重写程序使用多条命令实现集合键中元素数量超过64个的键。

## RDB和AOF混合持久化

在同时开启RDB和AOF持久化时，重启只会加载aof文件，不会加载rdb文件。

![image-20230423234709935](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230423234709935.png)

在这种情况下,当redis重启的时候会优先载入AOF文件来恢复原始的数据,
因为在通常情况下AOF文件保存的数据集要比RDB文件保存的数据集要完整.

问题：RDB的数据不实时，同时使用两者时服务器重启也只会找AOF文件。那要不要只使用AOF呢？
建议不要，因为RDB更适合用于备份数据库(AOF在不断变化不好备份)，留着rdb作为一个万一的手段。

### 配置

开启混合方式配置

`aof-use-rdb-preamble yes`

yes表示开启，设置为no表示禁用。

RDB镜像做全量持久化，AOF做增量持久化。

先使用RDB进行快照存储，然后使用AOF持久化记录所有的写操作，当重写策略满足或手动触发重写的时候，将最新的数据存储为新的RDB记录。这样的话，重启服务的时候会从RDB和AOF两部分恢复数据，既保证了数据完整性，又提高了恢复数据的性能。简单来说：混合持久化方式产生的文件一部分是RDB格式，一部分是AOF格式。----》AOF包括了RDB头部+AOF混写。

### 同时关闭RDB和AOF

`save ""`

禁用rdb持久化，可以使用命令save和bgsave生成rdb文件。

`appendonly no`

禁用`aof`持久化模式，可以使用`bgrewriteaof`生成aof文件。



