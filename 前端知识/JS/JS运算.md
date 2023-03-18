#### 关系运算

等于：==   简单做字面值的比较

全等于：===    除了字面值的比较，还会比较两个变量的数据类型

```html
    <head>
        <meta charset="UTF-8">
        <title>Document</title>
        <script type="text/javascript">
            var a = "12";
            var b = 12;
            alert(a == b); //true
            alert(a === b);  //false
        </script>
    </head>
```

#### 逻辑运算

在JavaScript语言中，所有的变量，都可以做为一个boolean类型的变量去使用。

0、null、undefined、“”（空串）都认为是false

且运算：&&  

第一种：当表达式全为真的时候，返回最后一个表达式的值

```html
    <head>
        <meta charset="UTF-8">
        <title>Document</title>
        <script type="text/javascript">
            var a = "abc";
            var b = true;
            alert(a && b);  //true
            alert(b && a);  //abc
        </script>
    </head>
```

第二种：当表达式中，有一个为假的时候，返回第一个为假的表达式的值

```html
    <head>
        <meta charset="UTF-8">
        <title>Document</title>
        <script type="text/javascript">
            var a = "abc";
            var b = true;
            var d = false;
            var c = null;
            alert(a && d); //false
            alert(a && c); //null
            alert(a && d && c); //false
        </script>
    </head>
```

或运算：||

第一种情况：当表达式全为假时，返回最后一个表达式的值

```html
    <head>
        <meta charset="UTF-8">
        <title>Document</title>
        <script type="text/javascript">
            var a = "abc";
            var b = true;
            var d = false;
            var c = null;
            alert(d || c); //null
            alert(c || d); //false
        </script>
    </head>
```

第二种情况：只要有一个表达式为真时，会返回第一个为真的表达式的值

```html
    <head>
        <meta charset="UTF-8">
        <title>Document</title>
        <script type="text/javascript">
            var a = "abc";
            var b = true;
            var d = false;
            var c = null;
            alert(a || c); //abc
            alert(b || c); //true
        </script>
    </head>
```

取反运算：|