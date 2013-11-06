---
layout: post
title: "strcpy和memcpy的区别"
category: C语言
tags: [C语言]
---

今天被问到strcpy和memcpy的区别，一时语塞，于是研究一下记录下来。

###strcpy

       #include <string.h>
       char *strcpy(char *dest, const char *src);

它的作用是将src指向的字符串，包括最后的'\0'，拷贝到dest指向的字符串。它的一个简单实现如下：

           char*
           strncpy(char *dest, const char *src, size_t n){
               size_t i;

               for (i = 0 ; i < n && src[i] != '\0' ; i++)
                   dest[i] = src[i];
               for ( ; i < n ; i++)
                   dest[i] = '\0';

               return dest;
           }

也就是说，strcpy会从头开始依次拷贝每个字符，但是一旦遇到了空字符NULL（'\0'），strcpy就会停止拷贝。

###memcpy

       #include <string.h>
       void *memcpy(void *dest, const void *src, size_t n);

memcpy用来进行内存拷贝，它将src指向的地址后的n个字节拷贝到dest开始的内存里，可以用它拷贝任何内型的数据对象。

----
以下是stackoverflow上的一个demo，它清楚的显示了这两个函数的区别：

    void dump5(char *str);
    
    int main()
    {
        char s[5]={'s','a','\0','c','h'};
    
        char membuff[5]; 
        char strbuff[5];
        memset(membuff, 0, 5); // init both buffers to nulls
        memset(strbuff, 0, 5);
    
        strcpy(strbuff,s);
        memcpy(membuff,s,5);
    
        dump5(membuff); // show what happened
        dump5(strbuff);
    
        return 0;
    }
    
    void dump5(char *str)
    {
        char *p = str;
        for (int n = 0; n < 5; ++n)
        {
            printf("%2.2x ", *p);
            ++p;
        }
    
        printf("\t");
    
        p = str;
        for (int n = 0; n < 5; ++n)
        {
            printf("%c", *p ? *p : ' ');
            ++p;
        }
    
        printf("\n", str);
    }

结果输出：

    73 61 00 63 68  sa ch
    73 61 00 00 00  sa

可见用strcpy拷贝时，ch被忽略了，但是memcpy也将它拷贝过来了。

详细讨论在[这里](http://stackoverflow.com/questions/2898364/strcpy-v-s-memcpy)。
