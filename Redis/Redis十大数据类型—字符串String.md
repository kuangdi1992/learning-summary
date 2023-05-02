## 介绍

![image-20230418220855108](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230418220855108.png)

### 获取命令地址

英文：https://redis.io/commands/

中文：http://www.redis.cn/commands.html

## 字符串(string)

字符串是一种最基本的Redis值类型。Redis字符串是二进制安全的，这意味着一个Redis字符串能包含任意类型的数据，例如： 一张JPEG格式的图片或者一个序列化的Ruby对象。

一个字符串类型的值最多能存储512M字节的内容。

`单值单value`

可以用Redis字符串做许多，例如：

- 利用INCR命令簇（[INCR](http://www.redis.cn/commands/incr.html), [DECR](http://www.redis.cn/commands/decr.html), [INCRBY](http://www.redis.cn/commands/incrby)）来把字符串当作原子计数器使用。
- 使用[APPEND](http://www.redis.cn/commands/append.html)命令在字符串后添加内容。
- 将字符串作为[GETRANGE](http://www.redis.cn/commands/getrange.html) 和 [SETRANGE](http://www.redis.cn/commands/setrange.html)的随机访问向量。
- 在小空间里编码大量数据，或者使用 [GETBIT](http://www.redis.cn/commands/getbit.html) 和 [SETBIT](http://www.redis.cn/commands/setbit.html)创建一个Redis支持的Bloom过滤器。

### 常用命令

![image-20230418225108569](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230418225108569.png)

![image-20230418225120448](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230418225120448.png)

### 常用案例

#### SET

`set key value [NX|XX] [GET] [EX seconds|PX milliseconds|EXAT unix-time-seconds|PXAT unix-time-milliseconds|KEEPTTL]`

![image-20230418225324285](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230418225324285.png)

##### [NX|XX]

```shell
127.0.0.1:6379> SET k1 v1 nx #键不存在时设置键值
OK
127.0.0.1:6379> get k1
"v1"
127.0.0.1:6379> set k1 v1 nx #键存在了，返回nil
(nil)
127.0.0.1:6379> set k1 v1ss xx #键存在时设置键值
OK
127.0.0.1:6379> set k1 v1ss xx
OK
127.0.0.1:6379> set k1 v1ss xx
OK
127.0.0.1:6379> keys *
1) "k1"
127.0.0.1:6379> get k1
"v1ss"
```

##### [GET]

```shell
127.0.0.1:6379> set k1 v1 get #先返回键原本的值，然后将新的值写入
"v1ss"
127.0.0.1:6379> get k1
"v1"
```

##### [EX]

```shell
127.0.0.1:6379> set k1 v1 EX 30
OK
127.0.0.1:6379> TTL k1
(integer) 23
127.0.0.1:6379> TTL k1
(integer) 21
```

##### [KEEPTTL]

```shell
127.0.0.1:6379> set k1 v1 EX 30 #设置过期时间为30
OK
127.0.0.1:6379> TTL k1
(integer) 23
127.0.0.1:6379> TTL k1
(integer) 21
127.0.0.1:6379> set k1 v11 #重新设置后，变成默认，永不过期，如果需要将过期时间延续的话，需要用到keepttl
OK
127.0.0.1:6379> TTL k1
(integer) -1
127.0.0.1:6379> set k1 v1 ex 60
OK
127.0.0.1:6379> ttl k1
(integer) 58
127.0.0.1:6379> set k1 v11 keepttl
OK
127.0.0.1:6379> ttl k1
(integer) 47
127.0.0.1:6379> get k1
"v11"

```

#### MSET

`MSET key value [key value ....]`

```
127.0.0.1:6379> MSET k1 v1 k2 v2
OK
```

#### MGET

`MGET key [key ....]`

```shell
127.0.0.1:6379> MGET k1 k2
1) "v1"
2) "v2"
```

#### MSETNX

`MSETNX key value [key value ...]`

同时设置一个或多个 key-value 对，当且仅当所有给定 key 都不存在。

```shell
127.0.0.1:6379> MSET k1 v1 k2 v2
OK
127.0.0.1:6379> MGET k1 k2
1) "v1"
2) "v2"
127.0.0.1:6379> MSETNX k1 v1 k3 v3 #因为k1已经存在，所以该命令失败，k3没有
(integer) 0
127.0.0.1:6379> get k3
(nil)
127.0.0.1:6379> MSETNX k3 v3 k4 v4 #当且仅当所有的key都不存在时该命令才成功
(integer) 1
127.0.0.1:6379> get k3
"v3"
```

#### GETRANGE

`GETRANGE key start end`

获取指定区间范围内的值，类似between......and的关系
`从零到负一表示全部`

```shell
127.0.0.1:6379> set k5 abcdefg
OK
127.0.0.1:6379> GETRANGE k5 0 -1
"abcdefg"
127.0.0.1:6379> GETRANGE k5 0 2
"abc"
127.0.0.1:6379> GETRANGE k5 1 4
"bcde"
```

#### SETRANGE

`SETRANGE key offset value`

设置指定区间范围内的值，格式是setrange key值 具体值

```shell
127.0.0.1:6379> get k5
"abcdefg"
127.0.0.1:6379> SETRANGE k5 2 kuangdi
(integer) 9
127.0.0.1:6379> get k5
"abkuangdi"
```

#### INCR 

`INCR key`

只有数字才能进行加

```shell
127.0.0.1:6379> set k6 100
OK
127.0.0.1:6379> get k6
"100"
127.0.0.1:6379> INCR k6
(integer) 101
127.0.0.1:6379> get k6
"101"
```

#### INCRBY

`INCRBY key increment`

增加指定的整数

```shell
127.0.0.1:6379> get k6
"101"
127.0.0.1:6379> INCRBY k6 100
(integer) 201
127.0.0.1:6379> get k6
"201"
```

#### DECR

`DECR key`

只有数字才能进行减

```shell
127.0.0.1:6379> get k6
"201"
127.0.0.1:6379> DECR k6
(integer) 200
127.0.0.1:6379> get k6
"200"
```

#### DECRBY

`DECRBY key decrement`

减少指定的整数

```shell
127.0.0.1:6379> get k6
"200"
127.0.0.1:6379> DECRBY k6 100
(integer) 100
127.0.0.1:6379> get k6
"100"
```

#### SETNX

`SETNX key value`

不存在就插入

```shell
127.0.0.1:6379> setnx k7 200
(integer) 1
127.0.0.1:6379> setnx k6 200
(integer) 0
127.0.0.1:6379> get k6
"100"
127.0.0.1:6379> get k7
"200"
```

#### SETEX

`SETEX key seconds value`

相当于：

`SET key value EX seconds`

设置值并设置过期时间

```shell
127.0.0.1:6379> SETEX k9 60 v9
OK
127.0.0.1:6379> ttl k9
(integer) 56
```

### 应用场景

#### 缓存对象

使用 String 来缓存对象有两种方式：

- 直接缓存整个对象的 JSON，命令例子：`SET user:1 '{"name":"xiaolin", "age":18}'`。
- 采用将 key 进行分离为 user:ID:属性，采用 MSET 存储，用 MGET 获取各属性值，命令例子：`MSET user:1:name xiaolin user:1:age 18 user:2:name xiaomei user:2:age 20`。

#### 常规计数

因为 Redis 处理命令是单线程，所以执行命令的过程是原子的。因此 String 数据类型适合计数场景，比如计算访问次数、点赞、转发、库存数量等等。

计算文章的阅读量：

```shell
# 初始化文章的阅读量
> SET aritcle:readcount:1001 0
OK
#阅读量+1
> INCR aritcle:readcount:1001
(integer) 1
#阅读量+1
> INCR aritcle:readcount:1001
(integer) 2
#阅读量+1
> INCR aritcle:readcount:1001
(integer) 3
# 获取对应文章的阅读量
> GET aritcle:readcount:1001
"3"
```

分布式锁

SET 命令有个 NX 参数可以实现「key不存在才插入」，可以用它来实现分布式锁：

- 如果 key 不存在，则显示插入成功，可以用来表示加锁成功；
- 如果 key 存在，则会显示插入失败，可以用来表示加锁失败。

一般而言，还会对分布式锁加上过期时间，分布式锁的命令如下：

`SET lock_key unique_value NX PX 10000`

- lock_key 就是 key 键；
- unique_value 是客户端生成的唯一的标识；
- NX 代表只在 lock_key 不存在时，才对 lock_key 进行设置操作；
- PX 10000 表示设置 lock_key 的过期时间为 10s，这是为了避免客户端发生异常而无法释放锁。

而解锁的过程就是将 lock_key 键删除，但不能乱删，要保证执行操作的客户端就是加锁的客户端。所以，解锁的时候，我们要先判断锁的 unique_value 是否为加锁客户端，是的话，才将 lock_key 键删除。

可以看到，解锁是有两个操作，这时就需要 Lua 脚本来保证解锁的原子性，因为 Redis 在执行 Lua 脚本时，可以以原子性的方式执行，保证了锁释放操作的原子性。

```Lua
// 释放锁时，先比较 unique_value 是否相等，避免锁的误释放
if redis.call("get",KEYS[1]) == ARGV[1] then
    return redis.call("del",KEYS[1])
else
    return 0
end
```

这样一来，就通过使用 SET 命令和 Lua 脚本在 Redis 单节点上完成了分布式锁的加锁和解锁。



