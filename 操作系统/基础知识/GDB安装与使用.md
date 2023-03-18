# 安装

安装gdb的具体步骤如下：

1、查看当前gdb安装情况

```shell
rpm -qa | grep gdb
```

如果有，则可以先删除：

```shell
rpm -e --nodeps 文件名
```

如果没有，则进行下一步。

2、下载gdb源码包或者直接apt安装。

apt命令安装：

```shell
sudo apt install gdb
```

源码包安装：

```shell
在linux中输入：
wget http://ftp.gnu.org/gnu/gdb/gdb-7.10.1.tar.gz
解压：
tar -zxvf gdb-7.10.1.tar.gz
进入gdb目录：
cd gdb-7.10.1
输入命令：
./configure
make
make install
```

3、查看是否安装成功

```shell
gdb -v
```

![image-20230318112606558](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318112606558.png)

# 使用

- 编写一段简单的C语言程序

  ```c
  #include <stdio.h>
  int main()
  {
    int i = 0;
    for(i = 0;i<10;++i)
    {
      printf("%d ",i);
    }
    printf("\n");
    return 0;
  }
  ```

- 生产debug版本的可执行程序：

  ```shell
  gcc test.c -o test_g -g
  ```

  注意：所有的调试代码操作必须在debug版本下执行

  使用下面的命令可以查看调试信息：

  ```shell
  readelf -S test_g | grep debug
  ```

  结果如下：

  ![image-20230318164309798](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318164309798.png)

- 进入gdb

  ```shell
  gdb test_g
  ```

  ![image-20230318164443442](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318164443442.png)

- 显示源代码

  > list或l :显示源代码，每次显示10行
  >
  > list或l 函数名：列出某个函数的源代码

  ![image-20230318165130142](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318165130142.png)

  ![image-20230318165158604](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318165158604.png)

- 打断点，查看断点信息

  > break或b 行号：在某一行设置断点
  >
  > break或b 函数名：在某个函数开头设置断点

  ![image-20230318165350956](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318165350956.png)

  > info b：查看断点信息

  ![image-20230318165454199](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318165454199.png)

- 运行程序

  > run或r：运行程序

  ![image-20230318165609295](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318165609295.png)

- 查看变量信息

  > print或p 变量：打印变量值
  >
  > print或p &变量：打印变量地址

  ![image-20230318165810179](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318165810179.png)

- 逐语句执行

  > step或s：进入函数调用

  ![image-20230318170119847](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318170119847.png)

- 逐过程执行

  > next或n：单条执行（不进入函数调用）

  ![image-20230318170207860](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318170207860.png)

- 删除断点

  > delete breakpoints或d：删除所有断点
  >
  > delete breakpoints或d 1：删除序号为n的断点

  ![image-20230318170359335](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318170359335.png)

- 调用堆栈

  > breaktrace或bt：查看各级函数调用及参数

  ![image-20230318170444279](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318170444279.png)

- 跟踪变量

  > display 变量名：跟踪查看一个变量，每次停下来都显示它的值
  >
  > undisplay：取消对先前设置的变量的跟踪

  ![image-20230318170821995](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318170821995.png)

  ![image-20230318170925059](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318170925059.png)

- 跳转至x行

  > until X行号：跳至X行

  ![image-20230318171011930](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318171011930.png)

- 跳转至下一个断点

  > continue或c：从当前位置开始连续而非单步执行程序

  ![image-20230318171126292](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/linux/image-20230318171126292.png)

- 将一个指定函数跑完

  > finish:执行完成一个函数就停止

  

