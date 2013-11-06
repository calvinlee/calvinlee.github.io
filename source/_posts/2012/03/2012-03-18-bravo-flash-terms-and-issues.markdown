---
layout: post
title: "bravo flash terms and issues"
category: 
tags: []
published: false
---

HBoot：http://alpharev.nl/
ROM Update Utility（RUU）
http://www.freeyourandroid.com/guide/flashing-ruu-htc
<http://shipped-roms.com/index.php?category=android&model=Bravo>

app2sd
<http://www.mrpeng.info/2010/12/data2sd_on_desire/>
app2ext

data2ext 
data2whatever:http://forum.xda-developers.com/showthread.php?t=867049&page=3

Bootloader(HBoot)-->recovery
Hboot Definition:
Hboot is most commonly known to the Android phone community as the first stage before the phone goes through its boot cycle.
In a boot control scenario, the hboot provides an avenue of choice between functions up to and including a standard boot. Other choices may be things such as recovery branch, or factory reset.
Hboot (aka: bootloader) also serves as a gatekeeper for software updates to the device. The hboot commonly uses encryption technology that will check to see if the package being written is "signed." This function is often referred to as "locked."
In any event, the hboot is a critical component. Without it, a device simply will not work.


Nand backup

http://stackoverflow.com/questions/3465259/can-someone-explain-these-android-rom-hacking-terms-hboot-bootloader-radio-re

非常好的解释：
http://androidforums.com/evo-4g-all-things-root/278898-android-partitions-kernels-explained.html

###android internal storage partition
https://www.google.com/search?client=ubuntu&channel=fs&q=android+internal+memory+partition&ie=utf-8&oe=utf-8
http://www.addictivetips.com/mobile/android-partitions-explained-boot-system-recovery-data-cache-misc/
http://stackoverflow.com/questions/4634774/android-memory-types-ram-v-internal-memory
So, with all that in mind:
    Your 512MB of ROM is the on-board flash storage, hearkening back to the old "flash ROM" term
    Your "Internal phone storage" in settings it the available space in the data partition for end-user apps and data (one of the reasons why I don't use this term to refer to the on-board flash storage as a whole)
    Your "SD card" is more generically referred to in Android as external storage, which on many devices is some form of SD card, though it could actually be just another partition of the on-board flash storage designated as serving in the role of external storage

HTC desire:
<http://forum.xda-developers.com/wiki/HTC_Desire>
Memory: RAM 576MB, ROM 512MB Flash 
$ adb shell cat /proc/mtd
+++++++++++++++++++++++++++++++++++++++++++++++
Fastboot
<http://en.wikipedia.org/wiki/Fastboot>
Utilizing the Fastboot protocol requires that the device be started in a boot loader or Second Program Loader mode in which only the most basic hardware initialization is performed. After enabling the protocol on the device itself it will accept any command sent to it over USB via a command line. Some of most commonly used fastboot commands include:
<http://wiki.cyanogenmod.com/wiki/Fastboot#Typical_Partition_Layout>
<http://android-dls.com/wiki/index.php?title=Fastboot>
<http://elinux.org/Android_Fastboot>

HBoot可以在fastboot和hboot之间切换
在fastboot模式时，如果是S-OFF，那么可以使用fastboot来刷写image
<http://wiki.cyanogenmod.com/wiki/Fastboot#fastboot_--help>

$ ./fastboot devices
SH12RPL03652	fastboot

对Nexus s 和 Xoom,可以使用fastboot oem unlock
++++++++++++++++++++++++++++++++++++++++++++++
IPL VS SPL
+++++++++++++++++++++++++++++++++++++++++++++++
HBoot参数详解
　　BRAVO PVT4 SHIP S-ON 
　　HBOOT-0.93.0001 
　　MICROP-031d 
　　RADIO-5.10.05.23 
　　Aug 10 2010,17:52:18
　　BRAVO：这个是手机型号的内部开发代号。 

　　PVT(或者是EVT，DVT，CVT)：是代表手机的版本类型。 
　　一台手机从研发到上市，可能会经历多次版本上的调试和改动，版本类型标志着机器是什么时候的产物，如下： 
　　EVT：工程机，研发阶段机器的型号; 
　　DVT：开发机，特殊开发用途机器的型号; 
　　CVT：商用机，交付运营商的机器的型号; 
　　PVT：量产机，最终上市的零售版机器的型号。(PVT1：第1批量产机) 
　　SHIP/ENG：手机HBOOT(SPL)的版本。 
　　SHIP：shippment的缩写，出货的意思，零售版的HBOOT版本。 
　　ENG：Engineer的缩写，工程的意思，修改版的HBOOT版本。 
　　S-ON(或者是S-OFF)： 
　　S代表Security Lock，即安全锁。HTC在手机内部设置了一个安全锁，用来控制系统分区的读写状态。 
　　S-ON：安全锁开; 
　　S-OFF：安全锁关。 
　　HBOOT-0.93.0001 
　　这里显示了HBOOT的版本号，HBOOT是一个很特殊的部分，刷坏了这里，手机就会变砖，类似于升级电脑的BIOS，刷错了BIOS，你只能返厂用特殊的擦写工具来恢复了，所以，对HBOOT的操作要特别的注意，如非必要，不要去轻易刷写此分区!  
　　RADIO-5.10.05.23 
　　这里显示了RADIO的版本号，同样的，RADIO会随着官方系统的升级而跟着升级，RADIO是负责信号和硬件驱动的，理论上讲，应该是越高版本越好，当然也不是绝对，也需要要看情况的，就像电脑上的驱动，最新的并不一定是最好的。

++++++++++++++++++++++++++++++++++++
第一级: Root
所谓root，就是linux系统的最高权限用户。因为android基本就是精简的linux+驱动+dalvik java虚拟机。所以获取了root，你就可以对手机里的软件进行修改了。在国内的手机软件网站能找到什么一键root的工具。root成功的标志一般是手机的程序图标里多了一个“授权管理”，这是就可以对需要root权限才能运行的软件授权了。

第二级：Recovery
所谓recovery,就是一个用于更新rom的基本完备的小系统，相当于电脑崩溃后用来修复系统的启动光盘。对了，解释下rom，rom本来的意思是只读内存，用在手机上呢表示用户不能修改的内存。注意，是用户不能修改，实际上是可以改的，还改的很快呢！不然也没recovery什么事了。也就是说手机出厂时原装的系统，类似于买电脑已经预装了系统，手机厂家是不希望用户乱改的。那厂家要刷rom怎么办呢? 因为他们能进入手机里他们的recovery，所以这不是问题。而有些不安分的人玩着觉得不爽了，觉得自己能搞出更好用的rom。而要刷自己的rom，那么就必须干掉原先系统里的recovery，刷自己的recovery，这是需要有root为前提的。unrevoked.com提供了windows下的工具，将root和刷recovery合二为一，默认刷入的是Clockwork mod的recovery 2.5版.当然也可以刷入你指定的recovery。
具体操作过程中会遇到两次驱动的问题。一个驱动是手机运行状态下的usb驱动，这个通过安装htc sync就能解决。一个驱动是用于手机调试的hboot usb驱动，只有进入到手机的hboot状态，windows才会提示你安装，网上很多教程都附有下载链接。本版版主的教程里也有。
还有一个问题是会遇到Backup CID的问题,不细说，搜搜网上的教程吧。
当看到unrevoked出现Done的时候，恭喜你，你进入了Class 2.
成功刷入recovery后还有一个战利品是可以更新手机的radio,我理解就是手机无线部分的底层代码，目前最新的版本是5.14。
刷了rom后，别忘了wipe user data和cache再重启。

第三级：S-OFF
S-OFF,就是security off的意思。意思是手机上的一个硬件安全标识处于off的状态，这时可以用android开发工具里的fastboot往手机里刷任何东西。手机出厂时可都是S-ON的。S-OFF了之后，刷recovery都可以不用unrevoked了，直接用fastboot吧。所谓刷s-off，是说这个硬件咱改不了，只能刷手机软件，让它不去管这个什么安全标识，该干嘛就干嘛。
看到这里，你可能觉得很晕，不是说s-on的系统就是不能改的吗，怎么刷recovery的时候没人提它呢？我刷recovery的时候还是s-on呢！
我以为unrevoked的行为本质是也是一种软s-off的方法，因为它“非法”修改了recovery,但是它没有解决hboot的s-on的问题。人家是有道理的：hboot比recovery启动的顺序更靠前，搞坏的话，手机就彻底变砖了。
本级这里的S-OFF，特指连hboot都已经被修改了，系统彻底被s-off了，彻底被free了。
刷S-OFF的风险在于，如果你把rom刷坏了，可以通过recovery修复；如果你把recovery刷坏了，厂家进入hboot还可以把recovery给你刷回来。hboot是手机变砖修复的最后一丝希望，如果hboot都被搞坏了，那估计只能把rom芯片取下来拿到编程器上刷了。一般来讲没必要修改，那什么时候修改hboot的收益能引诱我们冒这个风险呢？
对我而言，一个就是可以通过fastboot刷各种recovery,update,splash，而不必仰仗各种工具，反复的重启。一个就是因为Adam Green的Oxygen 2。
好吧，我承认我是AdamG的粉丝。Oxygen是一个来完全开源，代码都来自AOSP的以精简、稳定为追求的Gingerbread（就是android 2.3）的rom。另外，确实比较省电，据AdamG自己讲，电池最多能用到3天。由于比较精简，所以原先系统cache和system分区就能腾出不少空间。如果这些将近200M的空间拿来装我们自己的apk，就完全没必要去玩什么app2ext app2sd app2*了，还又快又省电。这也是AdamG为什么非常不情愿在Oxygen 2加入app2ext支持的原因。
所以，刷hboot最大的好处就是可以把这块空间腾出来。这个过程实际上也彻底屏蔽了hTC的安全标识，彻底s-off了，所以网上叫喊s-off的时候,干的其实是刷hboot的勾当。
干这个有工具吗？这个真还有。alpharev.nl上面提供一个iso文件和若干hboot映像的下载。有一个映像就是专供Oxygen的，你可以看到data分区的空间是多么大啊。具体方法就是用它提供的iso刻的光盘启动系统，并按提示连接手机，一切过程自动完成。不想去刻盘也可以用虚拟机vmware,只不过手机每次重启后都需要你点击vmware菜单里的removable devices里的high android phone将手机的usb连接重新接入虚拟机。
按我的经验，很可能会到手机型号不匹配的问题，网上有教程告诉你怎么做。
这事干完，你手机的hboot跟recovery版本都被翻新了。然后再用fastboot刷入Oxygen专供的hboot，然后就可以刷Oxygen 2了。不过因为这个hboot的cache分区很小,刷非Oxygen的其他rom和update的时候可能就不行了。

最后，祝你好运。刷机有风险，操作需谨慎。下载的非zip文件别忘了校对MD5或者SHA。
