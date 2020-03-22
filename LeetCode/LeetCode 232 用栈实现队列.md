## LeetCode 232 用栈实现队列
### 题目
使用栈实现队列的下列操作：
* push(x) -- 将一个元素放入队列的尾部。
* pop() -- 从队列首部移除元素。
* peek() -- 返回队列首部的元素。
* empty() -- 返回队列是否为空。

### 示例
```markdown
MyQueue queue = new MyQueue();

queue.push(1);
queue.push(2);  
queue.peek();  // 返回 1
queue.pop();   // 返回 1
queue.empty(); // 返回 false
```

### 我的思路
题目中明确提出了，使用栈来实现队列。队列是先进先出的，而栈是先进后出的，因此在这里，我的想法是使用两个栈来模拟队列。一个栈来专门存储入队列的元素，另一个栈用来专门存储出队列的元素，然后在进行出队列的动作时先将入队栈中的数据出栈到出队栈中，然后出栈即可。

### 我的代码
```python
class MyQueue:

    def __init__(self):
        """
        Initialize your data structure here.
        """
        self.instack = []
        self.outstack = []

    def push(self, x: int) -> None:
        """
        Push element x to the back of queue.
        """
        self.instack.append(x)

    def pop(self) -> int:
        """
        Removes the element from in front of queue and returns that element.
        """
        if len(self.outstack) == 0:
            while self.instack:
                self.outstack.append(self.instack.pop())
        return self.outstack.pop()

    def peek(self) -> int:
        """
        Get the front element.
        """
        if len(self.outstack) == 0:
            while self.instack:
                self.outstack.append(self.instack.pop())
        return self.outstack[-1]

    def empty(self) -> bool:
        """
        Returns whether the queue is empty.
        """
        if len(self.instack) == 0 and len(self.outstack) == 0:
            return True
        else:
            return False
```
### 最优解法
思路一样，但是写法不一样
```python
class MyQueue:

    def __init__(self):
        """
        Initialize your data structure here.
        """
        self.val = []

    def push(self, x: int) -> None:
        """
        Push element x to the back of queue.
        """
        self.val.append(x)


    def pop(self) -> int:
        """
        Removes the element from in front of queue and returns that element.
        """
        val_tmp = []
        for i in range(len(self.val)):
            val_tmp.append(self.val.pop())
        item = val_tmp.pop()
        for i in range(len(val_tmp)):
            self.val.append(val_tmp.pop())
        return item


    def peek(self) -> int:
        """
        Get the front element.
        """
        val_tmp = []
        for i in range(len(self.val)):
            val_tmp.append(self.val.pop())
        item = val_tmp[-1]
        for i in range(len(val_tmp)):
            self.val.append(val_tmp.pop())
        return item


    def empty(self) -> bool:
        """
        Returns whether the queue is empty.
        """
        return self.val == []
```