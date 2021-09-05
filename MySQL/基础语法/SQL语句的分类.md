# SQL语句

## DQL

#### 数据查询语言select

带有select关键字

```
select 字段名  from 表名;
```

##### 查询的列起别名

使用as关键字起别名

只是将显示的查询结果列名显示为deptname，不会改变原表的列名。

![image-20210824214337755](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210824214337755.png)

##### as关键字可以省略

```
select deptno,dname deptname from DEPT;
```

![image-20210824215540392](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210824215540392.png)

##### 当别名中出现空格的时候，可以使用单引号或者双引号括起来

```
select deptno,dname 'dept name' from DEPT;
```

![image-20210824220008148](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210824220008148.png)

```
select deptno,dname "dept name" from DEPT;
```

![image-20210824220044062](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210824220044062.png)

##### 字段使用数学表达式

当我们想计算年薪时，可以像下面这样：

![image-20210829162029763](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829162029763.png)

然后将sal*12起个别名即可。

##### 条件查询

1. 什么是条件查询？

   不将表中所有的数据都查出来，只查询符合条件的。

2. 语法格式

   select   字段1,字段2,,字段3…… 

   from  表名

   where 条件

3. 哪些条件

   - = 等于

   示例：查询薪资等于800的员工姓名和编号

   ![image-20210829162558811](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829162558811.png)

   示例：查询SMITH的编号和薪资

   ![image-20210829163345795](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829163345795.png)

   - 不等于 <>,!=

     查询薪资不等于800的员工姓名和编号

     ![image-20210829162706735](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829162706735.png)

     以及

     select empno,ename from EMP where sal <> 800;
    
   - 小于 <

     查询薪资小于2000的员工姓名和编号

     ![image-20210829162946109](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829162946109.png)

   - 小于等于 <=

     查询薪资小于等于3000的员工姓名和编号

     ![image-20210829163115802](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829163115802.png)

   - 大于 >

     查询薪资大于2000的员工姓名和编号

     ![image-20210829163153585](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829163153585.png)

   - 大于等于 >=

     查询薪资大于等于800的员工姓名和编号

     ![image-20210829163228968](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829163228968.png)

   - between …… and ……两个值之间，等同于>= and <=

     示例：工资在2450和3000之间的员工信息

     ![image-20210829163525562](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829163525562.png)

     <font color=red>使用between and的时候必须遵循左小右大的原则。</font>

   - is null 为null（is not null 不为空）

     查询哪些员工的津贴/步骤为空

     ![image-20210829164022618](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829164022618.png)

     在数据库中null不能使用=进行衡量，必须是is null。因为数据库中的null表示什么都没有，不是一个值。

   - and 并且

     查询工作岗位是MANAGER，并且工资大于2500的员工信息

     ![image-20210829164506312](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829164506312.png)

   - or 或者

     查询工作岗位是MANAGER或者是SALESMAN的员工信息

     ![image-20210829164633073](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829164633073.png)

     当and和or同时出现的时候，优先级是什么样的？

     示例：查询工资大于2500，并且部门编号为10或20的员工信息

     语句一：select 

     ​                     *

     ​                from

     ​                    EMP

     ​                where 

     ​                    sal > 2500 and deptno = 10 or deptno =  20;

     ​             注意：<font color=red> and优先级比or高。想让or先执行，要加小括号。</font>

     ​           那么上面语句的含义是找出工资大于2500并且部门编号为10的员工，或者部门编号为20的所有员工。

     结果如下：

     ![image-20210829165608111](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829165608111.png)

     语句二：select 

     ​                     *

     ​                from

     ​                    EMP

     ​                where 

     ​                    sal > 2500 and (deptno = 10 or deptno =  20);

     ![image-20210829165654812](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829165654812.png)

   - in 包含，相当于多个or（not in表示不在这个范围中）

     示例：查询工作岗位是MANAGER和SALESMEN的员工信息

     ![image-20210829170001006](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829170001006.png)

     in不表示一个区间，in后面是具体的值。

   - not 可以取非，主要用在is 或 in中，not is 或not in。

     ![image-20210829170248925](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829170248925.png)

   - like 模糊查找，支持%或者下划线匹配

     %匹配任意个字符

     ![image-20210829170409428](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829170409428.png)

     一个下划线只匹配一个字符

     ![image-20210829170554422](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829170554422.png)

     \转义字符，主要用在字符串中有_或%。

##### 排序

1、默认升序 order by

​      示例：

​	![image-20210829172842766](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829172842766.png)

2、指定降序 desc

​	![image-20210829172941310](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829172941310.png)

3、指定升序 asc

​	![image-20210829173000138](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829173000138.png)

4、按照多个字段排序

​	示例：查询员工名字和薪资，要求按照薪资升序，如果薪资一样的话，再按照名字升序排列。

```
	select
		ename，sal
	from
		EMP
	order by
			sal asc，ename asc；
```

![image-20210829173328965](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829173328965.png)

sal在前，起主导，只有在sal相等情况下，才会使用ename。

5、根据字段的位置排序（做了解）

```
	示例：select ename,sal from EMP order by 2;不建议
```

![image-20210829173502861](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829173502861.png)

综合案例：查询工资在1250到3000之间的员工信息，要求按照薪资降序排列。

![image-20210829173716984](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210829173716984.png)

注意：上述语句中的关键字顺序不能改变。

##### 去重

关键字：distinct

只对查询结果去重，不改变原表结构

用法：

```
select distinct job from EMP;
```

![image-20210905103244469](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210905103244469.png)

【注意】错误编写展示：

```
select ename,distinct job from EMP;
```

![image-20210905103402296](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210905103402296.png)

<font color=red>distinct只能出现在所有字段的最前方.</font>

正确展示：

```
select distinct job,deptno from EMP;
```

表示distinct后的两个字段联合起来去重。

![image-20210905103612907](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210905103612907.png)

示例：统计工作岗位的数量

```
select count(distinct job) from EMP;
```

![image-20210905103747073](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/MySQL/image-20210905103747073.png)

## DML

数据操作语言，对表中的数据进行增删改的语句

insert 增

delete 删

update 改

主要是操作表中的数据data。

## DDL

数据定义语言，带有create、drop、alter的语句。

DDL主要操作的是表的结构。

## TCL

事务控制语言

- 事务提交：commit
- 事务回滚：rollback

## DCL

数据控制语言

- 授权：grant
- 撤销权限：revoke