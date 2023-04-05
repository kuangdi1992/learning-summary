# 帮助启动类命令

## 启动docker

```shell
systemctl start docker
```

## 停止docker

```shell
systemctl stop docker
```

## 重启docker

```shell
systemctl restart docker
```

## 查看docker状态

```shell
systemctl status docker

[root@192 ~]# systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2023-04-05 03:15:27 PDT; 2h 50min ago
     Docs: https://docs.docker.com
 Main PID: 57020 (dockerd)
    Tasks: 9
   Memory: 26.8M
   CGroup: /system.slice/docker.service
           └─57020 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Apr 05 03:17:13 192.168.12.130 dockerd[57020]: time="2023-04-05T03:17:13.108401248-07:00" level=warning msg="Error getting v2 registry: Get \"https://registry-1.docker.io/v2/...ng headers)"
Apr 05 03:17:13 192.168.12.130 dockerd[57020]: time="2023-04-05T03:17:13.108437677-07:00" level=info msg="Attempting next endpoint for pull after error: Get \"https://registr...ng headers)"
Apr 05 03:17:13 192.168.12.130 dockerd[57020]: time="2023-04-05T03:17:13.139117872-07:00" level=error msg="Handler for POST /v1.42/images/create returned error: Get \"https:/...ng headers)"
Apr 05 03:20:45 192.168.12.130 dockerd[57020]: time="2023-04-05T03:20:45.052387199-07:00" level=warning msg="Error getting v2 registry: Get \"https://k8s.gcr.io/v2/\": net/ht...ng headers)"
Apr 05 03:20:45 192.168.12.130 dockerd[57020]: time="2023-04-05T03:20:45.053131992-07:00" level=info msg="Attempting next endpoint for pull after error: Get \"https://k8s.gcr...ng headers)"
Apr 05 03:20:45 192.168.12.130 dockerd[57020]: time="2023-04-05T03:20:45.102424271-07:00" level=error msg="Handler for POST /v1.42/images/create returned error: Get \"https:/...ng headers)"
Apr 05 03:24:00 192.168.12.130 dockerd[57020]: time="2023-04-05T03:24:00.307055426-07:00" level=info msg="ignoring event" container=2a8d6b1719d26e4d0b208790f6a1275320c71debd9....TaskDelete"
Apr 05 05:40:43 192.168.12.130 dockerd[57020]: time="2023-04-05T05:40:43.561690199-07:00" level=info msg="ignoring event" container=3808c4f7832a1c6bf40b88b4928aff50d16c021332....TaskDelete"
Apr 05 05:43:03 192.168.12.130 dockerd[57020]: time="2023-04-05T05:43:03.957113181-07:00" level=info msg="ignoring event" container=8256fa646d23b57f951e88b4384df92abfa863d03e....TaskDelete"
Apr 05 05:43:11 192.168.12.130 dockerd[57020]: time="2023-04-05T05:43:11.234024028-07:00" level=info msg="ignoring event" container=b3a5800afb4402e7c22276ebaecfe4172fae70cd59....TaskDelete"
Hint: Some lines were ellipsized, use -l to show in full.
```

## 开机启动

```shell
systemctl enable docker

[root@192 ~]# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
```

## 查看docker概要信息

```shell
docker info

[root@192 ~]# docker info
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.10.4
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.17.2
    Path:     /usr/libexec/docker/cli-plugins/docker-compose

Server:
 Containers: 4
  Running: 0
  Paused: 0
  Stopped: 4
 Images: 2
 Server Version: 23.0.3
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
  Using metacopy: false
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 2806fc1057397dbaeefbea0e4e17bddfbd388f38
 runc version: v1.1.5-0-gf19387a
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
 Kernel Version: 3.10.0-1160.el7.x86_64
 Operating System: CentOS Linux 7 (Core)
 OSType: linux
 Architecture: x86_64
 CPUs: 1
 Total Memory: 972.3MiB
 Name: 192.168.12.130
 ID: ead60f7e-69ed-46e5-ac19-efbb42f7375e
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Registry Mirrors:
  https://pylcjgsv.mirror.aliyuncs.com/
 Live Restore Enabled: false
```

## 查看docker总体帮助文档

```
docker --help
```

## 查看docker命令帮助文档

```shell
docker 具体命令 --help

[root@192 ~]# docker exec --help

Usage:  docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

Execute a command in a running container

Aliases:
  docker container exec, docker exec

Options:
  -d, --detach               Detached mode: run command in the background
      --detach-keys string   Override the key sequence for detaching a container
  -e, --env list             Set environment variables
      --env-file list        Read in a file of environment variables
  -i, --interactive          Keep STDIN open even if not attached
      --privileged           Give extended privileges to the command
  -t, --tty                  Allocate a pseudo-TTY
  -u, --user string          Username or UID (format: "<name|uid>[:<group|gid>]")
  -w, --workdir string       Working directory inside the container
```

# 镜像命令

## docker images

说明：列出本地主机上的镜像

```shell
[root@192 ~]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
ubuntu        latest    ba6acccedd29   17 months ago   72.8MB
hello-world   latest    feb5d9fea6a5   18 months ago   13.3kB
```

各选项说明：

| 选项       | 说明         |
| ---------- | ------------ |
| REPOSITORY | 镜像的仓库源 |
| TAG        | 镜像的标签   |
| IMAGE ID   | 镜像ID       |
| CREATED    | 镜像创建时间 |
| SIZE       | 镜像大小     |

同一个仓库源可以有多个TAG版本，代表这个仓库源的不同版本，使用REPOSITORY:TAG表示版本。

参数：

>  -a：列出本地所有的镜像

> -q：只显示镜像ID

```shell
[root@192 ~]# docker images -a
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
ubuntu        latest    ba6acccedd29   17 months ago   72.8MB
hello-world   latest    feb5d9fea6a5   18 months ago   13.3kB
[root@192 ~]# docker images -q
ba6acccedd29
feb5d9fea6a5
```

## docker search

说明：查找某个镜像是否在远程仓库，后面+镜像名字

命令：

```shell
docker search [OPTIONS] 镜像名字
```

```shell
[root@192 ~]# docker search hello-world
NAME                                       DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
hello-world                                Hello World! (an example of minimal Dockeriz…   2006      [OK]       
rancher/hello-world                                                                        4                    
okteto/hello-world                                                                         0                    
golift/hello-world                         Hello World Go-App built by Go Lift Applicat…   0                    
tacc/hello-world                                                                           0                    
armswdev/c-hello-world                     Simple hello-world C program on Alpine Linux…   0                    
tutum/hello-world                          Image to test docker deployments. Has Apache…   90                   [OK]
thomaspoignant/hello-world-rest-json       This project is a REST hello-world API to bu…   2                    
kitematic/hello-world-nginx                A light-weight nginx container that demonstr…   153                  
dockercloud/hello-world                    Hello World!                                    20                   [OK]
ansibleplaybookbundle/hello-world-apb      An APB which deploys a sample Hello World! a…   1                    [OK]
ansibleplaybookbundle/hello-world-db-apb   An APB which deploys a sample Hello World! a…   2                    [OK]
crccheck/hello-world                       Hello World web server in under 2.5 MB          15                   [OK]
strimzi/hello-world-producer                                                               0                    
strimzi/hello-world-consumer                                                               0                    
businessgeeks00/hello-world-nodejs                                                         0                    
koudaiii/hello-world                                                                       0                    
freddiedevops/hello-world-spring-boot                                                      0                    
strimzi/hello-world-streams                                                                0                    
garystafford/hello-world                   Simple hello-world Spring Boot service for t…   0                    [OK]
ppc64le/hello-world                        Hello World! (an example of minimal Dockeriz…   2                    
tsepotesting123/hello-world                                                                0                    
kevindockercompany/hello-world                                                             0                    
dandando/hello-world-dotnet                                                                0                    
vad1mo/hello-world-rest                    A simple REST Service that echoes back all t…   5                    [OK]
```

各选项说明：

| 选项        | 说明             |
| ----------- | ---------------- |
| NAME        | 镜像名称         |
| DESCRIPTION | 镜像说明         |
| STARS       | 点赞数量         |
| OFFICIAL    | 是否是官方的     |
| AUTOMATED   | 是否是自动构建的 |

参数：

> --limit： 只列出N个镜像，默认为25个
>
> 示例：docker search --limit 5 redis

```shell
[root@192 ~]# docker search --limit 5 redis
NAME                     DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
redis                    Redis is an open source key-value store that…   11980     [OK]       
redislabs/redisearch     Redis With the RedisSearch module pre-loaded…   56                   
redislabs/redisinsight   RedisInsight - The GUI for Redis                82                   
redislabs/rebloom        A probablistic datatypes module for Redis       22                   [OK]
redislabs/redis          Clustered in-memory database engine compatib…   36                   
```

## docker pull

说明：下载镜像

命令：

```shell
docker pull 镜像名字[:TAG] #加上了标签版本号，不加的话，是最新的
docker pull 镜像名字
```

```shell
[root@192 ~]# docker pull redis:6.0.8
6.0.8: Pulling from library/redis
bb79b6b2107f: Pull complete 
1ed3521a5dcb: Pull complete 
5999b99cee8f: Pull complete 
3f806f5245c9: Pull complete 
f8a4497572b2: Pull complete 
eafe3b6b8d06: Pull complete 
Digest: sha256:21db12e5ab3cc343e9376d655e8eabbdbe5516801373e95a8a9e66010c5b8819
Status: Downloaded newer image for redis:6.0.8
docker.io/library/redis:6.0.8
[root@192 ~]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
ubuntu        latest    ba6acccedd29   17 months ago   72.8MB
hello-world   latest    feb5d9fea6a5   18 months ago   13.3kB
redis         6.0.8     16ecd2772934   2 years ago     104MB
```

## docker system df

说明：查看镜像/容器/数据卷所占的空间

> docker system df

```shell
[root@192 ~]# docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          3         2         177MB     104.2MB (58%)
Containers      4         0         24B       24B (100%)
Local Volumes   0         0         0B        0B
Build Cache     0         0         0B        0B
```

## docker rmi

说明：删除镜像

命令：

> docker rmi 仓库名字/IMAGE ID

```shell
[root@192 ~]# docker rmi 16ecd2772934
Untagged: redis:6.0.8
Untagged: redis@sha256:21db12e5ab3cc343e9376d655e8eabbdbe5516801373e95a8a9e66010c5b8819
Deleted: sha256:16ecd277293476392b71021cdd585c40ad68f4a7488752eede95928735e39df4
Deleted: sha256:3746030fff867eb26a0338ad9d3ab832e6c19c7dc008090bcfa95c7b9f16f505
Deleted: sha256:1274ec54ad17d15ec95d2180cb1f791057e86dfcdfcc18cd58610a920e145945
Deleted: sha256:18d156147e54edec9a927080fdc0a53c4a8814b0c717b36dc62e637363c1a98d
Deleted: sha256:a8f09c4919857128b1466cc26381de0f9d39a94171534f63859a662d50c396ca
Deleted: sha256:2ae5fa95c0fce5ef33fbb87a7e2f49f2a56064566a37a83b97d3f668c10b43d6
Deleted: sha256:d0fe97fa8b8cefdffcef1d62b65aba51a6c87b6679628a2b50fc6a7a579f764c
```

强制删除单个：

> docker rmi -f 仓库名字/IMAGE ID

```shell
[root@192 ~]# docker rmi ba6acccedd29
Error response from daemon: conflict: unable to delete ba6acccedd29 (must be forced) - image is being used by stopped container f37e6b1f5e57
```

```shell
[root@192 ~]# docker rmi -f ba6acccedd29
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:626ffe58f6e7566e00254b638eb7e0f3b11d4da9675088f4781a50ae288f3322
Deleted: sha256:ba6acccedd2923aee4c2acc6a23780b14ed4b8a5fa4e14e252a23b846df9b6c1
[root@192 ~]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
hello-world   latest    feb5d9fea6a5   18 months ago   13.3kB
```

强制删除多个：

> docker rmi -f 镜像名1:TAG 镜像名2:TAG

```shell
[root@192 ~]# docker rmi -f ba6acccedd29 feb5d9fea6a5
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:626ffe58f6e7566e00254b638eb7e0f3b11d4da9675088f4781a50ae288f3322
Deleted: sha256:ba6acccedd2923aee4c2acc6a23780b14ed4b8a5fa4e14e252a23b846df9b6c1
Untagged: hello-world:latest
Untagged: hello-world@sha256:2498fce14358aa50ead0cc6c19990fc6ff866ce72aeb5546e1d59caac3d0d60f
Deleted: sha256:feb5d9fea6a5e9606aa995e879d862b825965ba48de054caab5ef356dc6b3412
```

删除全部：

> docker rmi -f $(docker images -qa)

```shell
[root@192 ~]# docker rmi -f $(docker images -qa)
Untagged: hello-world:latest
Untagged: hello-world@sha256:2498fce14358aa50ead0cc6c19990fc6ff866ce72aeb5546e1d59caac3d0d60f
Deleted: sha256:feb5d9fea6a5e9606aa995e879d862b825965ba48de054caab5ef356dc6b3412
```

# 容器命令

> 有镜像，才能创建容器，这个是根本前提。

## 新建+启动容器

命令：

> docker run [OPTIONS] IMAGE [COMMAND] [ARG……]

说明：

| 参数                | 说明                                       |
| ------------------- | ------------------------------------------ |
| --name="容器新名字" | 为容器指定一个名字                         |
| -d                  | 后台运行容器并返回容器ID，即启动守护式容器 |
| -i                  | 以交互模式运行容器，通常与-t同时使用       |
| -t                  | 为容器重新分配一个伪终端，通常与-i同时使用 |
| -P                  | 随机端口映射                               |
| -p                  | 指定端口映射                               |

```shell
[root@192 ~]# docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
ubuntu       latest    ba6acccedd29   17 months ago   72.8MB

[root@192 ~]# docker run -it ba6acccedd29 bash
root@abdd8899ef5d:/# ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 14:01 pts/0    00:00:00 bash
root          9      1  0 14:02 pts/0    00:00:00 ps -ef
root@abdd8899ef5d:/# 
```

## 列出当前所有正在运行的容器

命令：

> docker ps [OPTIONS]

```shell
[root@192 ~]# docker ps
CONTAINER ID   IMAGE          COMMAND   CREATED         STATUS         PORTS     NAMES
abdd8899ef5d   ba6acccedd29   "bash"    3 minutes ago   Up 3 minutes             determined_easley
```

参数说明：

-a：列出所有正在运行的容器，以及历史上运行过个

-l：显示最近创建的容器

-n：显示最近n个创建的容器

-q：只显示容器编号

```shell
[root@192 ~]# docker ps -a
CONTAINER ID   IMAGE          COMMAND    CREATED             STATUS                           PORTS     NAMES
abdd8899ef5d   ba6acccedd29   "bash"     8 minutes ago       Up 8 minutes                               determined_easley
60f7e6ddbe31   ba6acccedd29   "bash"     11 minutes ago      Exited (0) 8 minutes ago                   kind_tharp
f37e6b1f5e57   ubuntu         "bash"     32 minutes ago      Exited (0) 32 minutes ago                  stoic_grothendieck
b3a5800afb44   ubuntu         "bash"     About an hour ago   Exited (130) About an hour ago             exciting_black
8256fa646d23   ubuntu         "bash"     About an hour ago   Exited (127) About an hour ago             lucid_wescoff
3808c4f7832a   feb5d9fea6a5   "/hello"   About an hour ago   Exited (0) About an hour ago               epic_chatelet
2a8d6b1719d2   feb5d9fea6a5   "/hello"   4 hours ago         Exited (0) 4 hours ago                     frosty_mcnulty
[root@192 ~]# docker ps -l
CONTAINER ID   IMAGE          COMMAND   CREATED         STATUS         PORTS     NAMES
abdd8899ef5d   ba6acccedd29   "bash"    8 minutes ago   Up 8 minutes             determined_easley
[root@192 ~]# docker ps -n 1
CONTAINER ID   IMAGE          COMMAND   CREATED         STATUS         PORTS     NAMES
abdd8899ef5d   ba6acccedd29   "bash"    9 minutes ago   Up 9 minutes             determined_easley
[root@192 ~]# docker ps -q
abdd8899ef5d
```

## 退出容器

两种退出方式：

> exit：run进去容器，exit退出，容器停止
>
> ctrl+p+q：run进去容器，ctrl+p+q退出，容器不停止

## 启动已经停止运行的容器

命令：

> docker start 容器ID或容器名

```shell
[root@192 ~]# docker ps -n 2
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS                          PORTS     NAMES
cb0168fe2ff4   ba6acccedd29   "/bin/bash"   3 minutes ago   Up 3 minutes                              myu02
5442a45ff119   ba6acccedd29   "/bin/bash"   4 minutes ago   Exited (0) About a minute ago             myu01
[root@192 ~]# docker start 5442a45ff119
5442a45ff119
[root@192 ~]# docker ps 
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS          PORTS     NAMES
cb0168fe2ff4   ba6acccedd29   "/bin/bash"   4 minutes ago   Up 4 minutes              myu02
5442a45ff119   ba6acccedd29   "/bin/bash"   4 minutes ago   Up 11 seconds             myu01
```

## 重启容器

命令：

> docker restart 容器ID或容器名

## 停止容器

命令：

> docker stop 容器ID或容器名

## 强制停止容器

命令：

> docker kill 容器ID或容器名

```shell
[root@192 ~]# docker ps 
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS          PORTS     NAMES
cb0168fe2ff4   ba6acccedd29   "/bin/bash"   4 minutes ago   Up 4 minutes              myu02
5442a45ff119   ba6acccedd29   "/bin/bash"   4 minutes ago   Up 11 seconds             myu01
[root@192 ~]# docker kill cb0168fe2ff4
cb0168fe2ff4
[root@192 ~]# docker ps 
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS              PORTS     NAMES
5442a45ff119   ba6acccedd29   "/bin/bash"   6 minutes ago   Up About a minute             myu01
```

## 删除已经停止的容器

命令：

> docker rm 容器ID或容器名

```shell
[root@192 ~]# docker ps 
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS          PORTS     NAMES
cb0168fe2ff4   ba6acccedd29   "/bin/bash"   7 minutes ago   Up 32 seconds             myu02
5442a45ff119   ba6acccedd29   "/bin/bash"   8 minutes ago   Up 3 minutes              myu01

[root@192 ~]# docker rm cb0168fe2ff4
Error response from daemon: You cannot remove a running container cb0168fe2ff48213c74a6c8f1e7739496280ff394395f3d22be19a948da535e1. Stop the container before attempting removal or force remove

[root@192 ~]# docker stop cb0168fe2ff4
cb0168fe2ff4

[root@192 ~]# docker rm cb0168fe2ff4
cb0168fe2ff4

[root@192 ~]# docker ps
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS         PORTS     NAMES
5442a45ff119   ba6acccedd29   "/bin/bash"   8 minutes ago   Up 3 minutes             myu01

[root@192 ~]# docker start cb0168fe2ff4
Error response from daemon: No such container: cb0168fe2ff4
Error: failed to start containers: cb0168fe2ff4
```

注意：先停止后删除，删除后无法start

#### 强制删除

命令：

> docker rm -f 容器ID或容器名

```shell
[root@192 ~]# docker ps
CONTAINER ID   IMAGE          COMMAND       CREATED          STATUS         PORTS     NAMES
5442a45ff119   ba6acccedd29   "/bin/bash"   10 minutes ago   Up 6 minutes             myu01
[root@192 ~]# docker rm -f 5442a45ff119
5442a45ff119
[root@192 ~]# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## 启动守护式容器（后台运行模式）

命令：

> docker run -d 容器名

```shell
[root@192 ~]# docker run -d redis:6.0.8
95352021574c2e762d46e97a79cf00c851f6501b65dcd46e0ada7124b7dead64
[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS         PORTS      NAMES
95352021574c   redis:6.0.8   "docker-entrypoint.s…"   6 seconds ago   Up 5 seconds   6379/tcp   naughty_mccarthy
```

## 查看容器日志

命令：

> docker logs 容器ID

```shell
[root@192 ~]# docker logs 95352021574c
1:C 05 Apr 2023 14:35:17.448 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:C 05 Apr 2023 14:35:17.448 # Redis version=6.0.8, bits=64, commit=00000000, modified=0, pid=1, just started
1:C 05 Apr 2023 14:35:17.448 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
1:M 05 Apr 2023 14:35:17.449 * Running mode=standalone, port=6379.
1:M 05 Apr 2023 14:35:17.449 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:M 05 Apr 2023 14:35:17.450 # Server initialized
1:M 05 Apr 2023 14:35:17.450 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:M 05 Apr 2023 14:35:17.450 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo madvise > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled (set to 'madvise' or 'never').
1:M 05 Apr 2023 14:35:17.450 * Ready to accept connections
```

## 查看容器内运行的进程

命令：

> docker top 容器ID

```shell
[root@192 ~]# docker top 95352021574c
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
polkitd             64794               64776               0                   07:35               ?                   00:00:00            redis-server *:6379
```

## 查看容器内部细节

命令：

> docker inspect 容器ID

```shell
[root@192 ~]# docker inspect 95352021574c
[
    {
        "Id": "95352021574c2e762d46e97a79cf00c851f6501b65dcd46e0ada7124b7dead64",
        "Created": "2023-04-05T14:35:16.918978317Z",
        "Path": "docker-entrypoint.sh",
        "Args": [
            "redis-server"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 64794,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2023-04-05T14:35:17.418246839Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:16ecd277293476392b71021cdd585c40ad68f4a7488752eede95928735e39df4",
        "ResolvConfPath": "/var/lib/docker/containers/95352021574c2e762d46e97a79cf00c851f6501b65dcd46e0ada7124b7dead64/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/95352021574c2e762d46e97a79cf00c851f6501b65dcd46e0ada7124b7dead64/hostname",
        "HostsPath": "/var/lib/docker/containers/95352021574c2e762d46e97a79cf00c851f6501b65dcd46e0ada7124b7dead64/hosts",
        "LogPath": "/var/lib/docker/containers/95352021574c2e762d46e97a79cf00c851f6501b65dcd46e0ada7124b7dead64/95352021574c2e762d46e97a79cf00c851f6501b65dcd46e0ada7124b7dead64-json.log",
        "Name": "/naughty_mccarthy",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
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
                189
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
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
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
            "MaskedPaths": [
                "/proc/asound",
                "/proc/acpi",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/sys/firmware"
            ],
            "ReadonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/88cf6aab31d7760dceea5bf0db63702ccfefaf46724af20de31638b70f4aa5f5-init/diff:/var/lib/docker/overlay2/02928ca73709c53f403e0006443e01e4efe349160ad7105044c3affaddf05829/diff:/var/lib/docker/overlay2/8e7280e3826c7b37086d4b15df31ae9277e0e136bad018e5c6fba14039fe3e0c/diff:/var/lib/docker/overlay2/500312f0cdc1f41538b6ef59e50ac8512fa72e1f1d73b4b731f6e1216b80213f/diff:/var/lib/docker/overlay2/10a8d0bce4f296db22afd4a42cdb960074657ed4cb6d8b9bb02357e0d2a75f97/diff:/var/lib/docker/overlay2/db108b049ed4ad7619698ee371745ad669dc8117da6ef97cd1a800a3ce4091fb/diff:/var/lib/docker/overlay2/0e1d9dade46f0eee9e29bbe4defd41880380a8b229a5355e08b89e27117b4d52/diff",
                "MergedDir": "/var/lib/docker/overlay2/88cf6aab31d7760dceea5bf0db63702ccfefaf46724af20de31638b70f4aa5f5/merged",
                "UpperDir": "/var/lib/docker/overlay2/88cf6aab31d7760dceea5bf0db63702ccfefaf46724af20de31638b70f4aa5f5/diff",
                "WorkDir": "/var/lib/docker/overlay2/88cf6aab31d7760dceea5bf0db63702ccfefaf46724af20de31638b70f4aa5f5/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [
            {
                "Type": "volume",
                "Name": "7174544cb6bb449106ae1dc520d82f04391cdecf687a2acc6f3c5615e644c076",
                "Source": "/var/lib/docker/volumes/7174544cb6bb449106ae1dc520d82f04391cdecf687a2acc6f3c5615e644c076/_data",
                "Destination": "/data",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
        "Config": {
            "Hostname": "95352021574c",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "6379/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "GOSU_VERSION=1.12",
                "REDIS_VERSION=6.0.8",
                "REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-6.0.8.tar.gz",
                "REDIS_DOWNLOAD_SHA=04fa1fddc39bd1aecb6739dd5dd73858a3515b427acd1e2947a66dadce868d68"
            ],
            "Cmd": [
                "redis-server"
            ],
            "Image": "redis:6.0.8",
            "Volumes": {
                "/data": {}
            },
            "WorkingDir": "/data",
            "Entrypoint": [
                "docker-entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {}
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "47fb2f1a25b6dbed137769fda0f22bc29a19920e50214312a8ab8d1b4b59c59a",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "6379/tcp": null
            },
            "SandboxKey": "/var/run/docker/netns/47fb2f1a25b6",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "57aeafe68a50a20c34678f1a7995898b576289356e8178ddc5ce42fc0ebba998",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "e2c3a0acf795936bd3c61ae5cf9e50b8cfafbcf995c04575c0a6881176fd13ca",
                    "EndpointID": "57aeafe68a50a20c34678f1a7995898b576289356e8178ddc5ce42fc0ebba998",
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

```



## 进入正在运行的容器并以命令行交互

命令一：

> docker exec -it 容器ID /bin/bash

```shell
[root@192 ~]# docker run -it ubuntu /bin/bash
root@cf732f2f4d77:/# 
root@cf732f2f4d77:/# [root@192 ~]# 
[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS      NAMES
cf732f2f4d77   ubuntu        "/bin/bash"              18 seconds ago   Up 17 seconds              youthful_bell
95352021574c   redis:6.0.8   "docker-entrypoint.s…"   8 minutes ago    Up 8 minutes    6379/tcp   naughty_mccarthy
[root@192 ~]# docker exec -it cf732f2f4d77 /bin/bash
root@cf732f2f4d77:/# 
```

exec是在容器中打开新的终端，并且可以启动新的进程，用exit退出，不会导致容器的停止。

```shell
[root@192 ~]# docker exec -it cf732f2f4d77 /bin/bash

[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS      NAMES
cf732f2f4d77   ubuntu        "/bin/bash"              4 minutes ago    Up 25 seconds              youthful_bell
95352021574c   redis:6.0.8   "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes   6379/tcp   naughty_mccarthy

root@cf732f2f4d77:/# exit
exit

[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS      NAMES
cf732f2f4d77   ubuntu        "/bin/bash"              4 minutes ago    Up 25 seconds              youthful_bell
95352021574c   redis:6.0.8   "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes   6379/tcp   naughty_mccarthy
```

命令二：

> docker attach 容器ID 

```shell
root@cf732f2f4d77:/# read escape sequence
[root@192 ~]# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS      NAMES
cf732f2f4d77   ubuntu        "/bin/bash"              2 minutes ago    Up 2 minutes               youthful_bell
95352021574c   redis:6.0.8   "docker-entrypoint.s…"   10 minutes ago   Up 10 minutes   6379/tcp   naughty_mccarthy
[root@192 ~]# docker attach -it cf732f2f4d77 /bin/bash
unknown shorthand flag: 'i' in -it
See 'docker attach --help'.
[root@192 ~]# docker attach cf732f2f4d77
root@cf732f2f4d77:/# 
```

attach是直接进入容器启动命令的终端，不会启动新的进程，用exit退出，会导致容器的停止。

## 从容器内拷贝文件到主机上

命令：

> docker cp 容器ID:容器内路径 目的主机路径

```shell
[root@192 ~]# docker cp 3bfff26b9e08:/tmp/a.txt /tmp/a.txt
Successfully copied 1.536kB to /tmp/a.txt
[root@192 ~]# cd /tmp
[root@192 tmp]# ll
total 220
-rw-r--r--. 1 root    root         0 Apr  5 07:55 a.txt
```

## 导入和导出容器

> export：导出容器的内容左右一个tar归档文件，对应import命令：docker export 容器ID > 文件名.tar
>
> import：从tar包中的内容创建一个新的文件系统再导入为镜像，对应export：cat 文件名.tar | docker import - 镜像用户/镜像名:镜像版本号

```shell
[root@192 tmp]# docker export 769449ef2e46 > kd.tar
[root@192 tmp]# ll
total 73616
-rw-r--r--. 1 root    root    75157504 Apr  5 07:59 kd.tar
```

```shell
[root@192 tmp]# cat kd.tar | docker import - kd/u01:1
sha256:6c4d11c17d23810399791fecb4d7d66a6273cc3e97e18101edd3890ad84919b2
[root@192 tmp]# docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
kd/u01       1         6c4d11c17d23   4 seconds ago   72.8MB
kd/ubuntu    3.7       a0051a6ca222   5 minutes ago   72.8MB
ubuntu       latest    ba6acccedd29   17 months ago   72.8MB
redis        6.0.8     16ecd2772934   2 years ago     104MB
[root@192 tmp]# docker run -it 6c4d11c17d23 /bin/bash
root@274514d0e567:/# cd /tmp
root@274514d0e567:/tmp# ll
total 0
drwxrwxrwt. 2 root root 20 Apr  5 15:03 ./
drwxr-xr-x. 1 root root  6 Apr  5 15:06 ../
-rw-r--r--. 1 root root  0 Apr  5 15:03 kd.txt

```



# 面试题

## docker虚悬镜像是什么？

仓库名、标签都是<none>的镜像，称为虚悬镜像，dangling image。

![image-20230405214627671](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230405214627671.png)

工作中没有什么作用，需删除。