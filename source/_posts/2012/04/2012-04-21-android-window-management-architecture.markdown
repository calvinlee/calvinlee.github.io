---
layout: post
title: "Android 窗口管理"
category: Android
tags: [android, window, todo]
published: true
---

###基本概念

* Surface

  Surface就是每个View的画布，View及其子类都要画在surface上。  
  Surface都是双缓冲的，back buffer用来绘制，front buffer用来合成。每个surface对象对应surfaceflinger里面的一个layer，SurfaceFlinger负责将各个layer的front buffer合成（composite），然后将合成后的数据输出到frame buffer驱动并最终绘制到屏幕上。

* Window

  Window可以看作desktop上的window的概念。Window类定义了顶层视图的一些属性以及对这些属性的方法，包括背景，title，一些按键事件处理（如Volume up和Volump down按键在MediaController所属的Window里面被设置位控制媒体音量大小）以及一些其他的window feature，它含有一个window manager对象用来addView，removeView，updateView等等，window manager通过和运行在system\_server进程的window manager service建立联系来实现这些操作。每一个Window都对应一个Surface对象用来渲染添加到window里面的内容。  
  Window的实现为PhoneWindow。

* View

  View是添加到window里面的和用户产生交互的UI控件。View与ViewGroup一起组成了一个树状结构，每一个Window都有一个View的层级树与之关联。这个view的层级树组成了这个window的样式和行为。DecorView作为顶层view被添加到PhoneWindow中。

* SurfaceView

  每个SurfaceView拥有一个独立的Surface对象。

* ViewRoot:
  每一个view的层级树对应一个ViewRoot，也就是说one viewroot per window。每个ViewRoot对象都有一个对应的Surface对象用来绘制UI，当window需要重绘时（比如一个view调用了invalidate()方法），重绘的操作都是这个ViewRoot对应的Surface上进行的。Surface首先被lock住，然后返回一个可供重绘的Canvas，然后在view层级树中遍历，并把这个Canvas对象依次传递给每个View的onDraw方法。重绘结束后这个surface被unlock，然后交由surface finger进行组合。View层级树中的所有view均在这个Canvas对象上绘制。  
  ViewRoot是GUI管理系统与GUI呈现系统之间的桥梁，主要作用有：
    1. 向DecorView分发从WindowManagerService收到的用户发起的event事件，如按键，触屏，轨迹球等事件；
    1. 与WindowManagerService交互，完成整个Activity的GUI的绘制。

[![/images/android-window-architecture.png](/images/android-window-architecture.png)](/images/android-window-architecture.png)


* Bitmap

  Bitmap可以看作是一块数据存储区域，用来存储像素数据。

* Canvas
  每个Canvas底层都对应一个Bitmap对象，Canvas提供了一些绘制图形的接口，比如画直线，画圆，这些方法是在这个bitmap上操作的。

* Paint
  用来描述绘制时使用的颜色，风格等。

* Drawable:
  绘制的基本对象。

以上四种对象构成绘制图形的四个基本元素，如图：

[![/images/android_graphics.png](/images/android_graphics.png)](/images/android\_graphics.png)

###窗口类

[![/images/android-window-class.png](/images/android-window-class.png)](/images/android-window-class.png)

###Activity.attach
* ActivityManagerService.startActivity
    * ActivityThread.performLaunchActivity 
        * Activity.attach
            * PolicyManager.makeNewWindow //实例化一个activity或者dialog或者widget的地方才会make new window
    * ActivityThread.handleResumeActivity
        * WindowManagerImpl.addView //添加DecorView到WindowManager中
            * new ViewRootImpl // 实例化一个ViewRoot对象
                * WindowManagerService.openSession //建立ViewRoot到WMS的通信桥梁
            * ViewRootImpl.setView
                * requestLayout
                * IWindowSession.add // 将这个ViewRoot的IWindow对象（ViewRootImpl.W）添加到WMS中，作为WMS到ViewRoot的通信桥梁
                    * WindowManagerService.addWindow
                * ViewRootImpl.performTraversals //负责绘制View hierarchy，绘制的目的地是对应Surface的back buffer。这个方法总是在UI线程中调用
                    * DecorView.dispatchAttachedToWindow
                        * DecorView.measure
                    * ViewRootImpl.relayoutWindow // 通过WMS创建一个Surface对象，赋值给ViewRoot持有的Surface对象
                        * WindowManagerService.relayoutWindow
                    * DecorView.measure
                    * DecorView.layout
                    * ViewRootImpl.draw // 根据一个dirty的矩形区域决定重绘范围。这里有两种情况：是否使用GL绘制  
                        // 如果不使用GL绘制
                        * Surface.lockCanvas // 传入drity的区域，获取一个bitmap存储区，与一个Canvas对象绑定并返回
                        * Canvas.save
                        * DecorView.draw //绘制View hierarchy tree
                        * Canvas.restoreToCount
                        * Surface.unlockCanvasAndPost

### WindowManagerService.addWindow
* WindowManagerService.addWindow
   * new WindowState
   * WindowState.attach
       * WindowManagerService.Session.windowAddedLocked
           * new SurfaceSession() // Create a new connection with the surface flinger
               * SurfaceSession\_init(android\_view\_Surface.cpp)
                   * new SurfaceComposerClient(android\_view\_Surface.cpp)
                       * onFirstRef(SurfaceComposerClient.cpp)
                           * getComposerService //ComposerService 用于获取SurfaceFlinger服务，它是一个单例，每个进程一个实例
                           * BpSurfaceComposer.createConnection(SurfaceComposerClient.cpp)
                               * SurfaceFlinger.createConnection(SurfaceFlinger.cpp)
                                   * new BnSurfaceComposerClient // 这个client对象接收来自客户端的请求，并转发给SurfaceFlinger, 主要两个接口：createSurface和destroySurface
   * addWindowToListInOrderLocked
   * updateFocusedWindowLocked
   * assignLayersLocked

ComposerService

    class ComposerService : public Singleton<ComposerService>
    {
        //实际对象为BpSurfaceComposer,通过它与SurfaceFlinger进行通信，
        //BnSurfaceComposer是SurfaceFlinger的子类
        sp<ISurfaceComposer> mComposerService;

        //实际对象为BpMemoryHeap,它在SurfaceFlinger中对应为管理一个4096字节的
        //一个MemoryHeapBase对象，在SurfaceFlinger::readyToRun中创建
        sp<IMemoryHeap> mServerCblkMemory;
 
        //为MemoryHeapBase管理的内存在用户空间的基地址，通过mmap而来，
        //具体见MemoryHeapBase::mapfd
        surface_flinger_cblk_t volatile* mServerCblk;
        ComposerService();
        friend class Singleton<ComposerService>;
    public:
        static sp<ISurfaceComposer> getComposerService();
        static surface_flinger_cblk_t const volatile * getControlBlock();
    };
 
    ComposerService::ComposerService()
    : Singleton<ComposerService>() {
        const String16 name("SurfaceFlinger");
        //获取SurfaceFlinger服务，即BpSurfaceComposer对象
        while (getService(name, &mComposerService) != NO_ERROR) {
            usleep(250000);
        }
        //获取shared control block
        mServerCblkMemory = mComposerService->getCblk();
        //获取shared control block 的基地址
        mServerCblk = static_cast<surface_flinger_cblk_t volatile *>(
                mServerCblkMemory->getBase());
    }

这一步的主要作用：  
将新的Window添加到WMS，并为这个Window对象获取一个SurfaceFlinger的代理对象BpSurfaceComposerClient。

###WindowManagerService.relayoutWindow
* WindowManagerService.relayoutWindow
    * WindowManagerService.WindowState.createSurfaceLocked
        * SurfaceComposerClient.createSurface(android\_view\_Surface.cpp)
            * BpSurfaceComposerClient.createSurface // 在上一步已经获得了
                * Client::createSurface(SurfaceFlinger.cpp)
                    * SurfaceFlinger::createSurface
                        * SurfaceFlinger.createNormalSurface
                            * new Layer 
                                * onFirstRef > new SurfaceTextureLayer
                                    * new SurfaceTexture
                                        * SurfaceFlinger::createGraphicBufferAlloc
                                    * new LayerBaseClient(LayerBase.cpp)
                                        * new LayerBase(LayerBase.cpp)
                                * Layer.setBuffers(Layer.cpp) // 为这个layer分配GraphicBuffers
                                    * new SurfaceLayer
                                        * new LayerBaseClient::Surface
                            * SurfaceFlinger.addClientLayer 
                                * BnSurfaceComposerClient.attachLayer
                                * addLayer\_l // 将这个layer加入Z轴
                            * Layer.getSurface
                                * Layer::createSurface(Layer.cpp)
                                    * new BSurface // BSurface实现了ISurface接口
        * new SurfaceControl

[这篇文章](http://blog.csdn.net/myarrow/article/details/7180561)的这张图很好的描述了SurfaceComposerClient对象内的状态：

[![/images/android-surface-interfaces.jpeg](/images/android-surface-interfaces.jpeg)](/images/android-surface-interfaces.jpeg)

###Surface.lockCanvas
* Surface.lockCanvas
    * Surface\_lockCanvas(android\_view\_Surface.cpp)
        * getSurface
            * SurfaceControl.getSurface
                * new Surface
    * Surface.lock(Surface.cpp)
        * SurfaceTextureClient::lock
            * dequeueBuffer
            * lockBuffer
    * new SkBitmap

Gralloc

1. Used to allocate and map graphics memory to app processes
1. Facilitates graphics memory export via Binder IPC mechanism
1. Provides cache synchronization points
1. Also used for framebuffer discovery

###Surface.unlockCanvasAndPost
* Surface.lockCanvas
    * Surface\_lockCanvas(android\_view\_Surface.cpp)
        * getSurface
            * SurfaceControl.getSurface
                * new Surface
    * Surface.lock(Surface.cpp)
        * SurfaceTextureClient::unlockAndPost
        * GraphicBuffer.unlock
        * queueBuffer

###Reference
* <http://www.mail-archive.com/android-framework@googlegroups.com/msg01901.html>
* <http://stackoverflow.com/questions/4576909/understanding-canvas-and-surface-concepts>
* [关于MemoryHeapBase](http://www.androidenea.com/2010/03/share-memory-using-ashmem-and-binder-in.html)
* <http://blog.csdn.net/myarrow/article/details/7180561>
* <http://blog.csdn.net/droidphone/article/details/5972568>

###待续...
