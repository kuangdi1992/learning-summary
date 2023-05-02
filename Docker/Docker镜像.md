## UnionFS联合文件系统

UnionFS(联合文件系统)是一种分层、轻量级并且高性能的文件系统，支持对文件系统的修改作为一次提交来一层一层的叠加，可以将不同目录挂载到同一个虚拟文件系统下。

## Docker镜像加载原理

docker的镜像实际上由一层一层的文件系统组成，这种层级的文件系统UnionFS。

bootfs主要包含BootLoader和kernel，BootLoader主要引导加载kernel，Linux刚启动时会加载bootfs文件系统，在Docker镜像最底层是引导文件系统bootfs。

当boot加载完成之后，整个内核就都在内存中了，此时内存的使用权由bootfs交由内核，系统卸载bootfs。

rootfs，在bootfs之上，包含典型的Linux系统中的/dev、/proc、/bin等标准目录和文件。

对于一个精简的OS来说，rootfs可以很小，只需要基本的命令工具和程序库就行。

## 镜像分层的作用

镜像分层的最大好处：资源共享，方便复制迁移，为了复用。

docker镜像层都是只读的，容器层是可写的。

当容器启动时，一个新的可写层会被加载到镜像的顶部，这一层通常被称为“容器层”，容器层之下叫做镜像层。

## docker commit

第一步：运行基础的ubuntu镜像，命令如下：

```shell
[root@192 etc]# docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
ubuntu       latest    ba6acccedd29   17 months ago   72.8MB
redis        6.0.8     16ecd2772934   2 years ago     104MB
[root@192 etc]# docker run -it ubuntu /bin/bash
root@6505ac44512b:/# ls
bin   dev  home  lib32  libx32  mnt  proc  run   srv  tmp  var
boot  etc  lib   lib64  media   opt  root  sbin  sys  usr
root@6505ac44512b:/# vi a.txt
bash: vi: command not found
```

可以看到，运行基础Ubuntu镜像后，生成一个6505ac44512b的容器，其中没有vi命令。

第二步：使当前容器具有vi命令

```shell
root@6505ac44512b:/# apt-get update 
Get:1 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]
Get:2 http://archive.ubuntu.com/ubuntu focal InRelease [265 kB]
Get:3 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [28.5 kB]
Get:4 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [2590 kB]
Get:5 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
Get:6 http://archive.ubuntu.com/ubuntu focal-backports InRelease [108 kB]
Get:7 http://archive.ubuntu.com/ubuntu focal/restricted amd64 Packages [33.4 kB]
Get:8 http://archive.ubuntu.com/ubuntu focal/multiverse amd64 Packages [177 kB]
Get:9 http://archive.ubuntu.com/ubuntu focal/universe amd64 Packages [11.3 MB]          
Get:10 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [1028 kB] 
Get:11 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [2060 kB]
Get:12 http://archive.ubuntu.com/ubuntu focal/main amd64 Packages [1275 kB]                            
Get:13 http://archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 Packages [31.2 kB]              
Get:14 http://archive.ubuntu.com/ubuntu focal-updates/restricted amd64 Packages [2198 kB]              
Get:15 http://archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [1324 kB]                
Get:16 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [3069 kB]                    
Get:17 http://archive.ubuntu.com/ubuntu focal-backports/universe amd64 Packages [28.6 kB]              
Get:18 http://archive.ubuntu.com/ubuntu focal-backports/main amd64 Packages [55.2 kB]                  
Fetched 25.8 MB in 15s (1669 kB/s)                                                                     
Reading package lists... Done

root@6505ac44512b:/# apt-get -y install vim
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  alsa-topology-conf alsa-ucm-conf file libasound2 libasound2-data libcanberra0 libexpat1 libgpm2
  libltdl7 libmagic-mgc libmagic1 libmpdec2 libogg0 libpython3.8 libpython3.8-minimal
  libpython3.8-stdlib libreadline8 libsqlite3-0 libssl1.1 libtdb1 libvorbis0a libvorbisfile3
  mime-support readline-common sound-theme-freedesktop vim-common vim-runtime xxd xz-utils
……
Processing triggers for libc-bin (2.31-0ubuntu9.2) ...
root@6505ac44512b:/# vim a.txt
root@6505ac44512b:/# vim a.txt
root@6505ac44512b:/# cat a.txt
this is docker
```

到这里可以看到，容器中有了vim命令。

第三步：使用docker commit提交容器副本，使之称为一个新的镜像

> docker commit -m="提交的描述信息" -a="作者" 容器ID 目标镜像名:标签名

```shell
[root@192 ~]# docker commit -m="add vim cmd" -a="kd" 6505ac44512b kd/myubuntu:1.1
sha256:dac744a2b764116c33700f4bd13853bed724ffbffdfb368fd60690f8b2ed9f79
[root@192 ~]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
kd/myubuntu   1.1       dac744a2b764   4 seconds ago   183MB
ubuntu        latest    ba6acccedd29   17 months ago   72.8MB
redis         6.0.8     16ecd2772934   2 years ago     104MB

[root@192 ~]# docker run -it dac744a2b764 /bin/bash
root@e48111591c22:/# vim a.txt
root@e48111591c22:/# 
```

