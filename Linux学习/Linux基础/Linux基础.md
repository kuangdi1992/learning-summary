# Linux基础

## 介绍

裸机：只有计算机硬件的东西。

![image](https://github.com/kuangdi1992/Interview-knowledge/blob/master/%E5%9B%BE%E7%89%87/Linux%E5%9B%BE%E7%89%87/image-20210815213517106.png)

操作系统是在计算机硬件上的一层软件，让大家可以更好的使用计算机。

方便使用硬件，如使用显存……

问：操作系统管理哪些硬件？

答：CPU管理、内存管理、终端管理、磁盘管理、文件管理等



### 目的

- 能理解真实操作系统的运转
- printf（“hello”）到底怎么回事
- 能在真实的基本操作系统上动手实践

一句话：Learn OS concepts by coding them!

### 从打开电源开始

打开电源后，计算机就要开始工作了。那么，计算机是怎么工作的？让我们一起来探索。

#### 图灵机，通用图灵机

1936年，英国数学家A.C.图灵提出了一种模型，如下：

![image-20210815220252876](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20210815220252876.png)

在纸带上读入3，在纸带上读入2，在纸带上读入+，控制器查表知道为5，在纸带上写下5

![image-20210815220434684](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20210815220434684.png)

通用图灵机的结构如下：

![image-20210815220701997](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20210815220701997.png)

当我们将加法逻辑读入到控制器中，控制器就会做加法，把乘法逻辑读入到控制器中，控制器就会做乘法。

#### 冯诺依曼体系

存储程序的主要思想：将程序和数据存放到计算机内部的存储器中，计算机就在程序的控制下一步一步进行处理。