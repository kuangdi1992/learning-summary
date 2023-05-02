## 用户管理

MySQL用户分为`普通用户`和`root用户`。

>  root用户是超级管理员，拥有所有权限，包括创建用户、删除用户和修改用户的密码等管理权限。
>
> 普通用户只有被授予的权限。

MySQL提供了很多语句来管理用户账号，用来管理包括登录和退出MySQL服务器、创建用户、删除用户、密码管理和权限管理等内容。

MySQL数据库的安全性通过账户管理来保证。

### 登录MySQL服务器

命令：

`mysql –h hostname|IP –P port –u username –p DatabaseName –e "SQL语句"`

- -h：后面接主机名或主机IP
- -p：后面接MySQL服务的端口，通过该参数连接到指定的端口。默认端口是3306。不使用该参数时自动连接到3306端口。
- -u：后面接用户名
- -p：会提示输入密码

示例：

```mysql
C:\Users\kd>mysql -h localhost -P 3306 -u root -p dbtest1 -e "select * from test_int1";
Enter password: ******
+------+------+------+------+------+
| f1   | f2   | f3   | f4   | f5   |
+------+------+------+------+------+
|   12 | NULL | NULL | NULL | NULL |
|  -12 | NULL | NULL | NULL | NULL |
|  127 | NULL | NULL | NULL | NULL |
| -127 | NULL | NULL | NULL | NULL |
+------+------+------+------+------+
```

### 创建用户

使用`CREATE USER`语句来创建新用户时，必须拥有`CREATE USER`权限。

每添加一个用户，`CREATE USER`语会在`MySQL.user`表中添加一条新的记录，但是新创建的账户没有任何权限。

如果添加的账户已经存在，`CREATE USER`语句会返回一个错误。

基本语法：

`CREATE USER 用户名 [IDENTIFIED BY '密码'] [,用户名 [[IDENTIFIED BY '密码']];`

示例：

```mysql
mysql> select host,user from user;
+-----------+------------------+
| host      | user             |
+-----------+------------------+
| localhost | mysql.infoschema |
| localhost | mysql.session    |
| localhost | mysql.sys        |
| localhost | root             |
+-----------+------------------+
4 rows in set (0.00 sec)

mysql> create user 'kd' identified by '123456';
Query OK, 0 rows affected (0.10 sec)

mysql> select host,user from user;
+-----------+------------------+
| host      | user             |
+-----------+------------------+
| %         | kd               |
| localhost | mysql.infoschema |
| localhost | mysql.session    |
| localhost | mysql.sys        |
| localhost | root             |
+-----------+------------------+
5 rows in set (0.00 sec)

mysql> create user 'kd' identified by '123456';
ERROR 1396 (HY000): Operation CREATE USER failed for 'kd'@'%'

mysql> create user 'kd'@'localhost' identified by '123456';
Query OK, 0 rows affected (0.06 sec)

mysql> select host,user from user;
+-----------+------------------+
| host      | user             |
+-----------+------------------+
| %         | kd               | #支持任何连接
| localhost | kd               | #支持本地连接
| localhost | mysql.infoschema |
| localhost | mysql.session    |
| localhost | mysql.sys        |
| localhost | root             |
+-----------+------------------+
6 rows in set (0.00 sec)
```

登录创建的用户：

```mysql
C:\Users\kd>mysql -ukd -p123456
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 16
Server version: 8.0.21 MySQL Community Server - GPL

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
+--------------------+
1 row in set (0.00 sec)

mysql> show grants;
+----------------------------------------+
| Grants for kd@localhost                |
+----------------------------------------+
| GRANT USAGE ON *.* TO `kd`@`localhost` |
+----------------------------------------+
1 row in set (0.02 sec)
```

### 修改用户

主要是修改用户名，实际用的很少。

```shell
mysql> update mysql.user SET user='zhangsan' where user='kd';
Query OK, 2 rows affected (0.05 sec)
Rows matched: 2  Changed: 2  Warnings: 0

mysql> select host,user from user;
+-----------+------------------+
| host      | user             |
+-----------+------------------+
| %         | zhangsan         |
| localhost | mysql.infoschema |
| localhost | mysql.session    |
| localhost | mysql.sys        |
| localhost | root             |
| localhost | zhangsan         |
+-----------+------------------+
6 rows in set (0.00 sec)

mysql> flush privileges; #刷新权限后才会生效
Query OK, 0 rows affected (0.02 sec)
```

### 删除用户

#### DROP方法

语法：

`DROP user username;`

示例：

```mysql
mysql> drop user 'zhangsan'; #删除默认%的用户
Query OK, 0 rows affected (0.04 sec)

mysql> drop user 'zhangsan'@'localhsot'; #删除host为localhost的用户
Query OK, 0 rows affected (0.04 sec)

C:\Users\kd>mysql -ukd -p123456
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'kd'@'localhost' (using password: YES)
```

#### DETELE方法

该方法不推荐,该方法删除会有残留

语法：

`DELETE FROM user WHERE Host='%' and User='name123';
flush privileges;`

示例：

```mysql
mysql> delete from user where host='localhost' and user='zhangsan';
Query OK, 1 row affected (0.08 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.03 sec)

mysql> select host,user from user;
+-----------+------------------+
| host      | user             |
+-----------+------------------+
| localhost | mysql.infoschema |
| localhost | mysql.session    |
| localhost | mysql.sys        |
| localhost | root             |
+-----------+------------------+
4 rows in set (0.00 sec)
```

### 设置当前用户密码





