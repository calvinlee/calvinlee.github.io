---
layout: post
title: "Android消息处理机制理解"
category: Android
tags: [android]
toc: true
---

Android的消息处理机制是很多功能实现的基础，如UI绘制，键盘事件传递等等。在实现上，涉及到的类有Handler, Message, Looper等等，本篇研究Android消息处理机制的内部实现细节。

#UI线程消息循环的启动
Android所谓UI线程的启动位于ActivityThread.java，在其main方法中会启动这个消息循环：

{% codeblock lang:java %}
public static void main(String[] args) {
    ...

    Looper.prepareMainLooper();
    if (sMainThreadHandler == null) {
        sMainThreadHandler = new Handler();
    }

    ActivityThread thread = new ActivityThread();
    thread.attach(false);

    Looper.loop();
}
{% endcodeblock %}

首先调用`Looper.prepareMainLooper()`方法：

{% codeblock lang:java %}
    /**
     * Initialize the current thread as a looper, marking it as an
     * application's main looper. The main looper for your application
     * is created by the Android environment, so you should never need
     * to call this function yourself.  See also: {@link #prepare()}
     */
    public static void prepareMainLooper() {
        prepare();
        setMainLooper(myLooper());
        // main looper是不允许退出的，否则应用程序就没得玩了
        myLooper().mQueue.mQuitAllowed = false;
    }

     /** Initialize the current thread as a looper.
      * This gives you a chance to create handlers that then reference
      * this looper, before actually starting the loop. Be sure to call
      * {@link #loop()} after calling this method, and end it by calling
      * {@link #quit()}.
      * 
      * prepare方法将实例化一个Looper对象，并保存到一个ThreadLocal变量里, 这个
      * looper稍后可以通过myLooper()方法取出
      */
    public static void prepare() {
        if (sThreadLocal.get() != null) {
            throw new RuntimeException("Only one Looper may be created per thread");
        }
        sThreadLocal.set(new Looper());
    }

    private Looper() {
        // 初始化一个消息队列，其实现稍后解释
        mQueue = new MessageQueue();
        mRun = true;
        mThread = Thread.currentThread();
    }
{% endcodeblock %}

接下来调用Looper.loop()启动消息循环：

    /**
     * Run the message queue in this thread. Be sure to call
     * {@link #quit()} to end the loop.
     */
    public static void loop() {
        // 取得当前线程关联的looper对象
        Looper me = myLooper();
        if (me == null) {
            throw new RuntimeException("No Looper; Looper.prepare() wasn't called on this thread.");
        }
        MessageQueue queue = me.mQueue;
        ...
        while (true) {
            // 从消息队列中取出下一个需要处理的消息，这里可能会阻塞
            Message msg = queue.next(); // might block
            if (msg != null) {
                if (msg.target == null) {
                    // No target is a magic identifier for the quit message.
                    return;
                }
                ...
                msg.target.dispatchMessage(msg);
                ...
                msg.recycle();
            }
        }
    }

#消息队列的建立
每一个looper对象对应一个MessageQueue对象，Looper对象在这个消息队列上loop。每个消息是一个Message对象，而对这个消息队列的引用也是一个Message对象：

    Message mMessages;

每个Message对象内部也有一个Message对象的引用，指向队列中的下一个message对象，这些message形成了一个单向队列。**这个队列是按照message.when的大小顺序排列的**。队首的消息是最先发生的。

MessageQueue另外还有一个重要的变量：

    private int mPtr; // used by native code

每个MessageQueue在native层对应有一个C++的实现NativeMessageQueue，位于android\_os\_MessageQueue.cpp，Java层的MessageQueue的mPtr保存的就是这个对象的指针。

MessageQueue的构造方法为：

    MessageQueue() {
        nativeInit();
    }

nativeInit()方法在android\_os\_MessageQueue.cpp中实现：

    static void android_os_MessageQueue_nativeInit(JNIEnv* env, jobject obj) {
        NativeMessageQueue* nativeMessageQueue = new NativeMessageQueue();
        if (! nativeMessageQueue) {
            jniThrowRuntimeException(env, "Unable to allocate native queue");
            return;
        }
 
        // 将指针值设置给Java层MessageQueue的mPtr变量
        android_os_MessageQueue_setNativeMessageQueue(env, obj, nativeMessageQueue);
    }

NativeMessageQueue没有太多逻辑实现，它作为C++层的Looper对象的包装类。

C++层的Looper对象实现为framework/base/libs/utils/Looper.cpp:

    Looper::Looper(bool allowNonCallbacks) :
           mAllowNonCallbacks(allowNonCallbacks), mSendingMessage(false),
           mResponseIndex(0), mNextMessageUptime(LLONG_MAX) {
       int wakeFds[2];
       int result = pipe(wakeFds);
       LOG_ALWAYS_FATAL_IF(result != 0, "Could not create wake pipe.  errno=%d", errno);

       mWakeReadPipeFd = wakeFds[0];
       mWakeWritePipeFd = wakeFds[1];

       result = fcntl(mWakeReadPipeFd, F_SETFL, O_NONBLOCK);
       LOG_ALWAYS_FATAL_IF(result != 0, "Could not make wake read pipe non-blocking.  errno=%d",
               errno);

       result = fcntl(mWakeWritePipeFd, F_SETFL, O_NONBLOCK);
       LOG_ALWAYS_FATAL_IF(result != 0, "Could not make wake write pipe non-blocking.  errno=%d",
               errno);

       // Allocate the epoll instance and register the wake pipe.
       mEpollFd = epoll_create(EPOLL_SIZE_HINT);
       LOG_ALWAYS_FATAL_IF(mEpollFd < 0, "Could not create epoll instance.  errno=%d", errno);

       struct epoll_event eventItem;
       memset(& eventItem, 0, sizeof(epoll_event)); // zero out unused members of data field union
       eventItem.events = EPOLLIN;
       eventItem.data.fd = mWakeReadPipeFd;
       result = epoll_ctl(mEpollFd, EPOLL_CTL_ADD, mWakeReadPipeFd, & eventItem);
       LOG_ALWAYS_FATAL_IF(result != 0, "Could not add wake read pipe to epoll instance.  errno=%d",
               errno);
    }

这里先通过pipe系统调用创建了一个管道，这个管道非常重要：  
当当前线程没有新的消息需要处理时，它会睡眠在管道的读端文件描述符上，直到有新消息到来为止；另一方面，当其他线程向这个线程的消息队列发送一个消息后，其他线程会在这个管道的写端文件描述符上写入数据，这样导致等待在读端文件描述符的looper唤醒，然后对消息队列中的消息进行处理。但是，它对其他线程写入写端文件描述符的数据是什么并不关心，因为这些数据仅仅是为了唤醒它而已。

#开启消息循环
调用Looper.loop()开启消息循环，前面看到，loop()方法从next()#MessageQueue获取下一个待处理的消息：

    final Message next() {
        int pendingIdleHandlerCount = -1; // -1 only during first iteration
        int nextPollTimeoutMillis = 0;

        for (;;) {
            if (nextPollTimeoutMillis != 0) {
                Binder.flushPendingCommands();
            }

            // 这个方法可能会阻塞，一旦返回，说明有新的message可以处理了，第一次进来nextPollTimeoutMillis为0，表示不作等待，立即返回。
            nativePollOnce(mPtr, nextPollTimeoutMillis);

            synchronized (this) {
                // Try to retrieve the next message.  Return if found.
                final long now = SystemClock.uptimeMillis();
                final Message msg = mMessages;
                if (msg != null) {
                    final long when = msg.when;
                    // 如果队首的消息的when小于当前时间，说明这个消息已经过期了，需要马上处理。
                    if (now >= when) {
                        mBlocked = false;
                        mMessages = msg.next;
                        msg.next = null;
                        if (false) Log.v("MessageQueue", "Returning message: " + msg);
                        msg.markInUse();
                        return msg;
                    } else {
                        // 计算出还要睡眠多长时间以后再取出下一个消息
                        nextPollTimeoutMillis = (int) Math.min(when - now, Integer.MAX_VALUE);
                    }
                } else {
                    nextPollTimeoutMillis = -1;
                }

                ...

            // While calling an idle handler, a new message could have been delivered
            // so go back and look again for a pending message without waiting.
            nextPollTimeoutMillis = 0;
        }
    }

`nativePollOnce(mPtr, nextPollTimeoutMillis);` 方法用来检查当前线程的消息队列是否有新的消息需要处理, nextPollTimeoutMillis表示如果没有发现新的消息，当前线程需要睡眠的时间，如果等于-1，表示它需要进入无限睡眠，直到被其他线程唤醒为止。

nativePollOnce函数在C++层的Looper对象的实现为pollOnce()，进而调用pollInner():

    int Looper::pollInner(int timeoutMillis) {
        // Poll.
        int result = ALOOPER_POLL_WAKE;
        mResponses.clear();
        mResponseIndex = 0;

        int eventCount = epoll_wait(mEpollFd, eventItems, EPOLL_MAX_EVENTS, timeoutMillis);
        ...
        // 检查是哪个文件描述符上发生了IO事件
        for (int i = 0; i < eventCount; i++) {
            int fd = eventItems[i].data.fd;
            uint32_t epollEvents = eventItems[i].events;
            if (fd == mWakeReadPipeFd) {
                if (epollEvents & EPOLLIN) {
                    awoken();
                } else {
                    LOGW("Ignoring unexpected epoll events 0x%x on wake read pipe.", epollEvents);
                }
            } else {
            ...
            }
        }
        return result;
    }

如果是mWakeReadPipeFd上发生了IO事件，说明有其它线程在mWakeWritePipeFd上写入了数据，接下来在awoken()函数中读取这些数据，这样在后续有线程写入数据时可以被再次唤醒：

    void Looper::awoken() {
        ... 
        char buffer[16];
        ssize_t nRead;
        do {
            nRead = read(mWakeReadPipeFd, buffer, sizeof(buffer));
        } while ((nRead == -1 && errno == EINTR) || nRead == sizeof(buffer));
    }

这里只是将数据读出，它并不关心这些数据是什么。

#消息发送过程
发送消息最常见的方法就是使用sendMessage()#Handler, 这个方法最终会调用enqueueMessage()#MessageQueue.java:

    final boolean enqueueMessage(Message msg, long when) {

            msg.when = when;
            //Log.d("MessageQueue", "Enqueing: " + msg);
            Message p = mMessages;
            if (p == null || when == 0 || when < p.when) {
                msg.next = p;
                mMessages = msg;
                needWake = mBlocked; // new head, might need to wake up
            } else {
                Message prev = null;
                while (p != null && p.when <= when) {
                    prev = p;
                    p = p.next;
                }
                msg.next = prev.next;
                prev.next = msg;
                needWake = false; // still waiting on head, no need to wake up
            }
        }
        if (needWake) {
            nativeWake(mPtr);
        }
        return true;
    }

这个方法将新的message插入到消息队列中，并根据需要唤醒native的looper线程。消息的插入分为四种情况：

* 消息队列是一个空队列；
* 新消息的when等于0，表示需要立即处理；
* 新消息的when小于队首消息的when；
* 新消息的when大于或者等于队首消息的when；

前三种情况只需要将新消息插入到队首即可，并需要立即唤醒looper对这个新消息进行处理。第四种情况需要插入到队列中的合适位置，并且不需要唤醒looper。  
唤醒looper通过nativeWake()方法实现：
looper.cpp:

    void Looper::wake() {
        ssize_t nWrite;
        do {
            nWrite = write(mWakeWritePipeFd, "W", 1);
        } while (nWrite == -1 && errno == EINTR);
    
        if (nWrite != 1) {
            if (errno != EAGAIN) {
                LOGW("Could not write wake signal, errno=%d", errno);
            }
        }
    }

唤醒的过程就是望管道的写文件描述符mWakeWritePipeFd写入一些数据即可，这里写入了一个"W"字符，这样等待在管道另一端的正在睡眠的线程就会被唤醒，从而导致队首的消息被取出进行处理。

#HanderThread
HandlerThread最重要的特点是它的looper是在一个子线程中loop的，从而不会阻塞UI线程。
