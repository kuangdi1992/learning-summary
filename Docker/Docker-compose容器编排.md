## 介绍

Docker-Compose是Docker官方的开源项目，负责实现对Docker容器集群的快速编排。

Docker-Compose可以管理多个Docker容器组成的一个应用，需要定义一个YAML格式的配置文件docker-compose.yml，写好多个容器之间的调用关系，只要一个命令，就可以同时启动或关闭这些容器。

### docker-compose.yml示例

```shell
version: "3.9"  # optional since v1.27.0
services:
  web:
    build: .
    ports:
      - "8000:5000"
    volumes:
      - .:/code
      - logvolume01:/var/log
    depends_on:
      - redis
  redis:
    image: redis
volumes:
  logvolume01: {}
```

## 安装Docker Compose

- 下载Docker Compose

  ```curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose```

- 添加可执行权限

  ```chmod +x /usr/local/bin/docker-compose```

- 检验Docker Compose是否安装成功

  ```shell
  docker-compose --version
  Docker Compose version v2.17.2
  ```

遇到的问题

现象：

```shell
[root@192 myfile]# curl -L https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:20 --:--:--     0curl: (7) Failed connect to github.com:443; Connection refused
```

解决方法：

https://blog.51cto.com/u_11827525/5358789

## 核心概念

一个文件：docker-compose.yml

两个要素：

- 服务(service)：一个个应用容器示例，比如mysql容器，订单微服务等
- 工程(project)：由一组关联的应用容器组成的一个完整业务单元，在docker-compose.yml文件中定义。

实例（官网）

网址：https://docs.docker.com/compose/gettingstarted/

## 常用命令

官方文档：https://docs.docker.com/compose/reference/overview/

```docker-compose [-f <arg>...] [options] [COMMAND] [ARGS...]```
部分命令选项如下：

- -f，–file：指定使用的 Compose 模板文件，默认为 docker-compose.yml，可以多次指定，指定多个 yml；
- -p, --project-name：指定工程名称，默认使用 docker-compose.yml 文件所在目录的名称；
- -v：打印版本并退出；
- –log-level：定义日志等级（DEBUG, INFO, WARNING, ERROR, CRITICAL）。

#### help

`docker-compose -help`查看帮助。

#### config

`docker-compose config -q`验证`docker-compose.yml`文件。当配置正确时，不输出任何内容，当配置错误时，输出错误信息。

#### pull

`docker-compose pull`拉取服务依赖的镜像。

```shell
# 拉取工程中所有服务依赖的镜像
docker-compose pull
# 拉取工程中 nginx 服务依赖的镜像
docker-compose pull nginx
# 拉取镜像过程中不打印拉取进度信息
docker-compose pull -q
```

#### up

`docker-compose up`创建并启动所有服务的容器。指定多个`yml`加`-f`选项。以守护进程模式运行加`-d`选项。

```shell
# 前台启动
docker-compose up
# 后台启动
docker-compose up -d
# -f 指定使用的 Compose 模板文件，默认为 docker-compose.yml，可以多次指定，指定多个 yml
docker-compose -f docker-compose.yml up -d
```

#### logs

`docker-compose logs`查看服务容器的输出日志。默认情况下，`docker-compose`将对不同的服务输出使用不同的颜色来区分。可以通过`--no-color`来关闭颜色。

```shell
# 输出日志，不同的服务输出使用不同的颜色来区分
docker-compose logs
# 跟踪日志输出
docker-compose logs -f
# 关闭颜色
docker-compose logs --no-color
```

#### ps

`docker-compose ps`列出工程中所有服务的容器。

```shell
# 列出工程中所有服务的容器
docker-compose ps
# 列出工程中指定服务的容器
docker-compose ps nginx
```

#### run

`docker-compose run`在指定服务容器上执行一个命令。

```shell
# 在工程中指定服务的容器上执行 echo "helloworld"
docker-compose run nginx echo "helloworld"
```

#### exec

`docker-compose exec`进入服务容器。

```shell
# 进入工程中指定服务的容器
docker-compose exec nginx bash
# 当一个服务拥有多个容器时，可通过 --index 参数进入到该服务下的任何容器
docker-compose exec --index=1 nginx bash
```

#### pause

`docker-compose pause`暂停服务容器

```shell
# 暂停工程中所有服务的容器
docker-compose pause
# 暂停工程中指定服务的容器
docker-compose pause nginx
```



#### unpause

`docker-compose unpause`恢复服务容器。

```shell
# 恢复工程中所有服务的容器
docker-compose unpause
# 恢复工程中指定服务的容器
docker-compose unpause nginx
```



#### restart

`docker-compose restart`重启服务容器。

```shell
# 重启工程中所有服务的容器
docker-compose restart
# 重启工程中指定服务的容器
docker-compose restart nginx
```



#### start

`docker-compose start`启动服务容器。

```shell
# 启动工程中所有服务的容器
docker-compose start
# 启动工程中指定服务的容器
docker-compose start nginx
```



#### stop

`docker-compose stop`停止服务容器。

```shell
# 停止工程中所有服务的容器
docker-compose stop
# 停止工程中指定服务的容器
docker-compose stop nginx
```

#### kill

`docker-compose kill`通过发送`SIGKILL`信号停止指定服务的容器。

```shell
# 通过发送 SIGKILL 信号停止工程中指定服务的容器
docker-compose kill nginx
```



#### rm

`docker-compose rm` 删除服务（停止状态）容器。

```shell
# 删除所有（停止状态）服务的容器
docker-compose rm
# 先停止所有服务的容器，再删除所有服务的容器
docker-compose rm -s
# 不询问是否删除，直接删除
docker-compose rm -f
# 删除服务容器挂载的数据卷
docker-compose rm -v
# 删除工程中指定服务的容器
docker-compose rm -sv nginx
```

#### down

停止并删除所有服务的容器、网络、镜像、数据卷。

```shell
# 停止并删除工程中所有服务的容器、网络
docker-compose stop
# 停止并删除工程中所有服务的容器、网络、镜像
docker-compose down --rmi all
# 停止并删除工程中所有服务的容器、网络、数据卷
docker-compose down -v
```

#### images

`docker-compose images`打印服务容器所对应的镜像。

```shell
# 打印所有服务的容器所对应的镜像
docker-compose images
# 打印指定服务的容器所对应的镜像

docker-compose images nginx
```

#### port

`docker-compose port`打印指定服务容器的某个端口所映射的宿主机端口。

```docker-compose port nginx 80```


#### top

`docker-compose top`显示正在运行的进程。

```shell
# 显示工程中所有服务的容器正在运行的进程
docker-compose top
# 显示工程中指定服务的容器正在运行的进程
docker-compose top nginx
```

