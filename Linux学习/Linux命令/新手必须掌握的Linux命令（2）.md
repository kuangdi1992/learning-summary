### 文件目录管理命令 ###

> #### 1. touch命令 ####
> touch命令用于创建空白文件与修改文件时间，格式为：“touch [选项][文件]”。  

> 参数|作用
> ---|---
> -a|近修改“访问时间”(atime)
> -m|近修改“更改时间”(mtime)
> -d|同时修改atime和mtime
> -t|要修改成的时间[YYMMDDhhmm]

> 对于Linux中的文件有3种时间：  
>  > 1.更改时间(mtime)：内容修改时间（不包括权限的）  
>  > 2.更改权限(ctime)：更改权限与属性的时间  
>  > 3.读取时间(atime)：读取文件内容的时间

--------------------------------------------------------------------------
> #### 2. mkdir命令 ####  
> mkdir命令用于创建空白的文件夹，格式为：“mkdir [选项] [目录]”。  

> 参数|作用  
> ---|---  
> -m=MODE|默认的文件目录权限，如“-m 755”  
> -p|连续创建多层目录  
> -v|显示创建的过程  

> 创建一个名字叫做kd的目录：  
> [kd@linux ~]$ mkdir kd    
> [kd@linux ~]$ ll  
> total 8  
> -rw-rw-r--. 1 kd kd  85 Sep 29 05:46 A.txt  
> -rw-rw-r--. 1 kd kd 113 Sep 29 05:47 B.txt  
> drwxr-xr-x. 2 kd kd  40 Sep 25 10:11 Desktop  
> drwxr-xr-x. 2 kd kd   6 Sep 25 10:09 Documents  
> drwxr-xr-x. 2 kd kd   6 Sep 25 10:09 Downloads  
> drwxrwxr-x. 2 kd kd   6 Sep 30 02:58 kd  
> drwxr-xr-x. 2 kd kd   6 Sep 25 10:09 Music  
> drwxr-xr-x. 2 kd kd   6 Sep 25 10:09 Pictures  
> drwxr-xr-x. 2 kd kd   6 Sep 25 10:09 Public  
> drwxr-xr-x. 2 kd kd   6 Sep 25 10:09 Templates  
> drwxr-xr-x. 2 kd kd   6 Sep 25 10:09 Videos  

----------------------------------------------------------------------------
> #### 3. cp命令 ####
> cp命令用于复制文件或目录，格式为：“cp [选项] 源文件 目标文件”  
> 复制命令的三种情况：
> > 1.目标文件是一个目录，会将源文件复制到该目录中。
> > 2.目标文件是一个文件，会将源文件覆盖该文件。
> > 3.目标文件不存在，将会复制源文件并修改为目标文件的名称。

> 参数|作用
> ---|---
> -p|保留原始文件的属性  
> -d|若对象为“链接文件”，则保留该“链接文件”的属性  
> -r|递归持续复制(用于目录)  
> -i|若目标文件存在则询问是否覆盖  
> -a|相当于-pdr

> 例子：  
> [kd@linux ~]$ cp A.txt C.txt  
> [kd@linux ~]$ ls
> A.txt  C.txt    Documents  kd     Pictures  Templates
> B.txt  Desktop  Downloads  Music  Public    Videos

--------------------------------------------------------------------------------


