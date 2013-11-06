---
layout: post
title: "multipart/form-data与application/x-www-form-urlencoded"
category: Http
tags: [http]
---

在浏览器上提交表单时，根据提交的方式，get或者post，表单数据被封装进url或者http头中，这是http请求的Content-Type字段值默认为`application/x-www-form-urlencoded`。

    POST /upload HTTP/1.1
    Host: localhost:8080
    Origin: http://localhost:8080
    User-Agent: Mozilla/5.0 (X11; U; Linux x86_64; en-us) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/531.2+
    Accept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
    Referer: http://localhost:8080/
    Content-Type: application/x-www-form-urlencoded
    Accept-Encoding: gzip
    Cookie: JSESSIONID=18DE3AD950262E1EDA9A453A8C3BF430
    Content-Length: 14

    username=scott

    HTTP/1.1 
    200 OK
    Server: Apache-Coyote/1.1
    Content-Length: 0
    Date: Wed, 06 Jun 2012 06:31:20 GMT

这种情况下在服务器端使用`request.getParameter("username")`就可以取出scott这个值。

当需要通过表单上传文件时，这时enctype必须为`multipart/form-data`或者`multipart/mixed`。比如：

    <form method="post" action="upload"
    	enctype="multipart/form-data">
    		<input type="file" name="upload_file"/>
            <input type="text" name="username"/>
    		<input type="submit" value="Submit" />
    </form>

这时浏览器会以表单为单位将所有提交数据进行分割，并分隔符boundary分隔:

    POST /upload HTTP/1.1
    Host: localhost:8080
    Origin: http://localhost:8080
    User-Agent: Mozilla/5.0 (X11; U; Linux x86_64; en-us) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/531.2+
    Content-Type: multipart/form-data; boundary=----WebKitFormBoundarysJagkbbAojjjPOh8
    Accept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
    Referer: http://localhost:8080/
    Accept-Encoding: gzip
    Cookie: JSESSIONID=18DE3AD950262E1EDA9A453A8C3BF430
    Content-Length: 33076

    ------WebKitFormBoundarysJagkbbAojjjPOh8
    Content-Disposition: form-data; name="upload_file"; filename="mmssms.db-shm"
    Content-Type: application/octet-stream
    .....
    .....
    ------WebKitFormBoundarysJagkbbAojjjPOh8
    Content-Disposition: form-data; name="username"

    scott
    ------WebKitFormBoundarysJagkbbAojjjPOh8--
    HTTP/1.1 200 OK
    Server: Apache-Coyote/1.1
    Content-Length: 343
    Date: Wed, 06 Jun 2012 06:47:49 GMT

这时在server端就不能用request.getParameter这种方式获取表单数据了，必须对request的数据进行解码。这部分工作已经有现成的库帮我们做了，比如[Apache Common Fileupload](http://commons.apache.org/fileupload/)。

###Reference
<http://zh.wikipedia.org/wiki/MIME>
