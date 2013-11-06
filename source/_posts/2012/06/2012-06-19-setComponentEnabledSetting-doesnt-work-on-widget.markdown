---
layout: post
title: "setComponentEnabledSetting doesn't work on widget"
category: Android
tags: [android]
---

###需求
有一个系统属性disable\_widget用来标识是否需要禁用某个widget，如果是，那么禁用某个widget.

###实现与问题
`PackageManager.setComponentEnabledSetting` 可以用来禁用某个组件，包括activity，receiver等等。被禁用的组件会被持久化到/data/system/packages.xml中，如：

    <package name="com.android.setupwizard" codePath="/system/app/SetupWizard.apk" nativeLibraryPath="/data/data/com.android.setupwizard/lib" flags="1" ft="13349457a90" it="13349457a90" ut="13349457a90" version="130" userId="10016">
      <sigs count="1">
      <cert index="0" />
      </sigs>
      <disabled-components>
      <item name="com.android.setupwizard.SetupWizardActivity" />
      </disabled-components>
    </package>

因为widget实际上就是个reveiver，它接收android.appwidget.action.APPWIDGET\_UPDATE的action，所以开始的思路是：  
创建一个BroadcastReceiver，接收Intent.ACTION\_BOOT\_COMPLETED这个动作，从而在启动完成后调用SystemProperties.get("disable\_widget")，如果需要禁用这个widget，那么调用：

    PackageManager.setComponentEnabledSetting(widgetComponentName，PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    PackageManager.DONT_KILL_APP);

但是问题是，调用这个方法disable掉这个widget后，发现必须把设备重启之后才能生效...  
经过一番挖掘，发现问题出在com.android.server.AppWidgetService.java。  

开机后，SystemServer会调用AppWidgetService的systemReady()方法，这个方法通过PackageManager查询所有的widget receiver组件，保存到mInstalledProviders变量列表中，并持久化widget信息到/data/system/appwidgets.xml中。
而在Launcher上长按添加widget时的那个widget列表信息也是通过AppWidgetService取得mInstalledProviders列表。  

问题在于我们通过PackageManager.setComponentEnabledSetting（）禁用掉某个widget后，packagemanager确实将这个组件disable了，但是AppWidgetService却没有去从packagemanager reload widget信息，这就导致了mInstalledProviders中保存的widget信息还是开机时load进来的那些信息，并没有与pm进行同步。直到下一次开机调用systemReady重新加载widget信息才会刷新这个列表。

###Reference
* [Dynamically enabling or disabling a widget with PackageManager.setComponentEnabledSetting does not work](http://code.google.com/p/android/issues/detail?id=6533)
* <http://blog.csdn.net/yinlijun2004/article/details/6136108>
