---
layout: post
title: "Archlinux调教小记"
category: Linux
tags: [archlinux]
---

###开机时设置屏幕亮度为最暗

    sudo echo 'echo 0 > /sys/class/backlight/acpi_video0/brightness'>>/etc/rc.local

###关机或者重启时最后屏幕变黑，但是机器一直关不掉，只有强行按电源键关闭
原因在于我试图在开机时关掉Navia显卡<https://wiki.archlinux.org/index.php/Dell_XPS_15#System_Settings>：

    rc.conf中
    MODULES=(acpi_call)
    rc.local中
    echo '\_SB.PCI0.PEG0.PEGP._OFF' > /proc/acpi/call

由此会造成这个问题，去掉开机加载acpi\_call模块就行了，为什么会这样呢？不知道...

###音量设置

    #pacman -S alsa-utils alsa-lib
    #alsactl store

###ibus输入中文显示乱码
使用ibus输入中文，在gedit下没有问题，在terminal中或者gvim中输入显示乱码
google得知是glibc的问题，在/etc/locale.gen中去掉zh\_CN.UTF-8的注释，再运行locale-gen即可

###下载firefox后执行./firefox失败，

    $ /opt/firefox/firefox
    /opt/firefox/firefox: error while loading shared libraries: libstdc++.so.6: cannot open shared object file: No such file or directory
    $ file /opt/firefox/firefox
    /opt/firefox/firefox: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.9, stripped
    $ ldd /opt/firefox/firefox
    	linux-gate.so.1 =>  (0xf7753000)
    	libpthread.so.0 => /usr/lib32/libpthread.so.0 (0xf771d000)
    	libdl.so.2 => /usr/lib32/libdl.so.2 (0xf7718000)
    	libstdc++.so.6 => not found
    	libm.so.6 => /usr/lib32/libm.so.6 (0xf76ea000)
    	libgcc_s.so.1 => not found
    	libc.so.6 => /usr/lib32/libc.so.6 (0xf7546000)
    	/lib/ld-linux.so.2 (0xf7754000)

原因是firefox可执行文件是为32位平台编译的，在我的64位机器上的/lib等目录下缺少相应的64位库文件，下载<ftp://ftp.mozilla.org/pub/firefox/>64位firefox即可。

###Microsoft wireless mobile mouse 3500纵向滚动过快
每当从windows重启进入arch时会发现微软无线鼠标3500滚轮纵向滚动太快，每次拔下无线接收器问题就能解决，然而有一个更好的办法，见[here](http://www.jochus.be/site/2010-08-02/linux/microsoft-wireless-laser-mouse-5000-scroll-speed-too-fast-ubuntu-lucid-1004-lts),[here](https://github.com/paulrichards321/resetmsmice)有一个patch可以解决这个问题。  
编译安装后在/etc/rc.local中添加`resetmsmice`即可。  

###Disable PC Speaker Beep
<https://wiki.archlinux.org/index.php/Disable_PC_Speaker_Beep>

###禁用IPv6
添加ipv6.disable=1你的启动加载器的内核行中。  
另外可以通过sysctl禁用IPv6，添加下面的内容到 /etc/sysctl.conf:

    # Disable IPv6
    net.ipv6.conf.all.disable_ipv6 = 1
