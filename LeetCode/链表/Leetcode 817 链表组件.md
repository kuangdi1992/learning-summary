# Leetcode 817 链表组件

## 题目

- 给定链表头结点 head，该链表上的每个结点都有一个 唯一的整型值 。
- 同时给定列表 G，该列表是上述链表中整型值的一个子集。
- 返回列表 G 中组件的个数，这里对组件的定义为：链表中一段最长连续结点的值（该值必须在列表 G 中）构成的集合。

## 示例

```
输入:
    head: 0->1->2->3->4
    G = [0, 3, 1, 4]
    输出: 2
    解释:
    链表中，0 和 1 是相连接的，3 和 4 是相连接的，所以 [0, 1] 和 [3, 4] 是两个组件，故返回 2。
```

## 我的思路

从题目和示例上分析：

1. 从链表头开始遍历
2. 每遍历一个元素，判断其值是否在数组中（ps：这里我本来想的是判断值是否在数组中，不在的计数最后返回值+1）
3. 但是G中会出现连续的情况，那么自己的那种想法就不可行，于是需要如下判断：
4. 判断当前节点的值是否在数组中，并且下一个节点为空---尾结点，或者下一个节点的值不在数组中----表示当前节点的值是一个组件的尾。
5. 节点递增，知道节点为空，退出循环
6. 返回记录的值即可

## 我的代码

```
public int numComponents(ListNode head, int[] nums) {
    int ans = 0;
    ListNode cur = head;
    Set<Integer> num_set = new HashSet<Integer>();
    for (int i : nums){
        num_set.add(i);
    }
    while (cur != null){
        if(num_set.contains(cur.val) && (cur.next == null || !num_set.contains(cur.next.val)) ){
            ans += 1;
        }
        cur = cur.next;
    }
    return ans;
}
```