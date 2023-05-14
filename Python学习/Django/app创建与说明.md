# 创建APP

```
-项目
	-app，用户管理【表结构，函数，HTML模板，CSS】
	-app，订单管理【表结构，函数，HTML模板，CSS】
	-app，后台管理【表结构，函数，HTML模板，CSS】
	...
```

命令：

```python
python manage.py startapp app名字
```

![image-20230503100847113](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230503100847113.png)

# APP目录

```
│  manage.py
│
├─.idea
│  │  .gitignore
│  │  misc.xml
│  │  modules.xml
│  │  mysite.iml
│  │  vcs.xml
│  │  workspace.xml
│
├─app01
│  │  admin.py 【固定】
│  │  apps.py 【固定】
│  │  models.py  【重要，数据库相关操作】
│  │  tests.py
│  │  views.py 【重要，和ursl对应】
│  │  __init__.py
│  │
│  └─migrations 【数据库相关，固定】
│          __init__.py
│
├─mysite
│  │  asgi.py
│  │  settings.py
│  │  urls.py
│  │  wsgi.py
│  │  __init__.py
│
└─templates
```

# 注册APP

settings.py配置文件

```shell
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'app01.apps.App01Config', #对应app01的apps.py
]
```

# 编写URL和视图函数的对应关系

文件：urls.py

```python
from django.urls import path
from app01 import views

urlpatterns = [
    # path('admin/', admin.site.urls),
    path('index/', views.index),
]
```

# 编写视图函数

文件：app01/view.py

```python
from django.shortcuts import render, HttpResponse

# Create your views here.


def index(request):
    return HttpResponse("欢迎")
```

# 启动Django

- 命令行启动

  ```python
  python manage,py runserver
  ```

- Pycharm启动

![image-20230503102730595](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230503102730595.png)