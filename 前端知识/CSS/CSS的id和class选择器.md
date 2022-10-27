# id选择器

id 选择器可以为标有特定 id 的 HTML 元素指定特定的样式。

HTML元素以id属性来设置id选择器,CSS 中 id 选择器以 "#" 来定义。

代码示例：

```html
<body>
    <p id="hello">hello world!!!</p>
    <p class="hi">123456</p>
</body>

#hello
{
    color: blue;
    font-size: 30px;
}
```

结果：

![image-20221027234504784](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/%E5%89%8D%E7%AB%AF/CSS1.png)

# class选择器

class 选择器用于描述一组元素的样式，class 选择器有别于id选择器，class可以在多个元素中使用。

class 选择器在 HTML 中以 class 属性表示, 在 CSS 中，类选择器以一个点 **.** 号显示：

代码示例：

```css
p.hi
{
    color:blueviolet;
    text-align: center;
}
```

结合上面的html代码，结果如下：

![image-20221027234530220](https://github.com/kuangdi1992/learning-summary/blob/master/Picture/%E5%89%8D%E7%AB%AF/CSS2.png)