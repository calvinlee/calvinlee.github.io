---
layout: post
title: "在eclipse中调试Android源代码"
category: 
tags: [android]
---

1.编译android 代码树，编译sdk  
    编译注意：  
    1.gcc的版本过高，由于android源码编译要求为4.3，如果gcc版本为4.4，那么编译可能会失败，我的系统是ubuntu 10.04,默认的gcc版本为4.4，gcc-4.4太严格，那么怎样从gcc-4.4降到gcc- 4.3呢？  
        1.安装gcc-4.3  
              `$ sudo apt-get install gcc-4.3 g++-4.3`  
        2.修复gcc相关链接  

            $ cd /usr/bin
            $sudo ln -snf gcc-4.3 gcc
            $sudo ln -snf g++-4.3 g++
            $sudo ln -snf cpp-4.3 cpp

        将gcc,g++链接至4.3版本即可。  

    2.JDK 5.0, update 12 or higher.Java 6 is not supported, because of incompatibilities with @Override.  
    3.安装编译必须的软件包  

        $ sudo apt-get install git-core gnupg flex bison gperf build-essential zip curl sun-java5-jdk zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev ia32-libs x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev
    参见http://source.android.com/source/download.html

2、拷贝development/ide/eclipse/.classpath到.classpath.

3、启动 eclipse ，按照这个步骤 File->New->Java Project (不是 Android Project) ->Create project from existing source 选到代码树根目录 .

4、在经过长时间等待之后， source code将被导入project，正常情况下应该没有error。

5启动模拟器

    [calvin@calvin-desktop ~/android/source-code/android_1.5_Sourcecode 10:28:03 ] $ . build/envsetup.sh
    [calvin@calvin-desktop ~/android/source-code/android_1.5_Sourcecode 10:28:18 ] $ lunch 1
    [calvin@calvin-desktop ~/android/source-code/android_1.5_Sourcecode 10:30:31 ] $ ./out/host/linux-x86/bin/emulator

6、在ddms中选中要调试的进程

7、在source code中设置断点

8、在eclipse里, Run->Debug Configuration->Remote Java Application->New, 设置 Connection port to 8700 (DDMS’s 默认端口),即可正常调试了
