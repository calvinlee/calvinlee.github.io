---
layout: post
title: ".xinitrc and .xprofile"
category: Linux
tags: [linux]
---

如果使用startx或者slim等命令启动X，会source ~/.xinitrc。  
如果使用登录管理器GDM或者KDM，会source ~/.xprofile，忽略~/.xinitrc。  

为了统一，干脆这样好了：

    ln -s ~/.xinitrc ~/.xprofile
