---
layout: post
title: "一些有趣的C程序"
category: C语言
tags: [C语言, todo]
---


    #include <stdio.h>
    
    int n[]={0x48,0x65,0x6C,0x6C, 
    0x6F,0x2C,0x20, 
    0x77,0x6F,0x72, 
    0x6C,0x64,0x21, 
    0x0A,0x00},\*m=n;
    
    main(n){ 
        if(putchar (\*m)!='\0') main(m++);
    }

输出`Hello, world!`
