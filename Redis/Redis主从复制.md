# 介绍

主从复制，`master`以写为主，`slave`以读为主。

当`master`数据变化的时候，自动将新的数据异步同步到其他`slave`数据库。

## 作用

`读写分类`

`容灾备份`

`数据备份`

`水平扩容支持高并发`

## 配置及基本命令

# 实例

`环境要求`：一个`Master`，两个`Slave`——3台虚拟机，每台都安装`redis`

### 主机`master`配置

将redis压缩包中原装的配置文件拷贝一份，命令如下：

`cp redis.conf ./myredis/redis6379.conf`

实际配置：

```shell
# 开启daemonize yes
daemonize yes

# 注释掉bind 127.0.0.1
bind 127.0.0.1 -::1

#配置protected-mode no 关闭保护模式
protected-mode no

#指定端口
port 6379

#指定当前工作目录 dir
dir /opt/redis-7.0.10/myredis

#指定pid文件名字 pidfile 
pidfile /var/run/redis_6379.pid #可用默认

#指定log文件名字 logfile
logfile "/opt/redis-7.0.10/myredis/6379.log"

#配置requirepass 需要密码登录
requirepass 1

#指定dump.rdb名字，加上端口号
dbfilename dump6379.rdb

#指定aof文件名字 appendfilename（可选）
appendonly no 
```

### 从机`slave`配置

根据`master`主机的配置进行修改，并且添加下面的配置：

```shell
#replicaof masterip masterport
replicaof 192.168.12.131 6379

#masterauth masterpassword
masterauth "1"
```

将主从机上的配置弄好后，就可以开始启动`redis`了，但是启动是有顺序的。

### 依次启动

```shell
#master
redis-server redis6379.conf
redis-cli -a 1
#slave1
redis-server redis6380.conf
redis-cli -a 1 -p 6380
#slave2
redis-server redis6381.conf
redis-cli -a 1 -p 6381
```

### 主从关系查看

#### 查看日志

查看主机的`redis.log`日志

```shell
# 主机日志
65163:M 26 Apr 2023 08:16:52.555 # Diskless rdb transfer, done reading from pipe, 1 replicas still up.
65163:M 26 Apr 2023 08:16:52.574 * Background RDB transfer terminated with success
65163:M 26 Apr 2023 08:16:52.574 * Streamed RDB transfer with replica 192.168.12.132:6380 succeeded (socket). Waiting for REPLCONF ACK from slave to enable streaming
65163:M 26 Apr 2023 08:16:52.574 * Synchronization with replica 192.168.12.132:6380 succeeded
# 从机日志
61584:S 28 Apr 2023 08:10:46.548 * Connecting to MASTER 192.168.12.131:6379
61584:S 28 Apr 2023 08:10:46.548 * MASTER <-> REPLICA sync started
61584:S 28 Apr 2023 08:10:46.548 * Non blocking connect for SYNC fired the event.
61584:S 28 Apr 2023 08:10:46.549 * Master replied to PING, replication can continue...
61584:S 28 Apr 2023 08:10:46.549 * Partial resynchronization not possible (no cached master)
61584:S 28 Apr 2023 08:10:50.910 * Full resync from master: fe04bfd1299c64c6ea5e58754a224cdfc0944c0b:46536
61584:S 28 Apr 2023 08:10:50.912 * MASTER <-> REPLICA sync: receiving streamed RDB from master with EOF to disk
61584:S 28 Apr 2023 08:10:50.912 * MASTER <-> REPLICA sync: Flushing old data
61584:S 28 Apr 2023 08:10:50.912 * MASTER <-> REPLICA sync: Loading DB in memory
61584:S 28 Apr 2023 08:10:50.912 * Loading RDB produced by version 7.0.10
61584:S 28 Apr 2023 08:10:50.912 * RDB age 7 seconds
61584:S 28 Apr 2023 08:10:50.912 * RDB memory usage when created 1.02 Mb
61584:S 28 Apr 2023 08:10:50.913 * Done loading RDB, keys loaded: 6, keys expired: 0.
61584:S 28 Apr 2023 08:10:50.913 * MASTER <-> REPLICA sync: Finished with success
```

#### 命令查看

命令：`info replication`

```shell
# 主机命令
127.0.0.1:6379> info replication
# Replication
role:master
connected_slaves:2
slave0:ip=192.168.12.132,port=6380,state=online,offset=46550,lag=0
slave1:ip=192.168.12.133,port=6381,state=online,offset=46550,lag=0
master_failover_state:no-failover
master_replid:fe04bfd1299c64c6ea5e58754a224cdfc0944c0b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:46550
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:46550
# 从机命令
127.0.0.1:6381> info replication
# Replication
role:slave
master_host:192.168.12.131
master_port:6379
master_link_status:up
master_last_io_seconds_ago:0
master_sync_in_progress:0
slave_read_repl_offset:46606
slave_repl_offset:46606
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:fe04bfd1299c64c6ea5e58754a224cdfc0944c0b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:46606
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:46537
repl_backlog_histlen:70
```

### 主从问题演示

1、从机是否可以执行写命令？

```shell
127.0.0.1:6381> set k2 333
(error) READONLY You can't write against a read only replica.
```

答：从机不可以执行写命令。

2、主机`shutdown`后，从机会上位吗？

答：从机不会上位，主机`shutdown`后，从机原地待命，数据可以正常使用，等待主机重新启动。

```shell
#master shutdown
127.0.0.1:6379> shutdown
(0.65s)
not connected> quit
#slave1
127.0.0.1:6380> info replication
# Replication
role:slave
master_host:192.168.12.131
master_port:6379
master_link_status:down
master_last_io_seconds_ago:-1
master_sync_in_progress:0
slave_read_repl_offset:48450
slave_repl_offset:48450
master_link_down_since_seconds:21
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:fe04bfd1299c64c6ea5e58754a224cdfc0944c0b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:48450
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1107
repl_backlog_histlen:47344
#slave2
127.0.0.1:6381> info replication
# Replication
role:slave
master_host:192.168.12.131
master_port:6379
master_link_status:down
master_last_io_seconds_ago:-1
master_sync_in_progress:0
slave_read_repl_offset:48450
slave_repl_offset:48450
master_link_down_since_seconds:380
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:fe04bfd1299c64c6ea5e58754a224cdfc0944c0b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:48450
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:47601
repl_backlog_histlen:850
```

可以看到，主机`shutdown`后，两个从机的链接状态都是`down`的。

3、主机`shutdown`后，重启后主从关系还在吗？从机还能正常顺利复制吗？

答：重启后主从关系还在，可以正常顺利复制。

4、某台从机`down`后，`master`继续，从机重启后能跟上吗？

答：第一次启动的时候，会从头复制，后续会跟随，master写，slave复制。

5、`slave`是从头开始复制，还是从切入点开始复制？

答：第一次启动的时候，会从头复制，后续会跟随，master写，slave复制。

# 命令操作手动指定

#### 去掉从属关系

- 去掉配置文件中配置的从属关系

```shell
# replicaof <masterip> <masterport>
# replicaof 192.168.12.131 6379

# 重新启动slave
127.0.0.1:6381> info replication
# Replication
role:master
connected_slaves:0
master_failover_state:no-failover
master_replid:020d930711b48ae3cf2645b53756144c0d5b096a
master_replid2:5b1a61681e5735ba160e8f61d47b36a84c156aae
master_repl_offset:48880
second_repl_offset:48881
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:48881
repl_backlog_histlen:0
```

可以看到slave变成了master，那么现在三台机器都是主机。

- 在从机上执行如下命令：

  `slaveof no one`

在其中一台主机上执行`slaveof`命令，改为从机。

`slaveof  新主库IP 新主库端口`**临时命令，重启失效**

示例：

```shell
127.0.0.1:6380> get list
(nil)
127.0.0.1:6380> slaveof 192.168.12.131 6379
OK
127.0.0.1:6380> info replication
# Replication
role:slave
master_host:192.168.12.131
master_port:6379
master_link_status:up
master_last_io_seconds_ago:5
master_sync_in_progress:0
slave_read_repl_offset:48894
slave_repl_offset:48894
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:7e34ac9058f5e7d9fe4275036c76abffcb444785
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:48894
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:48895
repl_backlog_histlen:0
```

#### 小总结

- 使用`redis.conf`配置文件，持久稳定生效，不会随着主机重启失效
- 使用`slaveof`等命令，当次生效，重启失效

# 原理

- slave启动，同步初次请求
  - slave启动成功连接到master后会发送一个sync命令
  - slave首次全新连接master，一次完全同步（全量复制）将被自动执行，slave自身原有数据会被master数据覆盖清除
- 首次连接，全量复制
  - master节点收到sync命令后会在后台开始保存快照（即RDB持久化，主从复制会触发RDB），同时收集所有接收到的用于修改数据集命令缓存起来，master节点执行RDB持久化后，master将rdb快照文件和缓存的命令发送到所有slave，已完成一次完全同步
  - 而slave服务在接收到数据库文件数据后，将其存盘并加载到内存中，从而完成复制初始化
- 心跳持续，保持通信
  - repl-ping-replica-period 10
  - master发出PING包的周期，默认是10秒
- 进入平稳，增量复制
  - master 继续将新的所有收集到的修改命令自动一次传给slave，完成同步
- 从机下线，重连续传
  - master 会检查backlog里面的offset，master和slave都会保存一个复制的offset怀有一个masterId
  - offset 是保存在backlog 中的。master只会把已经复制的offset后面的数据赋值给slave，类似断电续传

# 缺点

复制延时，信号衰减

1. 由于所有的写操作都是先在Master上操作，然后同步更新到Slave上，所以从Master同步到Slave机器有一定的延迟，当系统很繁忙的时候，延迟问题会更加严重，Slave机器数量的增加也会使这个问题更加严重。
2. master挂了之后，默认情况下不会在slave节点自动重选一个master，需要人工干预

# 问题

```shell
[root@192 myredis]# redis-server redis6380.conf 
64598:C 26 Apr 2023 08:00:39.036 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
64598:C 26 Apr 2023 08:00:39.036 # Redis version=7.0.10, bits=64, commit=00000000, modified=0, pid=64598, just started
64598:C 26 Apr 2023 08:00:39.036 # Configuration loaded
64598:S 26 Apr 2023 08:00:39.037 * Increased maximum number of open files to 10032 (it was originally set to 1024).
64598:S 26 Apr 2023 08:00:39.037 * monotonic clock: POSIX clock_gettime
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 7.0.10 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                  
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 64598
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           https://redis.io       
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

64598:S 26 Apr 2023 08:00:39.038 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
64598:S 26 Apr 2023 08:00:39.038 # Server initialized
64598:S 26 Apr 2023 08:00:39.038 # WARNING Memory overcommit must be enabled! Without it, a background save or replication may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
64598:S 26 Apr 2023 08:00:39.038 * Loading RDB produced by version 7.0.10
64598:S 26 Apr 2023 08:00:39.038 * RDB age 62 seconds
64598:S 26 Apr 2023 08:00:39.039 * RDB memory usage when created 0.91 Mb
64598:S 26 Apr 2023 08:00:39.039 * Done loading RDB, keys loaded: 0, keys expired: 0.
64598:S 26 Apr 2023 08:00:39.039 * DB loaded from disk: 0.000 seconds
64598:S 26 Apr 2023 08:00:39.039 * Ready to accept connections
64598:S 26 Apr 2023 08:00:39.039 * Connecting to MASTER 192.168.12.131:6379
64598:S 26 Apr 2023 08:00:39.040 * MASTER <-> REPLICA sync started
64598:S 26 Apr 2023 08:00:39.040 # Error condition on socket for SYNC: No route to host
```

解决方法：

关闭主机防火墙

` systemctl stop firewalld`

# 防火墙配置

```shell
启动： systemctl start firewalld
关闭： systemctl stop firewalld
查看状态： systemctl status firewalld 
开机禁用  ： systemctl disable firewalld
开机启用  ： systemctl enable firewalld
    
添加 ：firewall-cmd --zone=public --add-port=80/tcp --permanent    （--permanent永久生效，没有此参数重启后失效）
重新载入： firewall-cmd --reload
查看： firewall-cmd --zone= public --query-port=80/tcp
删除： firewall-cmd --zone= public --remove-port=80/tcp --permanent
```



