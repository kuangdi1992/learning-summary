# 介绍

## docker启动

在docker启动之后 ，会生成一个docker0的虚拟网桥

```shell
[root@192 kd]# ifconfig
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:faff:fef5:a71d  prefixlen 64  scopeid 0x20<link>
        ether 02:42:fa:f5:a7:1d  txqueuelen 0  (Ethernet)
        RX packets 14626  bytes 597458 (583.4 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 17541  bytes 70736239 (67.4 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.12.130  netmask 255.255.255.0  broadcast 192.168.12.255
        inet6 fe80::23e3:c706:b319:18a6  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:e0:75:08  txqueuelen 1000  (Ethernet)
        RX packets 498287  bytes 730053396 (696.2 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 120040  bytes 7303978 (6.9 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 12  bytes 720 (720.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 12  bytes 720 (720.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:9f:50:4b  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```

地址是172.17.0.1，通过该虚拟网桥进行通信。

## docker网络命令(docker network)

### 查看网络

```shell
[root@192 kd]# docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
96f4b2477856   bridge    bridge    local
33289ee97f5d   host      host      local
733d5f735854   none      null      local
```

安装完docker之后，会默认创建3大网络模式。

### 创建网络

命令：

> docker network create 网络名称

```shell
[root@192 kd]# docker network create kd_network
c3c217cd8cf992bb1034ccbb60f140d347988cbcadfd2dc056f2724d4e7b085f
[root@192 kd]# docker network ls
NETWORK ID     NAME         DRIVER    SCOPE
96f4b2477856   bridge       bridge    local
33289ee97f5d   host         host      local
c3c217cd8cf9   kd_network   bridge    local
733d5f735854   none         null      local

# 创建网络时是可以添加一系列参数的：
# --driver：驱动程序类型
# --gateway：主子网的IPV4和IPV6的网关
# --subnet：代表网段的CIDR格式的子网
# mynet：自定义网络名称
docker network create --driver=bridge --gateway=192.168.137.1 --subnet=192.168.137.0/16 mynet
```

### 删除一个或多个网络

命令：

> docker network rm 网络名称

```shell
[root@192 kd]# docker network rm kd_network
kd_network
[root@192 kd]# docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
96f4b2477856   bridge    bridge    local
33289ee97f5d   host      host      local
733d5f735854   none      null      local
```

### 删除所有不使用的网络

```docker network pune```

### 查看网络数据源

命令：

> docker network inspect 网络名称

```shell
[root@192 kd]# docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "96f4b247785654a0cb26bd2032937500a29f78e90f54846549d7129148e2c6c5",
        "Created": "2023-04-11T07:49:12.545440621-07:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

### 将容器连接到指定网络

```docker network connect 网络名称 容器名称```

### 断开容器网络

```docker network disconnect 网络名称 容器名称```

## 作用

`Docker`容器每次重启后容器`ip`是会发生变化的。

这也意味着如果容器间使用`ip`地址来进行通信的话，一旦有容器重启，重启的容器将不再能被访问到。

Docker网络主要有以下两个作用：

- 容器之间的互联和通信以及端口映射
- 容器IP变动时可以通过服务名直接网络通信而不受影响

因此，只要处于同一个Docker网络下的容器，可以使用服务名进行直接访问，不担心重启。

Docker底层ip和容器映射变化

### 新建并启动容器c1和c2

```
[root@192 kd]# docker run -it --name c1 centos
[root@192 kd]# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
c0a052a880ee   centos    "/bin/bash"   6 minutes ago   Up 3 seconds             c1
[root@192 kd]# docker ps -n 2
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS                  PORTS     NAMES
c0a052a880ee   centos         "/bin/bash"              6 minutes ago   Up 14 seconds                     c1
6816f306592c   cf98988102b5   "/bin/sh -c /bin/bash"   3 days ago      Exited (0) 3 days ago             eloquent_wozniak
[root@192 kd]# docker run -it --name c2 centos
[root@0b85c6ee18fe /]# [root@192 kd]# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED              STATUS              PORTS     NAMES
0b85c6ee18fe   centos    "/bin/bash"   About a minute ago   Up About a minute             c2
c0a052a880ee   centos    "/bin/bash"   8 minutes ago        Up 2 minutes                  c1
```

### 查看c1和c2的网络地址

```shell
[root@192 kd]# docker inspect c1|tail -n 20
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "96f4b247785654a0cb26bd2032937500a29f78e90f54846549d7129148e2c6c5",
                    "EndpointID": "a51a4e5ce23406c1944f57de9885820ff8785c0555abc14109a92bf15c745027",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }
    }
]
[root@192 kd]# docker inspect c2|tail -n 20
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "96f4b247785654a0cb26bd2032937500a29f78e90f54846549d7129148e2c6c5",
                    "EndpointID": "0b2ac36497de3d769c6f44f2da324a08715fb4c711b2b71034a51c3d2b9dac2d",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.3",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:03",
                    "DriverOpts": null
                }
            }
        }
    }
]
```

可以看出c1的网络地址是172.17.0.2，c2的网络地址是172.17.0.3，每个容器都有自己的网络地址。

当c2宕机后，重新启动一个容器，它的网络地址是172.17.0.3，容器内部的IP是会变化的。



## Docker的网络模式

| 网络模式  | 命令                            | 描述                                                         |
| --------- | ------------------------------- | ------------------------------------------------------------ |
| bridge    | -network bridge                 | 为每一个容器分配、设置 `ip` ，并将容器连接到 `docker0` 虚拟网桥上，这也是默认网络模式 |
| host      | -network host                   | 容器不会创建自己的网卡，配置 `ip` 等，而是使用宿主机的 `ip` 和端口 |
| container | -network container:容器名称或id | 新创建的容器不会创建自己的网卡和配置自己的`ip`，而是和一个指定的容器共享`ip`、端口范围 |
| none      | -network none                   | 容器有独立的`Network namespace`，但并没有对其进行任何网络设置 |

### 桥接模式-bridge

Docker服务启动 时，默认会创建一个名称为 docker0 网桥（其上有一个名称为 docker0 内部接口）。

该桥接网络的名称为docker0，它在内核层连通了其他的物理或虚拟网卡，这就将所有容器和本地主机都放到同一个物理网络。

Docker会默认指定docker0 的 ip地址和子网掩码，让主机和容器之间可以通过网桥相互通信。

#### 原理图

![image-20230415223438212](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230415223438212.png)

#### 模式解析

- Docker使用Linux桥接的方式，在宿主机虚拟一个Docker容器网桥docker0.

  Docker每启动一个容器时会根据Docker网桥的网段分配给容器一个ip地址，同时Docker网桥是每个容器的默认网关。

  同一宿主机内的容器都接入同一个网桥，这样容器之间就能够通过容器的Container-IP直接通信。

- docker run创建容器的时，未指定network的容器默认的网络模式就是bridge，使用的就是docker0。

  在宿主机ifconfig，就可以看到docker0和自己创建的network：

  - eth0，eth1……代表网卡一，网卡二……
  - lo代表127.0.0.1(localhost)
  - inet addr表示网卡的ip地址

- 网桥docker0会创建一对对等虚拟设备接口：一个叫veth，另一个叫eth0，成对匹配。

  - 整个宿主机的网桥模式都是docker0，类似一个交换机有一堆接口，每个接口叫veth，
  - 在本地主机和容器内分别创建一个虚拟接口，并让他们彼此联通（这样一对接口叫veth pair）；
  - 每个容器实例内部也有一块网卡，每个接口叫eth0；
  - docker0上面的每个veth匹配某个容器实例内部的eth0，两两配对。

#### 实例

##### 宿主机

```shell
[root@192 myfile]# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED        STATUS        PORTS     NAMES
0b85c6ee18fe   centos    "/bin/bash"   23 hours ago   Up 23 hours             c2
c0a052a880ee   centos    "/bin/bash"   24 hours ago   Up 23 hours             c1
[root@192 myfile]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:e0:75:08 brd ff:ff:ff:ff:ff:ff
    inet 192.168.12.130/24 brd 192.168.12.255 scope global noprefixroute dynamic ens33
       valid_lft 1267sec preferred_lft 1267sec
    inet6 fe80::23e3:c706:b319:18a6/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:9f:50:4b brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
4: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master virbr0 state DOWN group default qlen 1000
    link/ether 52:54:00:9f:50:4b brd ff:ff:ff:ff:ff:ff
5: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:fa:f5:a7:1d brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:faff:fef5:a71d/64 scope link 
       valid_lft forever preferred_lft forever
28: vethc6328db@if27: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether 0a:87:d1:dc:81:24 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::887:d1ff:fedc:8124/64 scope link 
       valid_lft forever preferred_lft forever
30: veth31b87cd@if29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether 8a:fc:9c:2a:27:77 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::88fc:9cff:fe2a:2777/64 scope link 
       valid_lft forever preferred_lft forever
31: br-9903a7036791: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:08:38:7d:b2 brd ff:ff:ff:ff:ff:ff
    inet 172.19.0.1/16 brd 172.19.255.255 scope global br-9903a7036791
       valid_lft forever preferred_lft forever
```

##### docker容器c2

```shell
[root@0b85c6ee18fe /]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
29: eth0@if30: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

##### docker容器c1

```shell
[root@c0a052a880ee /]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
27: eth0@if28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

##### 总结

从上面的实例可以看出，在宿主机中会产生veth，而在容器中则是eth0，而且两个是成对的，例如容器c1中是27:eth0@if28而宿主机中是28:vethc6328db@if27。

### 主机模式-host

不创建任何网络接口，直接使用宿主机的 `ip`地址与外界进行通信，不再需要额外进行`NAT`转换。

在主机模式下**不能publish port**。

#### 原理图

![image-20230415225526587](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230415225526587.png)

host模式下的容器，和宿主机使用一个IP地址，不会虚拟出自己的。

#### 模式解析

容器将不会获得独立的Network Namespace，而是和宿主机共有一个。

<font color=red>容器不会虚拟出自己的网卡，而是使用宿主机的IP和端口。</font>

容器共享宿主机网络ip，好处：外部主机与容器可以直接通信。

#### 实例

使用主机模式启动tomcat容器。

```shell
[root@192 myfile]# docker run -d -p 8081:8080 --network host --name tomcat81 fb5657adc892
WARNING: Published ports are discarded when using host network mode
91e2be86846e5461caffc325d8a1faf4616623209e1e54afbe89f7778348d3e8
[root@192 myfile]# docker ps
CONTAINER ID   IMAGE          COMMAND             CREATED         STATUS         PORTS     NAMES
91e2be86846e   fb5657adc892   "catalina.sh run"   2 minutes ago   Up 2 minutes             tomcat81
[root@192 myfile]# docker inspect tomcat81|tail -n 20
            "Networks": {
                "host": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "33289ee97f5d777933673e86f5916530debe8c0b7758fff9bc76466fabfac83d",
                    "EndpointID": "1c2c15df9c0d6924ffb63ee74ea72f8fb25fd2b73c0ed4e3d060403034e9f6dc",
                    "Gateway": "",  #这里都是空的
                    "IPAddress": "",
                    "IPPrefixLen": 0,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "",
                    "DriverOpts": null
                }
            }
        }
    }
]
[root@192 myfile]# docker exec -it tomcat81 /bin/bash
root@192:/usr/local/tomcat# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:e0:75:08 brd ff:ff:ff:ff:ff:ff
    inet 192.168.12.130/24 brd 192.168.12.255 scope global dynamic noprefixroute ens33
       valid_lft 981sec preferred_lft 981sec
    inet6 fe80::23e3:c706:b319:18a6/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:9f:50:4b brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
4: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master virbr0 state DOWN group default qlen 1000
    link/ether 52:54:00:9f:50:4b brd ff:ff:ff:ff:ff:ff
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:fa:f5:a7:1d brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:faff:fef5:a71d/64 scope link 
       valid_lft forever preferred_lft forever
31: br-9903a7036791: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:08:38:7d:b2 brd ff:ff:ff:ff:ff:ff
    inet 172.19.0.1/16 brd 172.19.255.255 scope global br-9903a7036791
       valid_lft forever preferred_lft forever
```

##### 小知识

Docker启动时指定--network=host或-net=host，如果还指定了-p映射端口，此时就会有如下警告:

```NARNING: Published ports are discarded when using host network mode```
并且通过-p设置的参数将不会起到任何作用，端口号会以主机端口号为主，重复时则递增。

可以选择无视这个警告或者使用Docker的其他网络模式，例如--network=bridge

```shell
[root@192 myfile]# docker run -d --network host --name tomcat81 fb5657adc892---正确命令
ef886d6b5d88015dbd18862538378ba1e3ff243774da7beb9fb49f56aa893ed9
[root@192 myfile]# docker ps
CONTAINER ID   IMAGE          COMMAND             CREATED         STATUS         PORTS     NAMES
ef886d6b5d88   fb5657adc892   "catalina.sh run"   5 seconds ago   Up 3 seconds             tomcat81
```



### 容器模式-container

#### 原理图

![image-20230415232415296](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230415232415296.png)

#### 模式解析

新建的容器和已经存在的一个容器共享一个网络`ip`配置而不是和宿主机共享。

新创建的容器不会创建自己的网卡，配置自己的`ip`，而是和一个指定的容器共享`ip`、端口范围等。

两个容器除了网络方面，其他的如文件系统、进程列表等还是隔离的。

#### 错误实例

```shell
[root@192 myfile]# docker run -d -p 8085:8080 --name tomcat85 fb5657adc892
a8228954cf9ff6d3b283667bc367721de6832c2867c8af463060d6e42230619a
[root@192 myfile]# docker run -d -p 8086:8080 --network container:tomcat85 --name tomcat86 fb5657adc892
docker: Error response from daemon: conflicting options: port publishing and the container type network mode.
See 'docker run --help'.
```

这里主要是85和86公用了8080端口导致不行。

#### 正确实例

```shell
[root@192 myfile]# docker run -it --name alpine1 alpine /bin/sh
/ # [root@192 myfile]# docker ps
CONTAINER ID   IMAGE     COMMAND     CREATED          STATUS          PORTS     NAMES
c0a69971017e   alpine    "/bin/sh"   11 seconds ago   Up 10 seconds             alpine1
#alpine2的ip addr
[root@192 myfile]# docker run -it --network container:alpine1 --name alpine2 alpine /bin/sh
/ # ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
34: eth0@if35: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever

[root@192 kd]# docker ps
CONTAINER ID   IMAGE     COMMAND     CREATED          STATUS          PORTS     NAMES
ffabd3d09b7b   alpine    "/bin/sh"   17 seconds ago   Up 15 seconds             alpine2
c0a69971017e   alpine    "/bin/sh"   2 minutes ago    Up 2 minutes              alpine1
#alpine1的ip addr
[root@192 kd]# docker exec -it alpine1 /bin/sh
/ # ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
34: eth0@if35: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever

```

关闭alpine1后，alpine2的ip会怎么样呢？（只有本地回环lo）

```shell
[root@192 kd]# docker stop alpine1
alpine1
[root@192 kd]# docker ps
CONTAINER ID   IMAGE     COMMAND     CREATED         STATUS         PORTS     NAMES
ffabd3d09b7b   alpine    "/bin/sh"   3 minutes ago   Up 3 minutes             alpine2
#alpine1关闭后
/ # ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
```

### none模式（少用）

在none模式下，不为Docker容器进行任何网络配置。

也就是说，这个`Docker`容器没有网卡、`ip`、路由等信息，只有一个`lo`接口。

> lo标识代表禁用网络功能，即：127.0.0.1，本地回环的意思

需要我们自己为Docker容器添加网卡、配置IP等。

#### 实例

```shell
[root@192 kd]# docker run -d -p 8082:8080 --network none --name tomcat82 fb5657adc892
912453f9043ca75439465f2e65dfadccdb2800ed70dce74de2cd245bd1a1987a
[root@192 kd]# docker inspect tomcat82 | tail -n 20
            "Networks": {
                "none": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "733d5f73585414733806e47665fe70a4f5bd0a1c2a3bc64e1c5ca0e737645718",
                    "EndpointID": "8587128dee3707afa68c1ad23f1f3bdf2a17068560c4b063fee96bd83c9c649d",
                    "Gateway": "",
                    "IPAddress": "",
                    "IPPrefixLen": 0,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "",
                    "DriverOpts": null
                }
            }
        }
    }
]
[root@192 myfile]# docker exec -it tomcat82 /bin/bash
root@2fc26860a2d8:/usr/local/tomcat# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
```

### 自定义网络

使用create创建的。

#### 新建自定义网络

```shell
[root@192 myfile]# docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
96f4b2477856   bridge    bridge    local
33289ee97f5d   host      host      local
733d5f735854   none      null      local
[root@192 myfile]# docker network create kd_network
263e04e32d822287558a61b6b069a6c751142d23ccd211a4bfce49db48afb9f2
[root@192 myfile]# docker network ls
NETWORK ID     NAME         DRIVER    SCOPE
96f4b2477856   bridge       bridge    local
33289ee97f5d   host         host      local
263e04e32d82   kd_network   bridge    local
733d5f735854   none         null      local
```

#### 新建容器加入上一步的自定义网络

```shell
[root@192 myfile]# docker run -d -p 8081:8080 --network kd_network --name tomcat81 tomcat:7
4d9fc3137ccf6a972b9a42985561d2e354b38bf29a61213fe01b45ad50e97d1d
[root@192 myfile]# docker run -d -p 8082:8080 --network kd_network --name tomcat82 tomcat:7
6691a14727aa78f759bbf61bdcd8350b800111069fff70aa2d20469feb7bc9c1
[root@192 myfile]# docker ps
CONTAINER ID   IMAGE      COMMAND             CREATED          STATUS          PORTS                                       NAMES
6691a14727aa   tomcat:7   "catalina.sh run"   4 seconds ago    Up 3 seconds    0.0.0.0:8082->8080/tcp, :::8082->8080/tcp   tomcat82
4d9fc3137ccf   tomcat:7   "catalina.sh run"   12 seconds ago   Up 11 seconds   0.0.0.0:8081->8080/tcp, :::8081->8080/tcp   tomcat81
```

#### 进入容器，查看ip

```shell
[root@192 myfile]# docker exec -it tomcat81 /bin/bash
root@4d9fc3137ccf:/usr/local/tomcat# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
41: eth0@if42: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:14:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.20.0.2/16 brd 172.20.255.255 scope global eth0
       valid_lft forever preferred_lft forever

[root@192 kd]# docker exec -it tomcat82 /bin/bash
root@6691a14727aa:/usr/local/tomcat# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
43: eth0@if44: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:14:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.20.0.3/16 brd 172.20.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

#### 使用服务名进行ping

```shell
root@6691a14727aa(tomcat82):/usr/local/tomcat# ping tomcat81
PING tomcat81 (172.20.0.2) 56(84) bytes of data.
64 bytes from tomcat81.kd_network (172.20.0.2): icmp_seq=1 ttl=64 time=0.068 ms
64 bytes from tomcat81.kd_network (172.20.0.2): icmp_seq=2 ttl=64 time=0.050 ms
64 bytes from tomcat81.kd_network (172.20.0.2): icmp_seq=3 ttl=64 time=0.045 ms
^C
--- tomcat81 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 4ms
rtt min/avg/max/mdev = 0.045/0.054/0.068/0.011 ms

root@4d9fc3137ccf(tomcat81):/usr/local/tomcat# ping tomcat82
PING tomcat82 (172.20.0.3) 56(84) bytes of data.
64 bytes from tomcat82.kd_network (172.20.0.3): icmp_seq=1 ttl=64 time=0.040 ms
64 bytes from tomcat82.kd_network (172.20.0.3): icmp_seq=2 ttl=64 time=0.050 ms
64 bytes from tomcat82.kd_network (172.20.0.3): icmp_seq=3 ttl=64 time=0.047 ms
^C
--- tomcat82 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 0.040/0.045/0.050/0.008 ms
```

#### 结论

- 自定义网络本身已经维护好了主机名和ip的对应关系（ip和域名都能ping通）

