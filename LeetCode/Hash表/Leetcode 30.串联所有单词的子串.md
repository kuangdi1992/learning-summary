## LeetCode 30.串联所有单词的子串
### 题目
给定一个字符串 s 和一些长度相同的单词 words。找出 s 中恰好可以由 words 中所有单词串联形成的子串的起始位置。
注意子串要与 words 中的单词完全匹配，中间不能有其他字符，但不需要考虑 words 中单词串联的顺序。

### 示例1
```markdown
输入：
  s = "barfoothefoobarman",
  words = ["foo","bar"]
输出：[0,9]
解释：
从索引 0 和 9 开始的子串分别是 "barfoo" 和 "foobar" 。
输出的顺序不重要, [9,0] 也是有效答案。
```
### 示例2
```markdown
输入：
  s = "wordgoodgoodgoodbestword",
  words = ["word","good","best","word"]
输出：[]
```
#### hash表的思路
1. 维护两个hash表，一个hash表是words中单词出现的次数，另一个hash表是我们截取出的字符串中单词出现的次数，如果两个hash表是相同的，则表示我们截取的字符串是符合要求的。
2. 为了不漏掉每一个符合要求的字符串，我们从字符串s的第一个元素（也就是索引为0的元素）开始，向后截取长度为words中所有单词长度总和的长度，然后进行第一步中的比较即可
3. 整个过程中，每一次进行了第一步中的比较后向后移动一位，继续第二步和第一步，直到我们取到刚好剩下words中所有单词长度总和的长度为止，这样保障了不会漏掉字符串。
**核心点：维护两个hash表来进行比较。**

#### 相关代码

```python
    def findSubstring1(self, s: str, words: list) -> list:
        from collections import Counter
        result = []
        if len(s) == 0 or len(words) == 0:
            return result
        num_len = len(words[0]) #找出单词中含有的元素的个数
        words_len = num_len * len(words)
        words_num = Counter(words) #将words转变成为hash表
        for i in range(0,len(s)-words_len+1):
            tmp = s[i:i+words_len]
            tmp_words = []
            for j in range(0,len(tmp),num_len):
                tmp_words.append(tmp[j:j+num_len])
            if Counter(tmp_words) == words_num: #如果hash表中的数量相同则表示符合要求
                result.append(i)
        return result
```
**这里需要注意的知识点是：Python中的collections --- 容器数据类型中的Counter函数。一个 Counter 是一个 dict 的子类，用于计数可哈希对象。它是一个集合，元素像字典键(key)一样存储，它们的计数存储为值。计数可以是任何整数值，包括0和负数。**

#### 滑动窗口的思路（相对于上一个方法来说是一种优化）
1. 上一个方法其实也是一种滑动窗口的方法，只不过每一次滑动的间隔只是1.
2. 只讨论从0，1，...， num_len - 1开始的子串情况，每次后移一个单词长度，由左右窗口维持当前窗口位置。
3. 具体过程见代码中的注释。

#### 滑动窗口的代码
```python
    def findSubstring(self, s: str, words: list) -> list:
        from collections import Counter
        result = []
        if len(s) == 0 or len(words) == 0:
            return result
        num_len = len(words[0]) #找出单词中含有的元素的个数
        words_len = len(words)
        words_num = Counter(words) #将words转变成为hash表
        # 只讨论从0，1，...， num_len - 1开始的子串情况，每次后移一个单词长度，由左右窗口维持当前窗口位置
        for i in range(num_len):
            cur_num = 0
            left = i
            right = i #left和rigth表示窗口的左右边界，cur_num用来统计匹配的单词个数
            cur_count = Counter()
            while right + num_len <= len(s): #取完单词后索引小于s的长度
                cur_word = s[right:right+num_len] #取一个单词
                right += num_len #窗口右边界往右移动一个单词的长度
                if cur_word not in words: #如果取出的单词不在words中
                    left = right #直接将left右移到right处
                    cur_count.clear() #清理hash表
                    cur_num = 0
                else:
                    cur_count[cur_word] += 1 #hash表中cur_word单词的数量增加1
                    cur_num += 1 #匹配单词个数加1
                    while cur_count[cur_word] > words_num[cur_word]: #一个单词匹配多次（现在已有的次数多于words中的次数），需要缩小窗口，也就是left右移
                        cur_word_left = s[left:left+num_len]
                        left += num_len
                        cur_count[cur_word_left] -= 1
                        cur_num -= 1
                    if cur_num == words_len:
                        result.append(left)
        return result
```
