# LeetCode20 有效的括号 #

### 题目 ###
给定一个只包括 '('，')'，'{'，'}'，'['，']' 的字符串，判断字符串是否有效。  

> 有效字符串需满足：  
>> 1.左括号必须用相同类型的右括号闭合。  
>> 2.左括号必须以正确的顺序闭合。  

> 注意空字符串可被认为是有效字符串。  

示例 1:  
输入: "()"  
输出: true  

示例 2:  
输入: "()[]{}"  
输出: true  

示例 3:  
输入: "(]"  
输出: false  

示例 4:  
输入: "([)]"  
输出: false  

示例 5:  
输入: "{[]}"  
输出: true  

### 我的思路 ###
通过对题目的理解，我觉得遇到左括号的时候将所遇到的左括号进栈，然后遇到右括号的时候将进栈的左括号出栈，如果出栈的左括号和遇到的右括号刚好是一对的话，则表示没有问题，如果不是，则有问题返回FALSE。  
在这里有两个特殊情况：  
1.如果输入是“[”,这样要考虑没有右括号的情况，相似的是“[][”这种。  
2.如果输入是“}”，这样第一个就是右括号，这样是肯定不满足情况的。

### 我的代码 ###

    class Solution:
    def isValid(self, s):
        """
        :type s: str
        :rtype: bool
        """
        if s == "":
            return True
        if s[0] == '}' or s[0] == ')' or s[0] == ']':
            return False
        length = len(s)
        left = []
        i = 0
        while i < length:
            if s[i] == '{' or s[i] == '(' or s[i] == '[':
                left.append(s[i])
            if s[i] == '}' or s[i] == ')' or s[i] == ']':
                if left != []:
                    leftstr = left.pop()
                    if (s[i] == '}' and leftstr != '{') or (s[i] == ']' and leftstr != '[') or (s[i] == ')' and leftstr != '('):
                        return False
                else:
                    return False
            i = i + 1
        if left == []:
            return True
        else:
            return False
     
### 网上的代码 ###
网上的代码的思路和我的思路是一样的，也是那样的，但是解决的方式不一样。

    class Solution:
    def isValid(self, s):
        """
        :type s: str
        :rtype: bool
        """
        stack = list()
        match = {'{':'}', '[':']', '(':')'}
        for i in s:
            if i == '{' or i == '(' or i == '[':
                stack.append(i)
            else:
                if len(stack) == 0:
                    return False

                top = stack.pop()

                if match[top] != i:
                    return False

        if len(stack) != 0:
            return False
        return True
