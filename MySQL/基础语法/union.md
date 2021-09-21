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

```sql
select ename,job from EMP where job = 'MANAGER'
union
select ename,job from EMP where job = 'SALESMAN';
```

![image-20210921223426108](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210921223426108.png)

union的效率要更高一些。

对于表连接来说，每连接一次新表，则匹配次数满足笛卡尔积，成倍增加。

但是union可以减少匹配次数，并且可以完成两个结果集的拼接。

