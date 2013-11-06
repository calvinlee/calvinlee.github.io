---
layout: post
title: "利用onUserLeaveHint发送后台运行通知"
category: 
tags: [android]
---

###背景
用户按下Home键将程序置于后台运行或者应用启动其他activity，比如系统浏览器，短信等，需要向系统发送通知，用户做完别的操作后，点击通知栏，回到应用。

###问题
在什么时机发送通知？
用户按下Home的事件在应用层时捕捉不到的，因此只能从activity生命周期方法着手。

###方法一
系统所有activity继承一个BaseActivity，在BaseActivity中维护一个当前可见的activity数组：

    protected static ArrayList sVisibleActivities = new ArrayList();

在onResume中，将当前activity保存，同时清除所有通知：

    protected void onResume()
    {
    if (!sVisibleActivities.contains(this))
    {
    sVisibleActivities.add(this);
    }

    // 清除系统消息
    mNotificationManager.cancel(R.id.notify);
    }

    在onStop中，清除保存的当前activity：
    protected void onStop()
    {
    if (sVisibleActivities.contains(this))
    {
    sVisibleActivities.remove(this);
    }

    // 如果当前没有可见的activity，则发送系统通知
    if (sVisibleActivities.isEmpty())
    {
    sendBackgroundNotify();
    }

    super.onStop();
    }

这种方式在大多数情况下工作良好，可以达到需求，但是问题时，当前台的activity被至于后台时，onStop()方法**不一定**会被调用，因此通知有可能不会被发出！

###方法二
几经周折，发现activity有一个生命周期方法可以达到目的：

    protected void onUserLeaveHint ()

    Since: API Level 3
    Called as part of the activity lifecycle when an activity is about to go into the background as the result of user choice.
    For example, when the user presses the Home key, onUserLeaveHint() will be called, but when an incoming phone call causes the in-call Activity to be automatically brought to the foreground,
     onUserLeaveHint() will not be called on the activity being interrupted. In cases when it is invoked, this method is called right before the activity's onPause() callback.
    This callback and onUserInteraction() are intended to help activities manage status bar notifications intelligently; specifically, for helping activities determine the proper time to cancel a notfication.

从文档来看，这个方法似乎就是为了按下Home键时这样的场景设计的。  
这样，在onUserLeaveHint里发出系统通知即可。  
但是问题又来了，如果启动应用，从一个activity依次调用startActivity，finish关闭自己，启动一个新的activity时，onUserLeaveHint也会被调用....

再次翻阅文档，发现Intent中的一个Flag：  

        public static final int FLAG_ACTIVITY_NO_USER_ACTION

        Since: API Level 3
        If set, this flag will prevent the normal onUserLeaveHint() callback from occurring on the current frontmost activity before it is paused as the newly-started activity is brought to the front.

        Typically, an activity can rely on that callback to indicate that an explicit user action has caused their activity to be moved out of the foreground.
        The callback marks an appropriate point in the activity's lifecycle for it to dismiss any notifications that it intends to display "until the user has seen them," such as a blinking LED.
        If an activity is ever started via any non-user-driven events such as phone-call receipt or an alarm handler, this flag should be passed to Context.startActivity, ensuring that the pausing activity does not think the user has acknowledged its notification.

这正是我想要的，这样，在启动activity时，往intent中加上这个flag，onUserLeaveHint就不会再被调用了，hoory...
