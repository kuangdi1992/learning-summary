# delete语句和删除表

## 语法格式

```sql
delete from 表名 where 条件;
```

注意：没有条件的话整张表都会被删除。

使用delete语句删除后，硬盘上的物理空间不会被释放掉。

缺点：删除效率低

优点：支持回滚

## 示例

### 删除id为2的表行

```sql
mysql> select * from t_user;
+----+------+------------+
| id | name | birth      |
+----+------+------------+
|  1 | jack | 2000-10-11 |
|  1 | jack | 2000-10-11 |
|  2 | kd   | 1992-10-01 |
+----+------+------------+
3 rows in set (0.03 sec)

mysql> delete from t_user where id = 1;
Query OK, 2 rows affected (0.06 sec)
mysql> select * from t_user;
+----+------+------------+
| id | name | birth      |
+----+------+------------+
|  2 | kd   | 1992-10-01 |
+----+------+------------+
1 row in set (0.03 sec)
```

### 删除t_user表

```sql
mysql> delete from t_user;
Query OK, 1 row affected (0.07 sec)
mysql> select * from t_user;
Empty set
```

### 支持回滚

```sql
mysql> start transaction;
Query OK, 0 rows affected (0.00 sec)

mysql> delete from t_user;
Query OK, 3 rows affected (0.00 sec)
mysql> select * from t_user;
Empty set

mysql> rollback;
Query OK, 0 rows affected (0.03 sec)

mysql> select * from t_user;
+----+------+------------+
| id | name | birth      |
+----+------+------------+
|  1 | kd   | 1992-01-01 |
|  2 | kd   | 1992-01-01 |
|  3 | kd   | 1992-01-01 |
+----+------+------------+
3 rows in set (0.03 sec)
```

## 删除表 

```sql
drop table if exists t_student;
```

如果表存在的话，删除

结果：

```sql
mysql> drop table if exists t_student;
Query OK, 0 rows affected (0.23 sec)

mysql> desc t_student;
1146 - Table 'mysql.t_student' doesn't exist
```

## 快速删除表—truncate（DDL）

truncate语句删除表中的数据，物理删除

语法格式

```sql
truncate table 表名;
```

优点：删除效率高

缺点：无法回滚

```sql
mysql> select * from t_user;
+----+------+------------+
| id | name | birth      |
+----+------+------------+
|  1 | kd   | 1992-01-01 |
|  2 | kd   | 1992-01-01 |
|  3 | kd   | 1992-01-01 |
+----+------+------------+
3 rows in set (0.03 sec)

mysql> truncate table t_user;
Query OK, 0 rows affected (0.51 sec)
mysql> select * from t_user;
Empty set

mysql> rollback;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from t_user;
Empty set
```

