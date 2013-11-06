---
layout: post
title: "使用lvm管理磁盘分区"
category: Linux
tags: [linux]
---

最近在给新同学安装Ubuntu系统后发现有的同学home分区空间不够了，于是研究了下利用lvm对home空间进行扩容。  
lvm的概念介绍来自[这里](http://hi.baidu.com/sinyo/blog/item/d793be3e866682f9828b13c6.html).

LVM是逻辑盘卷管理（Logical Volume Manager）的简称，它是Linux环境下对磁盘分区进行管理的一种机制，LVM是建立在硬盘和分区之上的一个逻辑层，来提高磁盘分区管理的灵活性。通过LVM系统管理员可以轻松管理磁盘分区，如：将若干个磁盘分区连接为一个整块的卷组（volume group），形成一个存储池。管理员可以在卷组上随意创建逻辑卷组（logical volumes），并进一步在逻辑卷组上创建文件系统。管理员通过LVM可以方便的调整存储卷组的大小，并且可以对磁盘存储按照组的方式进行命名、管理和分配，例如按照使用用途进行定义：“development”和“sales”，而不是使用物理磁盘名“sda”和“sdb”。而且当系统添加了新的磁盘，通过LVM管理员就不必将磁盘的文件移动到新的磁盘上以充分利用新的存储空间，而是直接扩展文件系统跨越磁盘即可。

---

###lvm的基本组成
lvm包括以下几个概念：

* Physical volume (PV)  
  指代磁盘上的物理分区
* Volume group (VG)  
  VG类似与物理硬盘，由多个物理分区组成，可以在VG上创建一个或者多个逻辑卷（LV）
* Logical volume (LV)  
  在VG的基础上划分出来的逻辑分区，在这个分区上可以建立文件系统，如home
* Physical extent (PE)  
  每个逻辑卷被划分的最小可寻址单元，一般为4MB。

接下来记录一下对home分区进行扩容的过程。

###准备工作
已有的环境：  
/dev/sda5 是一块windows分区，格式为fat32;  
/dev/sda9 为当前home所在的分区，格式为ext4.  
现在需要把/dev/sda5合并到home分区中。在建立lvm分区之前，需要备份这两块分区中的数据，因为之后的操作会对这两块分区进行格式化。

首先备份两块分区的数据，重启机器进入recovery模式，以root用户登录，卸载home所在的/dev/sda9

    # umount /home

###安装lvm

    # apt-get install lvm2

###修改物理分区类型为8e
作为PV的物理分区类型必须为8e，表示这是一块lvm的物理分区。我们使用fdisk对/dev/sda5和/dev/sda9这两个物理分区的分区类型进行修改。

    # fdisk /dev/sda
 
    WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
             switch off the mode (command 'c') and change display units to
             sectors (command 'u').

    Command (m for help): t
    Partition number (1-10): 5
    Hex code (type L to list codes): 8e
    Changed system type of partition 5 to 8e (Linux LVM)
    Command (m for help): t
    Partition number (1-10): 9
    Hex code (type L to list codes): 8e
    Changed system type of partition 9 to 8e (Linux LVM)
    Command (m for help): w       //将修改写入磁盘

最后`fdisk -l`查看一下修改后的分区。

###创建物理卷

    # pvcreate /dev/sda5
    pvcreate -- physical volume "/dev/sda5" successfully created
    # pvcreate /dev/sda9
    pvcreate -- physical volume "/dev/sda9" successfully created
    # pvdisplay

###创建卷组

    # vgcreate lvm_sda /dev/sda5 // 以/dev/sda5为基础创建一个名为lvm_sda的卷组
    # vgextend lvm_sda /dev/sda9 // 将/dev/sda9添加进lvm_sda卷组
    # vgdisplay lvm_sda

###创建逻辑卷

    # lvcreate -L 150G lvm_sda -n lvolhome
这里在lvm\_sda上创建了一个150G的名为lvolhome的逻辑卷,这时会生成/dev/lvm\_sda/lvolhome设备节点。

###创建文件系统

    # mkfs.ext4 /dev/lvm_sda/lvolhome

然后将其挂载到/home，并创建对应用户的home目录。

    # mount /dev/lvm_sda/lvolhome /home
    # cd /home
    # mkdir calvin
    # chown -R calvin:calvin calvin/

###设置开机挂载逻辑卷

    # vi /etc/fstab
删除已有的home挂载信息，添加：
 
    /dev/lvm_sda/lvolhome /home ext4 defaults 0 2

重启系统，done。

###Reference
* <http://blog.csdn.net/jianghuyue/article/details/6001957>
* <http://www.linuxhomenetworking.com/wiki/index.php/Quick\_HOWTO\_:\_Ch27\_:\_Expanding\_Disk\_Capacity>
