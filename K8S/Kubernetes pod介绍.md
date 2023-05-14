介绍

Pod是一组紧密关联的容器集合，它们共享IPC、Network和UTS namespace，是Kubernetes调度的基本单位。

Pod的设计理念是支持多个容器在一个Pod中共享网络和文件系统，可以通过进程间通信和文件共享这种简单高效的方式组合完成服务。

![image-20230502231118835](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230502231118835.png)