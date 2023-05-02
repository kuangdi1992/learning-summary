# 总体步骤

> 搜索镜像
>
> 拉取镜像
>
> 查看镜像
>
> 启动镜像
>
> 停止容器
>
> 移除容器

# 示例（安装mysql）

## 搜索镜像

```
docker search mysql
```

```shell
[root@192 ~]# docker search mysql
NAME                            DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
mysql                           MySQL is a widely used, open-source relation…   14016     [OK]       
mariadb                         MariaDB Server is a high performing open sou…   5346      [OK]       
percona                         Percona Server is a fork of the MySQL relati…   603       [OK]       
phpmyadmin                      phpMyAdmin - A web interface for MySQL and M…   777       [OK]       
circleci/mysql                  MySQL is a widely used, open-source relation…   29                   
bitnami/mysql                   Bitnami MySQL Docker Image                      81                   [OK]
bitnami/mysqld-exporter                                                         4                    
ubuntu/mysql                    MySQL open source fast, stable, multi-thread…   44                   
cimg/mysql                                                                      0                    
rapidfort/mysql                 RapidFort optimized, hardened image for MySQL   14                   
google/mysql                    MySQL server for Google Compute Engine          23                   [OK]
rapidfort/mysql8-ib             RapidFort optimized, hardened image for MySQ…   0                    
hashicorp/mysql-portworx-demo                                                   0                    
rapidfort/mysql-official        RapidFort optimized, hardened image for MySQ…   0                    
newrelic/mysql-plugin           New Relic Plugin for monitoring MySQL databa…   1                    [OK]
databack/mysql-backup           Back up mysql databases to... anywhere!         82                   
linuxserver/mysql               A Mysql container, brought to you by LinuxSe…   38                   
mirantis/mysql                                                                  0                    
docksal/mysql                   MySQL service images for Docksal - https://d…   0                    
bitnamicharts/mysql                                                             0                    
vitess/mysqlctld                vitess/mysqlctld                                1                    [OK]
linuxserver/mysql-workbench                                                     48                   
eclipse/mysql                   Mysql 5.7, curl, rsync                          0                    [OK]
drud/mysql                                                                      0                    
ilios/mysql                     Mysql configured for running Ilios              1                    [OK]
```



## 拉取镜像

```
docker pull mysql:5.7
```

```shell
[root@192 ~]# docker pull mysql:5.7
5.7: Pulling from library/mysql
72a69066d2fe: Pull complete 
93619dbc5b36: Pull complete 
99da31dd6142: Pull complete 
626033c43d70: Pull complete 
37d5d7efb64e: Pull complete 
ac563158d721: Pull complete 
d2ba16033dad: Pull complete 
0ceb82207cd7: Pull complete 
37f2405cae96: Pull complete 
e2482e017e53: Pull complete 
70deed891d42: Pull complete 
Digest: sha256:f2ad209efe9c67104167fc609cca6973c8422939491c9345270175a300419f94
Status: Downloaded newer image for mysql:5.7
docker.io/library/mysql:5.7
```

## 查看镜像

```shell
[root@192 ~]# docker images
REPOSITORY                     TAG       IMAGE ID       CREATED         SIZE
192.168.12.130:5000/kdubuntu   1.2       9582a943a6b6   17 hours ago    116MB
kd/myubuntu                    1.2       9582a943a6b6   17 hours ago    116MB
mysql                          5.7       c20987f18b13   15 months ago   448MB
registry                       latest    b8604a3fe854   17 months ago   26.2MB
ubuntu                         latest    ba6acccedd29   18 months ago   72.8MB
redis                          6.0.8     16ecd2772934   2 years ago     104MB
```

可以到现在的镜像有mysql5.7了。

## 启动镜像

到Docker Hub（镜像仓库）官网查找mysql，然后找到how to use this image，如下：

> # How to use this image
>
> ## Start a `mysql` server instance
>
> Starting a MySQL instance is simple:
>
> ```console
> $ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
> ```
>
> ... where `some-mysql` is the name you want to assign to your container, `my-secret-pw` is the password to be set for the MySQL root user and `tag` is the tag specifying the MySQL version you want. See the list above for relevant tags.

```shell
[root@192 ~]# docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7
0b82f8f6a8360b791e4d7752de0afd700a1f16cd27b840536e6bc3864bc9989c
[root@192 ~]# docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                                                  NAMES
0b82f8f6a836   mysql:5.7   "docker-entrypoint.s…"   4 seconds ago   Up 2 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   zealous_wiles
#进入容器实例
[root@192 ~]# docker exec -it 0b82f8f6a836 /bin/bash
#进入mysql
root@0b82f8f6a836:/# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.36 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database db01;
Query OK, 1 row affected (0.00 sec)

mysql> use db01;
Database changed

mysql> create table kd(id int,name varchar(20));
Query OK, 0 rows affected (0.04 sec)

mysql> insert into kd values(1,'zhangsan');
Query OK, 1 row affected (0.00 sec)

mysql> select * from kd;
+------+----------+
| id   | name     |
+------+----------+
|    1 | zhangsan |
+------+----------+
1 row in set (0.00 sec)
#到这里可以看到，mysql正常使用
```

在主机上使用数据库工具可以正常连接docker中的mysql。

### 删除容器后，mysql数据怎么办

要想删除容器后，可以继续保存mysql数据，需要使用数据卷，命令如下：

> docker run -d -p 3306:3306 --privileged=true -v /tmp/mysql/log:/var/log/mysql  -v /tmp/mysql/data:/var/lib/mysql  -v /tmp/mysql/conf:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=123456 --name mysql mysql:5.7

1、删除当前容器

```shell
[root@192 ~]# docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS         PORTS                                                  NAMES
b74f0b9cfe34   mysql:5.7   "docker-entrypoint.s…"   11 minutes ago   Up 6 minutes   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql
[root@192 ~]# docker rm -f b74f0b9cfe34
b74f0b9cfe34
[root@192 ~]# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

2、重新启动容器

```shell
[root@192 ~]# docker run -d -p 3306:3306 --privileged=true -v /tmp/mysql/log:/var/log/mysql  -v /tmp/mysql/data:/var/lib/mysql  -v /tmp/mysql/conf:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=123456 --name mysql mysql:5.7
2be1c7d94c4606ea5e4be6cfa5df35aed653cd9cf9d6b9365ffc4c1ee9251bd6
[root@192 ~]# docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                                                  NAMES
2be1c7d94c46   mysql:5.7   "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql
[root@192 ~]# docker exec -it mysql /bin/bash
root@2be1c7d94c46:/# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.36 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use db01;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> select * from kd;
+------+--------+
| id   | name   |
+------+--------+
|    1 | dddd   |
|    2 | lisi   |
|    3 | 王五   |
+------+--------+
3 rows in set (0.01 sec)
```

可以看到重新启动后，之前的数据还在。

### 解决mysql乱码

1、在宿主机数据卷 /tmp/mysql/conf创建my.cnf文件，并添加如下内容

```
[root@192 conf]# cat my.cnf 
[client]
default_character_set=utf8
[mysqld]
collation_server = utf8_general_ci
character_set_server = utf8
```

2、重启容器并重新进入查看

```shell
[root@192 conf]# docker restart mysql
mysql
#进入
[root@192 conf]# docker exec -it b74f0b9cfe34 /bin/bash
#启动mysql
root@b74f0b9cfe34:/# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.36 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW VARIABLES LIKE 'character%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8                       |
| character_set_connection | utf8                       |
| character_set_database   | utf8                       |
| character_set_filesystem | binary                     |
| character_set_results    | utf8                       |
| character_set_server     | utf8                       |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.02 sec)

mysql> create database db01;
Query OK, 1 row affected (0.02 sec)

mysql> use db01;
Database changed
mysql> create table kd(id int,name varchar(20));
Query OK, 0 rows affected (0.01 sec)

mysql> insert into kd values(1,'dddd');
Query OK, 1 row affected (0.01 sec)

mysql> select * from kd;
+------+--------+
| id   | name   |
+------+--------+
|    1 | dddd   |
|    2 | lisi   |
|    3 | 王五   |
+------+--------+
3 rows in set (0.00 sec)
```

可以看到，乱码问题已经解决。

