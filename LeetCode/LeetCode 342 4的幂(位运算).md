## LeetCode 342 4的幂
### 题目
给定一个整数 (32 位有符号整数)，请编写一个函数来判断它是否是 4 的幂次方。
### 示例
```markdown
输入: 16
输出: true
输入: 5
输出: false
```
#### 我的思路
* 判断是否是2的幂 num & (num -1)
* 判断是否满足(num -1) % 3是否等于0

#### 我的代码
```python
class Solution:
    def isPowerOfFour(self, num: int) -> bool:
        if num < 0:
            return False
        if num & (num - 1) != 0:
            return False
        else:
            if (num - 1) % 3 != 0:
                return False
        return True
```
