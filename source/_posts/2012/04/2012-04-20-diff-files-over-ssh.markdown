---
layout: post
title: "Diff files over SSH"
category: Linux
tags: [linux, 命令]
---

###比较单个文件

    ssh user@host "cat path/to/remote/file" | diff path/to/local/file -

###比较目录
利用sshfs将远程目录mount到本地，然后你就可以像比较本地目录一样操作这两个目录了。
安装sshfs

    sudo apt-get install sshfs

这会同时安装sshfs和[fuse](http://en.wikipedia.org/wiki/Filesystem_in_Userspace)

加载fuse模块到内核

    sudo modprobe fuse

挂载远程目录到本地的挂载点，执行比较

    $ mkdir local-mount-point
    $ sshfs user@host:/path/to/remote/dir local-mount-point
    $ diff -r /path/to/local/dir local-mount-point

最后，umount这个目录

    $ fusermount -u local-mount-point

umount的时候可能提示failed to unmount device or resource busy的错误信息，这时可以：

    $ fusermount -m local-mount-point  // 查看哪些进程在使用这个挂载点
    $ fusermount -k pid                // 杀掉这个进程
    $ fusermount -u local-mount-point

另外，fusermount命令的setuid属性被设置了，所以运行的时候可能会有权限问题，需要把当前用户添加到fuse这个用户组中：

    sudo adduser <username> fuse
    sudo chown root:fuse /dev/fuse
    sudo chmod +x /dev/fusermount

###Reference
* <http://www.howtogeek.com/howto/ubuntu/how-to-mount-a-remote-folder-using-ssh-on-ubuntu/>
* <https://wiki.archlinux.org/index.php/Sshfs>
