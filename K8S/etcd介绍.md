# 介绍

Etcd 是 CoreOS 基于 Raft 开发的分布式 key-value 存储，可用于服务发现、共享配置以及一致性保障（如数据库选主、分布式锁等）。

# 主要功能

- 基本的`key-value`存储
- 监听机制
- `key`的过期及续约机制，用于监控和服务发现
- 原子`CAS`和`CAD`，用于分布式锁和`leader`选举

# 基于Raft的一致性

## 选举方法

- 初始启动时，节点处于 follower 状态并被设定一个 election timeout，如果在这一时间周期内没有收到来自 leader 的 heartbeat，节点将发起选举：将自己切换为candidate 之后，向集群中其它 follower 节点发送请求，询问其是否选举自己成为leader。
- 当收到来自集群中过半数节点的接受投票后，节点即成为 leader，开始接收保存client 的数据并向其它的 follower 节点同步日志。如果没有达成一致，则 candidate随机选择一个等待间隔（150ms ~ 300ms）再次发起投票，得到集群中半数以上follower 接受的 candidate 将成为 leader
-  leader 节点依靠定时向 follower 发送 heartbeat 来保持其地位。
-  任何时候如果其它 follower 在 election timeout 期间都没有收到来自 leader 的heartbeat，同样会将自己的状态切换为 candidate 并发起选举。每成功选举一次，新 leader 的任期（Term）都会比之前 leader 的任期大 1。

