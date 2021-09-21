# limit关键字

## 介绍

limit作用：将查询结果集的一部分取出来，通常用在分页查询当中。

分页：为了提高用户体验。

## 语法

```sql
select
    ....
from
    ....
where
    ....
limit
    startindex，length; // 取前length个，startindex是起始下标，length是长度
```

mysql中limit在order by之后执行。

## 示例

取出工资排名在[3,5]名的员工姓名和工资。

```sql
select
    ename,sal
from
	EMP
order by
	sal desc
limit
	2,3;//2表示起始位置从下标2开始，3表示长度为3
```

![image-20210921224952296](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210921224952296.png)