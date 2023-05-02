## 介绍

portainer是一个可视化docker操作工具，可以不用写docker命令实现容器的生命周期进行管理，方便的实现容器的创建、运行、停止、暂停、恢复、删除、复制等。

https://blog.csdn.net/linmengmeng_1314/article/details/106251469

## 安装步骤

### 官网

https://www.portainer.io/

https://docs.portainer.io/

### docker安装命令

`docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest`

实例：

```shell
[root@192 kd]# docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest
Unable to find image 'portainer/portainer-ee:latest' locally
latest: Pulling from portainer/portainer-ee
7721cab3d696: Pull complete 
0645e7e2a110: Pull complete 
3ce11b94aaa3: Pull complete 
Digest: sha256:0dcf19ddc8a844ca1868aac48e3985e3a562f91da40c93558a5c7a21d24d5148
Status: Downloaded newer image for portainer/portainer-ee:latest
f49e2f25727bf981bbd0a8cc530dda56e67fc8b89532df47df76c125f628e36d
```

### 登录

访问地址：`xx.xx.xx.xx:9443`，其中的`xx.xx.xx.xx`是本机ip地址。

![image-20230416101800203](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230416101800203.png)

![image-20230416103039692](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230416103039692.png)

![image-20230416103108775](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230416103108775.png)