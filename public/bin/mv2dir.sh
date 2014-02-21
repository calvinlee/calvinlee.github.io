#!/bin/bash
# Calvin.Lee<lihao921@gmail.com> @ Sun Mar 25 15:53:25 CST 2012
# A little script that helps me re-organize my posts.

POST_DIR=../_posts

for post in $POST_DIR/*; 
do 
    if [ -f $post ]; then 
        date=$(echo $post|grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}')
        year=`date -d $date "+%Y" 2>/dev/null`;
        month=`date -d $date "+%m" 2>/dev/null`;
        if [ $year ]; then
            mkdir -p $POST_DIR/$year/$month
            mv $post $POST_DIR/$year/$month
            echo "moved $post to directory $POST_DIR/$year/$month"
        fi
    fi 
done
