# alter语句

## MySQL表中添加一列

- 在已经建好的表中添加一列

```mysql
mysql> alter table TABLE_NAME add column NEW_COLUMN_NAME varchar(45) not null;

mysql> alter table t_user add column score int;
Query OK, 0 rows affected (0.45 sec)
Records: 0  Duplicates: 0  Warnings: 0
```

![image-20211031212402442](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20211031212402442.png)

- 希望添加到指定的一列

```mysql
mysql> alter table TABLE_NAME add column NEW_COLUMN_NAME varchar(45) not null after COLUMN_NAME;

mysql> alter table t_user add column age int not null after name;
Query OK, 0 rows affected (0.56 sec)
Records: 0  Duplicates: 0  Warnings: 0
```

![image-20211031212604887](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20211031212604887.png)

- 添加到第一列

```mysql
mysql> alter table TABLE_NAME add column NEW_COLUMN_NAME varchar(45) not null first;

mysql> alter table t_user add column id int not null first;
Query OK, 0 rows affected (0.57 sec)
Records: 0  Duplicates: 0  Warnings: 0
```

![image-20211031212746123](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20211031212746123.png)