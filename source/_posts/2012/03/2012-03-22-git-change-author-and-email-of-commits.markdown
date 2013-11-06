---
layout: post
title: "更改git提交历史信息"
category: Git
tags: [git]
---

如果你使用git进行版本控制，不知道你有没有遇到这种情况，提交了几个commit后发现你本地git库的author和email信息配置不是你预想的，这时你想要更新已经提交的commit的author和email信息，怎么办？  
这是stackoverflow上给出的[做法](http://stackoverflow.com/questions/750172/how-do-i-change-the-author-of-a-commit-in-git)：

    #!/bin/sh
    
    git filter-branch --env-filter '
    
    an="$GIT_AUTHOR_NAME"
    am="$GIT_AUTHOR_EMAIL"
    cn="$GIT_COMMITTER_NAME"
    cm="$GIT_COMMITTER_EMAIL"
    
    if [ "$GIT_COMMITTER_EMAIL" = "your@email.to.match" ]
    then
        cn="Your New Committer Name"
        cm="Your New Committer Email"
    fi
    if [ "$GIT_AUTHOR_EMAIL" = "your@email.to.match" ]
    then
        an="Your New Author Name"
        am="Your New Author Email"
    fi
    
    export GIT_AUTHOR_NAME="$an"
    export GIT_AUTHOR_EMAIL="$am"
    export GIT_COMMITTER_NAME="$cn"
    export GIT_COMMITTER_EMAIL="$cm"
    '
原文在[这里](http://help.github.com/change-author-info/)。

但是问题是，更新本地的提交历史信息后，想要把更新push到远程分支上去，出现non-fast-forward错误，意思是要推送的提交并非继远程版本库最新提交之后的提交，推送会造成覆盖远程仓库的提交。

    $ git push origin master
     ! [rejected]        master -> master (non-fast-forward)
    error: failed to push some refs to 'example.git'
    To prevent you from losing history, non-fast-forward updates were rejected
    Merge the remote changes (e.g. 'git pull') before pushing again.  See the
    'Note about fast-forwards' section of 'git push --help' for details.

使用--force选项进行强制push即可： `git push --force origin master`，但是这样会覆盖远程分支上的commit:

    -f, --force
        Usually, the command refuses to update a remote ref that is not an ancestor of the local ref used to overwrite it. This flag disables the
        check. This can cause the remote repository to lose commits; use it with care.

###另一种方法
使用`git rebase -i` 到你想更改的commit的前一个commit，选择reword选项，然后依次重新提交，这时提交的author和email将会是你本地配置的author和email，rebase完成后commit的author和email信息就更新了。
