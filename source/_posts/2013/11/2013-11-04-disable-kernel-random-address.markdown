---
layout: post
title: "禁用内核进程地址随机"
comments: true
category: Linux
tags: [kernel]
---

今天接触了Linux下的VDSO（Virtual Dynamically-linked Shared Object)，用来使系统调用更加快速和高效，但在查看进程vdso.so在进程地址空间的分布时，发现每次打印出来的进程地址都不一样：

    $ ldd /bin/ls
    	linux-vdso.so.1 =>  (0x00007ffff7ffe000)
    	libselinux.so.1 => /lib/x86\_64-linux-gnu/libselinux.so.1 (0x00007ffff7dc0000)
    	librt.so.1 => /lib/x86\_64-linux-gnu/librt.so.1 (0x00007ffff7bb8000)
    	libacl.so.1 => /lib/x86\_64-linux-gnu/libacl.so.1 (0x00007ffff79af000)
    	libc.so.6 => /lib/x86\_64-linux-gnu/libc.so.6 (0x00007ffff75ef000)
    	libdl.so.2 => /lib/x86\_64-linux-gnu/libdl.so.2 (0x00007ffff73eb000)
    	/lib64/ld-linux-x86-64.so.2 (0x0000555555554000)
    	libpthread.so.0 => /lib/x86\_64-linux-gnu/libpthread.so.0 (0x00007ffff71cd000)
    	libattr.so.1 => /lib/x86\_64-linux-gnu/libattr.so.1 (0x00007ffff6fc8000)
    $ cat /proc/self/maps 
    00400000-0040b000 r-xp 00000000 08:05 1438995                            /bin/cat
    0060a000-0060b000 r--p 0000a000 08:05 1438995                            /bin/cat
    0060b000-0060c000 rw-p 0000b000 08:05 1438995                            /bin/cat
    0060c000-0062d000 rw-p 00000000 00:00 0                                  [heap]
    7ffff7337000-7ffff7a1a000 r--p 00000000 08:05 137790                     /usr/lib/locale/locale-archive
    7ffff7a1a000-7ffff7bcf000 r-xp 00000000 08:05 407680                     /lib/x86\_64-linux-gnu/libc-2.15.so
    7ffff7bcf000-7ffff7dcf000 ---p 001b5000 08:05 407680                     /lib/x86\_64-linux-gnu/libc-2.15.so
    7ffff7dcf000-7ffff7dd3000 r--p 001b5000 08:05 407680                     /lib/x86\_64-linux-gnu/libc-2.15.so
    7ffff7dd3000-7ffff7dd5000 rw-p 001b9000 08:05 407680                     /lib/x86\_64-linux-gnu/libc-2.15.so
    7ffff7dd5000-7ffff7dda000 rw-p 00000000 00:00 0 
    7ffff7dda000-7ffff7dfc000 r-xp 00000000 08:05 407692                     /lib/x86\_64-linux-gnu/ld-2.15.so
    7ffff7fd9000-7ffff7fdc000 rw-p 00000000 00:00 0 
    7ffff7ff9000-7ffff7ffb000 rw-p 00000000 00:00 0 
    7ffff7ffb000-7ffff7ffc000 r-xp 00000000 00:00 0                          [vdso]
    7ffff7ffc000-7ffff7ffd000 r--p 00022000 08:05 407692                     /lib/x86\_64-linux-gnu/ld-2.15.so
    7ffff7ffd000-7ffff7fff000 rw-p 00023000 08:05 407692                     /lib/x86\_64-linux-gnu/ld-2.15.so
    7ffffffde000-7ffffffff000 rw-p 00000000 00:00 0                          [stack]
    ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]

原来在现代Linux内核中，为了安全起见，会对每个进程的进程地址进行随机化。用以下命令即可禁用这个功能：

    echo "0" > /proc/sys/kernel/randomize_va_space

