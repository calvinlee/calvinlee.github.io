---
layout: post
title: "Java动态代理"
category: Java
tags: [java, proxy]
---

###概念
Java动态代理是代理模式的延伸，之所以称为”动态“，是因为我们不用去设计代理类，代理类的字节码在运行时被动态生成后由classloader加载进JVM后运行。  
动态代理相关类有：

    java.lang.reflect.Proxy  
    这个类的主要作用是在运行时生成代理类的字节码，并通过这个字节码生成代理类对象供客户端使用。  

    java.lang.reflect.InvocationHandler  
    这个接口只定义了一个invoke方法，它是调用真实的被代理对象的地方，我们可以在这个方法里加上额外的代理逻辑，如果日志记录，访问鉴权等。  

    Object invoke(Object proxy, Method method, Object[] args);

    proxy参数是生成的代理类对象的引用，就像后面分析的，它的类型是$Proxy0，继承了Proxy类并实现了和被代理对象公共的业务接口。  
    method是当前被调用的被代理方法。  
    args是当前被调用的被代理方法的参数列表。

[![/images/dynamic_proxy.png](/images/dynamic_proxy.png)](/images/dynamic_proxy.png)

利用动态代理的机制，我们可以实现典型的AOP(Aspect-oriented programming)编程模式，实际上，这也是Spring AOP的实现原理。  

###举例
首先是被代理类和代理类公共的业务接口：

    public interface Subject {
        void request();
    }

AOP业务接口：

    public interface AopLogger {
        void logBefore();

        void logAfter();
    }

被代理类：

    public class RealSubject implements Subject {
        public void request() {
            System.out
                    .println("Processing request in real subject...");
        }
    }

委托对象类：

    import java.lang.reflect.InvocationHandler;
    import java.lang.reflect.Method;

    public class RequestInvocationHandler implements InvocationHandler {
        private Subject originalObj;

        private AopLogger logger;

        public RequestInvocationHandler(Subject originalObj) {
            super();
            this.originalObj = originalObj;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            // do some processing before the method invocation
            System.out.println("Before requesting real subject...");
            logger.logBefore();
            // TODO:
            // how to use this proxy object?

            // invoke the method
            Object result = method.invoke(originalObj, args);

            // do some processing after the method invocation
            logger.logAfter();
            System.out.println("After requesting real subject...");
            return result;
        }

        public AopLogger getLogger() {
            return logger;
        }

        public void setLogger(AopLogger logger) {
            this.logger = logger;
        }
    }

客户端测试代码：

    import java.lang.reflect.Field;
    import java.lang.reflect.Proxy;
    import java.util.Properties;

    public class Client {

        public static void main(String[] args) throws Exception {
            // ***** save proxy class into file *******
            Field field = System.class.getDeclaredField("props");
            field.setAccessible(true);
            Properties props = (Properties) field.get(null);
            props.put("sun.misc.ProxyGenerator.saveGeneratedFiles", "true");
            // ****************************************

            // TODO:
            // 怎样防止客户端绕过proxy直接调用RealSubject的方法？
            Subject origObj = new RealSubject();
            Subject proxy = (Subject) getProxy(origObj);

            proxy.request();
        }

        private static Object getProxy(Subject origObj) {
            RequestInvocationHandler handler = new RequestInvocationHandler(origObj);
            handler.setLogger(new AopLogger() {

                @Override
                public void logBefore() {
                    System.out.println("AOP logger working before...");
                }

                @Override
                public void logAfter() {
                    System.out.println("AOP logger working after...");
                }

            });

            // 这里会通过ProxyGenerator类生成代理类的字节码，并由origObj所在的classloader加载进JVM，然后通过反射实例化出一个代理对象
            return Proxy.newProxyInstance(origObj.getClass().getClassLoader(), origObj.getClass()
                    .getInterfaces(), handler);
        }

    }

在Client测试代码中加上如下代码后可以将生成的代理类字节码保存到本地文件中：

      Field field = System.class.getDeclaredField("props");
      field.setAccessible(true);
      Properties props = (Properties) field.get(null);
      props.put("sun.misc.ProxyGenerator.saveGeneratedFiles", "true");

反编译这个class文件后察看可以更清楚幕后究竟做了什么：

    import com.java.demo.dynamic_proxy.Subject;
    import java.lang.reflect.InvocationHandler;
    import java.lang.reflect.Method;
    import java.lang.reflect.Proxy;
    import java.lang.reflect.UndeclaredThrowableException;

    public final class $Proxy0 extends Proxy
      implements Subject {
      private static Method m1;
      private static Method m3;
      private static Method m0;
      private static Method m2;

      public $Proxy0(InvocationHandler paramInvocationHandler)
        throws {
        super(paramInvocationHandler);
      }

      public final boolean equals(Object paramObject)
        throws {
        try {
          return ((Boolean)this.h.invoke(this, m1, new Object[] { paramObject })).booleanValue();
        }
        catch (Error localError) {
          throw localError;
        }
        catch (Throwable localThrowable) {
        }
        throw new UndeclaredThrowableException(localThrowable);
      }

      public final void request()
        throws {
        try {
          // 转发给InvocationHanlder对象处理
          this.h.invoke(this, m3, null);
          return;
        }
        catch (Error localError) {
          throw localError;
        }
        catch (Throwable localThrowable) {
        }
        throw new UndeclaredThrowableException(localThrowable);
      }

      public final int hashCode()
        throws {
        try {
          return ((Integer)this.h.invoke(this, m0, null)).intValue();
        }
        catch (Error localError) {
          throw localError;
        }
        catch (Throwable localThrowable) {
        }
        throw new UndeclaredThrowableException(localThrowable);
      }

      public final String toString()
        throws {
        try {
          return (String)this.h.invoke(this, m2, null);
        }
        catch (Error localError) {
          throw localError;
        }
        catch (Throwable localThrowable) {
        }
        throw new UndeclaredThrowableException(localThrowable);
      }

      static {
        try {
          m1 = Class.forName("java.lang.Object").getMethod("equals", new Class[] { Class.forName("java.lang.Object") });
          m3 = Class.forName("com.java.demo.dynamic_proxy.Subject").getMethod("request", new Class[0]);
          m0 = Class.forName("java.lang.Object").getMethod("hashCode", new Class[0]);
          m2 = Class.forName("java.lang.Object").getMethod("toString", new Class[0]);
          return;
        }
        catch (NoSuchMethodException localNoSuchMethodException) {
          throw new NoSuchMethodError(localNoSuchMethodException.getMessage());
        }
        catch (ClassNotFoundException localClassNotFoundException) {
        }
        throw new NoClassDefFoundError(localClassNotFoundException.getMessage());
      }
    }

###Reference
* <http://chjl2020.iteye.com/blog/517835>

