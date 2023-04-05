# Docker安装

## Docker官网和仓库

docker官网：http://www.docker.com

Docker Hub（镜像仓库）官网：https://hub.docker.com/

## 前提说明

Docker必须部署在Linux内核的系统上，如果其他系统想部署Docker就必须安装一个虚拟Linux环境。

## Docker镜像

Docker镜像Image是一个只读的模板，镜像可以用来创建Docker容器，一个镜像就可以创建很多容器。

它相当于一个root文件系统。

image文件生产的容器实例，本身是一个文件，称为镜像文件。

## Docker仓库

仓库分为公开仓库（Public）和私有仓库（Private）两种形式。

最大的公开仓库就是上面的官网，存放了数量庞大的镜像供用户下载。国内的公开仓库包括阿里云、网易云等。

![image-20230404223202102](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230404223202102.png)

Docker整体架构和通信原理需要花时间理解。

## 安装过程

### 确定CentOS版本

```shell
[root@192 ~]# cat /etc/redhat-release 
CentOS Linux release 7.9.2009 (Core)
```

### 卸载旧版本

Older versions of Docker went by the names of `docker` or `docker-engine`. Uninstall any such older versions before attempting to install a new version, along with associated dependencies:

```shell
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

### yum安装gcc相关

```shell
[root@192 ~]# yum -y install gcc
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
Package gcc-4.8.5-44.el7.x86_64 already installed and latest version
Nothing to do


[root@192 ~]# yum -y install gcc-c++
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
Resolving Dependencies
--> Running transaction check
---> Package gcc-c++.x86_64 0:4.8.5-44.el7 will be installed
--> Processing Dependency: libstdc++-devel = 4.8.5-44.el7 for package: gcc-c++-4.8.5-44.el7.x86_64
--> Running transaction check
---> Package libstdc++-devel.x86_64 0:4.8.5-44.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=============================================================================================================================================================================================
 Package                                            Arch                                      Version                                          Repository                               Size
=============================================================================================================================================================================================
Installing:
 gcc-c++                                            x86_64                                    4.8.5-44.el7                                     base                                    7.2 M
Installing for dependencies:
 libstdc++-devel                                    x86_64                                    4.8.5-44.el7                                     base                                    1.5 M

Transaction Summary
=============================================================================================================================================================================================
Install  1 Package (+1 Dependent package)

Total download size: 8.7 M
Installed size: 25 M
Downloading packages:
warning: /var/cache/yum/x86_64/7/base/packages/libstdc++-devel-4.8.5-44.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY             ]  0.0 B/s | 623 kB  --:--:-- ETA 
Public key for libstdc++-devel-4.8.5-44.el7.x86_64.rpm is not installed
(1/2): libstdc++-devel-4.8.5-44.el7.x86_64.rpm                                                                                                                        | 1.5 MB  00:00:00     
(2/2): gcc-c++-4.8.5-44.el7.x86_64.rpm                                                                                                                                | 7.2 MB  00:00:01     
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                        4.6 MB/s | 8.7 MB  00:00:01     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-9.2009.0.el7.centos.x86_64 (@anaconda)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : libstdc++-devel-4.8.5-44.el7.x86_64                                                                                                                                       1/2 
  Installing : gcc-c++-4.8.5-44.el7.x86_64                                                                                                                                               2/2 
  Verifying  : gcc-c++-4.8.5-44.el7.x86_64                                                                                                                                               1/2 
  Verifying  : libstdc++-devel-4.8.5-44.el7.x86_64                                                                                                                                       2/2 

Installed:
  gcc-c++.x86_64 0:4.8.5-44.el7                                                                                                                                                              

Dependency Installed:
  libstdc++-devel.x86_64 0:4.8.5-44.el7                                                                                                                                                      

Complete!
```

命令如下：

> yum -y install gcc
>
> yum -y install gcc-c++

### 安装需要软件包

安装docker镜像仓库命令如下：

> sudo yum install -y yum-utils
>
> yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

结果：

```shell
[root@192 ~]# yum install -y yum-utils
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
Package yum-utils-1.1.31-54.el7_8.noarch already installed and latest version
Nothing to do
[root@192 ~]# yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
Loaded plugins: fastestmirror, langpacks
adding repo from: https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
grabbing file https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo to /etc/yum.repos.d/docker-ce.repo
repo saved to /etc/yum.repos.d/docker-ce.repo
```

### 更新yum软件包索引

> yum makecache fast

结果：

```shell
[root@192 ~]# yum makecache fast
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
base                                                                                                                                                                  | 3.6 kB  00:00:00     
docker-ce-stable                                                                                                                                                      | 3.5 kB  00:00:00     
extras                                                                                                                                                                | 2.9 kB  00:00:00     
updates                                                                                                                                                               | 2.9 kB  00:00:00     
(1/2): docker-ce-stable/7/x86_64/updateinfo                                                                                                                           |   55 B  00:00:00     
(2/2): docker-ce-stable/7/x86_64/primary_db                                                                                                                           | 102 kB  00:00:00     
Metadata Cache Created

```

### 安装docker engine

> yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

执行结果：

```shell
[root@192 ~]# yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
Resolving Dependencies
--> Running transaction check
---> Package containerd.io.x86_64 0:1.6.20-3.1.el7 will be installed
--> Processing Dependency: container-selinux >= 2:2.74 for package: containerd.io-1.6.20-3.1.el7.x86_64
---> Package docker-buildx-plugin.x86_64 0:0.10.4-1.el7 will be installed
---> Package docker-ce.x86_64 3:23.0.3-1.el7 will be installed
--> Processing Dependency: docker-ce-rootless-extras for package: 3:docker-ce-23.0.3-1.el7.x86_64
---> Package docker-ce-cli.x86_64 1:23.0.3-1.el7 will be installed
---> Package docker-compose-plugin.x86_64 0:2.17.2-1.el7 will be installed
--> Running transaction check
---> Package container-selinux.noarch 2:2.119.2-1.911c772.el7_8 will be installed
---> Package docker-ce-rootless-extras.x86_64 0:23.0.3-1.el7 will be installed
--> Processing Dependency: fuse-overlayfs >= 0.7 for package: docker-ce-rootless-extras-23.0.3-1.el7.x86_64
--> Processing Dependency: slirp4netns >= 0.4 for package: docker-ce-rootless-extras-23.0.3-1.el7.x86_64
--> Running transaction check
---> Package fuse-overlayfs.x86_64 0:0.7.2-6.el7_8 will be installed
--> Processing Dependency: libfuse3.so.3(FUSE_3.2)(64bit) for package: fuse-overlayfs-0.7.2-6.el7_8.x86_64
--> Processing Dependency: libfuse3.so.3(FUSE_3.0)(64bit) for package: fuse-overlayfs-0.7.2-6.el7_8.x86_64
--> Processing Dependency: libfuse3.so.3()(64bit) for package: fuse-overlayfs-0.7.2-6.el7_8.x86_64
---> Package slirp4netns.x86_64 0:0.4.3-4.el7_8 will be installed
--> Running transaction check
---> Package fuse3-libs.x86_64 0:3.6.1-4.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=============================================================================================================================================================================================
 Package                                             Arch                             Version                                               Repository                                  Size
=============================================================================================================================================================================================
Installing:
 containerd.io                                       x86_64                           1.6.20-3.1.el7                                        docker-ce-stable                            34 M
 docker-buildx-plugin                                x86_64                           0.10.4-1.el7                                          docker-ce-stable                            12 M
 docker-ce                                           x86_64                           3:23.0.3-1.el7                                        docker-ce-stable                            23 M
 docker-ce-cli                                       x86_64                           1:23.0.3-1.el7                                        docker-ce-stable                            13 M
 docker-compose-plugin                               x86_64                           2.17.2-1.el7                                          docker-ce-stable                            12 M
Installing for dependencies:
 container-selinux                                   noarch                           2:2.119.2-1.911c772.el7_8                             extras                                      40 k
 docker-ce-rootless-extras                           x86_64                           23.0.3-1.el7                                          docker-ce-stable                           8.8 M
 fuse-overlayfs                                      x86_64                           0.7.2-6.el7_8                                         extras                                      54 k
 fuse3-libs                                          x86_64                           3.6.1-4.el7                                           extras                                      82 k
 slirp4netns                                         x86_64                           0.4.3-4.el7_8                                         extras                                      81 k

Transaction Summary
=============================================================================================================================================================================================
Install  5 Packages (+5 Dependent packages)

Total download size: 103 M
Installed size: 366 M
Is this ok [y/d/N]: y
Downloading packages:
(1/10): container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm                                                                                                          |  40 kB  00:00:00     
warning: /var/cache/yum/x86_64/7/docker-ce-stable/packages/docker-buildx-plugin-0.10.4-1.el7.x86_64.rpm: Header V4 RSA/SHA512 Signature, key ID 621e9f35: NOKEY9 MB/s |  23 MB  00:00:42 ETA 
Public key for docker-buildx-plugin-0.10.4-1.el7.x86_64.rpm is not installed
(2/10): docker-buildx-plugin-0.10.4-1.el7.x86_64.rpm                                                                                                                  |  12 MB  00:00:11     
(3/10): containerd.io-1.6.20-3.1.el7.x86_64.rpm                                                                                                                       |  34 MB  00:00:32     
(4/10): docker-ce-23.0.3-1.el7.x86_64.rpm                                                                                                                             |  23 MB  00:00:22     
(5/10): docker-ce-rootless-extras-23.0.3-1.el7.x86_64.rpm                                                                                                             | 8.8 MB  00:00:08     
(6/10): fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm                                                                                                                       |  54 kB  00:00:00     
(7/10): slirp4netns-0.4.3-4.el7_8.x86_64.rpm                                                                                                                          |  81 kB  00:00:00     
(8/10): fuse3-libs-3.6.1-4.el7.x86_64.rpm                                                                                                                             |  82 kB  00:00:00     
(9/10): docker-ce-cli-23.0.3-1.el7.x86_64.rpm                                                                                                                         |  13 MB  00:00:12     
(10/10): docker-compose-plugin-2.17.2-1.el7.x86_64.rpm                                                                                                                |  12 MB  00:00:09     
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                        2.0 MB/s | 103 MB  00:00:51     
Retrieving key from https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
Importing GPG key 0x621E9F35:
 Userid     : "Docker Release (CE rpm) <docker@docker.com>"
 Fingerprint: 060a 61c5 1b55 8a7f 742b 77aa c52f eb6b 621e 9f35
 From       : https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
Is this ok [y/N]: y
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : 2:container-selinux-2.119.2-1.911c772.el7_8.noarch                                                                                                                       1/10 
  Installing : containerd.io-1.6.20-3.1.el7.x86_64                                                                                                                                      2/10 
  Installing : docker-compose-plugin-2.17.2-1.el7.x86_64                                                                                                                                3/10 
  Installing : slirp4netns-0.4.3-4.el7_8.x86_64                                                                                                                                         4/10 
  Installing : docker-buildx-plugin-0.10.4-1.el7.x86_64                                                                                                                                 5/10 
  Installing : 1:docker-ce-cli-23.0.3-1.el7.x86_64                                                                                                                                      6/10 
  Installing : fuse3-libs-3.6.1-4.el7.x86_64                                                                                                                                            7/10 
  Installing : fuse-overlayfs-0.7.2-6.el7_8.x86_64                                                                                                                                      8/10 
  Installing : 3:docker-ce-23.0.3-1.el7.x86_64                                                                                                                                          9/10 
  Installing : docker-ce-rootless-extras-23.0.3-1.el7.x86_64                                                                                                                           10/10 
  Verifying  : docker-ce-rootless-extras-23.0.3-1.el7.x86_64                                                                                                                            1/10 
  Verifying  : fuse3-libs-3.6.1-4.el7.x86_64                                                                                                                                            2/10 
  Verifying  : 1:docker-ce-cli-23.0.3-1.el7.x86_64                                                                                                                                      3/10 
  Verifying  : fuse-overlayfs-0.7.2-6.el7_8.x86_64                                                                                                                                      4/10 
  Verifying  : docker-buildx-plugin-0.10.4-1.el7.x86_64                                                                                                                                 5/10 
  Verifying  : 3:docker-ce-23.0.3-1.el7.x86_64                                                                                                                                          6/10 
  Verifying  : 2:container-selinux-2.119.2-1.911c772.el7_8.noarch                                                                                                                       7/10 
  Verifying  : containerd.io-1.6.20-3.1.el7.x86_64                                                                                                                                      8/10 
  Verifying  : slirp4netns-0.4.3-4.el7_8.x86_64                                                                                                                                         9/10 
  Verifying  : docker-compose-plugin-2.17.2-1.el7.x86_64                                                                                                                               10/10 

Installed:
  containerd.io.x86_64 0:1.6.20-3.1.el7               docker-buildx-plugin.x86_64 0:0.10.4-1.el7         docker-ce.x86_64 3:23.0.3-1.el7         docker-ce-cli.x86_64 1:23.0.3-1.el7        
  docker-compose-plugin.x86_64 0:2.17.2-1.el7        

Dependency Installed:
  container-selinux.noarch 2:2.119.2-1.911c772.el7_8     docker-ce-rootless-extras.x86_64 0:23.0.3-1.el7     fuse-overlayfs.x86_64 0:0.7.2-6.el7_8     fuse3-libs.x86_64 0:3.6.1-4.el7    
  slirp4netns.x86_64 0:0.4.3-4.el7_8                    

Complete!

```

### 启动docker

> systemctl start docker
> systemctl status docker

执行结果：

```shell
[root@192 ~]# systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: https://docs.docker.com
[root@192 ~]# systemctl start docker
[root@192 ~]# systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2023-04-05 02:21:22 PDT; 2s ago
     Docs: https://docs.docker.com
 Main PID: 52695 (dockerd)
    Tasks: 7
   Memory: 84.4M
   CGroup: /system.slice/docker.service
           └─52695 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Apr 05 02:21:20 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:20.657396557-07:00" level=info msg="[core] [Channel #4] Channel Connectivity change to READY" module=grpc
Apr 05 02:21:20 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:20.703841658-07:00" level=info msg="Loading containers: start."
Apr 05 02:21:21 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:21.621857331-07:00" level=info msg="Default bridge (docker0) is assigned with an IP address 172.17.0.0/1... IP address"
Apr 05 02:21:21 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:21.850315156-07:00" level=info msg="Firewalld: interface docker0 already part of docker zone, returning"
Apr 05 02:21:21 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:21.941546288-07:00" level=info msg="Loading containers: done."
Apr 05 02:21:22 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:22.004945157-07:00" level=info msg="Docker daemon" commit=59118bf graphdriver=overlay2 version=23.0.3
Apr 05 02:21:22 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:22.005104385-07:00" level=info msg="Daemon has completed initialization"
Apr 05 02:21:22 192.168.12.130 systemd[1]: Started Docker Application Container Engine.
Apr 05 02:21:22 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:22.027054127-07:00" level=info msg="[core] [Server #7] Server created" module=grpc
Apr 05 02:21:22 192.168.12.130 dockerd[52695]: time="2023-04-05T02:21:22.055933730-07:00" level=info msg="API listen on /run/docker.sock"
Hint: Some lines were ellipsized, use -l to show in full.
```

### hello-world

```shell
[root@192 ~]# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete 
Digest: sha256:2498fce14358aa50ead0cc6c19990fc6ff866ce72aeb5546e1d59caac3d0d60f
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

[root@192 ~]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
hello-world   latest    feb5d9fea6a5   18 months ago   13.3kB

```

## 问题记录

现象：

```
[root@192 ~]# docker run hello-world
Unable to find image 'hello-world:latest' locally
docker: Error response from daemon: Get "https://registry-1.docker.io/v2/": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers).
See 'docker run --help'.
```

尝试了很多方法都没有效果，后面是用修改dns解析的方法解决的

https://cloud.tencent.com/developer/article/1627708

https://blog.csdn.net/qq_36963950/article/details/127523445