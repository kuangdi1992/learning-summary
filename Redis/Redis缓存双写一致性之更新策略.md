# 介绍

![image-20230501101415166](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230501101415166.png)

# 面试题

1、只要用到缓存，就可能会涉及到Redis缓存与数据库双存储双写，只要是双写，就一定会有数据一致性问题，怎么解决一致性问题？

2、双写一致性，先动缓存redis还是数据库mysql？为什么？

3、延时双删？有哪些问题？

4、有一种情况，微服务查询redis无mysql有，为保证数据双写一致性回写redis需要注意什么？

5、双检加锁策略？如何避免缓存击穿？

6、redis和mysql双写一定会出现纰漏，做不到强一致性，如何保证最终一致性？

# 双写一致性

> Redis中有数据，需要和数据库中的值相同。

> Redis中无数据，数据库中的值是最新的值，并且准备回写Redis。

>  缓存按照操作划分
>
> - 只读缓存
>
> - 读写缓存
>
>   - 同步直写策略
>     - 写数据库后同步写Redis缓存，缓存中的数据和数据库中的一致
>     - 对于读写缓存，要保证缓存和数据库中数据的一致
>
>   - 异步缓写策略
>     - 正常业务运行，MySQL数据变动，但是可以在业务上容许出现一定时间后才作用于Redis，比如仓库等。
>     - 异常情况出现后，不得不将失败的动作修补，可能需要借助kafka等消息中间件，实现重写重试。

> 采用双检加锁策略
>
> - 多个线程同时去查询数据库的这条数据，就在第一个查询数据的请求上使用一个互斥锁来锁住他。
> - 其他线程获取不到锁就一直等待，等第一个线程查询到了数据，然后做了缓存
> - 后面的线程进来发现已经有了缓存，就直接走缓存

## Java示例

```java
package com.lv.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lv.User;
import com.lv.mapper.UserMapper;
import com.lv.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.concurrent.TimeUnit;

/**
 * @author 晓风残月Lx
 * @date 2023/3/27 12:39
 */
@Slf4j
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    public static final String CACHE_KEY_USER = "user:";
    @Resource
    private UserMapper userMapper;
    @Resource
    private RedisTemplate redisTemplate;


    /**
     *  业务逻辑没有写错，对于小厂中厂(QPS《=1000)可以使用，但是大厂不行
     * @param id
     * @return
     */
    public User findUserById1(Long id){
        User user = null;

        String key = CACHE_KEY_USER + id;

        // 1.先从redis中查询，如果有直接返回结果，没有再去查询 mysql
        user = (User) redisTemplate.opsForValue().get(key);

        if (user == null){
            // 2. redis中没有,查询mysql
             user = userMapper.selectById(id);
             if (user == null){
                 // 3.1 redis + mysql 都无数据
                 // 具体细化，防止多次穿透，业务规定，记录下导致穿透的这个key回写redis
                 return user;
             }else {
                 // 3.2 mysql有，需要回写到redis，保证下一次的缓存命中率
                 redisTemplate.opsForValue().set(key,user);
             }
        }
        return user;
    }

    /**
     * 加强补充，避免突然key失效了，打爆mysql，做一下预防，尽量不出现击穿的情况
     * @param id
     * @return
     */
    public User findUserById2(Long id){
        User user = null;
        String key = CACHE_KEY_USER + id;

        // 1.先从redis里面查询，如果有直接返回结果，如果没有再去查询mysql
        // 第一次查询redis，加锁前
        user = (User) redisTemplate.opsForValue().get(key);
        if (user == null){
            // 2.对于高QPS的优化，进来就先加锁，保证一个请求操作，让外面的redis等待一下，避免击穿mysql
            synchronized (UserServiceImpl.class){
                // 第二次查询redis，加锁后
                user = (User) redisTemplate.opsForValue().get(key);
                // 3. 二次查redis还是null，可以去查mysql了(mysql默认有数据)
                if (user == null) {
                    //4 查询mysql拿数据(mysql默认有数据)
                    user = userMapper.selectById(id);
                    if (user == null) {
                        return null;
                    } else {
                        // 5. mysql里面有数据的，需要回写redis，完成数据一致性的同步工作
                        redisTemplate.opsForValue().setIfAbsent(key, user, 7L, TimeUnit.DAYS);
                    }
                }
            }
        }
        return user;
    }
}
```

# 数据库和缓存一致性的几种更新策略

## 目的

`达到最终一致性。`

- 给缓存设置过期时间，定期清理缓存并回写，是保证最终一致性的解决方案。
- 我们可以对存入缓存的数据设置过期时间，所有的写操作以数据库为准，对缓存操作只是尽最大努力即可。也就是说如果数据库写成功，缓存更新失败，那么只要到达过期时间，则后面的读请求自然会从数据库中读取新值然后回填缓存，达到一致性，切记，`要以mysql的数据库写入库为准`。

## 不可停机的四种更新策略

### 先更新数据库，再更新缓存

#### 问题一

更新MySQL的某个商品的库存，当前商品的库存是100，更新为99 个。下一步先更新MySQL修改为99成功，然后更新Redis。这时出现异常，更新Redis失败，导致MySQL中的库存是99，而Redis中的还是100。这样会让数据库和缓存Redis中的数据不一致，`读到Redis脏数据`。

#### 问题二

A、B两个线程发起调用，正常逻辑如下：

```shell
1、A update mysql 100
2、A update redis 100
3、B update mysql 80
4、B update redis 80
```

而在多线程环境下，A和B两个线程有快有慢，有前有后，有并行，因此异常逻辑如下：

```shell
1、A update mysql 100
2、B update mysql 80
3、B update redis 80
4、A update redis 100
```

最终，`MySQL和Redis中的数据不一致`。

### 先更新缓存，再更新数据库

一般业务会将MySQL作为底单数据库，以MySQL为准。

#### 异常问题

A、B两个线程发起调用，正常逻辑如下：

```shell
1、A update redis 100
2、A update mysql 100
3、B update redis 80
4、B update mysql 80
```

而在多线程环境下，A和B两个线程有快有慢，有前有后，有并行，因此异常逻辑如下：

```shell
1、A update redis 100
2、B update redis 80
3、B update mysql 80
4、A update mysql 100
```

最终，`MySQL和Redis中的数据不一致。`

### 先删除缓存，再更新数据库

#### 异常问题

A线程先成功删除了Redis中的数据，然后去更新MySQL，此时MySQL正在更新，还没结束。B突然出现要读取缓存数据。

![image-20230502164103191](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502164103191.png)

此时Redis里面的数据是空的，B线程读取，先读取Redis里的数据(此时已经被A线程delete掉了)，这里会出现两个问题：

> B从MySQL获取了旧值，B线程发现了Redis中没有数据(缓存缺失)，会马上去MySQL中读取，这时数据库还没更新完成，从数据库中读取的是旧值。
>
> B会将获取到的旧值写回到Redis。B获取旧值数据后，返回前台并写回进Redis(刚被A线程删除的旧数据极大可能又被写回。)

![image-20230502164135443](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502164135443.png)

之后，A线程更新完MySQL，发现Redis里面的缓存是脏数据，这时A线程就不好处理了。

> 这里有两个并发操作，一个更新操作，一个查询操作。
>
> A删除缓存后，B查询操作没有命中缓存，B先把老数据读出来后，放到缓存中，然后A更新操作更新了数据库。
>
> 因此，在Redis缓存中的数据还是老数据，导致Redis缓存中的数据是脏的，而且会一直是脏数据。

| 时间 | 线程A                                                    | 线程B                                                        | 出现问题                                                     |
| ---- | -------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| t1   | 请求A进行写操作，删除缓存成功后，正在进行MySQL更新操作…… |                                                              |                                                              |
| t2   |                                                          | 1、缓存中读取不到，立刻读取MySQL，因为A还没有更新完MySQL，因此读到的是旧值<br>2、将从MySQL读取的旧值，写回了Redis | 1、A没有更新完MySQL导致B读到了旧值<br>2、线程B遵守回写机制，将旧值写回了Redis，导致其他请求从缓存中读取的是旧值，并没有更新 |
| t3   | A更新完MySQL数据库，完成                                 |                                                              | Redis缓存是被B写回的旧值<br>MySQL中是被A更新的新值<br>出现了数据不一致的问题 |

#### 总结

在该策略下，如果数据库更新失败或超时或返回不及时，导致B线程请求访问缓存时，发现Redis缓存中没有数据，缓存缺失，B会去MySQL数据库中进行读取，取到旧值，写回Redis缓存，导致数据不一致。

#### 解决方案

##### `延时双删策略`

示例代码(Java)：

![image-20230502170446108](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502170446108.png)

上述代码中，加上sleep，为了让线程B能先从数据库中读取数据，将缺失的数据写入缓存，然后A线程进行删除，因此，`线程A Sleep的时间要大于线程B读取数据写入缓存的时间`。

这个方案会在第一次删除缓存后，延迟一段时间后再次进行删除——延迟双删。

###### 相关面试题

1、这个删除该休眠多久？

> - 在业务程序运行的时候，统计下线程读数据和写缓存的操作时间，自行评估自己的项目的读数据业务逻辑的耗时，以此为基础来进行估算。然后写数据的休眠时间则在读数据业务逻辑的耗时基础上加百毫秒即可。
> - 新启动一个后台监控程序，比如**WatchDog监控程序**，会加时

2、这种同步淘汰策略，吞吐量降低怎么办？

> 第二次删除缓存使用`异步删除`
>
> ![image-20230502171520178](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502171520178.png)

3、看门狗WatchDog源码分析

### 先更新数据库，再删除缓存

#### 异常问题

| 时间 | 线程A               | 线程B                               | 出现的问题                               |
| ---- | ------------------- | ----------------------------------- | ---------------------------------------- |
| t1   | 更新数据库MySQL的值 |                                     |                                          |
| t2   |                     | 缓存立刻命中，此时B读取的是缓存旧值 | A还没删除缓存的值，导致B缓存命中读到旧值 |
| t3   | 更新缓存数据        |                                     |                                          |

#### 解决方案（消息队列）

![image-20230502172118756](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502172118756.png)

![image-20230502172313190](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502172313190.png)

### 总结

![image-20230502172504976](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502172504976.png)