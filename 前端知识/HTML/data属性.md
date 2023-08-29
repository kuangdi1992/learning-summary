data-toggle和data-target属性

以什么事件类型触发，常用的如下：

```html
data-toggle="dropdown"//下拉菜单
data-toggle="model" //模态框事件
data-toggle="tooltip"//提示框事件
data-toggle="tab"//标签页
data-toggle="collapse"//折叠
data-toggle="popover"//弹出框
data-toggle="button"//按钮事件
data-toggle="pill"
```

一般事件会作用到一个标签对象，如果是其他标签对象，需要使用data-target指事件的标签目标，因此data-toggle和data-target会结合使用。

```html
<button class="btn btn-primary btn-lg" data-toggle="modal" data-target="#myModal">

 开始演示模态框
</button>
<!-- 模态框（Modal） -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
 <div class="modal-dialog">
  <div class="modal-content">
   <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
     ×
    </button>
    code。。。
   </div>
  </div><!-- /.modal-content -->
 </div><!-- /.modal -->
</div>
```

