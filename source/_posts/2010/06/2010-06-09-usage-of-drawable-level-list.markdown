---
layout: post
title: "利用level-list显示图片"
category: 
tags: [android]
---

有时候，我们为了在一个ImageView中显示不同的图片，往往会使用：

    if (条件1) {
        image.setBackground(R.id.xxx1);
    } else if (条件2) {
        image.setBackground(R.id.xxx2);
    } ...

可以用另一个简便的方法实现相同的功能。

首先，在res/drawable下建立一个xml文件，内容如下

    <level-list xmlns:android="http://schemas.android.com/apk/res/android">
        <item android:maxLevel="4" android:drawable="@drawable/stat_sys_battery_0" />
        <item android:maxLevel="14" android:drawable="@drawable/stat_sys_battery_10" />
        <item android:maxLevel="29" android:drawable="@drawable/stat_sys_battery_20" />
        <item android:maxLevel="49" android:drawable="@drawable/stat_sys_battery_40" />
        <item android:maxLevel="69" android:drawable="@drawable/stat_sys_battery_60" />
        <item android:maxLevel="89" android:drawable="@drawable/stat_sys_battery_80" />
        <item android:maxLevel="100" android:drawable="@drawable/stat_sys_battery_100" />
    </level-list>

然后在layout中把ImageView的src设置成已创建好的xml文件。
程序中需要更新图片时，只需要使用

    imageview.getDrawable().setLevel(50)

Android会根据level的值自动选择对应的图片。显示剩余电量就是用这个方法来显示不同图片的。
