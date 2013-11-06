---
layout: post
title: "Android Vold 分析"
category: Android
tags: [android]
---

Vold(Volume Daemon) 主要负责管理和控制外部存储设备，这些控制包括SD卡设备插拔，挂载，格式化等等.
Vold在Android 平台上的作用相当于udev在Linux平台上的功能。

### Vold的架构
Vold的架构大致如图：

[![/images/vold-architecture.png](/images/vold-architecture.png)](/images/vold-architecture.png)

* Kernel：detect device hot-plug, load drivers
* Sysfs: generate events and send it to user space
* NetlinkManager: establish connection to sysfs, listen to uevents and process it
* VolumeManager: disk volume operation
* CommandListener:  wait for commands from MountService
* NativeDaemonConnector:establish connection between MountService and vold daemon

其中，一张SD卡对应一个DirectVolume对象。

Vold模块的类图如下：

[![/images/vold-class-diagram.png](/images/vold-class-diagram.png)](/images/vold-class-diagram.png)

### Vold startup
vold的启动分为两个过程，一是vold daemon的启动，二是Java层MountService的启动。

#### 启动Vold daemon
Vold daemon由init进程启动，参见init.rc片段：

[![/images/vold-initrc.png](/images/vold-initrc.png)](/images/vold-initrc.png)

vold入口函数位于/system/vold/mail.cpp，启动后处理流程如下：

[![/images/vold-startup-sequence.png](/images/vold-startup-sequence.png)](/images/vold-startup-sequence.png)

1.Create directory /dev/block/vold
1.Create singleton instance of VolumeManager , NetlinkManager  andCommandListener
1.Process configuration file /system/etc/vold.fstab
1.NetlinkManager creates connection between kernel and vold
1.Manually trigger uevents by writing “add\n” to file in /sys/block
1.CommandListener  starts listening commands from framework

#### 启动MountService
1.MountService initialized by SystemServer on device starts up
1.Create connection to vold

After MountService is up, the vold system is ready.

### Send commands from framework
以App层通过MountService 挂载一个volume为例，说明从上层向下层的调用流程。

[![/images/vold-send-commands-from-framework.png](/images/vold-send-commands-from-framework.png)](/images/vold-send-commands-from-framework.png)

1. NativeDaemonConnector::sendCommand()
1. SocketListener::runListener() `<`--vold accepting connections here
1. FrameworkListener::onDataAvailable()
1. FrameworkListener::dispatchCommand()
1. FrameworkCommand::runCommand()---CommandListener::VolumeCmd::runCommand()
1. VolumeManager::mountVolume()
1. Volume::mountVol()

### Process events from kernel
处理kernel发出的挂载事件：

[![/images/vold-process-events-from-kernel.png](/images/vold-process-events-from-kernel.png)](/images/vold-process-events-from-kernel.png)

1. SocketListener::runListener `<`--listening events from kernel
1. NetlinkListener::onDataAvailable()
1. NetlinkHandler::onEvent()
1. VolumeManager::handleBlockEvent , VolumeManager::handleSwitchEvent , VolumeManager::handleUsbCompositeEvent
1. DirectVolume::handleBlockEvent()
1. DirectVolume::handleDiskAdded, DirectVolume::handlePartitionAdded, DirectVolume::handleDiskRemoved, DirectVolume::handlePartitionRemoved,DirectVolume::handleDiskChanged, DirectVolume::handlePartitionChanged,or ignore non add/remove/change event

### Reference
* <http://blog.csdn.net/qianjin0703/article/details/6362389>  
* <http://www.cnblogs.com/iceocean/articles/1594195.html>  
* <http://www.chinaunix.net/jh/4/822500.html>  
* <http://blog.csdn.net/fudan_abc/article/details/1768277>  
* <http://dongyulong.blog.51cto.com/1451604/389159>  
* <http://blog.csdn.net/datangsoc/article/details/5928132>
