# 题目

给定一个二维矩阵 matrix，以下类型的多个请求：

计算其子矩形范围内元素的总和，该子矩阵的 左上角 为 (row1, col1) ，右下角 为 (row2, col2) 。
实现 NumMatrix 类：

NumMatrix(int[][] matrix) 给定整数矩阵 matrix 进行初始化
int sumRegion(int row1, int col1, int row2, int col2) 返回 左上角 (row1, col1) 、右下角 (row2, col2) 所描述的子矩阵的元素 总和 。

# 示例

![1](F:\git资料\Learning-summary\Picture\Leetcode\1.png)

```java
输入: 
["NumMatrix","sumRegion","sumRegion","sumRegion"]
[[[[3,0,1,4,2],[5,6,3,2,1],[1,2,0,1,5],[4,1,0,1,7],[1,0,3,0,5]]],[2,1,4,3],[1,1,2,2],[1,2,2,4]]
输出: 
[null, 8, 11, 12]

解释:
NumMatrix numMatrix = new NumMatrix([[3,0,1,4,2],[5,6,3,2,1],[1,2,0,1,5],[4,1,0,1,7],[1,0,3,0,5]]);
numMatrix.sumRegion(2, 1, 4, 3); // return 8 (红色矩形框的元素总和)
numMatrix.sumRegion(1, 1, 2, 2); // return 11 (绿色矩形框的元素总和)
numMatrix.sumRegion(1, 2, 2, 4); // return 12 (蓝色矩形框的元素总和)
```

# 分析

题目解读：

1. 从题目中可以看到int sumRegion(int row1, int col1, int row2, int col2) 返回 左上角 (row1, col1) 、右下角 (row2, col2) 所描述的子矩阵的元素总和 ，因此该题第一眼想到的是使用前缀和，先将二维数组中每个元素[row,col]到原点[0,0]的和算出来，存放在前缀和数组preSum中。

   ![2](F:\git资料\Learning-summary\Picture\Leetcode\2.jpeg)
   $$
   S(O,D)=S(O,C)+S(O,B)−S(O,A)+D
   $$
   减去 S(O, A)的原因是 S(O, C) 和 S(O, B)中都有 S(O, A)，即加了两次 S(O, A)，所以需要减去一次 S(O, A)。

   如果求 preSum[i]\[j]表示的话，对应了以下的递推公式：
   $$
   preSum[i][j] = preSum[i][j-1] + preSum[i-1][j] - preSum[i-1][j-1] + numMatrix[i][j]
   $$
   
2. 前面已经求出了数组中从 [0,0] 位置到 [i,j] 位置的 preSum。下面要利用 preSum[i]\[j]来快速求出任意子矩形的面积。

   ![3](F:\git资料\Learning-summary\Picture\Leetcode\3.jpeg)
   $$
   S(A,D)=S(O,D)−S(O,E)−S(O,F)+S(O,G)
   $$
   加上子矩形 S(O, G)面积的原因是 S(O, E)和 S(O, F)中都有 S(O, G)，即减了两次 S(O, G)，所以需要加上一次 S(O, G)。

   如果要求 [row1, col1] 到 [row2, col2] 的子矩形的面积的话，用 preSum 对应了以下的递推公式：
   $$
   preSum[row2][col2]−preSum[row2][col1−1]−preSum[row1−1][col2]+preSum[row1−1][col1−1]
   $$
# 代码

```java
public class leetcode304 {
    int[][] preSum;
    public void NumMatrix(int[][] matrix) {
        int col = matrix.length;
        int row = matrix[0].length;

        if (col == 0 || row == 0){
            return;
        }

        preSum = new int[col+1][row+1];
        for (int i = 1; i <= col; i++){
            for(int j = 1; j <= row; j++){
                preSum[i][j] = matrix[i-1][j-1] + preSum[i-1][j] + preSum[i][j-1] - preSum[i-1][j-1];
            }
        }

    }

    public int sumRegion(int row1, int col1, int row2, int col2) {
        return preSum[row2+1][col2+1] - preSum[row1][col2+1] - preSum[row2+1][col1] + preSum[row1][col1];
    }
}
```

![4](F:\git资料\Learning-summary\Picture\Leetcode\4.png)