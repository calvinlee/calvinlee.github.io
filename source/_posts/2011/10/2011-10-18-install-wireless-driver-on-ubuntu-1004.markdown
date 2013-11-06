---
layout: post
title: "Ubuntu10.04安装无线网卡ath9k_htc驱动"
category: 
tags: [linux]
---

我的USB无线网卡型号为TL\_WN721N，插在Ubuntu10.04上没有反应。据说10.10以后插上就可以用了，没有测试。

第一步 确定ath9k\_htc驱动支持你的网卡型号  
[这里](http://linuxwireless.org/en/users/Drivers/ath9k_htc/devices) 列出了支持的型号列表，你可以通过lsusb查看自己的网卡型号是否在列表当中。

第二步 安装firmwire  
从[这里](http://wireless.kernel.org/download/htc_fw/)下载htc_9271.fw，拷贝到/lib/firmwire下

第三步 安装compact wireless  
安装compact wireless有打包好的deb包，从这里下载GUI Program to install ath9k_htc，安装完后直接运行，等待安装完成重启机器就可以了。
爱折腾的也可以到[这里](http://wireless.kernel.org/download/)下载
最新的compact wireless驱动，然后编译安装：

    sudo make
    sudo make install
    sudo make unload
    sudo make load ath9k_htc

重启机器即可。

Reference
* <http://forum.ubuntu.com.cn/viewtopic.php?f=116&t=326568&p=2388841>
* <http://blog.chinaunix.net/space.php?uid=20620288&do=blog&id=2691282>
