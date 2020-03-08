## 深度优先搜索及相关代码
* 简单理解：只要可能，就在图中尽量“深入”。
简单例子：
起点是V0，只需要找出一条V0到V6的道路，而无需最短路。
![DFS1](./images/1583640343068.png)
假设按照以下的顺序来搜索：
1.V0->V1->V4，此时到底尽头，仍然到不了V6，于是原路返回到V1去搜索其他路径；
2.返回到V1后既搜索V2，于是搜索路径是V0->V1->V2->V6,，找到目标节点，返回有解。
* 对于已经被发现的节点u的相邻进行扫描时，每当发现一个节点v，DFS都会对此进行记录。（这里的记录很重要，）
### DFS与迷宫游戏
#### 迷宫游戏
```markdown
用一个二维的字符数组来表示迷宫：
1. s A A A
2. ……
3.  A A A t
s是迷宫的起点，t是迷宫的终点，A表示墙壁，.表示平地。
从s到t，只能走上下左右的位置，不能出地图，不能穿过墙壁，每个点只能通过一次。
```
#### DFS解法
* 首先确定边界条件，即什么时候搜索结束。
```java
    if(maze[x][y] == 't'){  //t是终点 
        return true;
    }
```
* 为了防止重复走不必要的路，我们将走过的点进行标记，所以需要一个vis数组进行标记。同时，为了标记出路径，我们使用"m"进行标记。
```java
    vis[x][y] = 1;
    maze[x][y] = 'm';
```
* 前面两步已经完成了对当前节点的操作，下面是下一步操作。我们先往左走：
```java
	int tx = x - 1, ty = y;
	if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
	 //在地图内，非障碍物，无访问过
	 if(dfs(tx, ty)){
	 return true;
	   }
	}
```
* 向下走。
```java
	int tx = x, ty = y - 1;
	if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
	 //在地图内，非障碍物，无访问过
	 if(dfs(tx, ty)){
	 return true;
	   }
	}
```
* 向右走。
```java
	int tx = x + 1, ty = y;
	if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
	 //在地图内，非障碍物，无访问过
	 if(dfs(tx, ty)){
	 return true;
	   }
	}
```  
* 向上走。
```java
	int tx = x, ty = y + 1;
	if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
	 //在地图内，非障碍物，无访问过
	 if(dfs(tx, ty)){
	 return true;
	   }
	}
```
* 如果路走不通的话，一定要取消一下m标记，标记成”.“障碍物。
```java
	vis[x][y] = 0;
	maze[x][y] = '.';
	return false;
```
* 最后写一下 in(int x, int y) 函数，来判断是否在地图内。

##### 总代码
```c++
//迷宫
#include<iostream>
using namespace std;
string maze[110];
bool vis[110][110];
int n, m;
bool in(int x, int y){
    return 0 <= x && x < n && 0 <= y && y < m;
}
bool dfs(int x, int y){
    if(maze[x][y] == 'T'){//T是终点 
        return true;
    }
    vis[x][y] = 1;
    maze[x][y] = 'm';
    int tx = x - 1, ty = y;
    if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
        //在地图内，非障碍物，无访问过
         if(dfs(tx, ty)){
            return true;
         }
    }
    int tx = x, ty = y - 1;
    if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
        //在地图内，非障碍物，无访问过
         if(dfs(tx, ty)){
            return true;
         }
    }
    int tx = x + 1, ty = y;
    if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
    //在地图内，非障碍物，无访问过
        if(dfs(tx, ty)){
             return true;
        }
    }
    int tx = x, ty = y + 1;
    if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
        //在地图内，非障碍物，无访问过
        if(dfs(tx, ty)){
            return true;
        }
    }
    vis[x][y] = 0;
    maze[x][y] = '.';
    return false;
} 
int main(){
    //输入地图
    cin >> n >> m;
    for(int i = 0; i < n; i++){
        cin>>maze[i];
    }
    int x, y;
    //找到起始点 
    for(int i = 0; i < n; i++){
        for(int j = 0; j < m; j++){
            if(maze[i][j] == 'S'){
                x = i; y = j;
            }
        }
    }
    if(dfs(x, y)){
        //打印
        for(int i = 0; i < n; i++){
            cout << maze[i] <<endl;
        } 
    }else{
        cout<<"No!"<<endl;
    }
    return 0;
}
```
##### 改进
* 首先有四个方向，每一个方向是使用二维向量表示。因此我们可以建立一个4*2的数据来标记我们要前进的方向。
```c++
	int dir[4][2] = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}}; 
```
* 然后使用for循环依次考虑四个方向。
```c++
	for(int i = 0; i < 4; i++){
	 int tx = x + dir[i][0];
	 int ty = y + dir[i][1];
	 if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
	 //在地图内，非障碍物，无访问过
	 if(dfs(tx, ty)){
	 return true;
		   }
	   }
	}
```
这样就可以减少很多的代码量，同时也是现在使用很多的一种方法。
 #### 最短路径
 前面我们只是寻找了是否有可行的路径，现在需要求最少多少步即可到达。
我们使用一个参数来记录前面参数以及走了多少步：step。
```c++
	int ans = 10000000000;//结果
	void dfs(int x, int y, int step){
		if(maze[x][y] == 'T'){//T是终点 
			if(step < ans){
				ans = step;
			}
			return;
		}
		vis[x][y] = 1;
		maze[x][y] = 'm';
		for(int i = 0; i < 4; i++){
			int tx = x + dir[i][0];
			int ty = y + dir[i][1];
			if(in(tx, ty) && maze[tx][ty] != '*' && !vis[tx][ty]){
				//在地图内，非障碍物，无访问过
				dfs(tx, ty, step + 1)
			}
		}
		vis[x][y] = 0;//取消标记 
	} 
```

