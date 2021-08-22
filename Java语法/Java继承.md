# 继承

## 为什么需要继承

当我们编写了两个类，两个类的属性和方法有很多是相同的，应该怎么办？

示例：

小学生类：

```
//小学生
public class Pupil {
    public String name;
    public int age;
    private double score;

    public void setScore(double score) {
        this.score = score;
    }

    public void testing(){
        System.out.println("小学生" + name +"……");
    }

    public void showInfo(){
        System.out.println(name + age + score);
    }
}
```

大学生类：

```
//大学生
public class Graduate {
    public String name;
    public int age;
    private double score;

    public void setScore(double score) {
        this.score = score;
    }

    public void testing(){
        System.out.println("大学生" + name +"……");
    }

    public void showInfo(){
        System.out.println(name + age + score);
    }
}
```

从上面两个类可以看出，两个类中的属性和方法除了testing方法不一致外，其他的都一样，这样就造成了代码复用性差。

可以使用继承来解决代码复用的问题。

## 继承原理图

![jichen](F:\git资料\Interview-knowledge\Picture\java\jichen.png)

#### 基本语法

class 子类 <font color=red>extends</font> 父类{}

子类会自动拥有父类定义的属性和方法

## 注意事项

- Java中类只支持单继承，不支持多继承

  ```
  多继承示例
  public class Son extends Father,Mother{
      
  }
  单继承示例：
  public class Son extends Father{
  
  }
  ```

- Java中支持多层继承

  ```
  多层继承
  public class Granddad {
      public void drink(){
          System.out.println("爷爷爱喝酒");
      }
  }
  public class Father extends Granddad{
      public void smoke(){
          System.out.println("b爸爸爱抽烟");
      }
  }
  public class Son extends Father{
  
  }
  ```

## 继承细节

1、子类继承了所有的属性和方法，但是私有属性和方法不能在子类直接访问，要通过公共方法去访问。

示例：

新建一个Base父类，其中包含四种属性和相应的方法，另外新建一个Sub子类，继承Base父类，Base代码如下：

```
public class Base {
    public int n1 = 100;
    protected int n2 = 200;
    int n3 = 300;
    private int n4 = 400;

    public Base() {
        System.out.println("Base()……");
    }
    //在父类提供一个public的方法，返回了n4
    public int getN4(){
        return n4;
    }
    //对方法test400也可以提供一个public方法
    public void callTest400(){
        test400();
    }

    public void test100(){
        System.out.println("test100");
    }

    protected void test200(){
        System.out.println("test200");
    }

    void test300(){
        System.out.println("test300");
    }

    private void test400(){
        System.out.println("test400");
    }
}
```

Sub代码如下：

```
public class Sub extends Base {
    public Sub() { //子类构造器
        System.out.println("Sub()......");
    }

    public void sayOk(){
        //非私有的属性和方法可以在子类直接访问
        System.out.println(n1 + n2 + n3);
        test100();
        test200();
        test300();
        callTest400();
//        test400();错误
        System.out.println("n4" + getN4());

    }
}
```

当没有getN4方法和calltest400方法时，在子类中直接访问n4属性和test400方法会报错。

因此，我们在父类中提供两个public方法来实现对两个private属性和方法的访问。结果如下：

![image-20210822104229902](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20210822104229902.png)

从下面的图中可以看出子类中继承了父类的所有的属性。

![image-20210822103744409](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20210822103744409.png)

2、子类必须调用父类的构造器，完成父类的初始化。

```
public class Sub extends Base {
    public Sub() { //子类构造器
        super();//默认调用父类的无参构造器，无论写不写都存在
        System.out.println("Sub()......");
    }
    //当创建子类对象时，不管使用子类哪个构造器，默认情况下都使用父类的无参构造器
    public Sub(String name){
        System.out.println("Sub name");
    }
```

当父类中存在无参构造器的时候，在Sub子类的构造器中，会默认使用super()函数调用父类的构造器，并且是不管子类使用哪个构造器。

结果如图：

![image-20210822105609250](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20210822105609250.png)

当父类中的无参构造器被覆盖后：

```
public class Base {
    public int n1 = 100;
    protected int n2 = 200;
    int n3 = 300;
    private int n4 = 400;

//    public Base() {
//        System.out.println("Base()……");
//    }

    public Base(String name, int age){
        System.out.println("父类base的有参构造器");
    }
```

子类的构造器中，需要使用super函数并且带父类有参构造器中的相应参数，如下图所示：

```
public class Sub extends Base {
    public Sub() { //子类构造器
//        super();//默认调用父类的无参构造器，无论写不写都存在
        super("smith",1);
        System.out.println("Sub()......");
    }
    //当创建子类对象时，不管使用子类哪个构造器，默认情况下都使用父类的无参构造器
    public Sub(String name){
        super("tom",2);
        System.out.println("Sub name");
    }
```

结果如下：

![image-20210822110554799](C:\Users\kd\AppData\Roaming\Typora\typora-user-images\image-20210822110554799.png)

【总结】当创建子类对象时，不管使用子类的哪个构造器，默认情况下总会调用父类的无参构造器。

如果父类没有提供无参构造器，则必须在子类的构造器中使用super去指定使用父类的哪个构造器完成对父类的初始化工作，否则，编译会不通过。