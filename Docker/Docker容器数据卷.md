# 介绍

卷是目录和文件，存在于一个或多个容器中，由docker挂载到容器，但不属于联合文件系统，因此能够绕过UnionFS提供一些用于持续存储或共享数据的特性。——将docker容器内的数据保存进宿主机的磁盘中。

卷的设计目的：数据持久化，独立于容器的生命周期，因此docker不会在容器删除时删除其挂载的数据卷。

# 作用

将容器中的数据备份到宿主机的磁盘中。

特点：

> - 数据卷可在容器之间共享或重用数据；
> - 卷中的更改可以直接实时生效；
> - 数据卷中的更改不会包含在镜像的更新中；
> - 数据卷的生命周期一直持续到没有容器使用它为止。

# 数据卷运用

## 如何运行一个带有容器数据卷存储功能的容器实例

```shell
docker run -it --privileged=true -v /宿主机绝对路径目录:/容器内目录 镜像名
```

```shell
[root@192 ~]# docker images
REPOSITORY                     TAG       IMAGE ID       CREATED         SIZE
192.168.12.130:5000/kdubuntu   1.2       9582a943a6b6   6 hours ago     116MB
kd/myubuntu                    1.2       9582a943a6b6   6 hours ago     116MB
registry                       latest    b8604a3fe854   17 months ago   26.2MB
ubuntu                         latest    ba6acccedd29   17 months ago   72.8MB
redis                          6.0.8     16ecd2772934   2 years ago     104MB
[root@192 ~]# docker run -it --privileged=true -v /tmp/host_data:/tmp/docker_data --name=u1 ubuntu
root@6f9775c9af9a:/# pwd
/
root@6f9775c9af9a:/# cd /tmp
root@6f9775c9af9a:/tmp# ll
total 0
drwxrwxrwt. 1 root root 25 Apr  8 14:33 ./
drwxr-xr-x. 1 root root 17 Apr  8 14:33 ../
drwxr-xr-x. 2 root root  6 Apr  8 14:33 docker_data/
root@6f9775c9af9a:/tmp# cd docker_data/
root@6f9775c9af9a:/tmp/docker_data# ll
total 0
drwxr-xr-x. 2 root root  6 Apr  8 14:33 ./
drwxrwxrwt. 1 root root 25 Apr  8 14:33 ../
root@6f9775c9af9a:/tmp/docker_data# 

[root@192 tmp]# ll
total 147440
-rw-r--r--. 1 root    root    75157504 Apr  5 07:59 abd.tar
-rw-r--r--. 1 root    root           0 Apr  5 07:55 a.txt
drwx------. 2 kuangdi kuangdi       25 Apr  5 03:04 firefox
drwxr-xr-x. 2 root    root           6 Apr  8 07:33 host_data
drwxr-xr-x. 2 root    root          18 Apr  5 01:09 hsperfdata_root
[root@192 host_data]# ll
total 0
```

当前容器中，有/tmp/docker_data目录，按照之前分析，/tmp/docker_data目录与宿主机中的/tmp/host_data对应，那么在/tmp/docker_data目录下创建的文件在宿主机中的/tmp/host_data目录下也可以看见，反之亦然。

```shell
root@6f9775c9af9a:/tmp/docker_data# touch dockerin.txt
root@6f9775c9af9a:/tmp/docker_data# ll
total 0
drwxr-xr-x. 2 root root 26 Apr  8 14:36 ./
drwxrwxrwt. 1 root root 25 Apr  8 14:33 ../
-rw-r--r--. 1 root root  0 Apr  8 14:36 dockerin.txt
 
[root@192 host_data]# ll
total 0
-rw-r--r--. 1 root root 0 Apr  8 07:36 dockerin.txt
```

## 查看数据卷是否挂载成功

```shell
docker inspect 容器ID
```

```shell
[root@192 host_data]# docker inspect 6f9775c9af9a
[
    {
        "Id": "6f9775c9af9a16c58ff205801c42112a99d4a62c39b42f68a42470f30679926d",
        "Created": "2023-04-08T14:33:26.684139466Z",
        "Path": "bash",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 3015,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2023-04-08T14:33:27.738661741Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:ba6acccedd2923aee4c2acc6a23780b14ed4b8a5fa4e14e252a23b846df9b6c1",
        "ResolvConfPath": "/var/lib/docker/containers/6f9775c9af9a16c58ff205801c42112a99d4a62c39b42f68a42470f30679926d/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/6f9775c9af9a16c58ff205801c42112a99d4a62c39b42f68a42470f30679926d/hostname",
        "HostsPath": "/var/lib/docker/containers/6f9775c9af9a16c58ff205801c42112a99d4a62c39b42f68a42470f30679926d/hosts",
        "LogPath": "/var/lib/docker/containers/6f9775c9af9a16c58ff205801c42112a99d4a62c39b42f68a42470f30679926d/6f9775c9af9a16c58ff205801c42112a99d4a62c39b42f68a42470f30679926d-json.log",
        "Name": "/u1",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": [
                "/tmp/host_data:/tmp/docker_data"
            ],
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "ConsoleSize": [
                38,
                104
            ],
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "host",
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": true,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": [
                "label=disable"
            ],
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": [],
            "BlkioDeviceWriteBps": [],
            "BlkioDeviceReadIOps": [],
            "BlkioDeviceWriteIOps": [],
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": false,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": null,
            "ReadonlyPaths": null
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/99549b82dea04814af5b2a2c0cfa91b6a1e078f1a86335383fc0e650f43c8ae4-init/diff:/var/lib/docker/overlay2/e81934f365fe1844be16c8c2bb2c4ad0832d2175eac46591283af567f8efd491/diff",
                "MergedDir": "/var/lib/docker/overlay2/99549b82dea04814af5b2a2c0cfa91b6a1e078f1a86335383fc0e650f43c8ae4/merged",
                "UpperDir": "/var/lib/docker/overlay2/99549b82dea04814af5b2a2c0cfa91b6a1e078f1a86335383fc0e650f43c8ae4/diff",
                "WorkDir": "/var/lib/docker/overlay2/99549b82dea04814af5b2a2c0cfa91b6a1e078f1a86335383fc0e650f43c8ae4/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/tmp/host_data",
                "Destination": "/tmp/docker_data",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ]  
    }
]

```

另外当容器stop后，在宿主机上进行文件修改，这些修改同样会同步到容器中。

# 读写规则映射添加说明

读写（默认）命令：

```shell
docker run -it --privileged=true -v /宿主机绝对路径目录:/容器内目录:rw 镜像名
```

只读命令：

容器实例内部被限制，只能读不能写，此时如果宿主机写入内容可以同步到容器中，容器内可以读，但是没有写的功能。

```shell
docker run -it --privileged=true -v /宿主机绝对路径目录:/容器内目录:ro 镜像名
```

# 容器数据卷的继承和共享

## 容器1完成和宿主机的映射

```shell
[root@192 ~]# docker run -it --privileged=true -v /tmp/host_data:/tmp/docker_data --name=u1 ubuntu
root@6f9775c9af9a:/# pwd
/
root@6f9775c9af9a:/# cd /tmp
root@6f9775c9af9a:/tmp# ll
total 0
drwxrwxrwt. 1 root root 25 Apr  8 14:33 ./
drwxr-xr-x. 1 root root 17 Apr  8 14:33 ../
drwxr-xr-x. 2 root root  6 Apr  8 14:33 docker_data/
[root@192 host_data]# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS          PORTS     NAMES
6f9775c9af9a   ubuntu    "bash"    19 minutes ago   Up 19 minutes             u1
```

实现了容器和宿主机的映射。

## 容器2继承容器1的卷规则

```shell
docker run -it --privileged=true --volumes-from 父类 镜像名
```

```shell
[root@192 host_data]# docker run -it --privileged=true --volumes-from u1 --name u2 ubuntu /bin/bash
root@d25e7bd306ac:/# cd /tmp/docker_data/
root@d25e7bd306ac:/tmp/docker_data# ll
total 0
drwxr-xr-x. 2 root root 40 Apr  8 14:54 ./
drwxrwxrwt. 1 root root 25 Apr  8 14:56 ../
-rw-r--r--. 1 root root  0 Apr  8 14:36 dockerin.txt
-rw-r--r--. 1 root root  0 Apr  8 14:54 kd.txt
[root@192 ~]# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS          PORTS     NAMES
d25e7bd306ac   ubuntu    "/bin/bash"   47 seconds ago   Up 45 seconds             u2
6f9775c9af9a   ubuntu    "bash"        24 minutes ago   Up 24 minutes             u1
#这里可以看到生成了u2
#在u2容器中，创建文件
root@d25e7bd306ac:/tmp/docker_data# touch kd_u2.txt
root@d25e7bd306ac:/tmp/docker_data# ll
total 0
drwxr-xr-x. 2 root root 57 Apr  8 14:58 ./
drwxrwxrwt. 1 root root 25 Apr  8 14:56 ../
-rw-r--r--. 1 root root  0 Apr  8 14:36 dockerin.txt
-rw-r--r--. 1 root root  0 Apr  8 14:54 kd.txt
-rw-r--r--. 1 root root  0 Apr  8 14:58 kd_u2.txt
#查看u1中是否存在
root@6f9775c9af9a:/tmp/docker_data# ll
total 0
drwxr-xr-x. 2 root root 57 Apr  8 14:58 ./
drwxrwxrwt. 1 root root 25 Apr  8 14:33 ../
-rw-r--r--. 1 root root  0 Apr  8 14:36 dockerin.txt
-rw-r--r--. 1 root root  0 Apr  8 14:54 kd.txt
-rw-r--r--. 1 root root  0 Apr  8 14:58 kd_u2.txt
#查看宿主机中是否存在
[root@192 host_data]# ll
total 0
-rw-r--r--. 1 root root 0 Apr  8 07:36 dockerin.txt
-rw-r--r--. 1 root root 0 Apr  8 07:54 kd.txt
-rw-r--r--. 1 root root 0 Apr  8 07:58 kd_u2.txt
#同理，在宿主机、u1上创建，在其他的上也可以看到
```

退出u1容器，u2和宿主机之前的映射是否还有？

```shell
[root@192 host_data]# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
d25e7bd306ac   ubuntu    "/bin/bash"   4 minutes ago   Up 4 minutes             u2
#退出u1
#在u2中创建文件
root@d25e7bd306ac:/tmp/docker_data# touch kd_test.txt
root@d25e7bd306ac:/tmp/docker_data# ll
total 0
drwxr-xr-x. 2 root root 76 Apr  8 15:01 ./
drwxrwxrwt. 1 root root 25 Apr  8 14:56 ../
-rw-r--r--. 1 root root  0 Apr  8 14:36 dockerin.txt
-rw-r--r--. 1 root root  0 Apr  8 14:54 kd.txt
-rw-r--r--. 1 root root  0 Apr  8 15:01 kd_test.txt
-rw-r--r--. 1 root root  0 Apr  8 14:58 kd_u2.txt
#宿主机
[root@192 host_data]# ll
total 0
-rw-r--r--. 1 root root 0 Apr  8 07:36 dockerin.txt
-rw-r--r--. 1 root root 0 Apr  8 08:01 kd_test.txt
-rw-r--r--. 1 root root 0 Apr  8 07:54 kd.txt
-rw-r--r--. 1 root root 0 Apr  8 07:58 kd_u2.txt
#同样生成了kd_test.txt文件
#重新启动u1容器，查看文件
[root@192 host_data]# docker ps -n 2
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS                     PORTS     NAMES
d25e7bd306ac   ubuntu    "/bin/bash"   6 minutes ago    Up 6 minutes                         u2
6f9775c9af9a   ubuntu    "bash"        30 minutes ago   Exited (0) 3 minutes ago             u1
[root@192 host_data]# docker start 6f9775c9af9a
6f9775c9af9a
[root@192 host_data]# docker exec -it 6f9775c9af9a /bin/bash
root@6f9775c9af9a:/# cd /tmp/docker_data/
root@6f9775c9af9a:/tmp/docker_data# ll
total 0
drwxr-xr-x. 2 root root 76 Apr  8 15:01 ./
drwxrwxrwt. 1 root root 25 Apr  8 14:33 ../
-rw-r--r--. 1 root root  0 Apr  8 14:36 dockerin.txt
-rw-r--r--. 1 root root  0 Apr  8 14:54 kd.txt
-rw-r--r--. 1 root root  0 Apr  8 15:01 kd_test.txt
-rw-r--r--. 1 root root  0 Apr  8 14:58 kd_u2.txt
#可以看到同样生成了。
```

