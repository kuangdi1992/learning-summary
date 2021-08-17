# Leetcode 707 设计链表(单链表)

## 题目

设计链表的实现。您可以选择使用单链表或双链表。单链表中的节点应该具有两个属性：val 和 next。val 是当前节点的值，next 是指向下一个节点的指针/引用。如果要使用双向链表，则还需要一个属性 prev 以指示链表中的上一个节点。假设链表中的所有节点都是 0-index 的。

在链表类中实现这些功能：

1. get(index)：获取链表中第 index 个节点的值。如果索引无效，则返回-1。
2. addAtHead(val)：在链表的第一个元素之前添加一个值为 val 的节点。插入后，新节点将成为链表的第一个节点。
3. addAtTail(val)：将值为 val 的节点追加到链表的最后一个元素。
4. addAtIndex(index,val)：在链表中的第 index 个节点之前添加值为 val  的节点。如果 index 等于链表的长度，则该节点将附加到链表的末尾。如果 index 大于链表长度，则不会插入节点。如果index小于0，则在头部插入节点。
5. deleteAtIndex(index)：如果索引 index 有效，则删除链表中的第 index 个节点。

## 示例

```
MyLinkedList linkedList = new MyLinkedList();
linkedList.addAtHead(1);
linkedList.addAtTail(3);
linkedList.addAtIndex(1,2);   //链表变为1-> 2-> 3
linkedList.get(1);            //返回2
linkedList.deleteAtIndex(1);  //现在链表是1-> 3
linkedList.get(1);            //返回3
```

我的思路：

1、get方法：先判断是否在链表的范围内，若在则从头结点开始，一直寻找到索引为index的节点，返回值。

```
public int get(int index) {
    if (index < 0 || index >= size){
        return -1;
    }//判断
    ListNode cur = head;
    for (int i = 0; i < index + 1; i++){
        cur = cur.next;
    }//找到index节点
    return cur.val;
}
```

2、addAtHead和addAtTail可以通过addAtIndex来实现。

​      addAtIndex方法：

- 找到要插入节点的前驱节点，在尾部插入前驱节点就是尾节点，在头部插入前驱节点就是伪头部。
- 通过移动next来进行插入

具体代码如下：

```
public void addAtHead(int val) {
    addAtIndex(0,val);
}

/** Append a node of value val to the last element of the linked list. */
public void addAtTail(int val) {
    addAtIndex(size,val);

}

/** Add a node of value val before the index-th node in the linked list. If index equals to the length of linked list, the node will be appended to the end of linked list. If index is greater than the length, the node will not be inserted. */
public void addAtIndex(int index, int val) {
    if (index > size){
        return;
    }
    if (index < 0){
        index = 0;
    }
    size += 1;
    ListNode Pre = head;
    for (int i = 0; i < index; i++){
        Pre = Pre.next;
    }
    ListNode tmp = new ListNode(val);
    tmp.next = Pre.next;
    Pre.next = tmp;

}
```

3、deleteAtIndex方法：同样先找到前驱节点，然后利用pred.next = pred.next.next就可以删除pred的next节点了。

```
public void deleteAtIndex(int index) {
    if (index < 0 || index > size){
        return;
    }

    size -= 1;
    ListNode pred = head;
    for (int i = 0; i < index; i++){
        pred = pred.next;
    }
    pred.next = pred.next.next;
}
```

## 全部代码

```
public class ListNode {
    int val;
    ListNode next;

    public ListNode(int x){
        val = x;
    }
}

public class leetcode707 {
    int size;
    ListNode head;
    /** Initialize your data structure here. */
    public leetcode707() {
        size = 0;
        head = new ListNode(0);
    }

    /** Get the value of the index-th node in the linked list. If the index is invalid, return -1. */
    public int get(int index) {
        if (index < 0 || index >= size){
            return -1;
        }
        ListNode cur = head;
        for (int i = 0; i < index + 1; i++){
            cur = cur.next;
        }
        return cur.val;
    }

    /** Add a node of value val before the first element of the linked list. After the insertion, the new node will be the first node of the linked list. */
    public void addAtHead(int val) {
        addAtIndex(0,val);
    }

    /** Append a node of value val to the last element of the linked list. */
    public void addAtTail(int val) {
        addAtIndex(size,val);

    }

    /** Add a node of value val before the index-th node in the linked list. If index equals to the length of linked list, the node will be appended to the end of linked list. If index is greater than the length, the node will not be inserted. */
    public void addAtIndex(int index, int val) {
        if (index > size){
            return;
        }
        if (index < 0){
            index = 0;
        }
        size += 1;
        ListNode Pre = head;
        for (int i = 0; i < index; i++){
            Pre = Pre.next;
        }
        ListNode tmp = new ListNode(val);
        tmp.next = Pre.next;
        Pre.next = tmp;

    }

    /** Delete the index-th node in the linked list, if the index is valid. */
    public void deleteAtIndex(int index) {
        if (index < 0 || index > size){
            return;
        }

        size -= 1;
        ListNode pred = head;
        for (int i = 0; i < index; i++){
            pred = pred.next;
        }
        pred.next = pred.next.next;
    }

    public static void main(String[] args) {
        leetcode707 lk = new leetcode707();
        lk.addAtHead(1);
        lk.addAtTail(3);
        lk.addAtIndex(1,2);
        System.out.println(lk.get(1));
    }
}
```