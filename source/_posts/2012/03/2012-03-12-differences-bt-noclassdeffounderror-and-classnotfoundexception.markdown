---
layout: post
title: "NoClassDefFoundError 和 ClassNotFoundException 的区别"
category: Java
tags: [java]
---

先看API解释：  
For ClassNotFoundException:

    Thrown when an application tries to load in a class through its string name using:

        * The forName method in class Class.
        * The findSystemClass method in class ClassLoader.
        * The loadClass method in class ClassLoader.

    but no definition for the class with the specified name could be found.


For NoClassDefFoundError:

    Thrown if the Java Virtual Machine or a ClassLoader instance tries to load in the definition of a class (as part of a normal method call or as part of creating a new instance using the new expression) and no definition of the class could be found.

    The searched-for class definition existed when the currently executing class was compiled, but the definition can no longer be found.

简单的说，就是如果使用new SomeClass()的方式创建对象的，而这时ClassLoader装载SomeClass失败（可能因为权限不够，JNI错误,etc），就会抛出NoClassDefFoundError。  
而如果使用反射来装载一个对象，但是SomeClass不在CLASSPATH中，这时就会抛出ClassNotFoundException。  

Reference:  
<http://stackoverflow.com/questions/1457863/what-is-the-difference-between-noclassdeffounderror-and-classnotfoundexception>
