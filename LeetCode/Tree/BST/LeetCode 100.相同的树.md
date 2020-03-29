## LeetCode 100.相同的树
### 题目
给定两个二叉树，编写一个函数来检验它们是否相同。
如果两个树在结构上相同，并且节点具有相同的值，则认为它们是相同的。

#### 示例 1:
```markdown
输入:      1         1
          / \       / \
         2   3     2   3

        [1,2,3],   [1,2,3]
输出: true

示例 2:

输入:      1         1
          /           \
         2             2

        [1,2],     [1,null,2]
输出: false

示例 3:

输入:      1         1
          / \       / \
         2   1     1   2

        [1,2,1],   [1,1,2]
输出: false
```
### 我的思路
本题只需要使用`递归`来判断节点的左子树和右子树，是否和另外一个树的左子树和右子树一样，如果不一样则返回False。

### python代码
```python
class TreeNode:
    def __init__(self, x):
        self.val = x
        self.left = None
        self.right = None
        self.parent = None

class BST:

    def __init__(self, *args):
        self.Root = None

    def insert(self, key, *args):
        if not self.Root:  # 树为空
            self.Root = TreeNode(key)  # 当前节点作为根节点
        elif len(args) == 0:  # 查找当前节点是否存在,不存在则执行插入操作
            if not self.find(key, self.Root):  # 从根节点开始查，没找到返回None
                self.insert(key, self.Root)  # 既然没找到，那就插入操作吧
        else:  # 树不为空了，当前节点在BST中也不存在了，那就开始插入操作
            child = TreeNode(key)  # 用节点类创建孩子节点
            parent = args[0]  # 找到当前根节点，设置为双亲节点
            if child.val > parent.val:  # 比较key值，大于则向右转
                if not parent.right:  # 看看当前根节点的右有人不？没人？这孩子我要了
                    parent.right = child
                    child.parent = parent
                else:  # 有人？那以当前根节点的右孩子为根节点，递归吧，看看谁要这孩子
                    self.insert(key, parent.right)
            else:  # 小于则向左转
                if not parent.left:
                    parent.left = child
                    child.parent = parent
                else:
                    self.insert(key, parent.left)

    def find(self, key, *args):
        # 边界条件作用：不断找根节点赋值给start，为空时start=None
        if len(args) == 0:
            start = self.Root
        else:
            start = args[0]
        if not start:  # 如果没有节点，则返回None
            return None
            # 如果根节点存在，则比较key值，遵循BST的右大左小规律递归查询
        if key == start.val:  # 找到则返回该节点
            return start
        elif key > start.val:  # 大于向右转
            return self.find(key, start.right)
        else:  # 小于向左转
            return self.find(key, start.left)
class Solution:
    def isSameTree(self, p: TreeNode, q: TreeNode) -> bool:
        if p is None and q is None:
            return True
        if p is None or q is None:
            return False
        if p.val != q.val:
            return False
        else:
            return self.isSameTree(p.left, q.left) and self.isSameTree(p.right, q.right)
tree1 = BST()
A = [1,2,3]
for i in A:
    tree1.insert(i)
tree2 = BST()
B = [1,2,3]
for i in B:
    tree2.insert(i)
s = Solution()
print(s.isSameTree(tree1.Root,tree2.Root))
```
### 复杂度
时间复杂度 : O(N)，其中 N 是树的结点数，因为每个结点都访问一次。

空间复杂度 : 最优情况（完全平衡二叉树）时为 O(log(N))，最坏情况下（完全不平衡二叉树）时为 O(N)，用于维护递归栈。

