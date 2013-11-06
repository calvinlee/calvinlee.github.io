---
layout: post
title: "使用Github Pages创建个人博客"
category: 
tags: [github]
---

## Github pages 是什么？
Github pages借助 git 工具和Jekyll（一个静态网站生成器），使得你可以将内容push到github，然后通过Jekyll发布成个人blog站点。通过github pages创建个人博客，至少有几个好处：

* 文章内容使用markdown标记语言书写，你可以使用任何你喜欢的文本编辑器编辑文章。
* 由于git的存在，你可以轻松的对你的文章进行版本控制。
* 尤其重要的一点，在天朝，你无需担心哪天你的站点被无端屏蔽，还得爬墙过去抢救数据--因为你本地就有一套完整的站点，而且都是文本格式，非常易于备份。

## 搭建步骤
### 创建github帐号
首先，你需要一个github帐号。
登录github后，创建一个USERNAME.github.com的repository，根据向导生成pages。

### 安装本地环境
你需要在本地搭建运行环境，这样在编写文章的时候你可以在本地进行充分的调整，满意后再push到github。
以下基于Ubuntu 10.04LTS系统安装，需要安装的包包括Ruby，RubyGems，jekyll和rake。

    $ sudo apt-get install ruby1.9.1-full rubygems1.9.1
然后通过gem命令安装jekyll

    $ sudo gem install jekyll
    WARNING:  You don't have /home/calvin/.gem/ruby/1.9.1/bin in your PATH,
    	  gem executables will not run.
    ERROR:  Error installing jekyll:
    	liquid requires RubyGems version >= 1.3.7

安装会出错，提示RubyGems版本过低。这时候需要到<http://packages.ubuntu.com/maverick/all/rubygems1.8/download> 下载离线安装包安装：

    $ sudo dpkg -i Downloads/rubygems1.8_1.3.7-2_all.deb
安装完成后查看gem版本：

    $ which gem
    /usr/bin/gem
    $ gem -v
    1.3.7

这时候可以继续安装jekyll了：

    $ sudo gem install jekyll

安装jekyll后还需要安装rake工具，通过rake工具可以用来创建新的文章和页面，安装主题等等，十分方便。

    $ sudo apt-get install rake
通过rake -T命令可以查看所有可用命令：

    $ rake -T
    (in /home/calvin/development/github/calvinlee.github.com)
    rake page           # Create a new page.
    rake post           # Begin a new post in ./_posts
    rake preview        # Launch preview environment
    rake theme:install  # Install theme
    rake theme:package  # Package theme
    rake theme:switch   # Switch between Jekyll-bootstrap themes.

### 安装Jekyll Bootstrap
由于jekyll仅仅是一个静态html的生成器，它不包含任何页面的templates，所以如果从头开始构建你的博客站点的话，还将要有很多工作要做。幸好，[Jekyll Bootstrap](http://jekyllbootstrap.com/)已经提供了一套基本的构架，我们只需要在它的基础上定制，使之符合你口味即可。

    $ git clone https://github.com/plusjade/jekyll-bootstrap.git USERNAME.github.com
    $ cd USERNAME.github.com
    $ git remote set-url origin git@github.com:USERNAME/USERNAME.github.com.git
    $ git push origin master

### 开始个性博客之旅
首先在本地启动jekyll：

    $ /var/lib/gems/1.8/gems/jekyll-0.11.2/bin/jekyll --server
然后你可以访问http://localhost:4000查看Jekyll Bootstrap给你提供了什么，之后你就可以开始写你的文章了。

    $ rake post title="my-first-post-on-git-pages" date="2012-03-02"
rake工具会为你生成posts/2012-03-02-my-first-post-on-git-pages.md
你可以开始使用markdown标记语言编辑文章了！

### 发布
发布很简单，直接将文章内容推送到github即可，如果你修改了页面主题或者布局，也一并推送：

    $ git add .
    $ git commit -m "Add new post"
    $ git push origin master

现在你就可以通过http://USERNAME.github.com访问你的页面了。

### Reference
* [详尽的Markdown语法](http://daringfireball.net/projects/markdown/syntax)
* [另外一篇Markdown简介](http://www.pushiming.com/blog/2010/11/tips-on-markdown/)
* [Jekyll wiki](https://github.com/mojombo/jekyll/wiki/) 
* [这里](https://github.com/mojombo/jekyll/wiki/Sites)是一些站点，有些是开放源代码的，你可以参照学习
* [怎样对文章进行分页？](https://github.com/mojombo/jekyll/wiki/Pagination)
* <http://www.pizn.net/24-09-2011/use-github-pages-to-build-a-blog/>
* <http://www.yangzhiping.com/tech/writing-space.html>
* <http://fastr.github.com/articles/Documenting-with-Jekyll.html>
