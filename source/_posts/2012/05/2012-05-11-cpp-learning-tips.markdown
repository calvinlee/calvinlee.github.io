---
layout: post
title: "C++ tips"
category: C++
tags: [C++]
published: false
---

###字符串
C++中有两种字符串的表示方法：
1. C风格的字符串

        #include <cstring>
        const char *st = "The expense of spirit\n";

1. 标准C++引入的 string 类类型(建议使用)

        #include <string>
        string st( "The expense of spirit\n" );

   参照：<http://www.cplusplus.com/reference/string/string/>

互相转换：  

    // C style to C++ stype
    string s1;
    const char *pc = "a character array";
    s1 = pc; 

    // c++ stype to c style
    const char *str = s1.c_str();

###函数
####内联函数
内敛函数在其调用点上被展开，这样省去了函数调用的开销。在类定义中被定义的函数被自动视为inline函数，也可以用inline关键字显示声明一个函数为内敛函数。

###对象的创建与销毁
####创建对象
圆点成员选择运算符(.)前面加对象名称或者对象的引用，则可以访问对象的成员;箭头成员选择运算符(->)前面加对象的指针，则可以访问对象的成员。  
析构函数不接受任何参数，也不返回任何值，析构函数不可以执行返回类型，甚至void也不行，一个类只能有一个析构函数，而且不能重载析构函数。  

####拷贝构造函数
当一个对象用本类的另外一个对象实例进行初始化时，拷贝构造函数被自动调用：

    ClassA a(100);
    ClassA b = a;
拷贝构造函数形为：`ClassA(const ClassA&)`
浅拷贝与深拷贝  

