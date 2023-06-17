# 特点

- 左小右大，每个节点的左子树都比当前节点的值小，右子树都比当前节点的值大
- 对于 BST 的每⼀个节点 node，它的左侧⼦树和右侧⼦树都是 BST
- 中序遍历的结果是有序的(**升序的**)

直接基于 BST 的数据结构有 AVL树，红⿊树等等，拥有了⾃平衡性质，可以提供 logN 级别的增删查改效率；还有 B+ 树，线段树等结构都是基于 BST 的思想来设计的。

# 中序遍历升序

将BST中每个节点的值升序打印出来：

```python
def traverse(root):
    if root is None:
        return
    traverse(root.left)
    print(root.val)
    traverse(root.right)
```

## leetcode 230 BST中第k小的元素【中等】

**题目**：给定一个二叉搜索树的根节点 `root` ，和一个整数 `k` ，请你设计一个算法查找其中第 `k` 个最小元素（从 1 开始计数）。

**示例**：

> 输入：root = [5,3,6,2,4,null,null,1], k = 3
> 输出：3

**思路**：

1、升序排序（中序遍历）

2、找第k个元素

**python代码**：

```python
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    res = 0
    rank = 0
    def kthSmallest(self, root: Optional[TreeNode], k: int) -> int:
        self.traverse(root, k)
        return self.res
    
    def traverse(self, root, k):
        if root is None:
            return
        
        self.traverse(root.left, k)
        self.rank += 1
        if k == self.rank:
            self.res = root.val
            return
        self.traverse(root.right, k)
```

## leetcode 538和1038 将BST转换成累加树

题目：

# 左小右大

代码逻辑：

```python
void BST(TreeNode root, int target) {
	if (root.val == target)
	// 找到⽬标，做点什么
	if (root.val < target)
		BST(root.right, target);
	if (root.val > target)
		BST(root.left, target);
}
```

## leetcode 700. BST 中的搜索【简单】

**题目**：给定二叉搜索树（BST）的根节点 root 和一个整数值 val。

你需要在 BST 中找到节点值等于 val 的节点。 返回以该节点为根的子树。 如果节点不存在，则返回 null 。

**示例**：

> 输入：root = [4,2,7,1,3], val = 2
> 输出：[2,1,3]



## leetcode 98. 验证BST【中等】

**题目**：给你一个二叉树的根节点 root ，判断其是否是一个有效的二叉搜索树。

有效 二叉搜索树定义如下：

- 节点的左子树只包含 小于 当前节点的数。
- 节点的右子树只包含 大于 当前节点的数。
- 所有左子树和右子树自身必须也是二叉搜索树。

**示例**：

> 输入：root = [2,1,3]
> 输出：true



