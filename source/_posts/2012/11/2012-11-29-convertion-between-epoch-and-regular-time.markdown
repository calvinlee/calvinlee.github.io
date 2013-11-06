---
layout: post
title: "Unix Epoch 与 时间字符串的转换"
category: 
tags: [命令]
---

###字符串 --> Epoch

    $ date -d "2012/11/29" +%s
    1354118400

###Epoch --> 字符串

    $ date -d@1354118400
    Thu Nov 29 00:00:00 CST 2012

或者加上格式控制：

    $ date -d@1354118400 '+%Y-%m-%d %H:%M:%S'
    2012-11-29 00:00:00
