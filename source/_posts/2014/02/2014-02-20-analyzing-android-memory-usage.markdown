---
layout: post
title: "分析Android App内存占用"
date: 2014-02-20 22:41
comments: true
categories: [Android]
tags: []
---

##使用dumpsys
``` bash
shell@android:/ # dumpsys meminfo com.android.systemui
Applications Memory Usage (kB):
Uptime: 296724 Realtime: 296723
** MEMINFO in pid 2786 [com.android.systemui] **
                         Shared  Private     Heap     Heap     Heap
                   Pss    Dirty    Dirty     Size    Alloc     Free
                ------   ------   ------   ------   ------   ------
       Native        0        0        0    12540    12384       83
       Dalvik     8256     5128     8088    13192     8327     4865
       Cursor        0        0        0                           
       Ashmem        0        0        0                           
    Other dev        4       24        0                           
     .so mmap     1704     1996     1256                           
    .jar mmap        0        0        0                           
    .apk mmap      750        0        0                           
    .ttf mmap        4        0        0                           
    .dex mmap     1284        0        0                           
   Other mmap       83       20       32                           
      Unknown     5692      652     5676                           
        TOTAL    17777     7820    15052    25732    20711     4948
 
 Objects
               Views:      155         ViewRootImpl:        7
         AppContexts:       12           Activities:        0
              Assets:        3        AssetManagers:        3
       Local Binders:       38        Proxy Binders:       38
    Death Recipients:        3
     OpenSSL Sockets:        0
 
 SQL
         MEMORY_USED:        0
  PAGECACHE_OVERFLOW:        0          MALLOC_SIZE:        0
```

有价值的两个值：

- PSS（Proportional Set Size ）  
应用本身所占的物理内存 + 和其他应用share的内存。这个值会被系统作为这个应用的phisical memory footprint
- Private Dirty  
应用本身所占的物理内存，如果把该应用杀掉，那么就会释放这些内存
通过AppContexts和Activities可以判断应用是否有activity内存泄漏（如果这个值一直在增长）。

##Tips for memory usage
> <http://developer.android.com/training/articles/memory.html>

1. Service会阻止进程被系统杀掉，不要让service一直运行，最好使用IntentService，运行完一个job就退出。
2. 在onTrimMemory回调中释放UI资源（注意：这里不同于onStop）
3. 使用getMemoryClass()获得应用的heap大小。app也可以使用android:largeHeap选项请求大的heap（慎用！）。
4. 使用优化过的数据结构： SparseArray, SparseBooleanArray, and LongSparseArray.
5. 除非有必要，否则不要抽象代码
6. 使用nano protocol buffer来取代xml序列化数据
7. 谨慎使用第三方库，因为这些库并不适合移动设备的运行环境。也不要为了使用so库中一两个功能，而引入整个库。
8. 使用ProGuard来压缩代码：去除无用的代码，同时混淆代码
9. 涉及到UI资源的进程很占内存。所以如果需要后台运行的service，如音乐播放，可以将这个service配置到另外的进程里，这样系统可以不用为了保持这个service服务的运行，而必须保留占内存的UI进程。

##其他工具
adb shell procrank  
adb shell cat /proc/meminfo

##Reference
<http://developer.android.com/tools/debugging/debugging-memory.html>
<http://elinux.org/Android\_Memory\_Usage>
<http://stackoverflow.com/questions/2298208/how-to-discover-memory-usage-of-my-application-in-android/>
<http://unix.stackexchange.com/questions/33381/getting-information-about-a-process-memory-usage-from-proc-pid-smaps>
[Android 4.4 meminfo 实现分析]<http://tech.uc.cn/?p=2714>



