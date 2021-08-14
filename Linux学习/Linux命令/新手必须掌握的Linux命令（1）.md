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
uname命令用于查看系统内核版本等信息，格式为：<font color="red">"uname [-a]"</font>。  
查看系统的内核名称、内核发行版、内核版本、节点名、硬件名称、硬件平台、处理器类型、操作系统等信息：
> [kd@linux ~]$ uname -a  
Linux linux.com 3.10.0-693.el7.x86_64 #1 SMP Thu Jul 6 19:56:57 EDT 2017 x86_64 x86_64 x86_64 GNU/Linux

> 想查看系统详细版本信息就看redhat-release文件：  
[kd@linux ~]$ cat /etc/redhat-release  
Red Hat Enterprise Linux Server release 7.4 (Maipo)

#### uptime命令 ####
uptime命令用于查看系统的负载情况，格式为：<font color="red">"uptime"</font>。  
经常使用watch -n 1 uptime来每秒刷新一次获得当前的系统负载情况，输出内容分别为系统当前时间、系统已运行时间、当前在线用户以及平均负载值。而平均负载分为最近1分钟、5分钟、15分钟的系统负载情况，负载值越低越好（小于1是正常）。
> 获取当前系统状态信息：
[kd@linux ~]$ uptime  
 20:52:14 up  2:57,  2 users,  load average: 0.00, 0.01, 0.05


#### free命令 ####
free命令用于显示当前系统中内存的使用量情况，格式为：<font color="red">“free [-m/-g]”</font>。  
> 以m为单位显示当前系统中内存的使用量情况：  
[kd@linux ~]$ free -m  
              total        used        free      shared  buff/cache   available
Mem:           1823         726         442          10         654         867
Swap:          2047           0        2047

#### who命令 ####
who命令用于查看当前登入主机的用户情况，格式为：<font color="red">“who [参数]”</font>。  
> 例子：  
查看当前登入主机用户的情况：  
[kd@linux ~]$ who  
kd       :0           2018-09-28 17:56 (:0)  
kd       pts/0        2018-09-28 17:57 (:0)  

#### last命令 ####
last命令用于查看所有系统的登入记录，格式为：<font color="red">“last [参数]”</font>。  
> 查看系统的登入记录：  
[kd@linux ~]$ last  
kd       pts/0        :0               Fri Sep 28 17:57   still logged in     
kd       :0           :0               Fri Sep 28 17:56   still logged in       
reboot   system boot  3.10.0-693.el7.x Fri Sep 28 17:54 - 00:03  (06:08)      
kd       pts/0        :0               Tue Sep 25 10:11 - 10:19  (00:07)      
kd       pts/0        :0               Tue Sep 25 10:11 - 10:11  (00:00)      
kd       pts/0        :0               Tue Sep 25 10:10 - 10:11  (00:00)      
kd       :0           :0               Tue Sep 25 10:09 - down   (00:10)      
reboot   system boot  3.10.0-693.el7.x Tue Sep 25 10:06 - 10:20  (00:14)      
wtmp begins Tue Sep 25 10:06:01 2018  

#### history命令 ####
history命令用于显示历史执行过的命令，格式为：<font color="red">“history [-c]”</font>。
> 查看当前用户在系统中执行过的命令：  
[kd@linux ~]$ history  
    1  ll  
    2  cd  Downloads/  
    3  ll  

历史命令会被保存到用户目录中的“.bash_history”文件中。  
Linux系统中以点.开头的文件均代表隐藏文件，一般会是系统文件。 
> [kd@linux ~]$ cat ~/.bash_history  
ll  
cd  Downloads/  
ll  

清空该用户在本机中执行过命令的历史记录：
> [kd@linux ~]$ history -c  
[kd@linux ~]$ history  
    1  history  

#### sosreport命令 ####
sosreport命令用于收集系统配置并诊断信息后输出结论文档，格式为“sosreport”。

### 工作目录切换命令 ###
#### pwd命令 ####
pwd命令用于显示当前的工作目录，格式为：“pwd [选项]”。  

参数|作用  
---|---  
-P|显示真实路径(即非快捷链接的地址)  

> 查看当前的工作路径：    
[kd@linux ~]$ pwd  
/home/kd  

#### cd命令 ####
cd命令用于切换工作路径，格式为：“cd [目录名称]”。  

参数|作用
---|---
-|切换到上一次的目录，如“cd-”
~|切换到“家目录”，如“cd~”
~username|切换到其他用户的家目录，如“cd ~teak”
..|切换到上级目录，如“cd..”

> [kd@linux etc]$ cd -  
/home/kd  

#### ls命令 ####
ls命令用于查看目录中有哪些文件，格式为：“ls [选项][文件]”。

参数|作用
---|---
-a|查看全部文件(包括隐藏文件)
-d|仅看目录本身
-h|易读的文件容量(如k，m，g)
-l|显示文件的详细信息  

> 查看当前目录下有哪些文件（长格式）：  
[kd@linux ~]$ ls /etc  
abrt                        hostname                  pulse  
adjtime                     hosts                     purple  
aliases                     hosts.allow               python  
aliases.db                  hosts.deny                qemu-ga  
alsa                        hp                        qemu-kvm  

### 文本文件编辑命令 ###
#### cat命令 ####
cat命令用于查看纯文本文件（较短的），格式为：“cat [选项][文件]”。  

参数|作用
---|---
-n|显示行号
-b|显示行号
-A|显示出“不可见”的符号，如空格、tab键等等  

> 查看文本文件： 
cat 文件名

#### more命令 ####
more命令用于查看纯文本文件(较长的)，格式为：“more [选项][文件]”。  

参数|作用
---|---
-数字|预先显示的行数（默认为一页）
-d|显示提示语句与报错信息

> 查看文本文件：
more 文件名

#### head命令 ####
head命令用于查看纯文本文档的前N行，格式为：“head [选项][文件]”。  

参数|作用
---|---
-n 10|显示10行
-n-10|正常输出（如cat命令），但不显示最后的10行  

> 查看文本文件前20行：
head -n 20 文件名

#### tail命令 ####
tail命令用于查看纯文本文档的后N行，格式为：“tail [选项][文件]”。  

参数|作用
---|---
-n 10|显示后面的10行
-f|持续刷新显示的内容

> 查看文本文件后20行：  
tail -n 20 文件名

#### od命令 ####
od命令用于查看特殊格式的文件，格式为：“od [选项][文件]”。  

参数|作用
---|---
-t a|默认字符
-t c|ASCII字符
-t o|八进制
-t d|十进制
-t x|十六进制
-t f|浮点数

#### tr命令 ####
tr命令用于转换文本文件中的字符，格式为：“tr [原始字符][目标字符]”。  
> 将tr.txt文件的内容转换成大写  
cat tr.txt|tr [a-z][A-Z]  
中间的|是管道命令符

#### wc命令 ####
wc命令用于统计指定文本的行数、字数、字节数，格式为“wc [参数][文件]”。  

参数|作用
---|---
-l|只显示行数
-w|只显示单词数
-c|只显示字节数

> 统计当前系统中的用户个数：  
[kd@linux ~]$ wc -l /etc/passwd  
41 /etc/passwd  

#### cut命令 ####
cut命令用于通过列来提取文本字符，格式为：“cut [参数][文件]”。  

参数|作用
---|---
-d 分隔符|指定分隔符，默认为Tab。
-f|指定显示的列数
-c|单位改为字符

参数作用：-d以“：”来做分隔符，-f参数代表只看第一列的内容。  

#### diff命令 ####
diff命令用于比较多个文本文件的差异，格式为：“diff [参数][文件]”。   

参数|命令
---|---
-b|忽略空格引起的差异
-B|忽略空行引起的差异
--brief或-q|仅报告是否存在差异
-c|使用上下文输出格式



























