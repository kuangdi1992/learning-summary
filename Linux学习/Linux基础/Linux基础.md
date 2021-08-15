# Linux基础

## 介绍

裸机：只有计算机硬件的东西。

![image](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210815213517106.png)

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

![image-20210815220252876](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210815220252876.png)

在纸带上读入3，在纸带上读入2，在纸带上读入+，控制器查表知道为5，在纸带上写下5

![image-20210815220434684](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210815220434684.png)

通用图灵机的结构如下：

![image-20210815220701997](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210815220701997.png)

当我们将加法逻辑读入到控制器中，控制器就会做加法，把乘法逻辑读入到控制器中，控制器就会做乘法。

#### 冯诺依曼体系

存储程序的主要思想：将程序和数据存放到计算机内部的存储器中，计算机就在程序的控制下一步一步进行处理。

计算机由五大部件组成：输入设备、输出设备、存储器、运算器、控制器。

下图是一个很重要的图：

![image-20210815224349021](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/linux/image-20210815224349021.png)

首先将程序放到内存中，用一个IP指针指向它，然后*取址执行，取址执行*，于是计算机就开始工作了。

**IP是指令指针寄存器，相当于偏移地址。**

控制器进行指令的解释执行。IP会指向下一条指令，控制器继续解释执行。