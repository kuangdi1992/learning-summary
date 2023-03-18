#### 格式

var 数组名 = [];   //空数组

var 数组名 = [1,'abc',true]; //定义数组同时赋值元素

```html
    <head>
        <meta charset="UTF-8">
        <title>Document</title>
        <script type="text/javascript">
            var arr = [];
            alert(arr.length); //0

            arr[0] = 1;
            alert(arr.length); //1

            //JS中的数组，通过数组下标赋值，最大的下标值会自动给数组扩容
            arr[2] = "abc";
            alert(arr.length); //3
        </script>
    </head>
```

