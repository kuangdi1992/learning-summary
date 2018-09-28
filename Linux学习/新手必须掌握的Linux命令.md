## 新手必须掌握的Linux命令 ##
本章节讲述了操作系统内核、bash解释器的关系与作用，学会如何正确的执行Linux命令以及常见排错方法。  
经验丰富的运维人员可以恰当的组合命令与参数，使Linux字符命令更加的灵活且相对减少消耗系统资源。
### 强大好用的SHELL ###
>* 计算机硬件是由运算器、控制器、存储器、输入/输出设备等设备组成的，而且能够让机箱内各种设备各司其职的东西叫做——系统内核。
>* 内核负责<font color="red">驱动硬件、管理活动和分配/管理硬件资源</font>，所以内核是不能直接让用户操作的。
>* 用户不能直接控制硬件和操作系统内核，所以要“系统调动接口”开发出的程序/服务来满足用户的日常工作。

### 执行命令与查看帮助 ###
>* 命令名称 [命令参数][命令对象]：命令名称、命令参数、命令对象之间用空格键分隔。
>* 1.命令对象一般是指要处理的目标
>* 2.命令参数对新手来说比较麻烦，这个值会随命令的不同和环境情况的不同而异，所以在参数选择搭配上需要长时间的经验累积。
>* 3.命令的参数有两种形式：
>* a.长格式：（完整的选项名称）如：man -help
>* b.短格式：（单个字母的缩写）如：man -h
#### man命令 ####
用于查看命令的具体可用参数和对象格式等等。
结构名称|代表意义
---|---
NAME|命令的名称
SYNOPSYS|参数的大致使用方法
DESCRIPTION|介绍说明
EXAMPLES|演示
OVERVIEW|概述
DEFAULTS|默认的功能
OPTIONS|具体的可用选项
ENVIRONMENT|环境变量
FILES|用到的文件
SEE ALSO|相关的资料
HISTORY|维护历史和联系方式

### 常用系统工作命令 ###
#### echo命令 ####
echo命令用于在终端显示字符串或变量，格式为："echo [字符串 | 变量]"
例子：
>* [kd@linux ~]$ echo \$SHELL
  /bin/bash
  
>* 查看本机主机名：
[kd@linux ~]$ echo \$HOSTNAME
linux.com

#### date命令 ####
date命令用于显示/设置系统的时间或日期，格式为：“date [选项][+指定的格式]”
强大的date命令能够按照指定格式显示系统日期或时间，只需要键入<font color="blue">“+”</font>号开头的字符串指定其格式，详细格式如下：
参数|作用
---|---
%t|跳格[TAB键]
%H|小时(00-23)
%I|小时(01-12)
%M|分钟(00-59)
%S|秒(00-60)
%X|相当于%H:%M:%S
%Z|显示时区
%p|显示本地AM或PM
%A|星期几（Sunday-Saturday）
%a|星期几(Sun-Sat)
%B|完整月份(January-December)
%b|缩写月份(Jan-Dec)
%d|日(01-31)
%j|一年中的第几天(001-366)
%m|月份(01-12)
%Y|完整的年份
例子：
> [kd@linux ~]$ date 
Fri Sep 28 19:07:39 CST 2018

> [kd@linux ~]$ date "+%Y-%m-%d %H:%M:%S"
2018-09-28 19:08:10

> [kd@linux ~]$ date "+%j"
271

#### reboot命令 ####
reboot命令用于重启系统(仅root用户可以使用)，格式为：“reboot”。

#### wget命令 ####
wegt命令用于使用命令行下载网络文件，格式为：<font color="red">"wegt [参数] 下载地址"</font>
参数|作用
---|---
-b|后台下载模式
-O|下载到指定目录
-t|最大尝试次数
-c|断点续传
-p|下载页面内所有资源，包括图片、视频等
-r|递归下载
例子：
> [kd@linux ~]$ wget -r -p http://www.linuxprobe.com
--2018-09-28 19:14:52--  http://www.linuxprobe.com/
Resolving www.linuxprobe.com (www.linuxprobe.com)... 

### 系统状态检测命令 ###
#### ifconfig命令 ####
ifconfig用于获取网卡配置与网络状态等信息：格式<font color="red">"ifconfig [网络设备][参数]"</font>
查看本机当前的网卡配置与网络状态等信息：
> [kd@linux ~]$ ifconfig
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.37.128  netmask 255.255.255.0  broadcast 192.168.37.255
        inet6 fe80::8a9a:812:7f66:3955  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:22:18:4b  txqueuelen 1000  (Ethernet)
        RX packets 217  bytes 21591 (21.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 316  bytes 29948 (29.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        
> lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1  (Local Loopback)
        RX packets 64  bytes 5184 (5.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 64  bytes 5184 (5.0 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

> virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:1d:90:49  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

#### uname命令 ####
uname命令用于查看系统内核版本等信息，格式为：<font color="red">"uname [-a]"</font>
查看系统的内核名称、内核发行版、内核版本、节点名、硬件名称、硬件平台、处理器类型、操作系统等信息：
> [kd@linux ~]$ uname -a
Linux linux.com 3.10.0-693.el7.x86_64 #1 SMP Thu Jul 6 19:56:57 EDT 2017 x86_64 x86_64 x86_64 GNU/Linux

> 想查看系统详细版本信息就看redhat-release文件：
[kd@linux ~]$ cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.4 (Maipo)

####uptime命令 ####
uptime命令用于查看系统的负载情况，格式为：<font color="red">"uptime"</font>
经常使用watch -n 1 uptime来每秒刷新一次获得当前的系统负载情况，输出内容分别为系统当前时间、系统已运行时间、当前在线用户以及平均负载值。而平均负载分为最近1分钟、5分钟、15分钟的系统负载情况，负载值越低越好（小于1是正常）。
> 获取当前系统状态信息：
[kd@linux ~]$ uptime  
 20:52:14 up  2:57,  2 users,  load average: 0.00, 0.01, 0.05


#### free命令 ####
free命令用于显示当前系统中内存的使用量情况，格式为：<font color="red">“free [-m/-g]”</font>
> 以m为单位显示当前系统中内存的使用量情况：
[kd@linux ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:           1823         726         442          10         654         867
Swap:          2047           0        2047





