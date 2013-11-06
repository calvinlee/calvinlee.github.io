---
layout: post
title: "Compile CyanogenMod (Linux) for HTC Desire"
category: 
tags: [android]
---

出现如下问题：  
1.repo init时报错：

    ......
    object 30d452905f166b316152f236422f85c8aa75a2d0
    type commit
    tag v1.7.5
    tagger Shawn O. Pearce <sop@google.com> 1307663540 -0700

    repo 1.7.5

    gpg: Signature made Fri 10 Jun 2011 07:52:20 AM CST using DSA key ID 920F5C65
    gpg: Can't check signature: public key not found
    error: could not verify the tag 'v1.7.5'

出错原因是曾使用repo sync从其它库sync过代码，删掉~/.repoconfig即可：  

    $ rm -rf ~/.repoconfig
    $ ./repo init -u git://github.com/CyanogenMod/android.git -b gingerbread
    gpg: keyring `/home/calvin/.repoconfig/gnupg/secring.gpg' created
    gpg: keyring `/home/calvin/.repoconfig/gnupg/pubring.gpg' created
    gpg: /home/calvin/.repoconfig/gnupg/trustdb.gpg: trustdb created
    gpg: key 920F5C65: public key "Repo Maintainer <repo@android.kernel.org>" imported
    gpg: Total number processed: 1
    gpg:               imported: 1

    Getting repo ...
       from http://android.git.kernel.org/tools/repo.git
    。。。。


2.repo sync时报错：

    ......
    Fetching projects:   1% (3/285) 
    Initializing project platform/bootable/bootloader/legacy ...
    android.git.kernel.org[0: 130.239.17.13]: errno=Connection refused
    android.git.kernel.org[0: 149.20.4.77]: errno=Connection timed out
    android.git.kernel.org[0: 199.6.1.173]: errno=Connection refused
    android.git.kernel.org[0: 2001:4f8:8:10:1972:112:1:0]: errno=Network is unreachable
    android.git.kernel.org[0: 2001:500:60:10:1972:112:1:0]: errno=Network is unreachable
    android.git.kernel.org[0: 2001:6b0:e:4017:1972:112:1:0]: errno=Network is unreachable
    android.git.kernel.org[0: 2001:4f8:1:10:1972:112:1:0]: errno=Network is unreachable
    fatal: unable to connect a socket (Network is unreachable)
    error: Cannot fetch platform/bootable/bootloader/legacy

连接服务器时的问题，解决：  
修改.repo/manifest.xml中

      <remote  name="korg"
               fetch="git://android.git.kernel.org/"
               review="review.source.android.com" />
为

      <remote  name="korg"
               fetch="http://android.git.kernel.org/"
               review="review.source.android.com" />

