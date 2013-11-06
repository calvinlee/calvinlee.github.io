---
layout: post
title: "Eclipse Content assist失效解决"
category: Eclipse
tags: [eclipse]
---

今天发现eclipse的conent assist的默认键Ctrl + Space与系统输入法冲突，于是打开Window -> Preference -> Keys，将content assist改为Alt + /，然而发现还是不起作用，最后找到解决方法：  
Window -> Preference -> Keys -> Word Completion -> Unbind Command  
然后apply。
