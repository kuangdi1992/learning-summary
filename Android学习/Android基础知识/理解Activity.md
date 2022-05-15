# 深入理解Activity

2022年5月15日

## 介绍

Activity是Android应用的重要组成单元之一，而Activity是Android应用最常见的组件之一。在实际应用中往往包括多个Activity，不同的Activity向用户呈现不同的操作界面。

Android应用的多个Activity组成Activity栈，当前活动的Activity位于栈顶。

## 建立、配置和使用Activity

### 建立Activity

建立自己的Activity需要继承Activity基类。在不同的应用场景下，有时要求继承Activity的子类，例如如果应用程序界面只包括列表，则可以让应用程序继承ListActivity。

![30](https://github.com/kuangdi1992/learning-summary/tree/master/Picture/Android/30.webp)

从上图可知，Activity类间接或者直接继承了Context、ContextWrapper、ContextThemeWrapper等基类，因此Activity可以直接调用它们的方法。

当一个Activity类定义出来后，这个Activity类何时被实例化、它所包含的方法何时被调用，这些都不是由开发者决定的，都应该由Android系统来决定。

#### 实例：用LauncherActivity开发启动Activity的列表

### 配置Activity

Android应用要求所有应用程序组件（Activity，Service，ContentProvider，BroadcastReceiver）都必须显示进行配置。

只要为\<application.../\>元素添加\<activity.../\>子元素即可配置Activity，实例如下：

`路径：AndroidManifest.xml`

```xml
<activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
```

上图主要指定该Activity作为应用程序的入口。

配置Activity时通常指定三个属性：

1. name：指定该Activity的实现类
2. icon：指定该Activity对应的图标
3. label：指定该Activity的标签
4. 通常还需要指定一个或多个\<intent-filter\>元素，该元素用于指定该Activity可响应的Intent。

### 启动、关闭Activity

一个Android应用通常会包含多个Activity，但只有一个Activity会作为程序的入口，Android应用运行时会自动启动并执行该Activity。

应用中的其他Activity，通常由入口Activity启动，或者由入口Activity启动的Activity启动。

Activity启动其他Activity有如下两种方法：

| 方法                                                   | 作用                                                         |
| ------------------------------------------------------ | ------------------------------------------------------------ |
| startActivity(Intent intent)                           | 启动其他Activity                                             |
| startActivityForResult(Intent intent, int requestCode) | 以指定请求码(requestCode)启动Activity，而且程序将会等到新启动Activity的结果（通过重写onActivityResult()方法来获取） |

Intent是Android应用里各个组件之间通信的重要方法，一个Activity通过Intent来表达自己的意图，想要启动哪个组件，被启动的组件既可以是Activity组件，也可以是Service组件。

Android关闭Activity的方法：

| 方法                    | 作用                                                         |
| ----------------------- | ------------------------------------------------------------ |
| finish()                | 结束当前Activity                                             |
| finish(int requestCode) | 结束以startActivityForResult(Intent intent, int requestCode)方法启动的Activity |

#### 实例：启动Activity，允许程序在两个Activity之间切换

`路径：MainActivity.java`

```java
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Button jump = (Button) findViewById(R.id.button);
        jump.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //创建需要启动的Activity对应的Intent
                Intent intent = new Intent(MainActivity.this,SecondActivity.class);
                //启动intent对应的Activity
                startActivity(intent);
            }
        });

    }
}
```

`SecondActivity.java`

```java
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.annotation.Nullable;

public class SecondActivity extends Activity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.second);
        Button start = (Button) findViewById(R.id.button1);
        Button close = (Button) findViewById(R.id.button2);
        start.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(SecondActivity.this, MainActivity.class);
                startActivity(intent);
            }
        });

        close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(SecondActivity.this, MainActivity.class);
                startActivity(intent);
                //结束当前Activity
                finish();
            }
        });
    }
}
```

`AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.startactivity">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.StartActivity">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity android:name=".SecondActivity"/>
    </application>

</manifest>
```



第二个界面只包含两个按钮，一个简单的返回上一个Activity不关闭自己，另一个结束自己并返回上一个Activity。

结果：

![31](https://github.com/kuangdi1992/learning-summary/tree/master/Picture/Android/31.png)

![32](https://github.com/kuangdi1992/learning-summary/tree/master/Picture/Android/32.png)

### Bundle在Activity之间交换数据

当一个Activity启动另一个Activity时，常常需要将一些数据传过去，这里我们只需要将需要交换的数据放入Intent即可。

Intent提供多种重载方法来携带额外的数据：

| 方法                                           | 作用                                 |
| ---------------------------------------------- | ------------------------------------ |
| putExtras(Bundle data)                         | 向Intent中放入需要携带的数据         |
| putXxx(String key,Xxx data)                    | 向Bundle放入int,Long等各种类型的数据 |
| putSerializable(String key, Serializable data) | 向Bundle中放入一个可序列化的对象     |

取出Bundle书记携带包里的数据，方法如下：

| 方法                                           | 作用                                 |
| ---------------------------------------------- | ------------------------------------ |
| getXxx(String key,Xxx data)                    | 从Bundle取出int,Long等各种类型的数据 |
| getSerializable(String key, Serializable data) | 从Bundle中取出一个可序列化的对象     |

#### 实例：用第二个Activity处理注册信息

#### 实例：用第二个Activity让用户选择信息

## Activity回调机制

当开发者开发一个组件时，如果开发者需要该组件能响应特定的事件，可以选择性地实现该组件的特定方法——当用户在该组件上激发某个事件时，该组件上特定的方法就会回调。

## Activity的生命周期

随着不同应用的运行，每个Activity都有可能从活动状态转入非活动状态，也可能从非活动状态转入活动状态。

### Activity的生命周期演示

Activity大致会经过如下四个状态：

> 活动状态：当前Activity位于前台，用户可见，可以获得焦点
>
> 暂停状态：其他Activity位于前台，该Activity亦然可见，只是不能获得焦点。
>
> 停止状态：该Activity不可见，失去焦点
>
> 销毁状态：该Activity结束，或Activity所在的Dalvik进程被结束

![33](https://github.com/kuangdi1992/learning-summary/tree/master/Picture/Android/33.png)

在Activity的生命周期中，如下方法会被系统回调：

> onCreate(Bundle savedStatus)：创建Activity时会被回调
>
> onStart()：启动Activity时被回调
>
> onRestart()：重新启动Activity时被回调
>
> onResume()：恢复Activity时被回调
>
> onPause()：暂停Activity时被回调
>
> onStop()：停止Activity时被回调
>
> onDestroy()：销毁Activity时被回调

覆盖onPause()方法很常见，比如一个用户正在玩游戏，此时有电话进来，那么需要将当前游戏暂停，并保存该游戏的进行状态，这就可以通过覆盖onPause()方法来实现。

Activity生命周期的几个过程：

1. 启动Activity：系统会先调用onCreate方法，然后调用onStart方法，最后调用onResume，Activity进入运行状态。

2. 当前Activity被其他Activity覆盖其上或被锁屏：系统会调用onPause方法，暂停当前Activity的执行。

3. 当前Activity由被覆盖状态回到前台或解锁屏：系统会调用onResume方法，再次进入运行状态。

4. 当前Activity转到新的Activity界面或按Home键回到主屏，自身退居后台：系统会先调用onPause方法，然后调用onStop方法，进入停滞状态。

5. 用户后退回到此Activity：系统会先调用onRestart方法，然后调用onStart方法，最后调用onResume方法，再次进入运行状态。

6. 当前Activity处于被覆盖状态或者后台不可见状态，即第2步和第4步，系统内存不足，杀死当前Activity，而后用户退回当前Activity：再次调用onCreate方法、onStart方法、onResume方法，进入运行状态。

7. 用户退出当前Activity：系统先调用onPause方法，然后调用onStop方法，最后调用onDestory方法，结束当前Activity。
   

#### 实例：Activity生命周期