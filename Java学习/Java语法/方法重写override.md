# 方法重写override

## 基本介绍

子类有一个方法，和父类的某个方法的名称、返回类型、参数一样，就可以说子类的方法覆盖了父类的方法。

## 示例

父类：

```java
public class Animal {
    public void cry(){
        System.out.println("动物交换");
    }
}
```

子类：

```java
public class Dog extends Animal{
    //Dog是Animal的子类
    //cry方法的名称、返回类型、参数完全一样
    public void cry(){
        System.out.println("小狗汪汪叫。。。");
    }

}
```

结果：

```java
小狗汪汪叫。。。
```



## 细节

1. 子类的方法的参数、方法名称，要和父类方法的参数、方法名称完全一样

2. 子类方法的返回类型和父类方法的返回类型一样，或者是父类返回类型的子类

   父类：

   ```java
   public class Animal {
       public Object m1(){
           return null;
       }
       
       public AAA m2(){
           return null;
       }
   }
   
   class AAA{
       
   }
   class BBB extends AAA{
       
   }
   ```

   子类：

   ```java
   public class Dog extends Animal{
       public String m1(){
           return null;
       }
   
       public BBB m2(){
           return null;
       }
   }
   
   ```

   可以看到父类中m1的返回类型是Object，子类中m1的返回类型是Object的子类String，这样是没有问题的。

   同样，父类中m2的返回类型是AAA，而子类中m2的返回类型是BBB（从父类的代码中可以看出，AAA是BBB的父类，所以这里返回的是AAA的子类），也是AAA的子类，同样没有问题。

3. 子类方法不能缩小父类方法的访问权限。

   访问权限：public > protected > 默认 > private

   父类：

   ```java
   public class Animal {
       public void cry(){
           System.out.println("动物交换");
       }
   }
   ```

   子类：

   ![image-20210909225400139](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/java/image-20210909225400139.png)

   ​	可以看出，由于默认 < public所以子类方法缩小了父类方法的权限，所以报错了。

   ## 重写和重载

   | 名称         | 发生范围 | 方法名   | 形参列表                     | 返回类型                                           | 修饰符                             |
   | ------------ | -------- | -------- | ---------------------------- | -------------------------------------------------- | ---------------------------------- |
   | 重载overload | 本类     | 必须一样 | 类型、个数或顺序至少一个不同 | 无要求                                             | 无要求                             |
   | 重写override | 父子类   | 必须一样 | 必须相同                     | 子类重写方法返回类型和父类返回类型一致，或是其子类 | 子类方法不能缩小父类方法的访问权限 |

   