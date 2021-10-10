# update语句

## 语法格式

```sql
update 表名 set 字段名1=值1,字段名2=值2,字段名3=值3,... where 条件;
```

注意：没有条件限制会导致所有数据全部更新。

## 示例

```sql
mysql> select * from t_user;
+----+------+------------+
| id | name | birth      |
+----+------+------------+
|  1 | kd   | 1992-10-01 |
|  1 | kd   | 1992-10-01 |
+----+------+------------+
2 rows in set (0.03 sec)

mysql> update t_user set name='jack',birth='2000-10-11' where id=1;
Query OK, 2 rows affected (0.04 sec)
Rows matched: 2  Changed: 2  Warnings: 0
mysql> select * from t_user;
+----+------+------------+
| id | name | birth      |
+----+------+------------+
|  1 | jack | 2000-10-11 |
|  1 | jack | 2000-10-11 |
+----+------+------------+
2 rows in set (0.04 sec)
```

可以看到所有id=1的数据都被修改了。