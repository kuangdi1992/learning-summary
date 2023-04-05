# HelloWorld介绍

安装好docker后，运行helloworld的时候，会出现下面的命令：

```shell
[root@192 ~]# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world #由于本地没有hello-world镜像，因此会下载一个hello-world镜像，并在容器内运行
2db29710123e: Pull complete 
Digest: sha256:2498fce14358aa50ead0cc6c19990fc6ff866ce72aeb5546e1d59caac3d0d60f
Status: Downloaded newer image for hello-world:latest

Hello from Docker!  #hello-world镜像运行结果
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
```

在输出最后一段提示之后，hello-world就会停止运行，容器自动终止。

## docker run干了什么

![image-20230405205229002](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230405205229002.png)