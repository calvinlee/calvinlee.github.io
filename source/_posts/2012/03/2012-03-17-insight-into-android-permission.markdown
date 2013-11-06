---
layout: post
title: "Android 权限机制"
category: Android
tags: [permission, android, todo]
---

###概要
Android基于Linux，Android的权限管理基于Linux的权限框架。此外，Android在此基础上为应用程序提供了permission机制，使得应用程序通过“申请-授予”的机制得以访问系统的敏感资源。权限的授予在应用程序安装过程中就已经确定了，在安装过程中，应用程序的gid，uid，pid已经gids都会被分配。Android不支持在运行时动态进行权限授予。[Why?](http://developer.android.com/guide/topics/security/security.html#arch)

###References
http://en.wikipedia.org/wiki/Group_identifier#Primary_vs._supplementary

