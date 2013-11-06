---
layout: post
title: "拉风的vim保存方法"
category: 
tags: [命令]
---

用vim编辑root用户的文件时，经常忘了敲sudo，结果保存不了。一个work around是保存为一个临时文件，然后sudo cp回去，不过从现在开始，我们可以这样做，输入：

    :w !sudo tee %

%代表当前编辑文件的文件路径，`tee %`表示把stdin的输入输入到stdout，同时保存到一个文件。  
`w !{cmd}`意思是说执行一个外部命令cmd，同时把当前缓冲区的内从通过管道连接到cmd的stdin。  
