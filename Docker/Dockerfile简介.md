## 介绍

Dockerfile是用来构建Docker镜像的文本文件，是由一条条构建镜像所需的指令和参数构成的脚本。

我们使用docker commit可以构造镜像，但是docker中的镜像随时变化，不能一次次的使用commit，因此使用Dockerfile来一次性构建。

官网地址：https://docs.docker.com/engine/reference/builder/

## 构建步骤

- 编写Dockerfile文件
- docker build命令构建镜像
- docker run镜像运行容器实例

## Dockerfile基础知识

1、每条保留字指令必须为大写字母，后面要跟随至少一个参数

2、指令按照从上到下，顺序执行

3、#表示注释

4、每条指令都会创建一个新的镜像层，并对镜像进行提交

## Docker执行Dockerfile的大致里程

- docker从基础镜像运行一个容器
- 执行一条指令并对容器作出修改
- 执行类似commit操作提交一个新的镜像层
- docker再基于刚提交的镜像运行一个新的容器
- 执行Dockerfile中的下一条指令直到所有指令都执行完成

## Dockerfile常用保留字指令（tomcat的Dockerfile为例）

### FROM

基础镜像，当前新镜像是基于哪个镜像的，指定一个已经存在的镜像作为模板，第一条必须是FROM。

```dockerfile
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM eclipse-temurin:17-jdk-jammy
```

### MAINTAINER

镜像维护者的姓名和邮箱地址

### RUN

容器构建时需要运行的命令

有两种格式：

> shell格式：RUN 命令行命令
>
> exec格式：RUN ["可执行文件","参数1","参数2"]
>
> ```
> RUN ["./test.php","dev","offline"] = RUN ./test.php dev offline
> ```
>
> 

RUN是在docker build时运行

```dockerfile
RUN mkdir -p "$CATALINA_HOME"
```

### EXPOSE

当前容器对外暴露的端口

```dockerfile
EXPOSE 8080
```

### WORKDIR

指定在创建容器后，终端默认登陆进来工作目录

```dockerfile
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME
```

### USER

指定镜像以什么样的用户去执行，如果不指定，默认是root

### ENV

运行时环境，在构造过程中设置环境变量。

这个环境变量可以在后面的RUN命令中使用。

```dockerfile
# let "Tomcat Native" live somewhere isolated
ENV TOMCAT_NATIVE_LIBDIR $CATALINA_HOME/native-jni-lib
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$TOMCAT_NATIVE_LIBDIR

# see https://www.apache.org/dist/tomcat/tomcat-11/KEYS
# see also "versions.sh" (https://github.com/docker-library/tomcat/blob/master/versions.sh)
ENV GPG_KEYS A9C5DF4D22E99998D9875A5110C01C5A2F6059E7

ENV TOMCAT_MAJOR 11
ENV TOMCAT_VERSION 11.0.0-M4
ENV TOMCAT_SHA512 a3de7a907ff97e25ffed4d0677080b718051dbc9d8c2aea4b2afd97a4bb69482bff8e4caa3378238829a1705f81759fad9460ac45dc553db0f63a10685c694c4
```

### ADD

将宿主机目录下的文件拷贝进镜像，自动处理URL和解压tar压缩包-COPY+解压命令。

### COPY

拷贝文件目录到镜像中。

从构建上下文目录中<源路径>的文件/目录复制到新的一层的镜像内的<目标路径>

> COPY src dest
>
> COPY ["src","dest"]
>
> <src源路径>：源文件或者源目录
>
> <dest目标路径>：容器内的指定路径，该路径不用事先建好

### VOLUME

容器数据卷，用于数据保存和持久化工作

### CMD

指定容器启动后要干的事情，在docker run时运行。

启动命令

> CMD指令格式和RUN相似，两种格式：
>
> - shell格式：CMD <命令>
> - exec格式：CMD ["可执行文件","参数1","参数2"……]
> - 参数列表格式：CMD  ["参数1","参数2"……]，在指定了ENTRYPOINT指令后，用CMD指定具体的参数。

Dockerfile中可以有多个CMD指令，但只有最后一个生效，CMD会被docker run之后的参数替换。

```dockerfile
CMD ["catalina.sh", "run"]
```

```shell
docker run -it tomcat /bin/bash
#会将上面的CMD中的覆盖掉
```

### ENTRYPOINT

用来指定一个容器启动时要运行的命令，类似于CMD命令。

ENTRYPOINT不会被docker run后面的命令覆盖，而且这些命令行参数会被当做参数发送给ENTRYPOINT指令指定的程序。

命令格式：

```dockerfile
ENTRYPOINT ["可执行文件","参数1","参数2"……]
```

**ENTRYPOINT可以和CMD一起使用，一般是变参才会使用CMD，等于给ENTRYPOINT传参。**

当指定了ENTRYPOINT后，CMD的含义就发生了变化，会变成<ENTRYPOINT> "<CMD>"。

实例：

```dockerfile
FROM nginx
ENTRYPOINT ["nginx","-c"] #定参
CMD ["/etc/nginx/nginx.conf"] #变参
```

## 案例

### 自定义镜像mycentosjava8

#### JDK下载

进入官网，下载jdk-***-linux-x64.tar.gz。

```shell
[root@192 myfile]# ll
total 186420
-rw-r--r--. 1 root root 190890122 Apr 11 06:36 jdk-8u171-linux-x64.tar.gz
```

#### Dockerfile编写

```shell
#继承的基础镜像
FROM centos:7
#镜像维护者的姓名和邮箱
MAINTAINER kd<kd@163.com>
 
ENV MYPATH /usr/local
WORKDIR $MYPATH
 
#安装vim编辑器
RUN yum -y install vim
#安装ifconfig命令查看网络IP
RUN yum -y install net-tools
#安装java8及lib库
RUN yum -y install glibc.i686
RUN mkdir /usr/local/java
#ADD 是相对路径jar,把jdk-8u121-linux-x64.tar.gz添加到容器中,安装包必须要和Dockerfile文件在同一位置
ADD jdk-8u171-linux-x64.tar.gz /usr/local/java/
#配置java环境变量
ENV JAVA_HOME /usr/local/java/jdk1.8.0_171
ENV JRE_HOME $JAVA_HOME/jre
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH
ENV PATH $JAVA_HOME/bin:$PATH
 
EXPOSE 80
 
CMD echo $MYPATH
CMD echo "success--------------ok"
CMD /bin/bash
```

#### 构建

命令：

```shell
docker build -t 镜像名:TAG .
```

错误示例：

```shell
[root@192 myfile]# docker build -t centosjava8:1.0
ERROR: "docker buildx build" requires exactly 1 argument.
See 'docker buildx build --help'.

Usage:  docker buildx build [OPTIONS] PATH | URL | -

Start a build
```

注意：版本号之后有一个空格，之后加上<font color=red>.</font>

正确示例：

```shell
[root@192 myfile]# docker build -t centosjava8:1.5 .
[+] Building 147.8s (12/12) FINISHED                                                                    
 => [internal] load build definition from Dockerfile                                               0.1s
 => => transferring dockerfile: 889B                                                               0.0s
 => [internal] load .dockerignore                                                                  0.0s
 => => transferring context: 2B                                                                    0.0s
 => [internal] load metadata for docker.io/library/centos:7                                       49.6s
 => [1/7] FROM docker.io/library/centos:7@sha256:be65f488b7764ad3638f236b7b515b3678369a5124c47b8d  0.0s
 => => resolve docker.io/library/centos:7@sha256:be65f488b7764ad3638f236b7b515b3678369a5124c47b8d  0.0s
 => [internal] load build context                                                                  0.0s
 => => transferring context: 110B                                                                  0.0s
 => CACHED [2/7] WORKDIR /usr/local                                                                0.0s
 => [3/7] RUN yum -y install vim                                                                  62.1s
 => [4/7] RUN yum -y install net-tools                                                             3.9s
 => [5/7] RUN yum -y install glibc.i686                                                           20.6s 
 => [6/7] RUN mkdir /usr/local/java                                                                0.4s 
 => [7/7] ADD jdk-8u171-linux-x64.tar.gz /usr/local/java/                                          4.4s 
 => exporting to image                                                                             6.2s 
 => => exporting layers                                                                            6.2s 
 => => writing image sha256:cf98988102b5025c90cd2f5509ee2f2d27faf89de06af93c474b21dcc55a15e4       0.0s 
 => => naming to docker.io/library/centosjava8:1.5   
```

#### 运行

```shell
[root@192 myfile]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED              SIZE
centosjava8   1.5       cf98988102b5   About a minute ago   1.24GB
centos        latest    5d0da3dc9764   19 months ago        231MB
[root@192 myfile]# docker run -it cf98988102b5
[root@6816f306592c local]# pwd
/usr/local
[root@6816f306592c local]# vi q.txt
[root@6816f306592c local]# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.2  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:ac:11:00:02  txqueuelen 0  (Ethernet)
        RX packets 8  bytes 656 (656.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[root@6816f306592c local]# java -version
java version "1.8.0_171"
Java(TM) SE Runtime Environment (build 1.8.0_171-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.171-b11, mixed mode)
```

### 虚悬镜像

在删除、修改等情况下，可能出现虚悬镜像，导致仓库和标签都是none。

#### Dockerfile编写

```shell
from ubuntu
CMD echo 'action is success'
```

#### 构建

```shell
[root@192 kd]# docker rmi -f 8059532fee8a
Untagged: ubuntukd:1.1
Deleted: sha256:8059532fee8a49ec982f3968a84ffe27067b4a11d1defb80d9cc52626c156681
[root@192 kd]# docker build .
[+] Building 0.2s (5/5) FINISHED                                                                        
 => [internal] load build definition from Dockerfile                                               0.0s
 => => transferring dockerfile: 138B                                                               0.0s
 => [internal] load .dockerignore                                                                  0.0s
 => => transferring context: 2B                                                                    0.0s
 => [internal] load metadata for docker.io/library/ubuntu:latest                                   0.1s
 => CACHED [1/1] FROM docker.io/library/ubuntu@sha256:626ffe58f6e7566e00254b638eb7e0f3b11d4da9675  0.0s
 => exporting to image                                                                             0.0s
 => => exporting layers                                                                            0.0s
 => => writing image sha256:8059532fee8a49ec982f3968a84ffe27067b4a11d1defb80d9cc52626c156681       0.0s
[root@192 kd]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
centosjava8   1.5       2ed86535f215   18 minutes ago   1.24GB
<none>        <none>    8059532fee8a   18 months ago    72.8MB
centos        latest    5d0da3dc9764   19 months ago    231MB
```

#### 查看

命令：

```shell
docker image ls -f dangling=true
```

示例：

```shell
[root@192 kd]# docker image ls -f dangling=true
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
<none>       <none>    8059532fee8a   18 months ago   72.8MB
```

#### 删除

命令：

```shell
docker image prune
```

示例：

```shell
[root@192 kd]# docker image prune
WARNING! This will remove all dangling images.
Are you sure you want to continue? [y/N] y
Deleted Images:
deleted: sha256:8059532fee8a49ec982f3968a84ffe27067b4a11d1defb80d9cc52626c156681

Total reclaimed space: 0B
```





