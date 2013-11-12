---
layout: post
title: "bind mount的使用"
date: 2013-11-07 18:10
comments: true
categories: [Linux]
tags: [命令]
---

如果你需要暂时修改一个配置文件用来测试，但是这个配置文件是read only的，你不想大费周折，怎么办？这时bind mount就可以派上用场。  

mount命令的常规用法是将一个*块设备*上的文件系统挂载一个指定的路径。而bind选项可以将一个目录挂载到一个指定的路径。

假设我们需要临时修改一下config文件，但是当前用户没有权限修改这个文件：
{% codeblock %}
$ ls /tmp/etc/
total 0
-rw-r----- 1 root root 0 Nov 12 10:38 config
$ sudo cat /tmp/etc/config 
sky=0
{% endcodeblock %} 

现在我们将/tmp/bind\_dir挂载到/tmp/etc：
{% codeblock %}
    $ sudo mount --bind /tmp/bind_dir /tmp/etc
    $ ls /tmp/bind_dir/
    total 0
    $ ls /tmp/etc/
    total 0
{% endcodeblock %} 
现在/tmp/bind\_dir被挂载到了/tmp/etc，也就是说访问/tmp/etc实际上是访问的是/etc/bind\_dir目录。现在我们可以往/tmp/etc目录写入我们想要的修改：

{% codeblock %}
    $ touch /tmp/etc/config
    $ echo "tmp=1" >> /tmp/etc/config
    $ cat /tmp/etc/config
    tmp=1
{% endcodeblock %} 

现在就达到了修改/tmp/etc/config的目的，可以执行测试。测试完毕后，执行umount：
{% codeblock %}
$ sudo umount /tmp/etc/
{% endcodeblock %} 

/tmp/etc目录下的内容没有变化：
{% codeblock %}
$ sudo umount /tmp/etc/
$ ls /tmp/etc/
total 4.0K
-rw-r----- 1 root root 6 Nov 12 10:41 config
$ sudo cat /tmp/etc/config
sky=0
{% endcodeblock %} 

mount的过程实际上是inode被替换的过程，这里我们将/tmp/bind\_dir挂载到/tmp/etc上，实际上的实现过程是将/tmp/etc的dentry目录项所指向的inode重定向到/tmp/bind\_dir的inode索引节点，也就是说让/tmp/bind\_dir和/tmp/etc指向同一个inode节点：
{% codeblock %}
$ ls -lid /tmp/bind\_dir/ /tmp/etc/
1094756 drwxrwxr-x 2 calvin calvin 4.0K Nov 12 10:47 /tmp/bind\_dir/
1094756 drwxrwxr-x 2 calvin calvin 4.0K Nov 12 10:47 /tmp/etc/
{% endcodeblock %} 
可见两个路径都指向了1094756的inode索引节点。

另外几个应用bind mount的例子：  
* <http://docs.1h.com/Bind\_mounts>  
* <http://backdrift.org/how-to-use-bind-mounts-in-linux>  

#Reference
[ext3 mount过程](http://alanwu.blog.51cto.com/3652632/1105681)
