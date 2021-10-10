# delete语句

## 语法格式

```sql
delete from 表名 where 条件;
```

注意：没有条件的话整张表都会被删除。

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

