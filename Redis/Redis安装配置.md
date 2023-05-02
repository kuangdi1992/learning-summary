## Linux版安装

`linux环境下安装Redis必须先具备gcc编译环境`

### gcc安装

安装gcc

```shell
root@192 ~]# yum install -y gcc-c++
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.ustc.edu.cn
 * extras: mirrors.ustc.edu.cn
 * updates: mirrors.ustc.edu.cn
base                                                                                                                                                                                        | 3.6 kB  00:00:00     
docker-ce-stable                                                                                                                                                                            | 3.5 kB  00:00:00     
extras                                                                                                                                                                                      | 2.9 kB  00:00:00     
updates                                                                                                                                                                                     | 2.9 kB  00:00:00     
Package gcc-c++-4.8.5-44.el7.x86_64 already installed and latest version
Nothing to do
```

查看gcc版本

```shell
[root@192 ~]# gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/libexec/gcc/x86_64-redhat-linux/4.8.5/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap --enable-shared --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++,objc,obj-c++,java,fortran,ada,go,lto --enable-plugin --enable-initfini-array --disable-libgcj --with-isl=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/isl-install --with-cloog=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/cloog-install --enable-gnu-indirect-function --with-tune=generic --with-arch_32=x86-64 --build=x86_64-redhat-linux
Thread model: posix
gcc version 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC) 
```

### redis安装

- 下载7.0版本的redis，放到opt目录下

- 解压redis，`tar -zxvf redis-7.0.10.tar.gz`，出现redis文件夹

- 进入redis目录

- 执行`make && make install`命令

- 查看默认安装目录：`/usr/local/bin`，安装完成后，去`/usr/local/bin`下查看

  ```shell
  [root@192 redis-7.0.10]# cd /usr/local/bin
  [root@192 bin]# ll
  total 74708
  -rwxr-xr-x. 1 root root 54453847 Apr 15 18:24 docker-compose
  -rwxr-xr-x. 1 root root  5197776 Apr 16 00:39 redis-benchmark
  lrwxrwxrwx. 1 root root       12 Apr 16 00:39 redis-check-aof -> redis-server
  lrwxrwxrwx. 1 root root       12 Apr 16 00:39 redis-check-rdb -> redis-server
  -rwxr-xr-x. 1 root root  5411112 Apr 16 00:39 redis-cli
  lrwxrwxrwx. 1 root root       12 Apr 16 00:39 redis-sentinel -> redis-server
  -rwxr-xr-x. 1 root root 11429256 Apr 16 00:39 redis-server
  ```

  文件说明：

  - redis-benchmark:性能测试工具，服务启动后运行该命令，看看自己电脑性能如何

  - redis-check-aof:修复有问题的AOF文件，RDB和AOF后续学习

  - redis-check-dump:修复有问题的dump.rdb文件

  - redis-cli:客户端操作入口

  - redis-sentinel:redis集群使用

  - reids-server:redis服务器启动命令

- 将默认的redis.conf拷贝到自己定义好的一个路径下，比如/myredis ，`cp redis.conf /myredis/redis7.conf`。

- 修改`myredis`目录下`redis7.conf`配置文件做初始化设置

  - 默认`daemonize no` 改为 `daemonize yes`

  - 默认`protected-mode yes` 改为 `protected-mode no`

  - 默认`bind 127.0.0.1` 改为 直接注释掉(默认`bind 127.0.0.1`只能本机访问)或改成本机IP，否则影响远程IP连接

  - 默认redis密码 改为 `requirepass 自己设定的密码`

- 启动服务

  命令：`redis-server ./myredis/redis7.conf`

- 连接服务

  命令：`redis-cli -a 1 -p 6379`(-a 后面是redis设置的密码)

- 关闭Redis服务器

  - 单实例关闭：在Redis服务器外面关闭命令：`redis-cli -a 123456 shutdown`，如果在Redis服务器里面可以直接使用`shutdown`命令
- 多实例关闭，指定端口关闭：`redis-cli -p 6379 shutdown`

## 问题

现象：

```shell
In file included from adlist.c:34:0:
zmalloc.h:50:31: fatal error: jemalloc/jemalloc.h: No such file or directory
 #include <jemalloc/jemalloc.h>
                               ^
```

解决方法：

```shell
make MALLOC=libc
make install
```



