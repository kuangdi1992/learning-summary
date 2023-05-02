# 面试题

1、海量数据里面如何查询某一固定前缀的key？

2、如何在生产上禁用`keys */flushdb/flushall`等危险命令以防止误删误用？

3、`MEMORY USAGE`命令是否使用过？

4、BigKey问题，多大算big？如何发现？如何删除？如何处理？

5、BigKey如何调优？惰性释放lazyfree？

6、Morekey问题，生产上redis数据库有1000W记录，如何遍历？key * 可以吗？

# Morekey案例

生产100w条redis批量设置kv的语句保存在redisTest.txt中。

```shell
for((i=1;i<=100*10000;i++)); do echo "set k$i v$i" >> /tmp/redisTest.txt ;done;
# 生成100W条redis批量设置kv的语句(key=kn,value=vn)写入到/tmp目录下的redisTest.txt文件中
```

通过redis管道命令插入100w大批量数据

`cat /tmp/redisTest.txt | redis-cli -h 127.0.0.1 -p 6379 -a 1 --pipe`

```shell
[root@192 ~]# cat /tmp/redisTest.txt | redis-cli -h 127.0.0.1 -p 6379 -a 1 --pipe
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
All data transferred. Waiting for the last reply...
Last reply received from server.
errors: 0, replies: 1000000
```

通过redis-cli登录，查看是否插入成功。

```shell
127.0.0.1:6379> DBSIZE
(integer) 0
127.0.0.1:6379> DBSIZE
(integer) 1000000
127.0.0.1:6379> get k1000000
"v1000000"
```

# 危险命令

`keys * / flushall / flushdb` 严禁在线上使用。（在上面的例子中使用`keys *`大概需要8S左右）

`keys * / flushall / flushdb` 会造成阻塞，会导致`Redis`其他的读写都被延后甚至是超时报错，可能会引起[缓存雪崩](https://so.csdn.net/so/search?q=缓存雪崩&spm=1001.2101.3001.7020)甚至数据库宕机。

**通过配置禁用危险命令**

```shell
# It is possible to change the name of dangerous commands in a shared
# environment. For instance the CONFIG command may be renamed into something
# hard to guess so that it will still be available for internal-use tools
# but not available for general clients.
#
# Example:
#
# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
#
# It is also possible to completely kill a command by renaming it into
# an empty string:
#
# rename-command CONFIG ""
rename-command keys ""
rename-command flushdb ""
rename-command flushall ""
```

查看是否成功

```shell
[root@192 myredis]# redis-server redis7.conf 
[root@192 myredis]# redis-cli -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> keys *
(error) ERR unknown command 'keys', with args beginning with: '*' 
127.0.0.1:6379> flushdb
(error) ERR unknown command 'flushdb', with args beginning with: 
127.0.0.1:6379> flushall
(error) ERR unknown command 'flushall', with args beginning with: 
```

# scan命令

因为海量数据下，使用`keys *`命令，会导致卡顿，因此使用`scan`命令代替。

- [SCAN](https://www.redis.com.cn/commands/scan.html) 命令用于迭代当前数据库中的数据库键。
- [SSCAN](https://www.redis.com.cn/commands/sscan.html) 命令用于迭代集合键中的元素。
- [HSCAN](https://www.redis.com.cn/commands/hscan.html) 命令用于迭代哈希键中的键值对。
- [ZSCAN](https://www.redis.com.cn/commands/zscan.html) 命令用于迭代有序集合中的元素（包括元素成员和元素分值）。

语法：

`SCAN cursor [MATCH pattern] [COUNT count]`

- cursor - 游标。
- pattern - 匹配的模式。
- count - 指定从数据集里返回多少元素，默认值为 10 。

[SCAN](https://www.redis.com.cn/commands/scan.html) 命令是一个基于游标的迭代器，每次被调用之后， 都会向用户返回一个新的游标， 用户在下次迭代时需要使用这个新游标作为 [SCAN](https://www.redis.com.cn/commands/scan.html) 命令的游标参数， 以此来延续之前的迭代过程。

[SCAN](https://www.redis.com.cn/commands/scan.html) 返回一个包含两个元素的数组， 第一个元素是用于进行下一次迭代的新游标， 而第二个元素则是一个数组， 这个数组中包含了所有被迭代的元素。当 [SCAN](https://www.redis.com.cn/commands/scan.html) 命令的游标参数被设置为 `0` 时， 服务器将开始一次新的迭代，而当服务器向用户返回值为 `0` 的游标时， 表示迭代已结束。

## 示例

```shell
127.0.0.1:6379> scan 0
1) "819200" #下一次迭代的新游标
2)  1) "k914081" #数组，被迭代元素
    2) "k600993"
    3) "k19329"
    4) "k666798"
    5) "k241760"
    6) "k264010"
    7) "k298885"
    8) "k109280"
    9) "k821745"
   10) "k236595"
127.0.0.1:6379> scan 819200 match *11*
1) "622592"
2) 1) "k341174"
```

# BigKey案例

## 多大算bigkey

防止网卡流量、慢查询，`string类型控制在10KB以内，hash、list、set、zset元素个数不要超过5000。`

反例：一个包含200万个元素的list。

非字符串的bigkey，不要使用del删除，使用hscan、sscan、zscan方式渐进式删除，同时要注意防止bigkey过期时间自动删除问题(例如一个200万的zset设置1小时过期，会触发del操作，造成阻塞，而且该操作不会不出现在慢查询中(latency可查))，查找方法和删除方法。——【阿里云Redis开发规范】

## 危害

1. 内存不均，集群迁移困难
2. 超时删除，大key导致阻塞
3. 网络流量阻塞

## 产生

社交类：粉丝列表逐步递增

汇总统计：某个报表，经年累月累积

## 发现

### `redis-cli --bigkeys`

命令如下：

```shell
redis-cli -h 127.0.0.1 -p 6379 -a 111111 --bigkeys

//每隔 100 条 scan 指令就会休眠 0.1s，ops 就不会剧烈抬升，但是扫描的时间会变长
redis-cli -h 127.0.0.1 -p 7001 –-bigkeys -i 0.1
```

示例：

```shell
[root@192 myredis]# redis-cli -h 127.0.0.1 -p 6379 -a 1 --bigkeys
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.

# Scanning the entire keyspace to find biggest keys as well as
# average sizes per key type.  You can use -i 0.1 to sleep 0.1 sec
# per 100 SCAN commands (not usually needed).

[00.00%] Biggest string found so far '"k601056"' with 7 bytes
[26.52%] Biggest string found so far '"k1000000"' with 8 bytes
[100.00%] Sampled 1000000 keys so far

-------- summary -------

Sampled 1000000 keys in the keyspace!
Total key length in bytes is 6888896 (avg len 6.89)

Biggest string found '"k1000000"' has 8 bytes

0 lists with 0 items (00.00% of keys, avg size 0.00)
0 hashs with 0 fields (00.00% of keys, avg size 0.00)
1000000 strings with 6888896 bytes (100.00% of keys, avg size 6.89)
0 streams with 0 entries (00.00% of keys, avg size 0.00)
0 sets with 0 members (00.00% of keys, avg size 0.00)
0 zsets with 0 members (00.00% of keys, avg size 0.00)
```

好处：给出每种数据结构Top 1的bigkey，同时给出每种数据类型的键值个数和平均大小。

不足：想查询大于`10kb`的所有key，--bigkeys就不行了。

### `memory usage`

语法：

`MEMORY USAGE key [SAMPLES count]`

`MEMORY USAGE`命令给出一个key和它的值在RAM中所占用的字节数，返回的结果是key的值以及为管理该key分配的内存总字节数。

示例：

```shell
127.0.0.1:6379> MEMORY USAGE k1000000
(integer) 72
127.0.0.1:6379> MEMORY USAGE k100000
(integer) 72
127.0.0.1:6379> MEMORY USAGE k10
(integer) 56
```

## 删除

`非字符串的bigkey，不要使用del删除，使用hscan、sscan、zscan方式渐进式删除`，同时要注意防止bigkey过期时间自动删除问题(例如一个200万的zset设置1小时过期，会触发del操作，造成阻塞，而且该操作不会不出现在慢查询中(latency可查))，查找方法和删除方法。

### String

一般使用`del`，过于庞大使用`unlink`

### hash

**使用`hscan`每次获取少量`field-value`，在使用`hdel`删除每个`field`。**

语法：

`HSCAN key cursor [MATCH pattern] [COUNT count]`

- cursor - 游标。
- pattern - 匹配的模式。
- count - 指定从数据集里返回多少元素，默认值为 10 。

返回的每个元素都是一个元组，每一个元组元素由一个字段(field) 和值（value）组成。

```shell
127.0.0.1:6379> HSCAN user:001 0
1) "0"
2) 1) "name"
   2) "kd"
   3) "age"
   4) "10"
   5) "sex"
   6) "n"
```

阿里手册示例：

```java
public void delBigHash(String host, int port, String password, String bigHashKey) {
    Jedis jedis = new Jedis(host, port);
    if (password != null && !"".equals(password)) {
        jedis.auth(password);
    }
    ScanParams scanParams = new ScanParams().count(100);
    String cursor = "0";
    do {
        ScanResult<Entry<String, String>> scanResult = jedis.hscan(bigHashKey, cursor, scanParams);
        List<Entry<String, String>> entryList = scanResult.getResult();
        if (entryList != null && !entryList.isEmpty()) {
            for (Entry<String, String> entry : entryList) {
                jedis.hdel(bigHashKey, entry.getKey());
            }
        }
        cursor = scanResult.getStringCursor();
    } while (!"0".equals(cursor));
    //删除bigkey
    jedis.del(bigHashKey);
}
```

### list

**使用`ltrim`渐进式逐步删除，直到全部删除**

语法：

`LTRIM key start stop`

Redis [LTRIM](https://www.redis.com.cn/commands/ltrim.html) 用于修剪(trim)一个已存在的 list，这样 list 就会只包含指定范围的指定元素。start 和 stop 都是由0开始计数的， 这里的 0 是列表里的第一个元素（表头），1 是第二个元素，以此类推。

```shell
127.0.0.1:6379> lrange list1 0 -1
1) "5"
2) "4"
3) "3"
4) "2"
5) "1"
127.0.0.1:6379> LTRIM list1 1 -1
OK
127.0.0.1:6379> lrange list1 0 -1
1) "4"
2) "3"
3) "2"
4) "1"
127.0.0.1:6379> ltrim list1 0 2 #0-2之外的被删除
OK
127.0.0.1:6379> lrange list1 0 -1
1) "4"
2) "3"
3) "2"
```

阿里手册示例：

```java
public void delBigList(String host, int port, String password, String bigListKey) {
    Jedis jedis = new Jedis(host, port);
    if (password != null && !"".equals(password)) {
        jedis.auth(password);
    }
    long llen = jedis.llen(bigListKey);
    int counter = 0;
    int left = 100;
    while (counter < llen) {
        //每次从左侧截掉100个
        jedis.ltrim(bigListKey, left, llen);
        counter += left;
    }
    //最终删除key
    jedis.del(bigListKey);
}
```

### Set

**使用sscan 每次获取部分元素，再使用 srem 命令删除每个元素**

语法：

`SSCAN key cursor [MATCH pattern] [COUNT count]`

- cursor - 游标。
- pattern - 匹配的模式。
- count - 指定从数据集里返回多少元素，默认值为 10 。

`SREM key member [member ...]`

- `SREM 用于在集合中删除指定的元素。`如果指定的元素不是集合成员则被忽略。
- 如果集合 `key` 不存在则被视为一个空的集合，该命令返回0。
- 如果key的类型不是一个集合，则返回 ERR WRONGTYPE Operation against a key holding the wrong kind of value 错误。

```shell
127.0.0.1:6379> SADD k1 v1 v2 v3
(integer) 3
127.0.0.1:6379> SSCAN k1 0
1) "0"
2) 1) "v1"
   2) "v3"
   3) "v2"
127.0.0.1:6379> SREM k1 v1 v2
(integer) 2
127.0.0.1:6379> SMEMBERS k1
1) "v3"
```

阿里手册示例：

```java
public void delBigSet(String host, int port, String password, String bigSetKey) {
    Jedis jedis = new Jedis(host, port);
    if (password != null && !"".equals(password)) {
        jedis.auth(password);
    }
    ScanParams scanParams = new ScanParams().count(100);
    String cursor = "0";
    do {
        ScanResult<String> scanResult = jedis.sscan(bigSetKey, cursor, scanParams);
        List<String> memberList = scanResult.getResult();
        if (memberList != null && !memberList.isEmpty()) {
            for (String member : memberList) {
                jedis.srem(bigSetKey, member);
            }
        }
        cursor = scanResult.getStringCursor();
    } while (!"0".equals(cursor));
    //删除bigkey
    jedis.del(bigSetKey);
}
```

### Zset

**使用`zscan`每次获取部分元素，再使用`ZREMRANGEBYRANK` 命令删除每个元素。**

语法：

zscan语法和上面一样。

`ZREMRANGEBYRANK key start stop`

Redis [ZREMRANGEBYRANK](https://www.redis.com.cn/commands/zremrangebyrank.html) 移除有序集key中，指定排名(rank)区间 `start` 和 `stop` 内的所有成员。下标参数start和stop都是从0开始计数，0是分数最小的那个元素。索引也可是负数，表示位移从最高分处开始数。例如，-1是分数最高的元素，-2是分数第二高的，依次类推。

返回值为删除元素的个数。

```shell
127.0.0.1:6379> ZADD myzset 1 "one"
(integer) 1
127.0.0.1:6379> ZADD myzset 2 "two"
(integer) 1
127.0.0.1:6379> ZADD myzset 3 "three"
(integer) 1
127.0.0.1:6379> ZRANGE myzset 0 -1 withscores
1) "one"
2) "1"
3) "two"
4) "2"
5) "three"
6) "3"
127.0.0.1:6379> zscan myzset 0
1) "0"
2) 1) "one"
   2) "1"
   3) "two"
   4) "2"
   5) "three"
   6) "3"
127.0.0.1:6379> ZREMRANGEBYRANK myzset 0 1
(integer) 2
127.0.0.1:6379> ZRANGE myzset 0 -1 withscores
1) "three"
2) "3"
```

阿里手册示例：

```java
public void delBigZset(String host, int port, String password, String bigZsetKey) {
    Jedis jedis = new Jedis(host, port);
    if (password != null && !"".equals(password)) {
        jedis.auth(password);
    }
    ScanParams scanParams = new ScanParams().count(100);
    String cursor = "0";
    do {
        ScanResult<Tuple> scanResult = jedis.zscan(bigZsetKey, cursor, scanParams);
        List<Tuple> tupleList = scanResult.getResult();
        if (tupleList != null && !tupleList.isEmpty()) {
            for (Tuple tuple : tupleList) {
                jedis.zrem(bigZsetKey, tuple.getElement());
            }
        }
        cursor = scanResult.getStringCursor();
    } while (!"0".equals(cursor));
    //删除bigkey
    jedis.del(bigZsetKey);
}
```

# BigKey生产调优

## 阻塞和非阻塞删除命令

- DEL，对象的阻塞删除，服务器会停止处理新命令，以便以同步方式回收与对象关联的所有内存。
- 非阻塞删除原语：`UNLINK、FLUSHALL和FLUSHDB的ASYNC选项`，以便在后台回收内存。

## 优化配置

```shell
############################# LAZY FREEING ####################################

# Redis has two primitives to delete keys. One is called DEL and is a blocking
# deletion of the object. It means that the server stops processing new commands
# in order to reclaim all the memory associated with an object in a synchronous
# way. If the key deleted is associated with a small object, the time needed
# in order to execute the DEL command is very small and comparable to most other
# O(1) or O(log_N) commands in Redis. However if the key is associated with an
# aggregated value containing millions of elements, the server can block for
# a long time (even seconds) in order to complete the operation.
#
# For the above reasons Redis also offers non blocking deletion primitives
# such as UNLINK (non blocking DEL) and the ASYNC option of FLUSHALL and
# FLUSHDB commands, in order to reclaim memory in background. Those commands
# are executed in constant time. Another thread will incrementally free the
# object in the background as fast as possible.
#
# DEL, UNLINK and ASYNC option of FLUSHALL and FLUSHDB are user-controlled.
# It's up to the design of the application to understand when it is a good
# idea to use one or the other. However the Redis server sometimes has to
# delete keys or flush the whole database as a side effect of other operations.
# Specifically Redis deletes objects independently of a user call in the
# following scenarios:
#
# 1) On eviction, because of the maxmemory and maxmemory policy configurations,
#    in order to make room for new data, without going over the specified
#    memory limit.
# 2) Because of expire: when a key with an associated time to live (see the
#    EXPIRE command) must be deleted from memory.
# 3) Because of a side effect of a command that stores data on a key that may
#    already exist. For example the RENAME command may delete the old key
#    content when it is replaced with another one. Similarly SUNIONSTORE
#    or SORT with STORE option may delete existing keys. The SET command
#    itself removes any old content of the specified key in order to replace
#    it with the specified string.
# 4) During replication, when a replica performs a full resynchronization with
#    its master, the content of the whole database is removed in order to
#    load the RDB file just transferred.
#
# In all the above cases the default is to delete objects in a blocking way,
# like if DEL was called. However you can configure each case specifically
# in order to instead release memory in a non-blocking way like if UNLINK
# was called, using the following configuration directives.

lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no -> yes
replica-lazy-flush no -> yes

# It is also possible, for the case when to replace the user code DEL calls
# with UNLINK calls is not easy, to modify the default behavior of the DEL
# command to act exactly like UNLINK, using the following configuration
# directive:

lazyfree-lazy-user-del no -> yes
```

