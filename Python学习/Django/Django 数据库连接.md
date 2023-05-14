# ORM

ORM可以帮助做两件事：

- 创建、修改、删除数据库中的表。
- 操作表中的数据。

# 连接`MySQL`配置

文件：settings.py

```python
#Django默认数据库
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
#使用MySQL数据库
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'dbtest1',
        'USER': 'root',
        'PASSWORD': '123456',
        'HOST': '127.0.0.1',
        'PORT': '3306',
    }
}
```

# Django操作表

文件：app01/models.py

## 创建表

```python
class UserInfo(models.Model):
    name = models.CharField(max_length=32)
    password = models.CharField(max_length=64)
    age = models.IntegerField()

"""
create table app01_userinfo(
    id bigint auto_increment primary key,
    name varchar(32),
    password varchar(64),
    age int
)
"""
```

在命令行执行如下命令，创建上述代码中的表：

`python manage.py makemigrations`

`python manage.py migrate`

```shell
F:\Python\mysite>python manage.py makemigrations
Migrations for 'app01':
  app01\migrations\0001_initial.py
    - Create model UserInfo

F:\Python\mysite>python manage.py migrate
Operations to perform:
  Apply all migrations: admin, app01, auth, contenttypes, sessions
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying app01.0001_initial... OK
  Applying contenttypes.0002_remove_content_type_name... OK
  Applying auth.0002_alter_permission_name_max_length... OK
  Applying auth.0003_alter_user_email_max_length... OK
  Applying auth.0004_alter_user_username_opts... OK
  Applying auth.0005_alter_user_last_login_null... OK
  Applying auth.0006_require_contenttypes_0002... OK
  Applying auth.0007_alter_validators_add_error_messages... OK
  Applying auth.0008_alter_user_username_max_length... OK
  Applying auth.0009_alter_user_last_name_max_length... OK
  Applying auth.0010_alter_group_name_max_length... OK
  Applying auth.0011_update_proxy_permissions... OK
  Applying auth.0012_alter_user_first_name_max_length... OK
  Applying sessions.0001_initial... OK
```

在数据库中查看：

```sql
mysql> use dbtest1;
Database changed

mysql> show tables;
+----------------------------+
| Tables_in_dbtest1          |
+----------------------------+
| app01_userinfo             |
| auth_group                 |
| auth_group_permissions     |
| auth_permission            |
| auth_user                  |
| auth_user_groups           |
| auth_user_user_permissions |
| django_admin_log           |
| django_content_type        |
| django_migrations          |
| django_session             |
| test_int1                  |
+----------------------------+
12 rows in set (0.00 sec)

mysql> desc app01_userinfo;
+----------+-------------+------+-----+---------+----------------+
| Field    | Type        | Null | Key | Default | Extra          |
+----------+-------------+------+-----+---------+----------------+
| id       | bigint      | NO   | PRI | NULL    | auto_increment |
| name     | varchar(32) | NO   |     | NULL    |                |
| password | varchar(64) | NO   |     | NULL    |                |
| age      | int         | NO   |     | NULL    |                |
+----------+-------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)
```

从上表可以看到，数据库表创建成功。

### 注意

- 增加表，删除列操作，可以直接执行上述命令



## 修改表

- 增加新的列或者修改列的时候，原数据库表中已有数据，会出现如下：

  ```
  F:\Python\mysite>python manage.py makemigrations
  Was userinfo.age renamed to userinfo.size (a IntegerField)? [y/N] n
  It is impossible to add a non-nullable field 'size' to userinfo without specifying a default. This is because the database needs something to populate existing rows.
  Please select a fix:
   1) Provide a one-off default now (will be set on all existing rows with a null value for this column)
   2) Quit and manually define a default value in models.py.
  Select an option:
  ```

  - 选择1的话，手动输入一个值

    ```shell
    F:\Python\mysite>python manage.py makemigrations
    Was userinfo.age renamed to userinfo.size (a IntegerField)? [y/N] n
    It is impossible to add a non-nullable field 'size' to userinfo without specifying a default. This is because the database needs something to populate existing rows.
    Please select a fix:
     1) Provide a one-off default now (will be set on all existing rows with a null value for this column)
     2) Quit and manually define a default value in models.py.
    Select an option: 1
    Please enter the default value as valid Python.
    The datetime and django.utils.timezone modules are available, so it is possible to provide e.g. timezone.now as a value.
    Type 'exit' to exit this prompt
    >>> 1
    Migrations for 'app01':
      app01\migrations\0003_remove_userinfo_age_userinfo_size.py
        - Remove field age from userinfo
        - Add field size to userinfo
    
    F:\Python\mysite>python manage.py migrate
    Operations to perform:
      Apply all migrations: admin, app01, auth, contenttypes, sessions
    Running migrations:
      Applying app01.0003_remove_userinfo_age_userinfo_size... OK
    ```

  - 选择2的话，需要添加一个默认值

    `age = models.IntegerField(default=1)`

  - 允许为空

    `data = models.IntegerField(null=True, blank=True)`

# ORM增删改查

## 增加

```python
# 测试ORM操作表中的数据
    models.Department.objects.create(title="IT部")
    models.UserInfo.objects.create(name='kd', password='123', age=22)
    models.UserInfo.objects.create(name='zs', password='234', age=21)
```

## 删除

```python
# 删除
    models.UserInfo.objects.filter(id=1).delete()
    models.Department.objects.all().delete()
```

## 修改

```python
# 更新数据
    models.UserInfo.objects.all().update(password='123')
    models.UserInfo.objects.filter(id=2).update(name='kd')
```

## 查询

```python
# 获取数据，符合条件的所有数据
    data = models.UserInfo.objects.all()
    print(type(data))
    print(data)
    for obj in data:
        print(obj.name, obj.password, obj.age)
    
    data2 = models.UserInfo.objects.filter(id=2)
    print(data2)
    # 获取第一条数据，对象
    data3 = models.UserInfo.objects.filter(id=2).first()
    print(data3.name, data3.password, data3.age)
```

