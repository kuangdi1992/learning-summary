### 常用方法1

在head标签中，使用style标签来定义各种自己需要的css样式。

```css
*** {
	key : value value;
}
```

具体代码如下：

```html
<head>
        <meta charset="UTF-8">
        <title>Document</title>

        <style type="text/css">
            div{
                border: 1px solid red;
            }
        </style>
    </head>

    <body>
        <div>标签1</div>
        <div>标签2</div>

    </body>
```

效果如下：

![image-20230223220807483](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20230223220807483.png)

### 常用方法2

将css样式单独放一个文件，例如1.css

然后在head标签中，使用link标签专门来引入css样式代码：

```
<head>
        <meta charset="UTF-8">
        <title>Document</title>

        <link rel="stylesheet" type="text/css" href="../css/1.css" />
    </head>
```

问题：为什么我这样写之后没有生效？

怀疑是href的路径没有写对，修改成如下后，正确

```
<link rel="stylesheet" type="text/css" href="./CSS/1.css" />
```

