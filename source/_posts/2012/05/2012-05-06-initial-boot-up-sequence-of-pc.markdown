---
layout: post
title: "Archlinux开机初始化基本步骤"
category: Linux
tags: [archlinux]
published: 
---

以下是对计算机开机加电后的自举流程的一个大致理解。

###MBR
计算机开机后CPU处于16位实模式下，加上4位的偏移量，CPU能寻址的范围是20位，也就是1 MB的地址空间。CPU从存储器地址为0xFFFF0的位置读取一条跳转指令，这条指令将下一条指令地址指向系统BIOS的初始地址。对后BIOS程序执行机器自检POST（power on self test）,检查系统基本的硬件设备，并检索系统中包含可启动代码的设备，所谓可启动的设备是指第一个扇区（sector）的最后两个字节包含0xAA55（boot签名），可以通过如下命令查看硬盘第一个扇区的信息：

    $ sudo dd if=/dev/sda1 of=sector.bin bs=512 count=1
    1+0 records in
    1+0 records out
    512 bytes (512 B) copied, 0.0245341 s, 20.9 kB/s
    $ od -x sector.bin

启动设备的第一个扇区的512字节称为MBR（master boot record），MBR存放三部分内容：

1. boot loader stage1程序     446字节 　　
1. 硬盘分区表                        64字节 　　
1. 该扇区的有效标示(OxAA55)              2字节

BIOS检索到可启动的设备后，将这个设备的MBR区域的stage1程序加载到起始地址为0x7C00的一块内存区域，然后从这个地址执行stage1程序。接下来的启动过程分为几个阶段：

###Bootloader
#### stage1加载执行stage1.5 
  stage1.5位于MBR区域后的30K范围内, 它包含文件系统相关的驱动代码, stage1.5可加载的文件系统包括：

      $ /bin/ls /boot/grub/*stage1_5
      /boot/grub/e2fs_stage1_5  /boot/grub/ffs_stage1_5      /boot/grub/jfs_stage1_5	  /boot/grub/reiserfs_stage1_5	/boot/grub/vstafs_stage1_5
      /boot/grub/fat_stage1_5   /boot/grub/iso9660_stage1_5  /boot/grub/minix_stage1_5  /boot/grub/ufs2_stage1_5	/boot/grub/xfs_stage1_5
      $ file /boot/grub/reiserfs_stage1_5
      /boot/grub/reiserfs_stage1_5: GRand Unified Bootloader stage1_5 version 3.2, identifier 0x5, GRUB version 0.97, configuration file /boot/grub/stage2
      $ file /boot/grub/stage2
      /boot/grub/stage2: GRand Unified Bootloader stage2 version 3.2, identifier 0x0, GRUB version 0.97, configuration file /boot/grub/menu.lst

#### stage1.5加载stage2

  在stage2阶段通过/boot/grub/menu.lst生成可启动的系统列表，并启动一个图形化的选择界面：

      timeout   7
      default   0
      color light-blue/black light-cyan/blue

      # (0) Arch Linux
      title  Arch Linux
      root   (hd0,7)
      kernel /boot/vmlinuz-linux root=/dev/sda8 ro
      initrd /boot/initramfs-linux.img

      # (1) Arch Linux
      title  Arch Linux Fallback
      root   (hd0,7)
      kernel /boot/vmlinuz-linux root=/dev/sda8 ro
      initrd /boot/initramfs-linux-fallback.img

      # (2) Windows
      title Microsoft Windows 7
      rootnoverify (hd0,1)
      makeactive
      chainloader +1

menu.lst指定了kernel和initrd镜像的路径。

#### 解压kernel
当选择进入某个系统后，对应的kernel被载入内存并解压，控制权转移到kernel，kernel接下来初始化硬件，加载必要的驱动模块

#### 加载initrd镜像
加载initrd（init ram filesystem，初始ram文件系统），在内存中展开位一个虚拟的文件系统，并执行其中的init脚本,通过以下命令可以揭开这个image文件，查看这个init脚本做了什么：

      $ cp /boot/initramfs-linux.img /tmp/initramfs/initramfs-linux.gz
      $ gzip -d initramfs-linux.gz 
      $ file initramfs-linux 
      initramfs-linux: ASCII cpio archive (SVR4 with no CRC)
      $ cpio -i <initramfs-linux 
      16076 blocks
      [calvin@arch-laptop /tmp/initramfs 01:11:09 ]
      $ ls
      total 7.9M
      lrwxrwxrwx 1 calvin calvin    7 May  7 01:11 bin -> usr/bin
      -rw-r--r-- 1 calvin calvin   70 May  7 01:11 config
      drwxr-xr-x 2 calvin calvin   40 May  7 01:11 dev
      drwxr-xr-x 3 calvin calvin  100 May  7 01:11 etc
      drwxr-xr-x 2 calvin calvin   60 May  7 01:11 hooks
      -rwxr-xr-x 1 calvin calvin 3.2K May  7 01:11 init
      -rw-r--r-- 1 calvin calvin 7.2K May  7 01:11 init_functions
      -rw-r--r-- 1 calvin calvin 7.9M May  7 01:10 initramfs-linux
      lrwxrwxrwx 1 calvin calvin    7 May  7 01:11 lib -> usr/lib
      drwxr-xr-x 2 calvin calvin   40 May  7 01:11 new_root
      drwxr-xr-x 2 calvin calvin   40 May  7 01:11 proc
      drwxr-xr-x 2 calvin calvin   40 May  7 01:11 run
      lrwxrwxrwx 1 calvin calvin    7 May  7 01:11 sbin -> usr/bin
      drwxr-xr-x 2 calvin calvin   40 May  7 01:11 sys
      drwxr-xr-x 2 calvin calvin   40 May  7 01:11 tmp
      drwxr-xr-x 4 calvin calvin  100 May  7 01:11 usr
      -rw-r--r-- 1 calvin calvin    5 May  7 01:11 VERSION
执行这个init脚本时，屏幕上会输出以下信息：

      :: Starting udevd...
      done.
      ... ... 

####启动init进程
挂载真正的根文件系统，执行/sbin/init程序。  
init程序首先读取/etc/inittab文件,这个过程参照[here](https://wiki.archlinux.org/index.php/Arch_Boot_Process_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29#init:_The_Arch_boot_scripts)

###Reference
* <http://en.wikipedia.org/wiki/Linux_startup_process#Overview_of_typical_process>
* <http://en.wikipedia.org/wiki/Booting#Boot_sequence_on_standard_PC_.28IBM-PC_compatible.29>
* <http://www.cnblogs.com/bangerlee/archive/2012/03/11/2388275.html>
* <http://blog.sina.com.cn/s/blog_4c2edd700100cne2.html>
* <http://www.ibm.com/developerworks/linux/library/l-linuxboot/>
* <https://wiki.archlinux.org/index.php/Arch_Boot_Process_(简体中文)#init:_The_Arch_boot_scripts>
* <http://en.wikipedia.org/wiki/Real_mode>
