# LeetCode 21 合并两个有序链表 #

## 题目 ##
将两个有序链表合并为一个新的有序链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。   
> 示例：  
> 输入：1->2->4, 1->3->4  
> 输出：1->1->2->3->4->4  

## 我的思路 ##
从第一个节点开始比较，如果l1小于l2,则将l1存入新的链表中，l1到下一个，同理l2也是一样的，当到最后只有l1或者l2后直接全部存储到新的链表中。

## 我的代码 ##

    class Solution:
    def mergeTwoLists(self, l1, l2):
        """
        :type l1: ListNode
        :type l2: ListNode
        :rtype: ListNode
        """
        l = ListNode(0)
        cur = l
        if l1 is None and l2 is None:
            return None
        while l1 is not None or l2 is not None:
            if l1 is not None and l2 is not None:
                if l1.val > l2.val:
                    cur.next = l2
                    l2 = l2.next
                else:
                    cur.next = l1
                    l1 = l1.next
            elif l1 is not None and l2 is None:
                cur.next = l1
                l1 = l1.next
            elif l1 is None and l2 is not None:
                cur.next = l2
                l2 = l2.next
            cur = cur.next
        return l.next

