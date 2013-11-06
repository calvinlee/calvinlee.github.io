---
layout: post
title: "Android模拟器与host主机以及模拟器之间进行TCP通信"
category: Android
tags: [android]
---

###QEMU Networking
Android 模拟器基于QEMU虚拟机构建，虚拟机（guest）与所在的PC主机（host）之间的网络通信有几种方式：

1. NAT方式  
     Android模拟器的网络连接使用NAT方式。  
    这种方式通过host机器的网络接口访问网络，优点是方便设置，不用创建额外的网络接口。缺点是guest可以访问外部网络，但是反过来host不能访问到guest。Android通过端口转发解决这一问题。  
    NAT网络结构如下所示(图片来自[qumu wiki](http://wiki.qemu.org/Documentation/Networking))：

    [![/images/qemu_Slirp_concept.png](/images/qemu_Slirp_concept.png)](/images/qemu\_Slirp\_concept.png)

    由此可见，guest与host不在同一个网段，guest通过10.0.2.2访问host机器.
1. Bridge方式


###模拟器与host通信
启动模拟器，adb server会在5554端口上监听来自adb client的连接，我们可以通过这个端口与模拟器通信。  
在模拟器上运行如下服务器程序，在**模拟器**的8000端口上监听客户端连接，接收到客户端连接后，发送一段echo字符串，然后关闭连接：

    public class EmulatorServerActivity extends Activity {
        private ServerSocket serverSocket = null;
    
        public static final int SERVERPORT = 8000;
    
        private boolean keepRunning = false;
    
        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.main);
            keepRunning = true;
            new Thread(new ServerThread()).start();
        }
    
        @Override
        protected void onStop() {
            super.onStop();
            try {
                keepRunning = false;
                serverSocket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    
        class ServerThread implements Runnable {
            public void run() {
                try {
                    serverSocket = new ServerSocket(SERVERPORT);
                } catch (IOException e) {
                    e.printStackTrace();
                    return;
                }
    
                while (keepRunning) {
                    try {
                        Log.d("Server", "Wating for connection...");
                        Socket s = serverSocket.accept();
                        BufferedReader reader = new BufferedReader(new InputStreamReader(
                                s.getInputStream()));
                        String msg = reader.readLine();
                        Log.d("Server", "Received message from client:" + msg);
                        String echo = "You are telling me: " + msg + ", bye\n";
                        s.getOutputStream().write(echo.getBytes());
                        s.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

在host机器上通过telnet连接到模拟器：

    telnet localhost 5554
然后设置端口转发：
    redir add tcp:7777:8000
    redir list // 显示已添加的端口转发
    exit

添加端口转发命令格式为：

    redir add <protocol>:<host-port>:<guest-port>
其中，protocol必须是tcp或udp，host-port是主机上开启的端口号，guest-port 是模拟器的监听端口号。  

这条端口转发命令表示将发送到host机器的7777端口的所有tcp数据转发到guest机器的8000端口，也就是我们的server程序监听的端口，这个过程对client来说是完全透明的，它只知道它把数据发送到host的7777端口，它对数据如何转发一无所知。这时在host机器上可以看到7777端口已经处于监听状态：

    $ netstat -tln
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State      
    tcp        0      0 127.0.0.1:7777          0.0.0.0:*               LISTEN 

通过设置端口转发，host机器就可以通过这个7777端口连接guest机器上的服务程序了：

    $ telnet localhost 7777
    Trying 127.0.0.1...
    Connected to localhost.
    Escape character is '^]'.
    hello
    You are telling me: hello, bye
    Connection closed by foreign host.

###模拟器之间通信
启动另一个模拟器，运行客户端程序：

    public class EmulatorClientActivity extends Activity {
        private String serverIpAddress = "10.0.2.2";
    
        // 注意：我们需要连接host机器的7777端口
        private static final int REDIRECTED_SERVERPORT = 7777;
    
        private Socket socket;
    
        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.main);
            new Thread(new CommsThread()).start();
        }
    
        class CommsThread implements Runnable {
            public void run() {
                try {
                    InetAddress serverAddr = InetAddress.getByName(serverIpAddress);
                    socket = new Socket(serverAddr, REDIRECTED_SERVERPORT);
                    socket.getOutputStream().write(new String("Hello\n").getBytes());
                    Log.d("Client", "Message sent to server");
                    socket.close();
                } catch (UnknownHostException e1) {
                    e1.printStackTrace();
                } catch (IOException e1) {
                    e1.printStackTrace();
                }
            }
        }
    }

注意：在这个客户端程序里，我们需要连接的socket为10.0.2.2:7777,其中，10.0.2.2是host机器的ip地址，发送到host机器的7777端口的数据会被透明的转发到另一个模拟器的8000端口上，这样，连接就建立起来了。

###Reference

* <http://wiki.qemu.org/Documentation/Networking>
* <http://www.virtualbox.org/manual/ch06.html#nat-limitations>
* <http://felipec.wordpress.com/2009/12/27/setting-up-qemu-with-a-nat/>
* <http://www.cnblogs.com/yangnas/archive/2010/05/28/1745917.html>
