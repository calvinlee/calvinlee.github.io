---
layout: post
title: "Android monkey & jni相关"
category: 
tags: [android]
---

首先，android平台应用程序可能产生以下四种crash：
* App层： Force close crash 和 ANR crash
* Native层： Tombstone crash
* Kernel层： Kernel panic 比较难定位，可以查看/proc/last_kmsg来辅助定位。

最近需要通过monkey工具测试Tombstone类型的crash，抓取log并分析。通过monkey测试，如果要抓取native类型的crash，需要加上--monitor-native-crash参数：

    seed=$(date +%Y%m%d%H%m%S)
    monkey -s $seed --pkg-whitelist-file ${your-package-list} --monitor-native-crashes --kill-process-after-error -v -v -v 2000000000

这样，monkey在跑出crash后，在/data/system/dropbox 和 /data/tombstones目录下会生成相关日志，moneky会停止发送事件流并退出测试.值得注意的是，/data/tombstones文件夹下只会保存10个日志，超过10个后，最早创建的会被替换。而monkey是通过监视这个文件夹下的文件数量变化来判断是否有tombtone类型的crash产生的。因此，当/data/tombstones文件夹下超过10个文件后，如果再有tombstone crash产生的话，monkey是不能检测到的，它会继续发送事件流。为了避免这个问题，可以在每次运行monkey之前先清空一下这个文件夹。

另外，在settings.db中的secure表中有三个字段：dropbox:data_app_wtf,dropbox:data_app_anr,dropbox:data_app_crash。如果设置为enabled，每当有app crash之后，在/data/system/dropbox这个文件夹下都会产生相关的日志信息，这对于分析调试问题都是第一手的信息。

###如何制造tombstone类型的crash？
这需要通过jni调用一个native的so文件，在本地代码中抛出异常即可。
可以编写如下代码tombstone_gen.cpp:

    int main(int argc, char **argv) {
      int *p=0;
      *p=1;    //will seg fault
      return 0;
    }

参照development/samples/SimpleJNI的示例，运行build出的apk即可。

关于jni调用，也有几个问题：

1.FindClass,RegisterNatives等找不到：
    
        target thumb C: libtombstonec <= development/samples/AndroidDemos/jni/tombstone_gen.c
        development/samples/AndroidDemos/jni/tombstone_gen.c: In function 'registerNativeMethods':
        development/samples/AndroidDemos/jni/tombstone_gen.c:48: error: request for member 'FindClass' in something not a structure or union
        development/samples/AndroidDemos/jni/tombstone_gen.c:53: error: request for member 'RegisterNatives' in something not a structure or union
        development/samples/AndroidDemos/jni/tombstone_gen.c: In function 'JNI_OnLoad':
        development/samples/AndroidDemos/jni/tombstone_gen.c:97: error: request for member 'GetEnv' in something not a structure or union
        make: *** [out/target/product/generic/obj/SHARED_LIBRARIES/libtombstonec_intermediates/tombstone_gen.o] Error 1
    
    问题原因在于：  
    如果是C程序，要用`(*env)->`  
    如果是C++要用 `env->`  
    因此有两种解决方法：  
    * 将 (*env)-> 改为 env->  
    * 将c文件改为cpp文件，改为c++的方式编译。  

2.运行时异常java.lang.UnsatisfiedLinkError  
    tombstone_gen.cpp中

        static const char *classPathName = "com/android/demo/AndroidDemos";

    类名有误，导致类链接错误。

最后，关于jni中JNINativeMethod相关解释：  
<http://hi.baidu.com/zhlg_hzh/blog/item/f0d782081f2f45d963d986f5.html>
