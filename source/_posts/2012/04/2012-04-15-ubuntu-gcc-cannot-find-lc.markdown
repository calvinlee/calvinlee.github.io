---
layout: post
title: "Ubuntu下gcc编译找不到libc.so"
category: Linux
tags: [gcc]
---

前几天升级了Ubuntu系统，今天编译时出现如下错误：

    $ gcc buffer.c 
    /usr/bin/ld: cannot find -lc
    collect2: ld returned 1 exit status

明显是ld找不到libc.so，可能时升级系统引起的。
查看/etc/ld.so.conf:

    $ cat /etc/ld.so.conf
    include /etc/ld.so.conf.d/*.conf
    $ cat /etc/ld.so.conf.d/*.conf
    /usr/lib/mesa
    # Multiarch support
    /lib/i486-linux-gnu
    /usr/lib/i486-linux-gnu
    # Multiarch support
    /lib/i386-linux-gnu
    /usr/lib/i386-linux-gnu
    /lib/i686-linux-gnu
    /usr/lib/i686-linux-gnu
    /usr/lib/alsa-lib
    # libc default configuration
    /usr/local/lib

刷新ld conf cache：

    $ sudo ldconfig

还是不能解决问题。
之后

    $ locate libc.so
    /lib/i386-linux-gnu/libc.so.6
    /usr/lib/i386-linux-gnu/libc.so
    $ sudo ln -s /usr/lib/i386-linux-gnu/libc.so /usr/lib/libc.so

再编译，成功了，ld.so.conf中已经包含了/usr/lib/i386-linux-gnu目录了，按理说应该可以找到libc.so，不知道为何要在/usr/lib下建个软链接才行。不解，留待日后再研究。

---
###Update
####编译期链接
当编译完成生成目标文件（.o）后，ld程序会对目标文件进行链接。(GCC没有调用ld进行链接，它调用一个名为collect2的程序，然后由collect2调用ld来进行链接)  
默认情况下，GCC在编译阶段搜索头文件的路径为：

    1. /usr/local/include/
    2. /usr/include/

在链接搜索库文件的路径为：

    1. /usr/local/lib/
    2. /usr/lib/

通过gcc选项指定搜索路径  

* 头文件的搜索路径可以通过gcc -I选项指定。  
* 库文件的搜索路径可以通过gcc -L选项指定。  

通过环境变量指定搜索路径  

* 环境变量C\_INCLUDE\_PATH(for c)和CPLUS\_INCLUDE\_PATH(for c++)可以指定头文件搜索路径
* 环境变量LIBRARY\_PATH可以指定库文件搜索路径

搜索顺序为：  

1. -I或者-L指定的路径
1. 通过环境变量指定的路径
1. 默认路径

参考[here](http://www.network-theory.co.uk/docs/gccintro/gccintro_21.html)  

####运行时进行动态链接
运行一个程序时，ld.so/ld-linux.so会对程序依赖的共享库进行搜索，然后装载进内存，进行重定位，最后控制权移交给程序开始运行。ld.so搜索依赖的共享库的路径顺序为：  

1. 查找环境变量LD\_LIBRARY\_PATH指定的路径。然而如果这个程序的setuid/setgid为被设置，这个步骤被忽略
1. 查找/etc/ld.so.cache中的共享库列表
1. 查找/lib
1. 查找/usr/lib

另外，程序本身也可以通过hard-code的方式在执行文件中通过rpath这个字段指定依赖的啥share library的路径：

    readelf -d <binary_file> | grep RPATH

**/etc/ld.so.conf以及LD\_LIBRARY\_PATH配置的路径是为runtime-linker（ld.so）用的，不是compile-time(ld)!**  
上述问题是一个编译期问题，所以修改更新/etc/ld.so.conf对解决问题没有帮助，而在/usr/lib下创建一个到libc.so的链接则可以让gcc找到从而正确链接。  

参考 man ldd, man ld, man 8 ld.so, man dlopen, man ldconfig

Reference:

* <http://www.threeway.cc/sitecn/informationInfo.aspx?tid=1382&pid=2445>
* <http://askubuntu.com/questions/40416/why-is-lib-libc-so-6-missing>
