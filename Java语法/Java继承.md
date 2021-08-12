# Java继承

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

