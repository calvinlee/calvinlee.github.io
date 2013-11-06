---
layout: post
title: "VIM heredoc格式化问题"
category: 
tags: [vim]
---

在VIM下使用gg=G格式化shell代码时，如果代码中有heredoc，经过格式化后会造成代码运行失败。如下：

    do
        echo "Deploying..."
        ssh $USER@$HOST <<-EOF
    cd testdir
    mv client client-bak-`date +%Y%m%d`
    tar zxf `basename $TARGET_DEPLOY_ZIP` -C .
    exit
    EOF
        echo ""

格式化后会成这样：

    do
        echo "Deploying..."
        ssh $USER@$HOST <<-EOF
         cd testdir
         mv client client-bak-`date +%Y%m%d`
         tar zxf `basename $TARGET_DEPLOY_ZIP` -C .
         exit
        EOF
        echo ""
    done

vim对heredoc的代码进行了缩进（四个空格），这样会导致执行出错。

解决：修改vim格式化shell脚本的规则，格式化时忽略heredoc。  
将[这个](http://vim.1045645.n5.nabble.com/bash-heredoc-in-a-for-loop-indented-incorrectly-td1177006.html)脚本保存到.vim/indent/sh.vim(摘录至此): 

    " Vim indent file
    " Language:    Shell Script
    " Maintainer:       Nikolai Weibull <[hidden email]>
    " Latest Revision:  2006-04-19
    
    if exists("b:did_indent")
      finish
    endif
    let b:did_indent = 1
    
    setlocal indentexpr=GetShIndent()
    setlocal indentkeys+==then,=do,=else,=elif,=esac,=fi,=fin,=fil,=done,=EOF,=END
    setlocal indentkeys-=:,0#
    
    if exists("*GetShIndent")
      finish
    endif
    
    let s:cpo_save = &cpo
    set cpo&vim
    
    function GetShIndent()
      let lnum = prevnonblank(v:lnum - 1)
      if lnum == 0
        return 0
      endif
    
      " Add a 'shiftwidth' after if, while, else, case, until, for, function()
      " Skip if the line also contains the closure for the above
      let ind = indent(lnum)
      let line = getline(lnum)
      if line =~ '^\s*\(if\|then\|do\|else\|elif\|case\|while\|until\|for\)\>'
            \ || line =~ '^\s*\<\k\+\>\s*()\s*{'
            \ || line =~ '^\s*{'
        if line !~ '\(esac\|fi\|done\)\>\s*$' && line !~ '}\s*$'
          let ind = ind + &sw
        endif
      endif
    
      if line =~ '^.*<<.*\(EOF\|END\)'
        let ind = 0
      endif
      if line =~ '^"\?\(EOF\|END\)"\?$'
        let ind = indent(search('>.*EOF', 'b'))
      endif
      " Subtract a 'shiftwidth' on a then, do, else, esac, fi, done
      " Retain the indentation level if line matches fin (for find)
      let line = getline(v:lnum)
      if (line =~ '^\s*\(then\|do\|else\|elif\|esac\|fi\|done\)\>' || line =~ '^\s*}')
            \ && line !~ '^\s*fi[ln]\>'
        let ind = ind - &sw
      endif
    
      return ind
    endfunction
    
    let &cpo = s:cpo_save
    unlet s:cpo_save 

不过delimiter只能是EOF或者END。
