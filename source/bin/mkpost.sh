#!/bin/bash
# Calvin.Lee<lihao921@gmail.com> @ Sun Mar 25 15:46:20 CST 2012
#
# Helper script that creates new template posts.

POST_DIR=./_posts
MARKDOWN_EXT=.md

usage() {
    echo "usage: $0 -t title [-d date]"
    exit 1
}

while getopts ":t:d:" flag
do
  case $flag in
    t) POST_TITLE=$OPTARG;;
    d) POST_DATE=$OPTARG;;
    *) usage
  esac
done

# POST_TITLE may have spaces
if [[ -z $POST_TITLE ]]; then
    echo "You must tell me the post title!"
    usage
    exit 1
fi

if [ $POST_DATE ]; then
    if date --date="$POST_DATE" "+%Y-%m-%d" > /dev/null 2>&1 ; then
        POST_DATE=$(date --date="$POST_DATE" "+%Y-%m-%d")
    else
        echo "Error - invalid date format, please check you typed it correctly!"
        exit 1
    fi
else
    POST_DATE=$(date "+%Y-%m-%d")
fi

# trim spaces and replace extra spaces with -
POST_TITLE=$(echo $POST_TITLE|tr -s " "|sed 's/^[ ]//g'|sed 's/ /-/g')

YEAR=${POST_DATE:0:4}
MONTH=${POST_DATE:5:2}
mkdir -p $POST_DIR/$YEAR/$MONTH

POST_PATH=$POST_DIR/$YEAR/$MONTH/$POST_DATE-$POST_TITLE$MARKDOWN_EXT
if [ -e $POST_PATH ]; then
    echo "$POST_PATH already exists!"
    exit 1
fi

cat > $POST_PATH <<EOF
---
layout: post
title: "UpdateMe"
category: 
tags: []
---
{% include JB/setup %}

EOF

echo "Created new post $POST_PATH"

if [ `which gvim` ]; then
    # set line number and put cursor at UpdateMe
    gvim "+set nu" "+call cursor(3,9)" $POST_PATH
fi
exit 0
