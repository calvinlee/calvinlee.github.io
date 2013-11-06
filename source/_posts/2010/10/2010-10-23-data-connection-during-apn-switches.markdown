---
layout: post
title: "APN切换后数据连接过程"
category: 
tags: [android]
---

###注册观察者回调
GsmDataConnectionTracker在实例化时，会注册一个观察者，监视apn数据库的变化。

    p.getContext().getContentResolver().registerContentObserver(
                Telephony.Carriers.CONTENT_URI, true, apnObserver);
               
当用户通过UI改变apn并保存后，Settings app将更新后的数据写入apn数据库。

###GsmDataConnectionTracker切换APN
Settings app更新apn数据库后，GsmDataConnectionTracker注册的ApnChangeObserver的onChange被调用，发送`EVENT_APN_CHANGED`消息：

    sendMessage(obtainMessage(EVENT_APN_CHANGED));

接着onApnChanged()@GsmDataConnectionTracker.java被调用

      -trySetupData(Phone.REASON_APN_CHANGED)@GsmDataConnectionTracker.java
        --setupData(String reason)@GsmDataConnectionTracker.java

        private boolean setupData(String reason) {
        ApnSetting apn;
        GsmDataConnection pdp;

        apn = getNextApn();
        if (apn == null) return false;

        //获取一个状态为inactive的pdp连接对象
        pdp = findFreePdp();
        if (pdp == null) {
            if (DBG) log("setupData: No free GsmDataConnection found!");
            return false;
        }
        mActiveApn = apn;
        mActivePdp = pdp;

        Message msg = obtainMessage();
        msg.what = EVENT_DATA_SETUP_COMPLETE;
        msg.obj = reason;

        //开始激活这个pdp
        //在android2.0.1版本时，有一个PdpConnection.java来进行连接，2.2时这个类被删掉了，connect的功能合并到GsmDataConnection里面
        pdp.connect(msg, apn);

        //设置这个pdp连接状态为INITING
        setState(State.INITING);
        if (DBG) log("setupData for reason: "+reason);

        //通知上层应用数据连接状态改变
        phone.notifyDataConnection(reason);
        return true;
    }

其中，在这一层，数据连接共七个状态：

        IDLE,
        INITING,
        CONNECTING,
        SCANNING,
        CONNECTED,
        DISCONNECTING,
        FAILED

对上层应用来说，这七个状态划分为四种状态（getDataConnectionState()@GSMPhone.java）：

    CONNECTED, CONNECTING, DISCONNECTED, SUSPENDED;

分别对应TelephonyManager的四种连接状态。
       

###激活PDP连接
开始激活PDP连接时，设置状态为State.INITING，调用phone.notifyDataConnection(reason)发出通知，后续调用过程为：

        notifyDataConnection(String reason)@PhoneBase.java
          --notifyDataConnection(Phone sender, String reason)@DefaultPhoneNotifier.java
            .
            .   这里需要经过IPC调用
            .
            notifyDataConnection()@TelephonyRegistry.java
              --onDataConnectionStateChanged()

当连接成功后，onDataSetupComplete（）@GsmDataConnectionTracker.java被调用
通过phone.notifyDataConnection(reason);回调应用层的onDataConnectionStateChanged()方法。

ps:可以通过adb logcat -b radio查看激活数据连接时，radio层的log输出。
