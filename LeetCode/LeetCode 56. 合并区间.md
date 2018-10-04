## LeetCode 56. 合并区间 ##
### 题目 ###
> 给出一个区间的集合，请合并所有重叠的区间。

> 示例 1:

> 输入: [[1,3],[2,6],[8,10],[15,18]]
输出: [[1,6],[8,10],[15,18]]
解释: 区间 [1,3] 和 [2,6] 重叠, 将它们合并为 [1,6].
示例 2:

> 输入: [[1,4],[4,5]]
> 输出: [[1,5]]
解释: 区间 [1,4] 和 [4,5] 可被视为重叠区间。

### 思路 ###
> 当我们把原输入按照开始的第一项排序后，我们能保证以下2点：

> 1. 出现断层，则前一项的end一定小于后一项的start

> 2. 更新答案时的最后一项的end永远是最大的。

> 既然最后一项区间的end永远最大，我们在融合的时候只需要考虑与新加入的区间与原最后一项的关系即可。

### Python代码 ###
<pre><code>class Solution:
    def merge(self,intervals):
        if len(intervals) == 1:
            return intervals

        merged = []

        intervals = sorted(intervals,key=lambda x: x.start)

        for interval in intervals:
            if not merged or interval.start > merged[-1].end:
                merged.append(interval)
            else:
                merged[-1].end = max(merged[-1].end, interval.end)
        return merged
</code></pre>

### 其他思路 ###
> 1.将intervals按每一个元素的start进行升序排列。 
> 2.此时后一个值的start一定在前一个值的start后(或相等)。这个时候只要判断后一个的start是否比前一个的end大。这里我设置了两个指针l和h来表示区间的起始值和终点，列表res作为结果。判断：  
如果 intervals[i].start <= intervals[i-1].end, 那么l保持不变，h为max(intervals[i].end, intervals[i-1].end)。否则，往列表res添加[l,h]，更新l和h的值。接下来继续循环判断。 
> 3.循环结束再往res添加[l,h]。

### 代码 ###
<code><pre>class Solution:
    def merge(self, intervals):
        """
        :type intervals: List[Interval]
        :rtype: List[Interval]
        """
        if len(intervals) <= 1:
            return intervals
        res = []
        intervals = sorted(intervals,key = lambda start: start.start)
        l = intervals[0].start
        h = intervals[0].end
        for i in range(1,len(intervals)):
            if intervals[i].start <= h:
                h = max(h,intervals[i].end)
            else:
                res.append([l,h])
                l = intervals[i].start
                h = intervals[i].end
        res.append([l,h])
        return res
</code></pre>