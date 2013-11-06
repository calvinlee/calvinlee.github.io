---
layout: post
title: "Java 字符串的==和equals"
category: Java
tags: [java]
---

###实例
问题起源于这段代码：

    if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
        Log.d(TAG, "mounted");
    } else {
        Log.d(TAG, "umounted");
    }

在SD卡处于mounted的状态下，这个case打印出umounted.

###问题
现在SD卡处于mounted的状态，所以Environment.getExternalStorageState()方法会返回"mounted"。  
跟踪Environment.getExternalStorageState方法的实现，如果SD卡处于mounted的状态，该方法返回Environment.MEDIA\_MOUNTED这个字符串常量。
那么问题是，Environment.MEDIA\_MOUNTED是一个字符串常量，一个字符串常量在JVM中只有一份，== 符号比较的是两边的对象是否是同一个引用，这样来说这里应该输出"mounted"才对，为什么会输出"umounted"呢？也就是说等号两边的两个字符串不是同一个引用。

原因在于只有在编译期确定的字符串常量才会被放进常量池，这个常量池会被保存在class文件中，稍后被JVM加载。而对于运行时才生成的字符串是不会放入常量池的。Environment.getExternalStorageState()方法返回的字符串虽然是一个字符串常量，但是这个常量在编译期并未确定，所以该方法返回的字符串不是从常量池中取得的。

`String.intern()`方法用于在运行时将一个字符串加入常量池中，所以对这个例子，`Environment.getExternalStorageState().intern() == Environment.MEDIA\_MOUNTED`才会返回true。

###Reference
* <http://en.wikipedia.org/wiki/String\_interning>
* <http://blog.csdn.net/jcc3120/article/details/2118870>
* <http://stackoverflow.com/questions/767372/java-string-equals-versus>
