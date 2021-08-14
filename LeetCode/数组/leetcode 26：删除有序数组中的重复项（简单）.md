# leetcode 26：删除有序数组中的重复项（简单）

## 题目

给你一个有序数组 nums ，请你 原地 删除重复出现的元素，使每个元素 只出现一次 ，返回删除后数组的新长度。

不要使用额外的数组空间，你必须在 原地 修改输入数组 并在使用 O(1) 额外空间的条件下完成。

## 说明

为什么返回数值是整数，但输出的答案是数组呢?

请注意，输入数组是以「引用」方式传递的，这意味着在函数里修改输入数组对于调用者是可见的。

你可以想象内部操作如下:

```
// nums 是以“引用”方式传递的。也就是说，不对实参做任何拷贝
int len = removeDuplicates(nums);

// 在函数里修改输入数组对于调用者是可见的。
// 根据你的函数返回的长度, 它会打印出数组中 该长度范围内 的所有元素。
for (int i = 0; i < len; i++) {
    print(nums[i]);
}
```

## 示例

```
输入：nums = [0,0,1,1,1,2,2,3,3,4]
输出：5, nums = [0,1,2,3,4]
解释：函数应该返回新的长度 5 ， 并且原数组 nums 的前五个元素被修改为 0, 1, 2, 3, 4 。不需要考虑数组中超出新长度后面的元素。
```

## 我的思路

注意：题目中重点是原地，不用额外数组空间，O(1)的额外空间

1、由于要原地，不能使用额外的数组空间，所以只能在原数组中进行操作
     2、用一个下标i来标记数组中起点开始的元素
     3、下标j从1开始往后移动，如果和i下标的元素相等则继续移动
     4、如果和i下标的元素不相等则将i往后移动一位，然后将j的数值赋给i
     5、返回i+1，注意加的元素是第0个元素

```
public class leetcode26 {
    public int removeDuplicates(int[] nums) {
        if (nums.length == 0){
            return nums.length;
        }
        int i = 0;
        for (int j = 1; j < nums.length; j++){
            if (nums[i] != nums[j]){
                i += 1;
                nums[i] = nums[j];
            }
        }
        return i+1;
    }

    public static void main(String[] args) {
        int[] nums = {1,2,3,3,3,3};
        leetcode26 li = new leetcode26();
        int result = li.removeDuplicates(nums);
        System.out.println(result);
        for (int i = 0; i < result; i++){
            System.out.println(nums[i]);
        }
    }
}
```

空间复杂度：O(1)

时间复杂度：O(n)，数组长度为n，i和j最多移动n次。

## 示例解法

双指针法：

定义两个指针 fast 和 slow 分别为快指针和慢指针，快指针表示遍历数组到达的下标位置，慢指针表示下一个不同元素要填入的下标位置，初始时两个指针都指向下标 1。

假设数组 nums 的长度为 n。将快指针fast 依次遍历从 1 到 n-1 的每个位置，对于每个位置，如果nums[fast] != nums[fast-1]，说明 nums[fast] 和之前的元素都不同，因此将nums[fast] 的值复制到 nums[slow]，然后将 slow 的值加 1，即指向下一个位置。

遍历结束之后，从nums[0] 到nums[slow−1] 的每个元素都不相同且包含原数组中的每个不同的元素，因此新的长度即为 slow，返回 slow 即可。

```
class Solution {
    public int removeDuplicates(int[] nums) {
        int n = nums.length;
        if (n == 0) {
            return 0;
        }
        int fast = 1, slow = 1;
        while (fast < n) {
            if (nums[fast] != nums[fast - 1]) {
                nums[slow] = nums[fast];
                ++slow;
            }
            ++fast;
        }
        return slow;
    }
}
```



