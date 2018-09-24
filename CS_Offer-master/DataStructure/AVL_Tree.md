AVL树是最早提出的`自平衡二叉树`，它是一种特殊的二叉搜索树，任一节点的左子树深度和右子树深度相差不超过1，所以它也被称为高度平衡树。

![][1]

上面的两张图片，左边的是AVL树，它的任何节点的两个子树的高度差别都<=1；而右边的不是AVL树，因为7的两颗子树的高度相差为2(以2为根节点的树的高度是3，而以8为根节点的树的高度是1)。

VL树的特性让二叉搜索树的节点实现平衡(balance)：节点相对均匀分布，而不是偏向某一侧。因此，AVL树种查找、插入和删除在平均和最坏情况下都是O（log n），增加和删除可能需要通过一次或多次树旋转来重新平衡这个树。

## 失衡状态

有四种种情况可能导致二叉查找树不平衡，分别为：

1. LL：插入一个新节点到根节点的左子树（Left）的左子树（Left），导致根节点的平衡因子由1变为2
2. LR：插入一个新节点到根节点的左子树（Left）的右子树（Right），导致根节点的平衡因子由1变为2
3. RR：插入一个新节点到根节点的右子树（Right）的右子树（Right），导致根节点的平衡因子由-1变为-2
4. RL：插入一个新节点到根节点的右子树（Right）的左子树（Left），导致根节点的平衡因子由-1变为-2

下面给出它们的示意图：

![][2]

上图中的4棵树都是"失去平衡的AVL树"，从左往右的情况依次是：LL、LR、RL、RR。除了上面的情况之外，还有其它的失去平衡的AVL树，如下图：

![][3]

总的来说，AVL树失去平衡时的情况一定是LL、LR、RL、RR这4种之一。

## 旋转操作

针对四种种情况可能导致的不平衡，可以通过旋转使之变平衡。以下图表以四列表示四种情况，每行表示在该种情况下要进行的操作。在左左和右右的情况下，只需要进行一次旋转操作；在左右和右左的情况下，需要进行两次旋转操作。

![][4]

## 插入、删除操作

平衡二叉树的插入操作和二叉查找树是一样的，区别在于要时刻保持树的平衡，所以在插入之后要添加一个旋转算法来保持平衡，保持平衡需要借助一个节点高度的属性。

只有 “插入点至根节点” 路径上的各节点可能改变平衡状态，因此，只要调整其中最深（区分深度和高度）的那个节点，便可以使整棵树重新获得平衡，调整最深的节点就是调整不平衡节点当中距离根节点最长的那个节点。

删除操作也是在平衡二叉树的删除基础上，加上旋转动作保持平衡二叉树的性质。

# 参考  
《STL源码剖析》  
[Wiki: AVL tree](https://en.wikipedia.org/wiki/AVL_tree)  
[AVL树(一)之 图文解析 和 C语言的实现](http://www.cnblogs.com/skywang12345/p/3576969.html)  


[1]: http://7xrlu9.com1.z0.glb.clouddn.com/DataStructure_AVL_1.jpg
[2]: http://7xrlu9.com1.z0.glb.clouddn.com/DataStructure_AVL_2.jpg
[3]: http://7xrlu9.com1.z0.glb.clouddn.com/DataStructure_AVL_3.jpg
[4]: http://7xrlu9.com1.z0.glb.clouddn.com/DataStructure_AVL_4.jpg

