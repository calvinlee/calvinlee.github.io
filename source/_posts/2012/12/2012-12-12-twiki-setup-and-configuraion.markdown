---
layout: post
title: "UpdateMe"
category: 
tags: []
published: false
---

Ldap configure:
ObjectClass=\*

Create new web

http://www.john-am.com/2011/01/configuring-ldap-with-twiki/

Here is my cron.daily script to update the Ldap entries:

    #!/bin/sh # # cd /var/www/twiki/bin && ./view refreshldap=on Main/WebHome >/dev/null chown www-data:www-data /var/www/twiki/working/work_areas/* -R >/dev/null 

多语言支持：
http://twiki.org/cgi-bin/view/TWiki/InstallationWithI18N
http://twiki.org/cgi-bin/view/Codev/UnderstandingEncodings
