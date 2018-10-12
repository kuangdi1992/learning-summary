# LeetCode 23 合并K个排序链表 #

## 题目 ##
合并 k 个排序链表，返回合并后的排序链表。请分析和描述算法的复杂度。
> 示例:
输入:
[
  1->4->5,
  1->3->4,
  2->6
]
输出: 1->1->2->3->4->4->5->6

## 我的思路1 ##
因为之前做过一道题是合并两个有序链表，所以我想的是将K个排序链表中2个2个的链表进行合并然后最后合并成一个。  
但是这样做的复杂度太高了。

## 我的代码1 ##

    class ListNode:
    def __init__(self, x):
        self.val = x
        self.next = None
    class Solution:
    def mergeKLists(self, lists):
        """
        :type lists: List[ListNode]
        :rtype: ListNode
        """
        l1 = lists[0]
        i = 1
        while i < len(lists):
            l2 = lists[i]
            l1 = self.mergeTwoLists(l1,l2)
        return l1
    def mergeTwoLists(self, l1, l2):
        l = ListNode(0)
        cur = l
        if l1 is None or l2 is None:
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
    
## 我的思路2 ##
考虑到Python的特殊性，所以我的想法是将所有的链表的值都装在一个列表中，然后再将列表进行排序，最后将排序后的列表变为链表就可以了，而且时间复杂度也在可以接受的范围内O(nlogn).

## 我的代码2 ##

    class Solution:
    def mergeKLists(self, lists):
        """
        :type lists: List[ListNode]
        :rtype: ListNode
        """
        res = []
        for i in lists:
            while i:
                res.append(i.val)
                i = i.next
        if res == []:
            return []
        res.sort()
        res = list(reversed(res))
        l = ListNode(0)
        first = l
        while res:
            l.next = ListNode(res.pop())
            l = l.next
        return first.next
        
## 最小堆结构思路 ##
本题可以使用最小堆结构进行代码实现。   
首先将每个list里面的第一个元素，也就是每个list的最小元素（因为list都是已排序），共K个指放入大小为K的堆中，将其维护成最小堆结构。每次将堆顶的元素，也就是最小元素放到结果中，然后取出该元素原先所处的list中的下一个元素放入队中，维护最小堆结构。当所有元素读取完，所有的元素就按照从小到大放到结果链表中。  
> 本次实现中直接使用了Python提供的最小堆的结构。
> heapq使用说明
> a为普通列表 
> - heapq.heapify(a) 调整a，使得其满足最小堆 
> - heapq.heappop(a) 从最小堆中弹出最小的元素 
> - heapq.heappush(a,b) 向最小堆中压入新的元素

## 最小堆结构代码 ##

    class Solution:
    def mergeKLists(self, lists):
        """
        :type lists: List[ListNode]
        :rtype: ListNode
        """
        heap = []
        for ln in lists:
            if ln:
                heap.append((ln.val, ln))
        dummy = ListNode(0)
        cur = dummy
        heapq.heapify(heap)
        while heap:
            valu, ln_index = heapq.heappop(heap)
            cur.next = ln_index
            cur = cur.next
            if ln_index.next:
                heapq.heappush(heap, (ln_index.next.val, ln_index.next))
        return dummy.next


        
