---
layout: post
title: "为什么要使用static内部类"
category: Java
tags: [java]
---

看一个例子：

    public class OuterClass {
        class NonStaticInner {
        }
        static class StaticInner {
        }
        public void foo() {
            NonStaticInner nonStaticInner = new NonStaticInner();
            StaticInner staticInner = new StaticInner();
        }
    }

编译后生成三个class文件：

    $ tree
    .
    └── com
        └── java
            └── demo
                ├── OuterClass.class
                ├── OuterClass$NonStaticInner.class
                ├── OuterClass$StaticInner.class
使用javap反编译class文件：

    $ javap -classpath . -private -c com.java.demo.OuterClass\$StaticInner
    Compiled from "OuterClass.java"
    class com.java.demo.OuterClass$StaticInner extends java.lang.Object{
    com.java.demo.OuterClass$StaticInner();
      Code:
       0:	aload_0
       1:	invokespecial	#8; //Method java/lang/Object."<init>":()V
       4:	return
    }

    $ javap -classpath . -private -c com.java.demo.OuterClass\$NonStaticInner
    Compiled from "OuterClass.java"
    class com.java.demo.OuterClass$NonStaticInner extends java.lang.Object{
    final com.java.demo.OuterClass this$0;

    com.java.demo.OuterClass$NonStaticInner(com.java.demo.OuterClass);
      Code:
       0:	aload_0
       1:	aload_1
       2:	putfield	#10; //Field this$0:Lcom/java/demo/OuterClass;
       5:	aload_0
       6:	invokespecial	#12; //Method java/lang/Object."<init>":()V
       9:	return
    }

从反编译的结果可以看出static内部类和non-static内部类的区别：  
**对non-static内部类来说，它会持有一个外部类的引用.**编译器会生成一个构造方法，并传入外部类的引用，像这样：

    class NonStaticInner {
        private final OuterClass this$0;

        OuterClass$NonStaticInner(OuterClass outer) {
            this$0 = outer;
        }
    }
这样的话，每生成一个内部类，都会增加一个对外部类的引用，从而阻止GC来回收外部类。在Android中，如果这个外部类是一个activity类，从而会间接引用更多的图片等资源，不小心的话可能会造成内存泄漏。  
而对static的内部类则不会持有所在外部类的引用。  
所以，从GC的角度考虑，应该尽可能使用static的内部类.

###Reference：
* <http://stackoverflow.com/questions/3106912/why-does-android-prefer-static-classes>
* <http://www.techrepublic.com/article/examine-class-files-with-the-javap-command/5815354>
