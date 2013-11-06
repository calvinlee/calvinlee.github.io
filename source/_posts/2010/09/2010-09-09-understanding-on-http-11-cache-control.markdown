---
layout: post
title: "HTTP/1.1 Cache-Control的理解"
category: HTTP
tags: [http, 转载]
---

网页的缓存是由HTTP消息头中的“Cache-control”来控制的，常见的取值有
* private
* no-cache
* max-age
* must-revalidate

等，默认为private。其作用根据不同的重新浏览方式分为以下几种情况：

（1） 打开新窗口  
如果指定cache-control的值为private、no-cache、must-revalidate，那么打开新窗口访问时都会重新访问服务器。而如果指定了max-age值，那么在此值内的时间里就不会重新访问服务器，例如：

    Cache-control: max-age=5
表示当访问此网页后的5秒内再次访问不会向服务器发起请求

（2） 在地址栏输入地址回车  
如果值为private或must-revalidate，则只有第一次访问时会访问服务器，以后就不再访问。如果值为no-cache，那么每次都会访问。如果值为max-age，则在过期之前不会重复访问。

（3） 按后退按扭  
如果值为private、must-revalidate、max-age，则不会重访问，而如果为no-cache，则每次都重复访问

（4） 按刷新按扭  
无论为何值，都会重复访问

cache-control字段取值含义：
[![/images/http_cache_control.jpg](/images/http_cache_control.jpg)](/images/http_cache_control.jpg)

Reference:  
<http://www.blogjava.net/dashi99/archive/2008/12/30/249207.html>
