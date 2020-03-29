二叉查找树，也称排序二叉树，是指一棵空树或者具备下列性质的二叉树(每个结点都不能有多于两个儿子的树)：

1. 若任意结点的左子树不空，则左子树上所有结点的值均小于它的根结点的值；
2. 若任意结点的右子树不空，则右子树上所有结点的值均大于它的根结点的值；
3. 任意结点的左、右子树也分别为二叉查找树；
4. **没有键值相等的结点**。

从其性质可知，定义排序二叉树树的一种自然的方式是递归的方法，其算法的核心为递归过程，由于它的平均深度为O(logN)，所以递归的操作树，一般不必担心栈空间被耗尽。

BST 的结点结构体定义如下，结点中除了 key 域，还包含域 left, right 和 parent，它们分别指向结点的左儿子、右儿子和父结点：
* C语言
```C
    typedef struct Node
    {
        int key;
        Node* left;
        Node* right;
        Node* parent;
    } *BSTree;
```
* python代码下BST的结构体的定义：
```python
	class Node:
		def __init__(self, key):
			self.key = key
			self.left = None
			self.right = None
			self.parent = None
			
	初始化操作：
	class BST:
		def __init__(self, *args):
			self.Root = None
```

## 插入结点

由于二叉查找树是递归定义的，插入结点的过程是：若原二叉查找树为空，则直接插入；否则，若关键字 k 小于根结点关键字，则插入到左子树中，若关键字 k 大于根结点关键字，则插入到右子树中。
* C语言
```C
    int BST_Insert(BSTree *T, int k, Node* parent=NULL)
    {
        if(T == NULL)
        {
            T = (BSTree)malloc(sizeof(Node));
            T->key = k;
            T->left = NULL;
            T->right = NULL;
            T->parent = parent;
            return 1;  // 返回1表示成功
        }
        else if(k == T->key)
            return 0;  // 树中存在相同关键字
        else if(k < T->key)
            return BST_Insert(T->left, k, T);
        else
            return BST_Insert(T->right, k, T);
    }
```
* python代码
```python
   def insert(self, key, *args):
        if not self.Root: #树为空
            self.Root = Node(key) #当前节点作为根节点
        elif len(args) == 0: #查找当前节点是否存在,不存在则执行插入操作
            if not self.find(key, self.Root): #从根节点开始查，没找到返回None
                self.insert(key, self.Root) #既然没找到，那就插入操作吧
        else: #树不为空了，当前节点在BST中也不存在了，那就开始插入操作
            child = Node(key) #用节点类创建孩子节点
            parent = args[0]  #找到当前根节点，设置为双亲节点
            if child.key > parent.key: #比较key值，大于则向右转
                if not parent.right: #看看当前根节点的右有人不？没人？这孩子我要了
                    parent.right = child
                    child.parent = parent
                else: #有人？那以当前根节点的右孩子为根节点，递归吧，看看谁要这孩子
                    self.insert(key, parent.right)
            else: #小于则向左转
                if not parent.left:
                    parent.left = child
                    child.parent = parent
                else:
                    self.insert(key, parent.left)
```

## 搜索结点

BST 的查找是从根结点开始，若二叉树非空，将给定值与根结点的关键字比较，若相等，则查找成功；若不等，则当给定值小于根结点关键字时，在根结点的左子树中查找，否则在根结点的右子树中查找。显然，这是一个递归的过程。
* C语言
```C
    Node* BST_Search(BSTree *T, int k)
    {
    	if(T == NULL || k == T->key)
    		return T;
    	if(k < T->key)
    		return BST_Search(T->left, k);
    	else
    		return BST_Search(T->right, k);
    }

也可以使用非递归的实现：

    Node* BST_Search_NonRecur(BSTree *T, int k)
    {
    	while(T != NULL && k != T->key)
    	{
    		if(k < T->key)
    			T = T->left;
    		else
    			T = T->right;
    	}
    	return T;
    }
```
* python代码
```python
	 def find(self, key, *args):
	    #边界条件作用：不断找根节点赋值给start，为空时start=None
	    if len(args) == 0: 
			start = self.Root
		else:
			start = args[0] 
		if not start: #如果没有节点，则返回None
			return None 
		#如果根节点存在，则比较key值，遵循BST的右大左小规律递归查询
		if key == start.key: #找到则返回该节点
			return start
		elif key > start.key: #大于向右转
			return self.find(key, start.right)
		else: #小于向左转
			return self.find(key, start.left)
```

由二叉查找树的性质可知，最左下结点即为关键字最小的结点，最右下结点即为关键字最大的结点。

## 删除结点

二叉查找树的删除操作是相对复杂一点，它要按 3 种情况来处理：

1. 若被删除结点 z 是叶子结点，则直接删除，不会破坏二叉排序树的性质；
2. 若结点 z 只有左子树或只有右子树，则让 z 的子树成为 z 父结点的子树，替代 z 的位置；
3. 若结点 z 既有左子树，又有右子树，则用 z 的直接前驱（或后继）代替 z，然后从二叉查找树中删除这个前驱（或后继）结点，这样就转换成了第一或第二种情况。（**这里z的前驱一定为z的左子树中值最大的结点，前驱一定为叶子结点或者前驱只有左子树**）。

删除一个有左、右子树的结点的示意图（用前驱替换被删除结点）如下：

![][1]

`前驱`和`后继`即为该结点在中序遍历中的前一个结点和后一个结点。如果所有的关键字均不相同，则某结点 x 的后继是：

* 若结点 x 的右子树不为空，则 x 的后继就是它的右子树中值最小的结点；
* 若结点 x 的右子树为空，为了找到其后继，从结点 x 开始向上查找，直到遇到一个祖先结点 y，它的左儿子为 x 或者为结点 x 的祖先，则结点 y 就是结点 x 的后继。如下图

如下图：

![][2]

寻找后继结点的实现如下：

    Node* BST_Successor(Node* node)
    {
        if(node->right != NULL)
            return BST_Minimum(node->right);
        Node* p = node->parent;
        while(p!=NULL && p->right == node)
        {
            node = p;
            p = p->parent;
        }
        return p;
    }

其中 BST_Minimum 返回值最小的结点，即最左下方的结点，实现如下：

    Node* BST_Minimum(BSTree *T)
    {
    	while(T->left != NULL)
    		T = T->left;
    	return T;
    }
## 寻找最小值
BST上查找——最小值：find_min()，这个只要记住BST上节点值最小的就是树上最左边的节点。就一直找左边，直到某个没有左子的节点为止。
* python代码
```python
	def find_min(self, *args): # 查找BST上最小值：其实就是树上最左边的节点
		if len(args) == 0: # 没给出参数，则找到BST的根节点
			node = self.Root
		else: #否则找到当前节点作为根节点
			node = args[0]

		if not node.left: #直到某个没有左子的节点为止，该节点就是最小的点
			return node
		else:
			return self.find_min(node.left)
```
## 寻找最大值
BST上查找——最小值：find_max()。
* python代码
```python
	def find_max(self, *args):
        if len(args) == 0:
            node = self.Root
        else:
            node = args[0]
            
        if not node.right:
            return node
        else:
            return self.find_max(node.right)
```
## 寻找次大值
BST上查找——次大值：next_larger(), 算法思路（1）找到该节点；（2）查找该节点右子树上最小的点；（3）如果该节点无右子树，则查找左双亲节点的右双亲节点。
* python代码
```python
	def next_larger(self, key):
		if self.find(key) is None:
			print("no exist this node")
		else:
			node = self.find(key)
			if node.right is not None: #有右子树的情况
				print("The node %d has right child, its next larger node is %d!" % (key, self.find_min(node.right).key))
			else: #没有右子树的情况
				leftparent = node.parent
				rightparent = leftparent.parent
				print("The node %d has no right, its next larger node is %d!" % (key, rightparent.key))
```
参考：
[二叉查找树（BST）](http://songlee24.github.io/2015/01/13/binary-search-tree/)


[1]: http://7xrlu9.com1.z0.glb.clouddn.com/DataStructure_BST_1.png
[2]: http://7xrlu9.com1.z0.glb.clouddn.com/DataStructure_BST_2.png


