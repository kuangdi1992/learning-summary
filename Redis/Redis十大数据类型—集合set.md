## 介绍

set类型是一个无序并唯一的键值集合，set的存储顺序不会按照插入的先后顺序进行存储。

一个集合最多可以存储2^32-1个元素。

set类型除了支持集合内的增删改查，同时还支持多个集合取交集、并集、差集。

![dd46f18f087da7d2171e4d1f6845d8c0.png](https://img-blog.csdnimg.cn/img_convert/dd46f18f087da7d2171e4d1f6845d8c0.png)

Set 类型和 List 类型的区别如下：

- List 可以存储重复元素，Set 只能存储非重复元素；
- List 是按照元素的先后顺序存储元素的，而 Set 则是无序方式存储元素的。

## 常用命令

![image-20230419215338887](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230419215338887.png)

## 示例

### SADD

`SADD key member [member ...]`

往集合key中存入元素，元素存在则忽略，若不存在则新建

```shell
127.0.0.1:6379> SADD k1 v1 v2 v3
(integer) 3
127.0.0.1:6379> SADD k1 v1 v2 v3
(integer) 0
```

### SMEMBERS

`SMEMBERS key`

遍历集合中的所有元素

```shell
127.0.0.1:6379> SADD k1 v1 v2 v3
(integer) 3
127.0.0.1:6379> SMEMBERS k1
1) "v3"
2) "v2"
3) "v1"
```

### SISMEMBER

`SISMEMBER key member`

判断元素是否在集合中

```shell
127.0.0.1:6379> SISMEMBER k1 v4
(integer) 0
127.0.0.1:6379> SISMEMBER k1 v2
(integer) 1
```

### SREM

`SREM key member [member ...]`

删除元素

```shell
127.0.0.1:6379> SMEMBERS k1
1) "v3"
2) "v2"
3) "v1"
127.0.0.1:6379> SREM k1 v1
(integer) 1
127.0.0.1:6379> SMEMBERS k1
1) "v3"
2) "v2"
```

### SCARD

`SCARD key`

获取集合里面的元素个数

```shell
127.0.0.1:6379> SMEMBERS k1
1) "v3"
2) "v2"
127.0.0.1:6379> SCARD k1
(integer) 2
```

SRANDMEMBER 

`SRANDMEMBER key number`

从集合中随机展现设置的数字个数元素，元素不删除

```shell
127.0.0.1:6379> SRANDMEMBER k1 2
1) "v3"
2) "v2"
127.0.0.1:6379> SRANDMEMBER k1 3
1) "v3"
2) "v2"
```

### SPOP 

`SPOP key [count]`

从集合中随机弹出一个元素，出一个删一个

```shell
127.0.0.1:6379> SMEMBERS k2
1) "c"
2) "v2"
3) "b"
4) "a"
127.0.0.1:6379> SPOP k2 1
1) "a"
127.0.0.1:6379> SMEMBERS k2
1) "c"
2) "v2"
3) "b"
```

### SMOVE

`SMOVE source destination member`

将source 里已存在的某个值赋给destination 

```shell
127.0.0.1:6379> SADD k2 a b c
(integer) 3
127.0.0.1:6379> SMOVE k1 k2 v2
(integer) 1
127.0.0.1:6379> SMEMBERS k2
1) "c"
2) "v2"
3) "b"
4) "a"
```

### SINTER

`SINTER key [key ...]`

交集运算

```shell
127.0.0.1:6379> SINTER A B
1) "1"
2) "a"
3) "2"
```

### SINTERSTORE 

`SINTERSTORE destination key [key ...]`

 将交集结果存入新集合destination中

```shell
127.0.0.1:6379> SINTERSTORE C A B
(integer) 3
127.0.0.1:6379> SMEMBERS C
1) "2"
2) "1"
3) "a"
```

### SUNION 

`SUNION key [key ...]`

并集运算

```shell
127.0.0.1:6379> SUNION A B
1) "3"
2) "1"
3) "2"
4) "c"
5) "x"
6) "b"
7) "a"
```

### SUNIONSTORE 

`SUNIONSTORE destination key [key ...]`

将并集结果存入新集合destination中

```shell
127.0.0.1:6379> SUNIONSTORE D A B
(integer) 7
127.0.0.1:6379> SMEMBERS D
1) "3"
2) "1"
3) "2"
4) "c"
5) "x"
6) "b"
7) "a"
```

### SDIFF 

`SDIFF key [key ...]`

差集运算，属于A但不属于B的元素构成的集合

```shell
127.0.0.1:6379> SADD A a b c 1 2
(integer) 5
127.0.0.1:6379> SADD B 1 2 3 a x
(integer) 5
127.0.0.1:6379> SDIFF A B
1) "c"
2) "b"
```

### SINTERCARD

`SINTERCARD numkeys key [key ...] [LIMIT limit]`

它不返回结果集，而只返回结果的基数。
返回由所有给定集合的交集产生的集合的基数。

```shell
127.0.0.1:6379> SINTERCARD 2 A B
(integer) 3
127.0.0.1:6379> SINTERCARD 2 A B limit 1 #limit限制个数
(integer) 1
127.0.0.1:6379> SINTERCARD 2 A B limit 2
(integer) 2
127.0.0.1:6379> SINTERCARD 2 A B limit 3
(integer) 3
127.0.0.1:6379> SINTERCARD 2 A B limit 4
(integer) 3
```



## 应用场景

集合的主要几个特性，无序、不可重复、支持并交差等操作。

因此 Set 类型比较适合用来数据去重和保障数据的唯一性，还可以用来统计多个集合的交集、错集和并集等，当我们存储的数据是无序并且需要去重的情况下，比较适合使用集合类型进行存储。

但是要提醒一下，这里有一个潜在的风险。**Set 的差集、并集和交集的计算复杂度较高，在数据量较大的情况下，如果直接执行这些计算，会导致 Redis 实例阻塞**。

在主从集群中，为了避免主库因为 Set 做聚合计算（交集、差集、并集）时导致主库被阻塞，我们可以选择一个从库完成聚合统计，或者把数据返回给客户端，由客户端来完成聚合统计。

#### 点赞

Set 类型可以保证一个用户只能点一个赞，这里举例子一个场景，key 是文章id，value 是用户id。

`uid:1` 、`uid:2`、`uid:3`  三个用户分别对 article:1 文章点赞了。

```go
# uid:1 用户对文章 article:1 点赞
> SADD article:1 uid:1
(integer) 1
# uid:2 用户对文章 article:1 点赞
> SADD article:1 uid:2
(integer) 1
# uid:3 用户对文章 article:1 点赞
> SADD article:1 uid:3
(integer) 1
```

`uid:1` 取消了对 article:1 文章点赞。

```go
> SREM article:1 uid:1
(integer) 1
```

获取  article:1 文章所有点赞用户 :

```go
> SMEMBERS article:1
1) "uid:3"
2) "uid:2"
```

获取 article:1 文章的点赞用户数量：

```go
> SCARD article:1
(integer) 2
```

判断用户 `uid:1` 是否对文章 article:1 点赞了：

```go
> SISMEMBER article:1 uid:1
(integer) 0  # 返回0说明没点赞，返回1则说明点赞了
```

#### 共同关注

Set 类型支持交集运算，所以可以用来计算共同关注的好友、公众号等。

key 可以是用户id，value 则是已关注的公众号的id。

`uid:1` 用户关注公众号 id 为 5、6、7、8、9，`uid:2` 用户关注公众号 id 为 7、8、9、10、11。

```go
# uid:1 用户关注公众号 id 为 5、6、7、8、9
> SADD uid:1 5 6 7 8 9
(integer) 5
# uid:2  用户关注公众号 id 为 7、8、9、10、11
> SADD uid:2 7 8 9 10 11
(integer) 5
```

`uid:1` 和 `uid:2` 共同关注的公众号：

```go
# 获取共同关注
> SINTER uid:1 uid:2
1) "7"
2) "8"
3) "9"
```

给  `uid:2`  推荐 `uid:1` 关注的公众号：

```go
> SDIFF uid:1 uid:2
1) "5"
2) "6"
```

验证某个公众号是否同时被  `uid:1`  或  `uid:2`  关注:

```go
> SISMEMBER uid:1 5
(integer) 1 # 返回0，说明关注了
> SISMEMBER uid:2 5
(integer) 0 # 返回0，说明没关注
```

#### 抽奖活动

存储某活动中中奖的用户名 ，Set 类型因为有去重功能，可以保证同一个用户不会中奖两次。

key为抽奖活动名，value为员工名称，把所有员工名称放入抽奖箱 ：

```go
>SADD lucky Tom Jerry John Sean Marry Lindy Sary Mark
(integer) 5
```

如果允许重复中奖，可以使用 SRANDMEMBER 命令。

```go
# 抽取 1 个一等奖：
> SRANDMEMBER lucky 1
1) "Tom"
# 抽取 2 个二等奖：
> SRANDMEMBER lucky 2
1) "Mark"
2) "Jerry"
# 抽取 3 个三等奖：
> SRANDMEMBER lucky 3
1) "Sary"
2) "Tom"
3) "Jerry"
```

如果不允许重复中奖，可以使用 SPOP 命令。

```go
# 抽取一等奖1个
> SPOP lucky 1
1) "Sary"
# 抽取二等奖2个
> SPOP lucky 2
1) "Jerry"
2) "Mark"
# 抽取三等奖3个
> SPOP lucky 3
1) "John"
2) "Sean"
3) "Lindy"
```



