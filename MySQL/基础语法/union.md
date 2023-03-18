# union合并查询结果集

### 案例

​	查询工作岗位MANAGER和SLAESMAN的员工

### SQL代码

```sql
select ename,job from EMP where job = 'MANAGER' or job = 'SALESMAN';
select ename,job from EMP where job in ('MANAGER','SALESMAN');
```

![image-20210921223142321](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210921223142321.png)

### 使用union

语法格式

```sql
SELECT column,... FROM table1
UNION [ALL]
SELECT column,... FROM table2
```

示例

```sql
select ename,job from EMP where job = 'MANAGER'
union
select ename,job from EMP where job = 'SALESMAN';
```

![image-20210921223426108](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210921223426108.png)

union的效率要更高一些。

对于表连接来说，每连接一次新表，则匹配次数满足笛卡尔积，成倍增加。

但是union可以减少匹配次数，并且可以完成两个结果集的拼接。

#### UNION操作符

UNION操作符返回两个查询的结果集的并集，去除重复记录。

#### UNION ALL操作符

UNION ALL不会执行去重的操作。尽量使用UNION ALL。

```sql
SELECT employee_id,department_name
from employees e LEFT JOIN departments d
ON e.department_id = d.department_id
UNION ALL
SELECT employee_id,department_name
from employees e RIGHT JOIN departments d
ON e.department_id = d.department_id
WHERE e.department_id is NULL;
```





