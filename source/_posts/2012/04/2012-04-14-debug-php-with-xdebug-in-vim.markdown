---
layout: post
title: "VIM+Xdebug调试php"
category: 
tags: [vim, php]
---

1. 安装Xdebug

        sudo apt-get install php5-xdebug

2. 配置Xdebug
编辑/etc/php5/apache2/conf.d/xdebug.ini，加入

        xdebug.remote_enable = 1
        xdebug.remote_port = 9000
        xdebug.remote_host = localhost

3. 安装vim插件DBGp
下载页面： <http://www.vim.org/scripts/script.php?script_id=1929>
下载后放入plugins目录中即可。

4. 在浏览器中打开要调试的php页面,在URL后加上`?XDEBUG_SESSION_START=1`参数
用vim打开此文件，用:Bp 设置断点，然后安 F5 键，vi会提示 waiting for a new connection on port 9000 for 5 seconds… ，此时在5秒内刷新刚才那个页面，即可在vim中看到调试界面。
如果出现 AttributeError("DbgProtocol instance has no attribute 'stop'", 则说明没有配置成功，要么是 xdebug.remote_* 没有配置好，要么是url尾部上没有加入 ?XDEBUG_SESSION_START=1 ，要么是你没有在5秒内刷新页面 .

5. 在获取变量内容时，如果变量为 array ，那么默认只会显出 (array) ，而不会显示数组内的各元素，如果无法显示数组元素内容，那么调试会遇到很多问题，因此可以根据 debugger.vim 中的注释，自行在 .vimrc 中加上如下一行：

        let g:debuggerMaxDepth = 5

更多的配置，可以依次类推，都在debugger.vim中有所说明。

Reference:  
<http://lds2008.blogbus.com/logs/115127244.html>
