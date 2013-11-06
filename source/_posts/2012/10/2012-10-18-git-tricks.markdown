---
layout: post
title: "Git tips and tricks"
category: Git
tags: [git]
---

###在提交历史中查找指定文本

    git log -G'password' --all
or
    git rev-list --all | (
    while read revision; do
        git grep -F 'password' $revision
    done
    )
or

    for revision in `git rev-list --all`; 
    do
        git grep -F 'password' $revision;
    done

or 
`git log -S'bad\_code' path/to/file ` 查看指定代码片段在哪个版本出现过。
`git blame path/to/file`: 查看指定文件的每一行的最后修改时间是在哪个版本，但不能查看删除的行或者被替换的行
参见man git-blame.

###git commit
`git commit -c <commit>`  reedit commit message of <commit>
`git commit -C <commit>`  reuse commit message of <commit>

###git底层命令
git ls-tree  
git write-tree  
git ls-files  
git cat-file  
git rev-parse  

.git/refs 保存所有引用的命名空间
.git/refs/heads 所有的本地分支

git commit --allow-empty --amend

[TODO] strace命令


.git/index 包含文件索引的目录树，记录了文件名和文件的状态信息，文件的内容存储在.git/objects中，文件索引建立了文件和对象库中的文件对象之间的对应关系。

git checkout . / git checkout -- <file>  
丢弃workspace中的内容，保留暂存区的内容  

git checkout HEAD . / git checkout HEAD <file>  
用HEAD指向的commit中的内容替代workspace和暂存区的内容，这将导致当前workspace和暂存区的内容被丢弃。  

###使用git reflog挽回错误的reset
git reflog  
git reflog show master

分支的变更记录都会被记录在.git/logs/refs下，通过 git reflog命令可以获得分支的历史变更记录，然后可以通过git reset 命令将HEAD任意重置到任意一个提交。

