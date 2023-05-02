## 介绍

- 可以一次执行多个命令，本质是一组命令的集合。一个事务中的所有命令都会序列化， **按顺序地串行化执行而不会被其他命令插入**
- 一个队列中，一次性、顺序性、排他性的执行一系列命令
- 没有隔离级别的概念，没有脏读、不可重复读等。

## Redis事务和数据库事务

| 单独的隔离操作     | Redis的事务仅仅是保证事务里的操作会被连续独占的执行，redis命令执行是单线程架构，在执行完事务内所有指令前是不可能再去同时执行其他客户端的请求的 |
| ------------------ | ------------------------------------------------------------ |
| 没有隔离级别的概念 | 因为事务提交前任何指令都不会被实际执行，也就不存在”事务内的查询要看到事务里的更新，在事务外查询不能看到”这种问题了 |
| 不保证原子性       | Redis的事务不保证原子性，也就是不保证所有指令同时成功或同时失败，只有决定是否开始执行全部指令的能力，没有执行到一半进行回滚的能力 |
| 排它性             | Redis会保证一个事务内的命令依次执行，而不会被其它命令插入    |

## 基本操作

![image-20230424223152865](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230424223152865.png)

### 正常执行

```shell
MULTI #事务开始
EXEC #执行事务
```

示例

```shell
127.0.0.1:6379> flushdb
OK
127.0.0.1:6379> MULTI #事务开始
OK
127.0.0.1:6379(TX)> set k1 v1
QUEUED
127.0.0.1:6379(TX)> set k2 v2
QUEUED
127.0.0.1:6379(TX)> INCR count
QUEUED
127.0.0.1:6379(TX)> EXEC #执行事务
1) OK
2) OK
3) (integer) 1
127.0.0.1:6379> keys *
1) "k2"
2) "k1"
3) "count"
```

### 放弃事务

```shell
MULTI #事务开始
DISCARD #放弃事务
```

示例

```shell
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379(TX)> set k3 v3
QUEUED
127.0.0.1:6379(TX)> set k4 v4
QUEUED
127.0.0.1:6379(TX)> DISCARD
OK
127.0.0.1:6379> keys *
1) "k2"
2) "k1"
3) "count"
```

### 全体连坐

`在MULTI 和 EXEC 之间有一个**指令语法错误**，所有的命令都不会执行`

```shell
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379(TX)> set k3 33333
QUEUED
127.0.0.1:6379(TX)> set k4 44444
QUEUED
127.0.0.1:6379(TX)> set k5 #语法错误，无法编译通过
# 如果任何一个命令语法错误，Redis会直接返回错误，所有的命令都不会执行
(error) ERR wrong number of arguments for 'set' command
127.0.0.1:6379(TX)> EXEC
(error) EXECABORT Transaction discarded because of previous errors.
127.0.0.1:6379> keys *
1) "k2"
2) "k1"
3) "count"
```

### 错误命令停止

- Redis 不提供事务回滚的功能，`开发者必须在事务执行出错后，自行恢复数据库状态`
- 注意和传统数据库事务区别，不一定要么一起成功要么一起失败

```shell
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379(TX)> set k4 4444
QUEUED
127.0.0.1:6379(TX)> set email kkkkk@kkk.com
QUEUED
127.0.0.1:6379(TX)> INCR email #语法没有错误
QUEUED
127.0.0.1:6379(TX)> EXEC #执行事务
1) OK
2) OK
3) (error) ERR value is not an integer or out of range #报错，对的命令执行了，错误则没有执行，keys *中可以看到
127.0.0.1:6379> keys *
1) "k2"
2) "k1"
3) "count"
4) "k4"
5) "k3"
6) "email"
```

### watch监控

Redis使用Watch 来提供乐观锁定，类似于 CAS（Check-and-Set）

- 悲观锁
  - 认为每次去拿数据都很认为别人会修改，所以每次拿数据的时候都会上锁，这样别人想拿这个数据就会阻塞直到它拿到锁
- 乐观锁
  - 认为每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是`在更新的时候会判断一下在此期间别人有没有去更新这个数据`
  - 策略：提交版本必须 大于 记录当前版本才能执行更新
- CAS
  - check-and-set（JUC中CAS操作相似）

#### watch

初始化`k1`和`balance`两个`key`，先监控，再开启`MULTI`，保证两个`key`变动在同一事务中。

##### 正常执行（`没有加塞和篡改`）

```shell
127.0.0.1:6379> get k1
"abc"
127.0.0.1:6379> get balance
"100"
127.0.0.1:6379> WATCH balance
OK
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379(TX)> set k1 abc2
QUEUED
127.0.0.1:6379(TX)> set balance 110
QUEUED
127.0.0.1:6379(TX)> get k1
QUEUED
127.0.0.1:6379(TX)> get balance
QUEUED
127.0.0.1:6379(TX)> EXEC
1) OK
2) OK
3) "abc2"
4) "110"
```

##### 加塞和篡改

`watch 命令`是一种乐观锁的实现，`Redis` 在修改的时候会检测数据是否被更改，如果更改了，则执行失败。

1、监控当前的`balance`，并开启事务

```shell
127.0.0.1:6379> get balance
"110"
127.0.0.1:6379> WATCH balance
OK
127.0.0.1:6379> MULTI
OK
```

2、打开另一个客户端，修改`balance`的值（加塞篡改）

```shell
[root@192 myredis]# redis-server redis7.conf 
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> set balance 300
OK
```

3、在事务中修改`balance`的值，并执行事务

```shell
127.0.0.1:6379(TX)> set balance 200
QUEUED
127.0.0.1:6379(TX)> set k2 222
QUEUED
127.0.0.1:6379(TX)> EXEC
(nil)
127.0.0.1:6379> get balance
"300"
```

可见，当另一个客户端已经修改`balance`的值之后，再在监控后的事务中修改`balance`的值，会导致事务执行失败。因为数据已经被更改了。

#### unwatch

放弃对键值的监控

1、监控当前的`balance`

```shell
127.0.0.1:6379> WATCH balance
OK
127.0.0.1:6379> get balance
"300"
```

2、在另一个客户端中，修改`balance`的值

```shell
127.0.0.1:6379> set balance 400
OK
127.0.0.1:6379> get balance
"400"
```

3、放弃对`balance`的监控

```shell
127.0.0.1:6379> UNWATCH
OK
```

4、打开事务，修改`balance`的值，并执行事务

```shell
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379(TX)> set balance 500
QUEUED
127.0.0.1:6379(TX)> get balance
QUEUED
127.0.0.1:6379(TX)> EXEC
1) OK
2) "500"
```

#### 小结

- 一旦执行了 exec 之前加的watch监控锁都会被取消掉
- 当客户端连接丢失的时候（比如退出连接），所有东西都会被取消监视







