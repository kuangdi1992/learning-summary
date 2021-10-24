# Object类—toString方法

### 介绍

```java
public String toString()
```

返回对象的字符串表示形式。

​        一般来说， toString方法返回一个“textually代表”这个对象的字符串。 结果应该是一个简明扼要的表达，容易让人阅读。 建议所有子类覆盖此方法。 
​        该toString类方法Object返回一个由其中的对象是一个实例，该符号字符`的类的名称的字符串@ ”和对象的哈希码的无符号的十六进制表示。 换句话说，这个方法返回一个等于下列值的字符串： 

```java
 getClass().getName() + '@' + Integer.toHexString(hashCode())
```

默认返回：全类名 + @ + 哈希值的十六进制。

toString方法源码如下：

```java
/* @return  a string representation of the object.
 * 1、getClass().getName() 类的全类名（包名+类名）
 * 2、Integer.toHexString(hashCode()) 将对象的hashCode值转成16进制
     */
    public String toString() {
        return getClass().getName() + "@" + Integer.toHexString(hashCode());
    }
```

示例

```java
public class ToString_ {         
    public static void main(String[] args) {  
        Monster monster = new Monster("小妖怪","吃人",100);           
        System.out.println(monster.toString() + "hashCode=" + monster.hashCode()); 
    }               
}                                                                                        
class Monster{         
    private String name;           
    private String job;          
    private double sal;                            
    public Monster(String name, String job, double sal) {         
        this.name = name;        
        this.job = job;    
        this.sal = sal;      
    }                   
}                                                                                  
```

结果

```java
com.company.object.Monster@49dc11af   hashCode=1239159215
```

通过计算可以得到1239159215的16进制就是49dc11af，也就是toString返回的是全类名 + @ + 哈希值的十六进制。

## 重写toString方法

输出对象的属性

快捷键：alt+insert ---->  toString

```java
public class ToString_ {
    public static void main(String[] args) {
        Monster monster = new Monster("小妖怪","吃人",100);
        System.out.println(monster.toString() + "   hashCode=" + monster.hashCode());
    }

}

class Monster{
    private String name;
    private String job;
    private double sal;

    public Monster(String name, String job, double sal) {
        this.name = name;
        this.job = job;
        this.sal = sal;
    }

    @Override
    public String toString() {
        return "Monster{" +
                "name='" + name + '\'' +
                ", job='" + job + '\'' +
                ", sal=" + sal +
                '}';
    }
}
```

重写了toString后，会从子类开始找，当从子类找到toString方法后就不会去寻找父类的toString方法。

结果

```java
Monster{name='小妖怪', job='吃人', sal=100.0}   hashCode=1418633757
```

### 特性

当直接输出一个对象时，默认会调用toString方法。

```java
public class ToString_ {
    public static void main(String[] args) {
        Monster monster = new Monster("小妖怪","吃人",100);
        System.out.println(monster.toString() + "   hashCode=" + monster.hashCode());
        System.out.println(monster);
    }

}
```

结果

```java
Monster{name='小妖怪', job='吃人', sal=100.0}   hashCode=853992494
Monster{name='小妖怪', job='吃人', sal=100.0}
```

