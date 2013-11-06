---
layout: post
title: "使用iconv和convmv转换文本编码"
category: Linux
tags: [命令, linux]
---

###文本内容编码转换
文本显示乱码是因为文件本身的编码格式和编辑器打开文本所使用的编码格式不一致，使用iconv命令可以转换文本编码。如：

    $ iconv -f coding1 -t coding2 file1 -o file2
    -f:指定文件原始编码
    -t:指定转换的目标编码
    file1:代转换的文件
    -o:指定输出文件

###文件名编码转换
常常有这样的情况，将一个rar文件解压后中文的文件名显示乱码，显示”invalid encoding“，利用convmv命令可以进行转换：

    $ convmv -f gbk -t utf-8 -r --notest path/to/your/file
    -f:指定原始编码
    -t:指定转换的目标编码
    -r:如果目标文件是一个目录，递归处理目录下的文件
    --notest:转换后将文件重命名，默认情况下这个命令不会重命名文件
