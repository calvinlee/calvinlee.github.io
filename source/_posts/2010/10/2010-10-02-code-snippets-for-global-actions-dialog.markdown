---
layout: post
title: "Android关机界面代码"
category: 
tags: [android]
---

Android中长按Power键默认会弹出对话框让用户选择“飞行模式”，“静音”，“关机”等功能,弹出对话框的代码位于：
`frameworks\policies\base\phone\com\android\internal\policy\impl\PhoneWindowManager.java`

    private final Runnable mPowerLongPress = new Runnable() {
        public void run() {
            // The context isn't read
            if (mLongPressOnPowerBehavior < 0) {
                mLongPressOnPowerBehavior = mContext.getResources().getInteger(
                        com.android.internal.R.integer.config_longPressOnPowerBehavior);
            }
            switch (mLongPressOnPowerBehavior) {
            case LONG_PRESS_POWER_NOTHING:
                break;
            case LONG_PRESS_POWER_GLOBAL_ACTIONS:
                mPowerKeyHandled = true;
                performHapticFeedbackLw(null, HapticFeedbackConstants.LONG_PRESS, false);
                sendCloseSystemWindows(SYSTEM_DIALOG_REASON_GLOBAL_ACTIONS);
                showGlobalActionsDialog();
                break;
            case LONG_PRESS_POWER_SHUT_OFF:
                mPowerKeyHandled = true;
                performHapticFeedbackLw(null, HapticFeedbackConstants.LONG_PRESS, false);
                sendCloseSystemWindows(SYSTEM_DIALOG_REASON_GLOBAL_ACTIONS);
                ShutdownThread.shutdown(mContext, true);
                break;
            }
        }
    };

    void showGlobalActionsDialog() {
        if (mGlobalActions == null) {
            mGlobalActions = new GlobalActions(mContext);
        }
        final boolean keyguardShowing = mKeyguardMediator.isShowingAndNotHidden();
        mGlobalActions.showDialog(keyguardShowing, isDeviceProvisioned());
        if (keyguardShowing) {
            // since it took two seconds of long press to bring this up,
            // poke the wake lock so they have some time to see the dialog.
            mKeyguardMediator.pokeWakelock();
        }
    }
