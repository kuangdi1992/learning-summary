# Object类—hashCode方法

## 介绍

1. 提高具有哈希结构的容器的效率
2. 两个引用，如果指向的是同一个对象，则哈希值肯定一样
3. 两个引用，如果指向不同对象，则哈希值不一样
4. 哈希值主要根据地址号来，不能完全将哈希值等价于地址
5. 在集合中，hashCode如果需要也会进行重写

### 示例

```java
public class HashCode_ {
    public static void main(String[] args) {
        AA aa1 = new AA();
        AA aa2 = new AA();
        AA aa3 = aa1;

        System.out.println("aa1.hashCode()=" + aa1.hashCode());
        System.out.println("aa2.hashCode()=" + aa2.hashCode());
        System.out.println("aa3.hashCode()=" + aa3.hashCode());
    }
}
class AA{}
```

在上面的代码中，aa1和aa3指向同一个对象，和aa2没有指向同一个对象。

结果：

```java
aa1.hashCode()=1239159215
aa2.hashCode()=252517899
aa3.hashCode()=1239159215
```

