# Kubernetes简介

`Kubernetes` 是谷歌开源的容器集群管理系统，是 Google 多年大规模容器管理技术 `Borg `的开源版本，主要功能包括： 

- 基于容器的应用部署、维护和滚动升级 
- 负载均衡和服务发现 
- 跨机器和跨地区的集群调度 
- 自动伸缩 
- 无状态服务和有状态服务 
- 广泛的 Volume 支持 
- 插件机制保证扩展性 

# Kubernetes架构组件

Kubernetes架构主要包括两个部分：Master(主控节点)和Work node(工作节点)。

![image-20230502223443413](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502223443413.png)

## Kubernetes组件

- Master：主控节点
  - API server：集群统一入口，以`restful`风格进行操作，同时交给`etcd`存储，提供认证、授权、访问控制、API注册和发现等机制。
  - scheduler：节点的调度，选择node节点应用部署
  - controller-manager：处理集群中常规后台任务，一个资源对应一个控制器
  - etcd：存储系统，用于保存集群中的相关数据
- Worker node：工作节点
  - Kubelet：master派到node节点代表，管理本机容器
    - 一个集群中每个节点上运行的代理，它保证容器运行在Pod中
    - 负责维护容器的生命周期，同时也负责Volume(CSI)和网络(CNI)的管理
  - kube-proxy：通过该网络代理，负载均衡等操作。
- 容器运行环境（`Container Runtime`）
  - 容器运行环境是负责运行容器的软件
  - Kubernetes支持多容器运行环境：Docker、containerd、cri-o、rktlet 以及任何实现 Kubernetes CRI （容器运行环境接口） 的软件。
- fluentd
  - 一个守护进程，有助于提升集群层面日志

## API Server

kube-apiserver 是 Kubernetes 最重要的核心组件之一，主要提供以下的功能

- 提供集群管理的 REST API 接口，包括认证授权、数据校验以及集群状态变更等
- 提供其他模块之间的数据交互和通信的枢纽（其他模块通过 API Server 查询或修改数据，只有 API Server 才直接操作 etcd）。

kube-apiserver支持同时提供https(默认监听在6443端口)和http API(默认监听在127.0.0.1的8080端口)，其中 http API 是非安全接口，不做任何认证授权机制，不建议生产环境启用。

在实际使用中，通常通过 kubectl 来访问 apiserver，也可以通过 Kubernetes 各个语言的 client 库来访问 apiserver。在使用 kubectl 时，打开调试日志也可以看到每个 API 调用的格式，比如：

`kubectl --v=8 get pods`



