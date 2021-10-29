# CSS技术

## CSS介绍

CSS 是「层叠样式表单」 ， 是用于(增强)控制网页样式并允许将样式信息与网页内容分离的一种标记性语言。 

## CSS语法规则

 ![image-20211025195419266](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20211025195419266.png)

- 选择器： 浏览器根据“选择器” 决定受 CSS 样式影响的 HTML 元素（标签） 。
- 属性 (property) 是你要改变的样式名， 并且每个属性都有一个值。 属性和值被冒号分开， 并由花括号包围， 这样就组成了一个完整的样式声明（declaration） ， 例如： p {color: blue}
- 多个声明： 如果要定义不止一个声明， 则需要用分号将每个声明分开。 虽然最后一条声明的最后可以不加分号(但尽量在每条声明的末尾都加上分号)  

## CSS和HTML结合方式

### 第一种

在标签的style属性上设置”key:value value;”， 修改标签样式。  

```html
<body>
    <!--需求1：分别定义两个 div、span标签，分别修改每个 div 标签的样式为：边框1个像素，实线，红色。-->
    <div style="border: 1px solid red;">div标签1</div>
    <div style="border: 1px solid red;">div标签2</div>
    <span style="border: 1px solid red;">span标签1</span>
    <span style="border: 1px solid red;">span标签2</span>
</body>
```

结果：

![image-20211025200713814](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20211025200713814.png)

### 第二种

在head标签中，使用style标签来定义各种自己需要的CSS样式。

```html
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <!--style标签专门用来定义css样式代码-->
    <style type="text/css">
        /* 需求1：分别定义两个 div、span标签，分别修改每个 div 标签的样式为：边框1个像素，实线，红色。*/
        div{
            border: 1px solid red;
        }
        span{
            border: 1px solid red;
        }
    </style>
</head>

<body>
    <div>div标签1</div>
    <div>div标签2</div>

    <span>span标签1</span>
    <span>span标签2</span>
</body>
```

结果：

![image-20211025200713814](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20211025200713814.png)

缺点：只能在同一个页面中复用代码，不推荐。

### 第三种

将CSS样式写成一个单独的CSS文件，再通过link标签引入即可复用。

```
使用 html 的<link rel="stylesheet" type="text/css" href="./styles.css" />标签 导入 css 样式文件。
```

   ![image-20211025201656742](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20211025201656742.png)

```html
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <!--link标签专门用来引入css样式代码-->
    <link rel="stylesheet" type="text/css" href="1.css"/>
</head>

<body>
    <div>div标签1</div>
    <div>div标签2</div>

    <span>span标签1</span>
    <span>span标签2</span>
</body>
```

结果：

![image-20211025200713814](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20211025200713814.png)

## CSS选择器

### 标签名选择器

格式：

```
标签名{
属性： 值;
}
```

标签名选择器， 可以决定哪些标签被动的使用这个样式。 

### ID选择器

格式：

```html
#id 属性值{
属性： 值;
}
```

id选择器， 可以让我们通过 id 属性选择性的去使用这个样式。  

```html
<head>
   <meta charset="UTF-8">
   <title>ID选择器</title>
   <style type="text/css">

      #id001{
         color: blue;
         font-size: 30px;
         border: 1px yellow solid;
      }

      #id002{
         color: red;
         font-size: 20px;
         border: 5px blue dotted ;
      }

   </style>
</head>
<body>    
   <!--
   需求1：分别定义两个 div 标签，
   第一个div 标签定义 id 为 id001 ，然后根据id 属性定义css样式修改字体颜色为蓝色，
   字体大小30个像素。边框为1像素黄色实线。
   
   第二个div 标签定义 id 为 id002 ，然后根据id 属性定义css样式 修改的字体颜色为红色，字体大小20个像素。
   边框为5像素蓝色点线。
    -->
   
   <div id="id002">div标签1</div>
   <div id="id001">div标签2</div>
</body>
```

![image-20211025202527691](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20211025202527691.png)

通过id属性可以选择性的使用。

### class选择器

格式：

```html
.class 属性值{
属性： 值;
}
```

可以通过 class 属性有效的选择性地去使用这个样式  。

```html
<head>
   <meta charset="UTF-8">
   <title>class类型选择器</title>
   <style type="text/css">
      .class01{
         color: blue;
         font-size: 30px;
         border: 1px solid yellow;
      }

      .class02{
         color: grey;
         font-size: 26px;
         border: 1px solid red;
      }
   </style>
</head>
<body>
   <!--
      需求1：修改 class 属性值为 class01的 span 或 div 标签，字体颜色为蓝色，字体大小30个像素。边框为1像素黄色实线。
      需求2：修改 class 属性值为 class02的 div 标签，字体颜色为灰色，字体大小26个像素。边框为1像素红色实线。
    -->

   <div class="class01">div标签class01</div>
   <div class="class02">div标签</div>
   <span class="class02">span标签class01</span>
   <span>span标签2</span>
</body>
```

![image-20211025204722993](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20211025204722993.png)

### 组合选择器

格式：

```
选择器 1， 选择器 2， 选择器 n{
属性： 值;
}
```

```html
<head>
    <meta charset="UTF-8">
    <title>class类型选择器</title>
    <style type="text/css">
        .class01 , #id01{
            color: blue;
            font-size: 20px;
            border:  yellow 1px solid;
        }
    </style>
</head>
<body>
   <!-- 
   需求1：修改 class="class01" 的div 标签 和 id="id01" 所有的span标签，
   字体颜色为蓝色，字体大小20个像素。边框为1像素黄色实线。
    -->
   <div id="id01">div标签class01</div> <br />
   <span class="class01">span 标签</span>  <br />
   <div>div标签</div> <br />
   <div>div标签id01</div> <br />
</body>
```

![image-20211025204920567](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20211025204920567.png)

