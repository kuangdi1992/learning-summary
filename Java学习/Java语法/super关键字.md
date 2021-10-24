# super关键字

## 介绍

super关键字代表父类的引用，用于访问父类的属性、方法和构造器。

## 基本语法

父类代码：

```
public class A {
    private int n1 = 1;
    protected int n2 = 2;
    int n3 = 3;
    public int n4 = 4;

    private void test100(){

    }

    protected void test200(){

    }

    void test300()
    {

    }

    public void test400(){

    }
}
```

1. 访问父类的属性，但不能访问父类的private属性：super.属性

   ![image-20210907210841876](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/java/image-20210907210841876.png)

2. 访问父类的方法，但不能访问父类的private方法：super.方法名(参数列表)

   ![image-20210907211044395](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/java/image-20210907211044395.png)

3. 访问父类的构造器：super(参数列表)

   只能放在构造器的第一句，且只能出现一句。

![image-20210907211321114](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/java/image-20210907211321114.png)

## super的细节和好处

1、分工明确

​      父类属性由父类初始化，子类属性由子类初始化。

​      父类：

​              ![image-20210907211759203](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/java/image-20210907211759203.png)

​     子类：

​      ![image-20210907211832668](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/java/image-20210907211832668.png)

​     可以看出在子类中初始化了子类属性n2.

2、当子类中有和父类中的成员重名时，为了访问父类的成员，必须通过super。

​       父类：

​			![image-20210907212803061](https://github.com/kuangdi1992/Interview-knowledge/blob/master/Picture/java/image-20210907212803061.png)

​       子类：

```java
public class B extends A {
    public void cal(){
        System.out.println("B中的cal方法...");
    }

    public void sum(){
        System.out.println("B类的sum方法....");
        //希望调用父类的cal方法
        cal();//找cal方法时，顺序是，先找本类，如果有并且可以调用，则调用，如果没有，则找父类
              //父类没有的话，继续找父类的父类，直到object类。
              //查找过程中，找到了但不能访问，则报错
              //查找过程中，没有找到，则提示方法不存在
        this.cal(); //和直接访问方法的顺序一样
        super.cal(); //没有查找本类的过程，直接到父类中查找
    }
}
```

结果：

```java
B类的sum方法....
B中的cal方法...
B中的cal方法...
A类的cal方法....
```

父类和子类中都有cal方法，从结果中可以看到通过super可以查找到父类的cal方法，但是其他两种方法则是找到了本类中的cal方法。

3、如果没有重名，使用super、this、直接访问是一样的效果。  

​     子类：

```java
public class B extends A {
    public void sum(){
        System.out.println("B类的sum方法....");
        //希望调用父类的cal方法
        cal();//找cal方法时，顺序是，先找本类，如果有并且可以调用，则调用，如果没有，则找父类
              //父类没有的话，继续找父类的父类，直到object类。
              //查找过程中，找到了但不能访问，则报错
              //查找过程中，没有找到，则提示方法不存在
        this.cal(); //和直接访问方法的顺序一样
        super.cal(); //没有查找本类的过程，直接到父类中查找
    }
}
```

​    4、super的访问不限于直接父类，如果爷爷类和本类中有同名的成员，可以使用super去访问爷爷类的成员。

​          若多个基类中都有同名的成员，使用super遵循就近原则，来不停的往上找。

```java
public class Base {
    public int n2 = 999;
}

public class A extends Base {
    public int n2 = 2;
}

public class B extends A {
    public void test(){
        System.out.println(super.n2);
    }
}
```

结果如下：

```
2
```

也就是super的就近原则。

## super和this的区别

| 区别点     | this                                               | super                                  |
| ---------- | -------------------------------------------------- | -------------------------------------- |
| 访问属性   | 访问本类的属性，若本类中没有此属性，则到父类中查找 | 直接从父类中开始查找                   |
| 调用方法   | 访问本类的方法，若本类中没有此属性，则到父类中查找 | 直接从父类中开始访问                   |
| 调用构造器 | 调用本类构造器必须放在构造器首行                   | 调用父类构造器必须放在子类构造器的首行 |
| 特殊性     | 表示当前对象                                       | 子类访问父类对象                       |

