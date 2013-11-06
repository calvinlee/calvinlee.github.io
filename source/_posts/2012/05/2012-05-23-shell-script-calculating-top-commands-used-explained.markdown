---
layout: post
title: "一段shell脚本的分析"
category: Shell
tags: [linux, shell, awk, 命令]
---

[陈皓](http://coolshell.cn/about)在微博上放出一段脚本，用来统计在日常工作中哪些命令用的最多：

    history | awk '{CMD[$2]++;count++;} END { for (a in CMD ) print CMD[a] " " CMD[a]/count*100 "% " a }' | grep -v "./" | column -c3 -s " " -t |sort -nr | nl | head -n10

我的运行结果是这样的：

     1	421  21.05%  git
     2	232  11.6%   cd
     3	169  8.45%   ls
     4	126  6.3%    vi
     5	108  5.4%    sudo
     6	94   4.7%    man
     7	66   3.3%    fg
     8	56   2.8%    adb
     9	52   2.6%    vim
    10	38   1.9%    grep

下面简单分析下这段脚本。  
这段脚本分为以下几个步骤执行：

1. 执行命令history，输出命令历史记录，输出格式为：

    number command

1. 将step 1的输出结果交给awk脚本处理：

       awk '{CMD[$2]++;count++;} END { for (a in CMD )print CMD[ a ]" " CMD[ a ]/count*100 "% " a }' 
   history的输出记录首先依次交给`CMD[$2]++;count++;`处理。awk中，`$n`表示当前记录的第n个字段，字段间由FS分隔，默认为空格，`$0`表示完整的输入记录。此处`$2`表示输入记录的第2个字段，即command字段。这里定义了一个名为CMD的数组和一个count变量，其中CMD数组的index为命令字符串，value为一个整数，代表这条命令出现的次数。count变量记录了处理过的记录条数。每处理一条记录，以这条记录里的命令为index对应的value就会加1,同时count值加1。  
   END模式指定了当读完所有的记录后，执行的操作。<http://www.gnu.org/software/gawk/manual/gawk.html#Using-BEGIN_002fEND>。这里会遍历CMD数组并打印，格式为：

       命令出现的次数 命令出现的次数所占的百分比 命令名
       2 0.1% ps
       421 21.05% git

1. 将step 2的输出交由grep处理：

       grep -v "./"
   将把匹配”./“的记录滤掉,如”./configure"这样的不在PATH中的命令
1. 将step 3的输出用column命令格式化对齐。
1. 然后用sort命令排序，-n选项指定按照数字排序，-r指定倒序排序
1. 用nl命令加上行号
1. 用head命令取前10条记录输出

###Reference
* <http://www.linux.gov.cn/shell/awk.htm>
* <http://www.gnu.org/software/gawk/manual/gawk.html#Using-BEGIN_002fEND>
* [awk数组](http://www.thegeekstuff.com/2010/03/awk-arrays-explained-with-5-practical-examples/)
