---
layout: post
title: "改善SD卡读取速度"
category: Android
tags: [android, linux]
---

一年前刷了CM的rom，发现sd卡速度下降了很多，今天看见有人发了一个kernel的patch改善这个问题，原理是修改sys文件系统下的一个read\_ahead\_kb参数值，这个值指定了每次从SD卡上读取数据时预读的大小。

    adb shell 'echo 128 > /sys/devices/virtual/bdi/179:0/read_ahead_kb'

但这个值也不是越大越好，128是个比较平衡的值，因为在读取小文件的情况下，如果这个值太大，那么预读的数据很大几率是无用的数据，反而降低性能，[这个](http://forum.xda-developers.com/showthread.php?t=1032317)帖子有详细的分析。

这个值的定义在/include/linux/mm.h中：

    /* readahead.c */
    #define VM_MAX_READAHEAD	128	/* kbytes */
    #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */

###设置开机生效
注意：重启后这个设置就失效了，为了避免每次开机后都要设置，可以在init.rc脚本中加上：

    write /sys/devices/virtual/bdi/179:0/read_ahead_kb 128
或者利用init.d脚本的支持，在/system/etc/init.d目录下创建一个文件10sdcard:

    #!/system/bin/sh
    echo 128 > /sys/devices/virtual/bdi/179:0/read_ahead_kb

    这样每次开机后都会执行这段脚本。

###CM支持init.d开机脚本的方法
1. 在init.rc的class\_start default上加上

       # Run sysinit
       exec /system/bin/sysinit

       class_start default
1. 建立文件/system/bin/sysinit

       #!/system/bin/sh

       export PATH=/sbin:/system/sbin:/system/bin:/system/xbin
       /system/bin/logwrapper /system/xbin/run-parts /system/etc/init.d

然后将启动脚本放在/system/etc/init.d目录下，这些脚本以数字命名，run-parts命令按照顺序排序依次执行这些脚本(cron命令也是利用run-parts命令执行指定目录下的脚本的，参见/etc/crontab)。

其实也可以这样做：  
在init.rc的class\_start default上加入

    start sysinit

然后在所有service定义的后面加上：

    service sysinit /system/bin/logwrapper /system/xbin/busybox run-parts /system/etc/init.d
        disabled
        oneshot

###Reference
* <http://forum.xda-developers.com/showthread.php?t=815557>
