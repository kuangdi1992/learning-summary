#### 标签名选择器

格式：

```
标签名{
	属性：值
}
```

可以决定哪些标签被动的使用这个样式，直接生效的。

#### id选择器

格式

```
#id 属性值{
	属性：值;
}
```

可以通过id属性选择性的去使用这个样式。

示例：

```html
<head>
        <meta charset="UTF-8">
        <title>Document</title>

        <style type="text/css">
            #id001{
                color:blue;
                font-size: 30px;
                border: 1px yellow dotted;
            }
        </style>
    </head>

    <body>
        <div id="id001">div标签1</div>
        <div id="id002">div标签2</div>
    </body>
```

![image-20230223224719567](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230223224719567.png)

#### class选择器（类选择器）

格式

```
.class属性值{
	属性：值；
}
```

可以通过class属性有效的选择使用这个样式。

```html
<head>
        <meta charset="UTF-8">
        <title>Document</title>

        <style type="text/css">
            .class01{
                color:blue;
                font-size: 30px;
                border: 1px red dotted;
            }
        </style>
    </head>

    <body>
        <div class="class01">div标签class</div>
    </body>
```

#### 组合选择器

格式

```
选择器1，选择器2，选择器n{
	属性：值；
}
```

示例：

```
<head>
        <meta charset="UTF-8">
        <title>Document</title>

        <style type="text/css">
            #id001,.class01{
                color:blue;
                font-size: 30px;
                border: 1px red dotted;
            }
        </style>
    </head>

    <body>
        <div id="id001">div标签1</div>
        <div id="id002">div标签2</div>
        <div class="class01">div标签class</div>
    </body>
```

结果：

![image-20230223225455226](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230223225455226.png)