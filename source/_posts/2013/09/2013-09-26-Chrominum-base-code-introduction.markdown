---
layout: post
title: "Chromium base库介绍"
category: chromium
tags: [c++]
---

Chromium的base库包含了一些常用的基础代码，包括: 
    * 文件操作
    * json读写
    * 字符串操作
    * 时间操作
    * 智能指针

在线代码浏览：
https://code.google.com/p/chromium/codesearch#chromium/src/base/

###常用宏
1. DISALLOW\_COPY/DISALLOW\_ASSIGN/DISALLOW\_COPY\_AND\_ASSIGN
位于base/basictyps.h，它通过将拷贝构造函数和=运算符重载设置为private来禁用类对象的拷贝和赋值操作。
示例用法：sql/transaction.h

###智能指针
scoped\_ptr: base/memory/scoped\_ptr.h
经过scoped\_ptr封装的指针在出作用域后自动被释放, 该指针的ownership只能传递，不能拷贝。使用方法见头文件的注释。


###文件操作
base/platform\_file.h
base/file\_util.h
base/files/file\_path.h
base/path\_service.h

