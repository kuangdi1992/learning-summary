# LeetCode 24 两两交换链表中的节点 #

## 题目 ##
给定一个链表，两两交换其中相邻的节点，并返回交换后的链表。
> 示例:
> 给定 1->2->3->4, 你应该返回 2->1->4->3.
>> 说明:
>>> 1.你的算法只能使用常数的额外空间。  
>>> 2.你不能只是单纯的改变节点内部的值，而是需要实际的进行节点交换。

## 我的思路 ##
创建三个指针：  
　　head指向开始交换的节点的上一个节点  
　　n1指向需要交换的第一个节点，即head.next  
　　n2指向需要交换的第二个节点，即head.next.next  
循环链表，通过head不断交换n1/n2位置即可。  
其实这就是利用了上一个节点来对后面的两个节点进行交换。

## 我的代码 ##

    class Solution:
    def swapPairs(self, head):
        """
        :type head: ListNode
        :rtype: ListNode
        """
        k = ListNode(0)
        k.next = head
        head = k

        while head.next is not None and head.next.next is not None:
            n1 = head.next
            n2 = head.next.next

            head.next = n2
            n1.next = n2.next
            n2.next = n1
            head = n1

        return k.next 