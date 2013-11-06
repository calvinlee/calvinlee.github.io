---
layout: post
title: "WebView.clearHistory()的问题"
category: Android
tags: [android]
---

###Q:
I call WebView.clearHistory(), but I am still able to go back after
doing so. I want to reuse a WebView, but I don't want the back button
to allow the user to go back further than the current "session" of
using the WebView. Anybody know what is the best way to handle this? I
thought for sure that clearHistory() would do it.

###A:
I recently had the same issue. What I found is that you have to clear
history AFTER the (first) page loads. It appears that the history
clears everything before the current page so if your browser is at
page "A", you clear history and navigate to page "B" your history will
be "A" "B", not just "B", but if you clear history when "B" finishes
loading you will have only "B".
In my case I end up using "onPageFinished" method of the
WebViwClient, but in this case you have to know what your start page
is and clear the history only after it otherwise you will be clearing
the history after every page navigated after the first.
Stefan 
