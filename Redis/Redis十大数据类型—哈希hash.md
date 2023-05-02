## 介绍

Hash 是一个键值对（key - value）集合，其中 value 的形式入：`value=[{field1，value1}，...{fieldN，valueN}]`。Hash 特别适合用于存储对象。

### Hash和String对象的区别

![6077a1a10341be439a5eb8ab8b7d45fa.png](https://img-blog.csdnimg.cn/img_convert/6077a1a10341be439a5eb8ab8b7d45fa.png)

### 内部实现

Hash 类型的底层数据结构是由`压缩列表或哈希表`实现的：

- 如果哈希类型元素个数小于 `512` 个（默认值，可由 `hash-max-ziplist-entries` 配置），所有值小于 `64` 字节（默认值，可由 `hash-max-ziplist-value` 配置）的话，Redis 会使用**压缩列表**作为 Hash 类型的底层数据结构；
- 如果哈希类型元素不满足上面条件，Redis 会使用**哈希表**作为 Hash 类型的 底层数据结构。

## 常用命令

![image-20230419025447085](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230419025447085.png)

## 示例

### HSET

`HSET key field value [field value ...]`

存储一个哈希表key的键值

```shell
127.0.0.1:6379> HSET user:001 name kd age 10 sex n
(integer) 3
```

### HGET

`HGET key field`

返回哈希表key对应的field键值

```shell
127.0.0.1:6379> HGET user:001 name
"kd"
127.0.0.1:6379> HGET user:001 age
"10"
127.0.0.1:6379> HGET user:001 sex
"n"
```

### HMSET

`HMSET key field value [field value ...]`

在一个哈希表key中存储多个键值对

```shell
127.0.0.1:6379> HMSET user:002 name zs age 20 id 12
OK
```

### HMGET

`HMGET key field [field ...]`

批量获取哈希表key中多个field键值

```shell
127.0.0.1:6379> HMGET user:002 name age id
1) "zs"
2) "20"
3) "12"
```

### HGETALL

`HGETALL key`

返回哈希表key中的所有键值

```shell
127.0.0.1:6379> HGETALL user:001
1) "name"
2) "kd"
3) "age"
4) "10"
5) "sex"
6) "n"
```

### HDEL

`HDEL key field [field ...]`

删除哈希表key中的field键值

```shell
127.0.0.1:6379> HDEL user:002 name
(integer) 1
127.0.0.1:6379> HGETALL user:002
1) "age"
2) "20"
3) "id"
4) "12"
```

### HLEN

`HLEN key`

返回哈希表key中field的数量

```shell
127.0.0.1:6379> HGETALL user:002
1) "age"
2) "20"
3) "id"
4) "12"
127.0.0.1:6379> HLEN user:002
(integer) 2
```

### HEXISTS

`HEXISTS key field`

在哈希表key中是否存在field

```shell
127.0.0.1:6379> HEXISTS user:002 name
(integer) 0
127.0.0.1:6379> HEXISTS user:002 age
(integer) 1
```

### HKEYS

`HKEYS key`

返回哈希表key中所有的field

```shell
127.0.0.1:6379> HKEYS user:002
1) "age"
2) "id"
```

### HVALS

`HVALS key`

返回哈希表key中的所有value

```shell
127.0.0.1:6379> HKEYS user:001
1) "name"
2) "age"
3) "sex"
127.0.0.1:6379> HVALS user:001
1) "kd"
2) "10"
3) "n"
```

### HINCRBY

`HINCRBY key field increment`

为哈希表key中field键的值加上增量increment，只有integer可以加

```shell
127.0.0.1:6379> HINCRBY user:001 age 10
(integer) 20
127.0.0.1:6379> HINCRBY user:001 age 300
(integer) 320
127.0.0.1:6379> HVALS user:001
1) "kd"
2) "320"
3) "n"
127.0.0.1:6379> HINCRBY user:001 name 2
(error) ERR hash value is not an integer
```

### HINCRBYFLOAT

`HINCRBYFLOAT key field increment`

为哈希表key中field键的值加上增量increment，增量为float

```shell
127.0.0.1:6379> HINCRBYFLOAT user:001 age 0.3
"320.29999999999999999"
127.0.0.1:6379> HINCRBYFLOAT user:001 age 0.3
"320.59999999999999998"
127.0.0.1:6379> HINCRBYFLOAT user:001 age 0.3
"320.89999999999999997"
127.0.0.1:6379> HINCRBYFLOAT user:001 age 0.3
"321.19999999999999996"
127.0.0.1:6379> HINCRBYFLOAT user:001 age 0.3
"321.49999999999999994"
127.0.0.1:6379> HVALS user:001
1) "kd"
2) "321.49999999999999994"
3) "n"
```

### HSETNX

`HSETNX key field value`

当field不存在时，进行赋值，如果存在，则无效

```shell
127.0.0.1:6379> HSETNX user:001 name kd
(integer) 0
127.0.0.1:6379> HSETNX user:001 stu 20
(integer) 1
```

## 应用场景

### 缓存对象

Hash 类型的 （key，field， value） 的结构与对象的（对象id， 属性， 值）的结构相似，也可以用来存储对象。

我们以用户信息为例，它在关系型数据库中的结构是这样的：

![8dd839ef3450951c4ab72a0951f7a237.png](https://img-blog.csdnimg.cn/img_convert/8dd839ef3450951c4ab72a0951f7a237.png)

我们可以使用如下命令，将用户对象的信息存储到 Hash 类型：

```go
# 存储一个哈希表uid:1的键值
> HSET uid:1 name Tom age 15
2
# 存储一个哈希表uid:2的键值
> HSET uid:2 name Jerry age 13
2
# 获取哈希表用户id为1中所有的键值
> HGETALL uid:1
1) "name"
2) "Tom"
3) "age"
4) "15"
```

在介绍 String 类型的应用场景时有所介绍，String + Json也是存储对象的一种方式，那么存储对象时，到底用 String + json 还是用 Hash 呢？

一般对象用 String + Json 存储，对象中某些频繁变化的属性可以考虑抽出来用 Hash 类型存储。

### 购物车

以用户 id 为 key，商品 id 为 field，商品数量为 value，恰好构成了购物车的3个要素。

![ccd2d336ecfbed26e9184a58e5a0247a.png](https://img-blog.csdnimg.cn/img_convert/ccd2d336ecfbed26e9184a58e5a0247a.png)

涉及的命令如下：

- 添加商品：`HSET cart:{用户id} {商品id} 1`
- 添加数量：`HINCRBY cart:{用户id} {商品id} 1`
- 商品总数：`HLEN cart:{用户id}`
- 删除商品：`HDEL cart:{用户id} {商品id}`
- 获取购物车所有商品：`HGETALL cart:{用户id}`

当前仅仅是将商品ID存储到了Redis 中，在回显商品具体信息的时候，还需要拿着商品 id 查询一次数据库，获取完整的商品的信息。

