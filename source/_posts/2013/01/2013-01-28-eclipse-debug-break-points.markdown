---
layout: post
title: "Eclipse 调试中的五种断点"
category: Eclipse
tags: [eclipse, debug]
---

Eclipse调试支持五种不同的断点，这些断点都可以通过Run主菜单下的选项来添加或者删除。  

###Line breakpoints
Line breakpoints就是我们平时使用最多的一种断点类型，它以代码行为单位，代码执行到这一行时就会被suspend。有两个比较有用的属性：  

* Condition breakpoint
为该断点添加一个条件，只有当这个条件成立时才会suspend
* Hit count
指定一个整数值N，只有当这个断点被执行过的次数达到N次时才会suspend。

###Watchpoint
Watchpoint针对的是变量。如果我们对程序运行的过程不关心，而对某个关键变量的值的变化比较关心，那么我们可以对这个变量设置一个Watchpoint, 同时指定它的Access和Modification属性用来执行这个变量被访问时suspend还是被修改时suspend。

注意：  
Android的Dalvik虚拟机目前还不支持这种breakpoint。

###Method breakpoints
Method breakpoints用来指定针对一个方法的断点。他有两个属性：

* Entry：当进入该方法时suspend
* Exit：当执行玩该方法时suspend

###Exception breakpoints
指定当某个exception发生时suspend当前线程。

###Class Load breakpoints
指定当某个类被虚拟机加载时suspend当前线程。


以上五种断点都可以在Breakpoints 视图中查看，可以通过右上角的菜单，Group by，选择Breakpoint types，这样可以按照这五种类型来对当前所有的Breakpoint进行分类查看，比较方便。

[![/images/eclipse-debug.png](/images/eclipse-debug.png)](/images/eclipse-debug.png)

###Reference
* <http://www.vogella.com/articles/EclipseDebugging/article.htm>
* <http://developer.51cto.com/art/201111/302928.htm>
