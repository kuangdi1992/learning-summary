## 常用命令

![image-20230418222706678](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230418222706678.png)

## 常用案例

### keys *

查看当前库所有的key

```shell
127.0.0.1:6379> keys *
1) "k1"
```

### exists key

判断某个key是否存在，存在几个则返回几，不存在则返回0

```shell
127.0.0.1:6379> exists k1
(integer) 1
127.0.0.1:6379> exists k2
(integer) 0
127.0.0.1:6379> EXISTS k1 k2 k3
(integer) 2
```

### type key

查看key的数据类型

```shell
127.0.0.1:6379> SET k2 12
OK
127.0.0.1:6379> type k2
string
127.0.0.1:6379> lpush list 1 2 3
(integer) 3
127.0.0.1:6379> type list
list
```

### del key

删除指定的key数据，存在数据删除则返回1，不存在则返回0.

```shell
127.0.0.1:6379> del list
(integer) 1
127.0.0.1:6379> GET list
(nil)
127.0.0.1:6379> DEL k3
(integer) 0
```

### unlink key

非阻塞删除，仅仅将keys从keyspace元数据中删除，真正的删除会在后续异步中操作。

### ttl key

查看还有多少秒过期，-1表示永不过期（不设置过期时间则为-1），-2表示已过期

### expire key 秒钟

为给定的key设置过期时间

```shell
127.0.0.1:6379> ttl k1
(integer) -1
127.0.0.1:6379> EXPIRE k1 5
(integer) 1
127.0.0.1:6379> ttl k1
(integer) 1
127.0.0.1:6379> ttl k1
(integer) -2
```

### move key dbindex【0-15】

将当前数据库的 key移动到给定的数据库 db 当中

注：Redis自带16个库，默认在0号库

```shell
127.0.0.1:6379> keys *
1) "k1"
2) "list"
3) "k2"
127.0.0.1:6379> move list 2 #将list移动到2号库中
(integer) 1
```

### select dbindex

切换数据库【0-15】，默认为0

```shell
127.0.0.1:6379> select 2 #切换到2号库
OK
127.0.0.1:6379[2]> keys *
1) "list"
```

### dbsize

查看当前数据库key的数量

```shell
127.0.0.1:6379[2]> keys *
1) "list"
127.0.0.1:6379[2]> dbsize
(integer) 1
127.0.0.1:6379[2]> select 0
OK
127.0.0.1:6379> keys *
1) "k1"
2) "k2"
127.0.0.1:6379> dbsize
(integer) 2
```

### flushdb

清空当前库

```shell
127.0.0.1:6379> flushdb
OK
127.0.0.1:6379> keys *
(empty array)
127.0.0.1:6379> select 2
OK
127.0.0.1:6379[2]> keys *
1) "list"
```

### flushall

清空所有库

```shell
127.0.0.1:6379> flushall
OK
127.0.0.1:6379> select 2
OK
127.0.0.1:6379[2]> keys *
(empty array)
```



