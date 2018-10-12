# LeetCode 22 括号生成 #
## 题目 ##
给出 n 代表生成括号的对数，请你写出一个函数，使其能够生成所有可能的并且有效的括号组合。  
> 例如，给出 n = 3，生成结果为：
> [
>   "((()))",
>   "(()())",
>   "(())()",
>   "()(())",
>   "()()()"
> ]

## 自己的思路 ##
说实话，这道题我开始的时候的想法是：将n对括号进行排列组合，然后进行判断是不是有效的括号组合。  
但是这样的方法太愚蠢，所以我想用另外的方法。
在网上找了一圈，方法大概都差不多，分成left和right，开始的时候将left和right初始化为n，如果left的个数大于0，则加左括号，同时left-1，如果right的个数大于left的个数，则可以加上右括号，同时right-1，这样直到left和right都=0为止。  
> 用到了递归。

## 代码 ##

    class Solution:
    def generateParenthesis(self, n):
        """
        :type n: int
        :rtype: List[str]
        """
        ans = []
        self.guocheng(n,n,"",ans)
        return ans


    def guocheng(self,left,right,ret,ans):
        if left == 0 and right == 0:
            ans.append(ret)
            return
        if left > 0:
            self.guocheng(left-1,right,ret+"(",ans)
        if left < right:
            self.guocheng(left,right-1,ret+")",ans)