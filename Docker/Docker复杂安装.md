# 安装mysql主从复制

主从复制原理

## 主从搭建步骤

### 新建主服务器容器实例3307

```shell
[root@192 ~]# docker run -d -p 3307:3306 --privileged=true -v /tmp/mysql-master/log:/var/log/mysql  -v /tmp/mysql-master/data:/var/lib/mysql  -v /tmp/mysql-master/conf:/etc/mysql -e MYSQL_ROOT_PASSWORD=123456 --name mysql-master mysql:5.7
4c4f9d0a09d9848bcb6fa130aa0fbaa063961a2cec115c79935e044ed8bfb5a6
[root@192 ~]# docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                                                  NAMES
4c4f9d0a09d9   mysql:5.7   "docker-entrypoint.s…"   6 seconds ago   Up 4 seconds   33060/tcp, 0.0.0.0:3307->3306/tcp, :::3307->3306/tcp   mysql-master
```

### 进入/tmp/mysql-master/conf新建my.cnf

```shell
[root@192 ~]# cd /tmp/mysql-master/conf/
[root@192 conf]# ll
total 0
[root@192 conf]# vi my.cnf
[root@192 conf]# cat my.cnf 
[mysqld]
#设置server_id，同一局域网中需要唯一
server_id=101 
## 指定不需要同步的数据库名称
binlog-ignore-db=mysql  
## 开启二进制日志功能
log-bin=mall-mysql-bin  
## 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M  
## 设置使用的二进制日志格式（mixed,statement,row）
binlog_format=mixed  
## 二进制日志过期清理时间。默认值为0，表示不自动清理。
expire_logs_days=7  
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062
[root@192 conf]# ll
total 4
-rw-r--r--. 1 root root 685 Apr  8 19:59 my.cnf
```

### 重启master实例

```shell
[root@192 conf]# docker restart mysql-master
mysql-master
[root@192 conf]# docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS          PORTS                                                  NAMES
4c4f9d0a09d9   mysql:5.7   "docker-entrypoint.s…"   6 minutes ago   Up 43 seconds   33060/tcp, 0.0.0.0:3307->3306/tcp, :::3307->3306/tcp   mysql-master
```

### 进入mysql-master容器

```
[root@192 conf]# docker exec -it mysql-master /bin/bash
root@4c4f9d0a09d9:/# 

```

### master容器实例内创建数据同步用户

```shell
root@4c4f9d0a09d9:/# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.36-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
#创建用户
mysql> CREATE USER 'slave'@'%' IDENTIFIED BY '123456';
Query OK, 0 rows affected (0.02 sec)
#为用户授予权限
mysql> GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';
Query OK, 0 rows affected (0.00 sec)
```

### 新建从服务器容器实例3308

```shell
[root@192 ~]# docker run -d -p 3308:3306 --privileged=true -v /tmp/mysql-slave/log:/var/log/mysql  -v /tmp/mysql-slave/data:/var/lib/mysql  -v /tmp/mysql-slave/conf:/etc/mysql -e MYSQL_ROOT_PASSWORD=123456 --name mysql-slave mysql:5.7
cbd7d884994fa8e2d003e26497227369f6897fe157eb2554e20cd989fcb2c465
[root@192 ~]# docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
cbd7d884994f   mysql:5.7   "docker-entrypoint.s…"   37 seconds ago   Up 37 seconds   33060/tcp, 0.0.0.0:3308->3306/tcp, :::3308->3306/tcp   mysql-slave
4c4f9d0a09d9   mysql:5.7   "docker-entrypoint.s…"   15 minutes ago   Up 8 minutes    33060/tcp, 0.0.0.0:3307->3306/tcp, :::3307->3306/tcp   mysql-master
```

### 进入/tmp/mysql-slave/conf新建my.cnf

my.cnf内容如下：

```shell
[mysqld]
## 设置server_id，同一局域网中需要唯一
server_id=102
## 指定不需要同步的数据库名称
binlog-ignore-db=mysql  
## 开启二进制日志功能，以备Slave作为其它数据库实例的Master时使用
log-bin=mall-mysql-slave1-bin  
## 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M  
## 设置使用的二进制日志格式（mixed,statement,row）
binlog_format=mixed  
## 二进制日志过期清理时间。默认值为0，表示不自动清理。
expire_logs_days=7  
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062  
## relay_log配置中继日志
relay_log=mall-mysql-relay-bin  
## log_slave_updates表示slave将复制事件写进自己的二进制日志
log_slave_updates=1  
## slave设置为只读（具有super权限的用户除外）
read_only=1
```

### 修改完配置，重启slave实例

```shell
[root@192 conf]# docker restart mysql-slave
mysql-slave
[root@192 conf]# docker ps 
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
cbd7d884994f   mysql:5.7   "docker-entrypoint.s…"   2 minutes ago    Up 4 seconds    33060/tcp, 0.0.0.0:3308->3306/tcp, :::3308->3306/tcp   mysql-slave
4c4f9d0a09d9   mysql:5.7   "docker-entrypoint.s…"   17 minutes ago   Up 11 minutes   33060/tcp, 0.0.0.0:3307->3306/tcp, :::3307->3306/tcp   mysql-master
```

### 在主数据库中查看主从同步状态

```mysql
mysql> show master status;
+-----------------------+----------+--------------+------------------+-------------------+
| File                  | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+-----------------------+----------+--------------+------------------+-------------------+
| mall-mysql-bin.000001 |      617 |              | mysql            |                   |
+-----------------------+----------+--------------+------------------+-------------------+
1 row in set (0.03 sec)
```

### 进入mysql-slave容器

```shell
[root@192 conf]# docker ps 
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
cbd7d884994f   mysql:5.7   "docker-entrypoint.s…"   2 minutes ago    Up 4 seconds    33060/tcp, 0.0.0.0:3308->3306/tcp, :::3308->3306/tcp   mysql-slave
4c4f9d0a09d9   mysql:5.7   "docker-entrypoint.s…"   17 minutes ago   Up 11 minutes   33060/tcp, 0.0.0.0:3307->3306/tcp, :::3307->3306/tcp   mysql-master

[root@192 conf]# docker exec -it cbd7d884994f /bin/bash
root@cbd7d884994f:/# mysql -uroot -p    
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.36-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

### 在从数据库中配置主从复制

命令：

> ```
> change master to master_host='宿主机ip', master_user='slave', master_password='123456', master_port=3307, master_log_file='mall-mysql-bin.000001', master_log_pos=617, master_connect_retry=30;
> ```
>
> > master_host='宿主机ip'：自己查询主库宿主机的ip
> >
> > master_user='slave'：刚刚你在mysql-master容器实例内创建的用于数据同步的用户名。
> >
> > master_password='123456'：刚刚你在mysql-master容器实例内创建的用于数据同步的用户密码。
> >
> > master_port=3303：主数据库在宿主机上的映射端口号。
> >
> > master_log_file='mall-mysql-bin.000001', master_log_pos=617：根据第四步查询的状态写
> >
> > master_log_file：指定从数据库要复制数据的日志文件，通过查看主数据的状态，获取File参数；
> >
> > master_log_pos：指定从数据库从哪个位置开始复制数据，通过查看主数据的状态，获取Position参数；
> >
> > master_connect_retry：连接失败重试的时间间隔，单位为秒。

```mysql
mysql> change master to master_host='192.168.12.130', master_user='slave', master_password='123456', master_port=3307, master_log_file='mall-mysql-bin.000001', master_log_pos=617, master_connect_retry=30;
Query OK, 0 rows affected, 2 warnings (0.03 sec)
```

### 在从数据库中查看主从同步状态

```mysql
mysql> show slave status \G;
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: 192.168.12.130
                  Master_User: slave
                  Master_Port: 3307
                Connect_Retry: 30
              Master_Log_File: mall-mysql-bin.000001
          Read_Master_Log_Pos: 617
               Relay_Log_File: mall-mysql-relay-bin.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: mall-mysql-bin.000001
             Slave_IO_Running: No #表示还没开始主从同步
            Slave_SQL_Running: No
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 617
              Relay_Log_Space: 154
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: NULL
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 0
                  Master_UUID: 
             Master_Info_File: /var/lib/mysql/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: 
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
1 row in set (0.00 sec)

ERROR: 
No query specified
```

### 在从数据库中开启主从同步

```mysql
mysql> start slave;
Query OK, 0 rows affected (0.01 sec)
```

### 查看从数据库状态

```mysql
mysql> show slave status \G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.12.130
                  Master_User: slave
                  Master_Port: 3307
                Connect_Retry: 30
              Master_Log_File: mall-mysql-bin.000001
          Read_Master_Log_Pos: 617
               Relay_Log_File: mall-mysql-relay-bin.000002
                Relay_Log_Pos: 325
        Relay_Master_Log_File: mall-mysql-bin.000001
             Slave_IO_Running: Yes #表示主从同步启动
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 617
              Relay_Log_Space: 537
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 101
                  Master_UUID: ed28b69e-d681-11ed-bcd3-0242ac110002
             Master_Info_File: /var/lib/mysql/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
1 row in set (0.00 sec)

ERROR: 
No query specified
```

### 主从复制测试

主机master中创建db，表等

```mysql
Query OK, 1 row affected (0.02 sec)

mysql> use db01;
Database changed
mysql> create table kd(id int,name varchar(20));
Query OK, 0 rows affected (0.01 sec)

mysql> insert into kd values(1,'kkk');
Query OK, 1 row affected (0.03 sec)

mysql> select * from kd;
+------+------+
| id   | name |
+------+------+
|    1 | kkk  |
+------+------+
1 row in set (0.00 sec)

```

从机slave中查看：

```mysql
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| db01               |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> use db01;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> select * from kd;
+------+------+
| id   | name |
+------+------+
|    1 | kkk  |
+------+------+
1 row in set (0.00 sec)
```

# 安装redis集群

## 分布式存储

1~2亿条数据需要缓存，如何设计这个存储案例？

单机单台100%不可能，要考虑分布式存储，用Redis如何落地。

- 哈希取余分区

  > 2亿条记录是2亿个key，value，单机肯定是不行的，必须要使用分布式多机。
  >
  > 假设有3台机器构成一个集群，用户每次读写操作都是根据公式hash(key)%N个机器台数，计算出哈希值，用来决定数据映射到哪个节点上。
  >
  > 缺点：原来规划好的节点，进行扩容或缩容就比较麻烦，每次数据变得导致节点有变化，映射关系需要重新进行计算，在服务器个数固定不变时没有问题，如果需要弹性扩容或故障停机的情况下，原来的取模公式就会发生变化。

- 一致性哈希算法分区

  > https://www.cnblogs.com/jajian/p/10896624.html
  >
  > 背景：一致性哈希算法在1997年由麻省理工学院提出的，目标是为了解决分布式缓存数据变动和映射问题，某个机器宕机了，分母数量改变了，自然取余就不行了。

  > 目的：当服务器个数发生变动时，尽量减少影响客户端到服务器的映射关系。

  > - 一致性hash算法：对2的32次方取模，简单来说，一致性hash算法将整个哈希值空间组织成一个虚拟的的圆环（hash环）。
  >
  > - 节点映射：将集群中各个IP节点映射到环上的某一个位置。将各个服务器使用hash进行一个哈希，可以选择服务器的IP或主机名作为关键字进行哈希，这样每台机器就能确定其在哈希环上的位置，例如：4个节点A、B、C、D，经过IP地址的哈希函数计算，使用IP地址哈希后在环空间的位置如下：
  >
  >   ![img](https://pic002.cnblogs.com/images/2011/274814/2011120923354024.png)
  >
  > - 将数据key使用相同的函数Hash计算出哈希值，并确定此数据在环上的位置，从此位置沿环顺时针“行走”，第一台遇到的服务器就是其应该定位到的服务器。例如我们有Object A、Object B、Object C、Object D四个数据对象，经过哈希计算后，在环空间上的位置如下：
  >
  >   ![img](https://pic002.cnblogs.com/images/2011/274814/2011121009134748.png)
  >
  > - 根据一致性哈希算法，数据A会被定为到Node A上，B被定为到Node B上，C被定为到Node C上，D被定为到Node D上。
  >
  > - 下面分析一致性哈希算法的容错性和可扩展性。现假设Node C不幸宕机，可以看到此时对象A、B、D不会受到影响，只有C对象被重定位到Node D。一般的，在一致性哈希算法中，如果一台服务器不可用，则受影响的数据仅仅是此服务器到其环空间中前一台服务器（即沿着逆时针方向行走遇到的第一台服务器）之间数据，其它不会受到影响。即C宕机了，收到影响的只是B、C之间的数据，并且这些数据会转移到D进行存储。

  > 扩展性
  >
  > 如果在系统中增加一台服务器Node X，如下图所示：
  >
  > ![img](https://pic002.cnblogs.com/images/2011/274814/2011121010010787.png)
  >
  > 此时对象Object A、B、D不受影响，只有对象C需要重定位到新的Node X 。一般的，在一致性哈希算法中，如果增加一台服务器，则受影响的数据仅仅是新服务器到其环空间中前一台服务器（即沿着逆时针方向行走遇到的第一台服务器）之间数据，其它数据也不会受到影响。
  >
  > 综上所述，一致性哈希算法对于节点的增减都只需重定位环空间中的一小部分数据，具有较好的容错性和可扩展性。

  > 缺点：数据倾斜问题（节点较少）
  >
  > 例如系统中只有两台服务器，其环分布如下，
  >
  > ![img](https://pic002.cnblogs.com/images/2011/274814/2011121009511640.png)
  >
  > 此时必然造成大量数据集中到Node A上，而只有极少量会定位到Node B上。
  >
  > 解决方法：为了解决这种数据倾斜问题，一致性哈希算法引入了虚拟节点机制，即对每一个服务节点计算多个哈希，每个计算结果位置都放置一个此服务节点，称为虚拟节点。具体做法可以在服务器ip或主机名的后面增加编号来实现。例如上面的情况，可以为每台服务器计算三个虚拟节点，于是可以分别计算 “Node A#1”、“Node A#2”、“Node A#3”、“Node B#1”、“Node B#2”、“Node B#3”的哈希值，于是形成六个虚拟节点：
  >
  > ![img](https://pic002.cnblogs.com/images/2011/274814/2011121009513382.png)

- 哈希槽分区

  > 哈希槽实质上是一个数组，数组[0,2^14-1]形成hash slot空间。
  >
  > 哈希槽主要解决均匀分配的问题，在数据和节点之间又加入了一层，把这一层称为哈希槽(slot),用于管理数据和节点之间的关系。现在就相当于节点上放的是槽，槽里面上的是数据。
  >
  > ![image-20230409163133881](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230409163133881.png)
  >
  > 槽解决的是粒度问题，相当于是把粒度变大了。这样便于数据移动。
  >
  > 哈希解决的是映射问题，使用key的哈希值来计算所对应槽，便于数据分配。

  > hash槽的数量：一个集群中只能有16384个槽，编号为0-16383（0-2^14-1），这些槽会分配给集群中所有的主节点，分配策略没有要求。可以指定哪个编号的槽分配给哪个主节点。集群会记录节点和槽对应的关系。解决了节点和槽的关系后，接下来就需要对key进行hash值计算，然后对16384取余。余数是几，那么key就落入到对应的槽中。slot=CRC16(key)%16384.以槽为单位移动数据，因为槽的数目是固定的，处理起来比较容易，这样数据迁移问题就解决了.

  > 哈希槽的计算
  >
  > Redis集群中内置了16384个哈希槽，Redis会根据节点数量大致均等地将hash槽映射到不同的节点。当需要在集群中放置一个k-v时，Redis先对key使用crc16算法算出一个结果，然后把结果对16834求余数。这样每个key都会对应一个编号，也就会映射到某个节点上。
  >
  > ![image-20230409164425156](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230409164425156.png)

## 3主3从redis集群配置

### 关闭防火墙和启动docker后台服务

```shell
systemctl restart docker
```

### 新建6个docker容器实例

```shell
docker run -d --name redis-node-1 --net host --privileged=true -v /data/redis/share/redis-node-1:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6381
```

```shell
[root@192 ~]# docker run -d --name redis-node-1 --net host --privileged=true -v /data/redis/share/redis-node-1:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6381
e3c27e283b669e9ff613083a0beffc2bcd6296df584e67ff31ed77f5a690c6c6
[root@192 ~]# docker run -d --name redis-node-2 --net host --privileged=true -v /data/redis/share/redis-node-2:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6382
f4a3ddd32c5e2531dff32682b069eb04f358409e05cdb955774f630c0d8a2db9
[root@192 ~]# docker run -d --name redis-node-3 --net host --privileged=true -v /data/redis/share/redis-node-3:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6383
a6bbcde4f5c9ad58e7221870dbb70e5928c87a0211b5166d54976093064124a8
[root@192 ~]# docker run -d --name redis-node-4 --net host --privileged=true -v /data/redis/share/redis-node-4:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6384
667bfe725d07e785dad1c9e6f7c9ad40220992b0f8039d8e4842e2ba88a9802a
[root@192 ~]# docker run -d --name redis-node-5 --net host --privileged=true -v /data/redis/share/redis-node-5:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6385
4cb3e229a4d826b63f1467ca3bfbd4b9f035b33939a0724fcce1d6d7015a3f37
[root@192 ~]# docker run -d --name redis-node-6 --net host --privileged=true -v /data/redis/share/redis-node-6:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6386
a8323872cf577e16182e7af90c0778dbd587d9d36fa86cc15b3a8e3d07609059
[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS     NAMES
a8323872cf57   redis:6.0.8   "docker-entrypoint.s…"   4 seconds ago    Up 4 seconds              redis-node-6
4cb3e229a4d8   redis:6.0.8   "docker-entrypoint.s…"   11 seconds ago   Up 10 seconds             redis-node-5
667bfe725d07   redis:6.0.8   "docker-entrypoint.s…"   11 seconds ago   Up 11 seconds             redis-node-4
a6bbcde4f5c9   redis:6.0.8   "docker-entrypoint.s…"   11 seconds ago   Up 11 seconds             redis-node-3
f4a3ddd32c5e   redis:6.0.8   "docker-entrypoint.s…"   11 seconds ago   Up 11 seconds             redis-node-2
e3c27e283b66   redis:6.0.8   "docker-entrypoint.s…"   12 seconds ago   Up 12 seconds             redis-node-1
```

命令讲解：

- --net host： 使用宿主机的IP和端口，默认
- --privileged=true：获取宿主机root用户权限
- -v /data/redis/share/redis-node-6:/data：容器数据卷，宿主机地址：docker内部地址
- redis:6.0.8：redis镜像和版本号
- --cluster-enabled yes：开启redis集群
- --appendonly yes：开启持久化
- --port 6386：redis端口号

### 进入容器redis-node-1并为6台机器构建集群关系

#### 进入一个容器

```shell
[root@192 ~]# docker exec -it redis-node-1 /bin/bash
root@192:/data# 
```

#### 构建主从关系

```shell
root@192:/data# redis-cli --cluster create 192.168.12.130:6381 192.168.12.130:6382 192.168.12.130:6383 192.168.12.130:6384 192.168.12.130:6385 192.168.12.130:6386 --cluster-replicas 1
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.12.130:6385 to 192.168.12.130:6381
Adding replica 192.168.12.130:6386 to 192.168.12.130:6382
Adding replica 192.168.12.130:6384 to 192.168.12.130:6383
>>> Trying to optimize slaves allocation for anti-affinity
[WARNING] Some slaves are in the same host as their master
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[0-5460] (5461 slots) master
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[5461-10922] (5462 slots) master
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[10923-16383] (5461 slots) master
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   replicates be54e7b0653f908981218365be5f4d63e059a100
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
.
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

#### 查看集群状态

```shell
root@192:/data# 
root@192:/data# redis-cli -p 6381 -c
127.0.0.1:6381> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:1
cluster_stats_messages_ping_sent:89
cluster_stats_messages_pong_sent:91
cluster_stats_messages_sent:180
cluster_stats_messages_ping_received:86
cluster_stats_messages_pong_received:89
cluster_stats_messages_meet_received:5
cluster_stats_messages_received:180
127.0.0.1:6381> cluster nodes
3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386@16386 slave 0917909b9ef1918ca32b9d57ee73aed4ce712d80 0 1681033072459 1 connected
a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384@16384 slave be54e7b0653f908981218365be5f4d63e059a100 0 1681033073466 2 connected
edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385@16385 slave 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 0 1681033071451 3 connected
0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381@16381 myself,master - 0 1681033071000 1 connected 0-5460
be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382@16382 master - 0 1681033072000 2 connected 5461-10922
10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383@16383 master - 0 1681033072000 3 connected 10923-16383
127.0.0.1:6381> 

root@192:/data# redis-cli -p 6381 -c
127.0.0.1:6381> set k1 v1
-> Redirected to slot [12706] located at 192.168.12.130:6383
OK
```

![image-20230409174343927](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230409174343927.png)

#### 查看集群信息

> redis-cli --cluster check 192.168.111.147:6381

示例：

```shell
root@192:/data# redis-cli --cluster check 192.168.12.130:6381
192.168.12.130:6381 (0917909b...) -> 0 keys | 5461 slots | 1 slaves.
192.168.12.130:6382 (be54e7b0...) -> 0 keys | 5462 slots | 1 slaves.
192.168.12.130:6383 (10d3a734...) -> 1 keys | 5461 slots | 1 slaves.
[OK] 1 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

## 主从容错切换迁移案例

### Redis集群主从切换（1号宕机6号上位）

#### 停止主机6381

```shell
#进入主机6381
root@192:/data# redis-cli -p 6381 -c
#查看节点信息
127.0.0.1:6381> cluster nodes
3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386@16386 slave 0917909b9ef1918ca32b9d57ee73aed4ce712d80 0 1681130495479 1 connected
a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384@16384 slave be54e7b0653f908981218365be5f4d63e059a100 0 1681130494472 2 connected
edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385@16385 slave 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 0 1681130496490 3 connected
0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381@16381 myself,master - 0 1681130495000 1 connected 0-5460
be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382@16382 master - 0 1681130494000 2 connected 5461-10922
10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383@16383 master - 0 1681130496000 3 connected 10923-16383

#停止6381主机
[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS        PORTS     NAMES
a8323872cf57   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-6
4cb3e229a4d8   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-5
667bfe725d07   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-4
a6bbcde4f5c9   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-3
f4a3ddd32c5e   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-2
e3c27e283b66   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-1
[root@192 ~]# docker stop redis-node-1
redis-node-1
[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS        PORTS     NAMES
a8323872cf57   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-6
4cb3e229a4d8   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-5
667bfe725d07   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-4
a6bbcde4f5c9   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-3
f4a3ddd32c5e   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours             redis-node-2
```

#### 查看6号机是否上位（集群信息）

```shell
[root@192 ~]# docker exec -it redis-node-2 /bin/bash
root@192:/data# redis-cli -p 6382 -c
127.0.0.1:6382> cluster nodes
edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385@16385 slave 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 0 1681130690342 3 connected
0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381@16381 master,fail - 1681130602361 1681130597235 1 disconnected
a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384@16384 slave be54e7b0653f908981218365be5f4d63e059a100 0 1681130689331 2 connected
be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382@16382 myself,master - 0 1681130689000 2 connected 5461-10922
10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383@16383 master - 0 1681130691352 3 connected 10923-16383
3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386@16386 master - 0 1681130689000 7 connected 0-5460
127.0.0.1:6382> get k1
-> Redirected to slot [12706] located at 192.168.12.130:6383
"v1"
```

问题：这个时候6381宕机了，6386号机上位，那么如果这时6381恢复了，会是什么情况？

```shell
[root@192 ~]# docker start redis-node-1
redis-node-1
[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS         PORTS     NAMES
a8323872cf57   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours              redis-node-6
4cb3e229a4d8   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours              redis-node-5
667bfe725d07   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours              redis-node-4
a6bbcde4f5c9   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours              redis-node-3
f4a3ddd32c5e   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 27 hours              redis-node-2
e3c27e283b66   redis:6.0.8   "docker-entrypoint.s…"   27 hours ago   Up 5 seconds             redis-node-1

192.168.12.130:6383> cluster nodes
3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386@16386 master - 0 1681130882000 7 connected 0-5460
edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385@16385 slave 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 0 1681130882817 3 connected
0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381@16381 slave 3327459caaf963b41570d58c80d28431d28a2b4d 0 1681130884845 7 connected
a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384@16384 slave be54e7b0653f908981218365be5f4d63e059a100 0 1681130884000 2 connected
be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382@16382 master - 0 1681130884000 2 connected 5461-10922
10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383@16383 myself,master - 0 1681130880000 3 connected 10923-16383
#这里可以看出，6386还是master，6381成了slave。
```

#### 还原之前的3主3从

- 启动6381（见上面）

- 宕机6386

  ```shell
  [root@192 ~]# docker stop redis-node-6
  redis-node-6
  192.168.12.130:6383> cluster nodes
  3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386@16386 master,fail - 1681131066551 1681131063491 7 disconnected
  edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385@16385 slave 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 0 1681131081000 3 connected
  0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381@16381 master - 0 1681131080656 8 connected 0-5460
  a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384@16384 slave be54e7b0653f908981218365be5f4d63e059a100 0 1681131082000 2 connected
  be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382@16382 master - 0 1681131082674 2 connected 5461-10922
  10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383@16383 myself,master - 0 1681131082000 3 connected 10923-16383
  ```

- 启动6386

  ```shell
  [root@192 ~]# docker start redis-node-6
  redis-node-6
  192.168.12.130:6383> cluster nodes
  3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386@16386 slave 0917909b9ef1918ca32b9d57ee73aed4ce712d80 0 1681131094268 8 connected
  edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385@16385 slave 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 0 1681131096000 3 connected
  0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381@16381 master - 0 1681131096796 8 connected 0-5460
  a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384@16384 slave be54e7b0653f908981218365be5f4d63e059a100 0 1681131096000 2 connected
  be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382@16382 master - 0 1681131096000 2 connected 5461-10922
  10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383@16383 myself,master - 0 1681131095000 3 connected 10923-16383
  ```

- 查看集群信息

  ```shell
  root@192:/data# redis-cli --cluster check 192.168.12.130:6381
  192.168.12.130:6381 (0917909b...) -> 0 keys | 5461 slots | 1 slaves.
  192.168.12.130:6382 (be54e7b0...) -> 0 keys | 5462 slots | 1 slaves.
  192.168.12.130:6383 (10d3a734...) -> 1 keys | 5461 slots | 1 slaves.
  [OK] 1 keys in 3 masters.
  0.00 keys per slot on average.
  >>> Performing Cluster Check (using node 192.168.12.130:6381)
  M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
     slots:[0-5460] (5461 slots) master
     1 additional replica(s)
  S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
     slots: (0 slots) slave
     replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
  M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
     slots:[5461-10922] (5462 slots) master
     1 additional replica(s)
  M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
     slots:[10923-16383] (5461 slots) master
     1 additional replica(s)
  S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
     slots: (0 slots) slave
     replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
  S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
     slots: (0 slots) slave
     replicates be54e7b0653f908981218365be5f4d63e059a100
  [OK] All nodes agree about slots configuration.
  >>> Check for open slots...
  >>> Check slots coverage...
  [OK] All 16384 slots covered.
  ```

## 主从扩容案例

述求：3主3从扩容到4主4从，加入6387主机和6388从机，涉及槽位变更和主机添加。

#### 新建6387、6388两个节点并启动

```shell
[root@192 ~]# docker run -d --name redis-node-7 --net host --privileged=true -v /data/redis/share/redis-node-7:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6387
da01544be827ba87c00e1de54ebe88cd03f9b58397f35ae41bea4405e1d4d4a1
[root@192 ~]# docker run -d --name redis-node-8 --net host --privileged=true -v /data/redis/share/redis-node-8:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6388
5076046b9fe0a6d9e092f7c6e7236b61476601ded8913d17c7d11abaa2ad27f3
[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS          PORTS     NAMES
5076046b9fe0   redis:6.0.8   "docker-entrypoint.s…"   3 seconds ago   Up 2 seconds              redis-node-8
da01544be827   redis:6.0.8   "docker-entrypoint.s…"   5 seconds ago   Up 4 seconds              redis-node-7
a8323872cf57   redis:6.0.8   "docker-entrypoint.s…"   28 hours ago    Up 9 minutes              redis-node-6
4cb3e229a4d8   redis:6.0.8   "docker-entrypoint.s…"   28 hours ago    Up 28 hours               redis-node-5
667bfe725d07   redis:6.0.8   "docker-entrypoint.s…"   28 hours ago    Up 28 hours               redis-node-4
a6bbcde4f5c9   redis:6.0.8   "docker-entrypoint.s…"   28 hours ago    Up 28 hours               redis-node-3
f4a3ddd32c5e   redis:6.0.8   "docker-entrypoint.s…"   28 hours ago    Up 28 hours               redis-node-2
e3c27e283b66   redis:6.0.8   "docker-entrypoint.s…"   28 hours ago    Up 13 minutes             redis-node-1
```

#### 进入6387容器实例内部

```
[root@192 ~]# docker exec -it redis-node-7 /bin/bash
root@192:/data# 
```

#### 将新增6387节点（空槽号）作为master节点加入原集群

命令：

```shell
redis-cli --cluster add-node 实际IP地址:6387 实际IP地址:6381
```

其中，6387是作为master的新增节点，6381就是原来集群节点里的领路人。

实例：

```shell
root@192:/data# redis-cli --cluster add-node 192.168.12.130:6387 192.168.12.130:6381
>>> Adding node 192.168.12.130:6387 to cluster 192.168.12.130:6381
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.12.130:6387 to make it join the cluster.
[OK] New node added correctly.
```

#### 检查集群情况

```shell
root@192:/data# redis-cli --cluster check 192.168.12.130:6381
192.168.12.130:6381 (0917909b...) -> 0 keys | 5461 slots | 1 slaves.
192.168.12.130:6387 (7341270d...) -> 0 keys | 0 slots | 0 slaves.
192.168.12.130:6382 (be54e7b0...) -> 0 keys | 5462 slots | 1 slaves.
192.168.12.130:6383 (10d3a734...) -> 1 keys | 5461 slots | 1 slaves.
[OK] 1 keys in 4 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
   slots: (0 slots) master
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.#4个M
```

#### 重新分配槽位号

命令：

```
redis-cli --cluster reshard IP地址:端口号
```

实例：

```shell
root@192:/data# redis-cli --cluster reshard 192.168.12.130:6381
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
   slots: (0 slots) master
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 4096 #16384/主节点数
What is the receiving node ID? 7341270d98523556b87b8566a93b38ca38fd43fb #这里的ID是新添加的主节点主机的ID号
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1: all #这里选择全部分配

Ready to move 4096 slots.
  Source nodes:
    M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
       slots:[0-5460] (5461 slots) master
       1 additional replica(s)
    M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
       slots:[5461-10922] (5462 slots) master
       1 additional replica(s)
    M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
       slots:[10923-16383] (5461 slots) master
       1 additional replica(s)
  Destination node:
    M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
       slots: (0 slots) master
  Resharding plan:
    Moving slot 5461 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5462 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5463 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5464 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5465 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5466 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5467 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5468 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5469 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5470 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5471 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5472 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5473 from be54e7b0653f908981218365be5f4d63e059a100
    Moving slot 5474 from be54e7b0653f908981218365be5f4d63e059a100
```

#### 检查集群情况

```shell
root@192:/data# redis-cli --cluster check 192.168.12.130:6381
192.168.12.130:6381 (0917909b...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6387 (7341270d...) -> 0 keys | 4096 slots | 0 slaves.
192.168.12.130:6382 (be54e7b0...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6383 (10d3a734...) -> 1 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 4 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

可以看到6387主机分配了4096个槽位。

注意：重新分配成本太高，因此前三个各自出一部分，所以6387为[0-1364],[5461-6826],[10923-12287]。

#### 主节点6387分配从节点6388

命令：

```
redis-cli --cluster add-node ip:新slave端口 ip:新master端口 --cluster-slave --cluster-master-id 新master主机节点ID
```

实例：

```shell
root@192:/data# redis-cli --cluster add-node 192.168.12.130:6388 192.168.12.130:6387 --cluster-slave --cluster-master-id 7341270d98523556b87b8566a93b38ca38fd43fb
>>> Adding node 192.168.12.130:6388 to cluster 192.168.12.130:6387
>>> Performing Cluster Check (using node 192.168.12.130:6387)
M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.12.130:6388 to make it join the cluster.
Waiting for the cluster to join

>>> Configure node as replica of 192.168.12.130:6387.
[OK] New node added correctly.
```

#### 检查集群情况

```
root@192:/data# redis-cli --cluster check 192.168.12.130:6381
192.168.12.130:6381 (0917909b...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6387 (7341270d...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6382 (be54e7b0...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6383 (10d3a734...) -> 1 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 4 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
   1 additional replica(s)
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
S: ac96d7c270afda6f62ddab4315ccef409f99df0e 192.168.12.130:6388
   slots: (0 slots) slave
   replicates 7341270d98523556b87b8566a93b38ca38fd43fb
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

### 主从缩容案例

述求：删除6387和6388，恢复3主3从，问题：槽位重新分配问题？

#### 清除6388从节点（必须从从节点开始）

命令：

```
redis-cli --cluster del-node ip:从机端口 从机节点ID（从集群情况中获取）
```

实例：

```shell
root@192:/data# redis-cli --cluster del-node 192.168.12.130:6388 ac96d7c270afda6f62ddab4315ccef409f99df0e
>>> Removing node ac96d7c270afda6f62ddab4315ccef409f99df0e from cluster 192.168.12.130:6388
>>> Sending CLUSTER FORGET messages to the cluster...
>>> Sending CLUSTER RESET SOFT to the deleted node.
```

```shell
root@192:/data# redis-cli --cluster check 192.168.12.130:6381
192.168.12.130:6381 (0917909b...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6387 (7341270d...) -> 0 keys | 4096 slots | 0 slaves.
192.168.12.130:6382 (be54e7b0...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6383 (10d3a734...) -> 1 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 4 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

#### 将从机槽号清空，重新分配

本例中将清空的槽号分配给6381

```shell
root@192:/data# redis-cli --cluster reshard 192.168.12.130:6381
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 4096 #表示多少个槽位要重新分配
What is the receiving node ID? 0917909b9ef1918ca32b9d57ee73aed4ce712d80 #表示用哪一个节点来接收重新分配的槽位，这里我们就使用6381节点来接收
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1: 7341270d98523556b87b8566a93b38ca38fd43fb #表示哪个节点的槽位要重新分配，这里填写我们需要删除的6387主机ID
Source node #2: done

Ready to move 4096 slots.
  Source nodes:
    M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
       slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
  Destination node:
    M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
       slots:[1365-5460] (4096 slots) master
       1 additional replica(s)
  Resharding plan:
    Moving slot 0 from 7341270d98523556b87b8566a93b38ca38fd43fb
    Moving slot 1 from 7341270d98523556b87b8566a93b38ca38fd43fb
    Moving slot 2 from 7341270d98523556b87b8566a93b38ca38fd43fb
Do you want to proceed with the proposed reshard plan (yes/no)? yes
Moving slot 0 from 192.168.12.130:6387 to 192.168.12.130:6381: 
Moving slot 1 from 192.168.12.130:6387 to 192.168.12.130:6381: 
Moving slot 2 from 192.168.12.130:6387 to 192.168.12.130:6381: 
Moving slot 3 from 192.168.12.130:6387 to 192.168.12.130:6381: 
```

#### 查看集群情况

```shell
root@192:/data# redis-cli --cluster check 192.168.12.130:6381
192.168.12.130:6381 (0917909b...) -> 0 keys | 8192 slots | 1 slaves.
192.168.12.130:6387 (7341270d...) -> 0 keys | 0 slots | 0 slaves.
192.168.12.130:6382 (be54e7b0...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6383 (10d3a734...) -> 1 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 4 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[0-6826],[10923-12287] (8192 slots) master
   1 additional replica(s)
M: 7341270d98523556b87b8566a93b38ca38fd43fb 192.168.12.130:6387
   slots: (0 slots) master
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

#### 删除主机6387

```shell
root@192:/data# redis-cli --cluster del-node 192.168.12.130:6387 7341270d98523556b87b8566a93b38ca38fd43fb（主机ID）
>>> Removing node 7341270d98523556b87b8566a93b38ca38fd43fb from cluster 192.168.12.130:6387
>>> Sending CLUSTER FORGET messages to the cluster...
>>> Sending CLUSTER RESET SOFT to the deleted node.

root@192:/data# redis-cli --cluster check 192.168.12.130:6381
192.168.12.130:6381 (0917909b...) -> 0 keys | 8192 slots | 1 slaves.
192.168.12.130:6382 (be54e7b0...) -> 0 keys | 4096 slots | 1 slaves.
192.168.12.130:6383 (10d3a734...) -> 1 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.12.130:6381)
M: 0917909b9ef1918ca32b9d57ee73aed4ce712d80 192.168.12.130:6381
   slots:[0-6826],[10923-12287] (8192 slots) master
   1 additional replica(s)
S: 3327459caaf963b41570d58c80d28431d28a2b4d 192.168.12.130:6386
   slots: (0 slots) slave
   replicates 0917909b9ef1918ca32b9d57ee73aed4ce712d80
M: be54e7b0653f908981218365be5f4d63e059a100 192.168.12.130:6382
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
M: 10d3a734ae6b58a6d16d8700cb6dc1185a07f406 192.168.12.130:6383
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
S: edbd4d1624901c6bf81280907f7058f64860c6d9 192.168.12.130:6385
   slots: (0 slots) slave
   replicates 10d3a734ae6b58a6d16d8700cb6dc1185a07f406
S: a80aa20ddf67ee899d62a24afa769c5f36f0e004 192.168.12.130:6384
   slots: (0 slots) slave
   replicates be54e7b0653f908981218365be5f4d63e059a100
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

