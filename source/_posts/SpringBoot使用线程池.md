---
title: SpringBoot使用线程池
tags:
  - 实操
categories:
  - java
abbrlink: 48678
date: 2022-12-15 18:54:10
---

以往学习多线程总是很零碎，不写就忘，然后一段时间又要翻各种资料，就打算最近写一写多线程内容，当然自己可能了解的都是基础，记录的话呢还是准备以实战为主，理论为辅

<!--more-->

# 1、Java中创建线程池

## 一、 ThreadPoolExecutor类介绍

```java
package java.util.concurrent;
/**
     * @param corePoolSize 核心线程数 -> 线程池中保持的线程数量,即使它们是空闲的也不会销毁,
     *        除非设置了{@code allowCoreThreadTimeOut}核心线程超时时间
     * @param maximumPoolSize 最大线程数 -> 线程池中允许接收的最大线程数量
     *        如果设定的数量比系统支持的线程数还要大时,会抛出OOM(OutOfMemoryError)异常
     * @param keepAliveTime 最大存活时间 -> 当前线程数大于核心线程数的时候,
     *        其他多余的线程接收新任务之前的最大等待时间,超过时间没有新任务就会销毁.
     * @param unit {@code keepAliveTime}最大存活时间的单位.eg:TimeUnit.SECONDS
     * @param workQueue 工作队列 -> 保存任务直到任务被提交到线程池的线程中执行.
     * @param threadFactory 线程工厂 -> 当线程池需要创建线程得时候会从线程工厂获取新的实例.
     *        (自定义ThreadFactory可以跟踪线程池究竟何时创建了多少线程,也可以自定义线程的名称、
     *        组以及优先级等信息,甚至可以任性的将线程设置为守护线程.
     *        总之,自定义ThreadFactory可以更加自由的设置线程池中所有线程的状态。)
     * @param handler 当线程数量等于最大线程数并且工作队列已满的时候,再有新的任务添加进来就会进入这个handler,
     *        可以理解为设置拒绝策略（此处不清楚的可以看一下ThreadPoolExecutor中的execute方法的注释）
     */
public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue,
                          ThreadFactory threadFactory,
                          RejectedExecutionHandler handler) {
}

```

## 二、ThreadPoolExecutor的执行流程如下：

![image-20221215142602116](http://lzcoder.cn/image-20221215142602116.png)

1.主线程提交新任务到线程池
2.线程池判断当前线程池的线程数和核心线程数的大小,小于就新建线程处理请求;否则继续判断当前工作队列是否已满.
3.如果当前工作队列未满就将任务放到工作队列中;否则继续判断当前线程池的线程数和最大线程数的大小.
4.如果当前线程池的线程数小于最大线程数就新建线程处理请求;否则就调用RejectedExecutionHandler来做拒绝处理。

## 三、jdk提供四种拒绝策略

### 1. AbortPolicy

直接抛出RejectedExecutionException异常

### 2. CallerRunsPolicy

交由主线程执行

### 3. DiscardOldestPolicy

抛弃工作队列中旧的任务,将新任务添加进队列;会导致被丢弃的任务无法再次被执行

### 4. DiscardPolicy

抛弃当前任务;会导致被抛弃的任务无法再次被执行

**当然你也可以自定义拒绝策略,只需要实现RejectedExecutionHandler接口即可**

# 2、Spring中创建线程池

## 一、ThreadPoolTaskExecutor类介绍

```java
package org.springframework.scheduling.concurrent;

public class ThreadPoolTaskExecutor {
    private final Object poolSizeMonitor = new Object(); // 线程池大小锁,保证获取的当前线程池大小的正确性
    private int corePoolSize = 1; // 核心线程数
    private int maxPoolSize = 2147483647; // 最大线程数
    private int keepAliveSeconds = 60; // 最大存活时间
    private int queueCapacity = 2147483647; // 工作队列大小
    private boolean allowCoreThreadTimeOut = false; // 是否允许核心线程超时,false不允许
    private TaskDecorator taskDecorator; // 围绕任务的调用设置一些执行上下文,或者为任务执行提供一些监视/统计
    private ThreadPoolExecutor threadPoolExecutor; // java中的线程池创建类
｝
```

**从源码中可以看出ThreadPoolTaskExecutor就是在java中ThreadPoolExecutor的基础上封装的**

# 3、线程池使用示例

## 一、使用ThreadPoolTaskExecutor

1. 定义配置类：我们需要通过SpringBoot的配置类来配置线程池的Bean和对应的参数

```java
import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

@Configuration
@EnableAsync // 允许使用异步方法
public class ThreadPoolConfig {

    @Bean
    public Executor threadPoolTaskExecutor() {
        ThreadPoolTaskExecutor threadPoolTaskExecutor = new ThreadPoolTaskExecutor();
        // 设置核心线程数
        threadPoolTaskExecutor.setCorePoolSize(5);
        // 设置最大线程数
        threadPoolTaskExecutor.setMaxPoolSize(5);
        // 设置工作队列大小
        threadPoolTaskExecutor.setQueueCapacity(2000);
        // 设置线程名称前缀
        threadPoolTaskExecutor.setThreadNamePrefix("threadPoolTaskExecutor-->");
        // 设置拒绝策略.当工作队列已满,线程数为最大线程数的时候,接收新任务抛出RejectedExecutionException异常
        threadPoolTaskExecutor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());
        // 初始化线程池
        threadPoolTaskExecutor.initialize();
        return threadPoolTaskExecutor;
    }
}
```

2. 调用方法 sevice

```java
/**
  *  @Async标注的方法，称之为异步方法；这些方法将在执行的时候，
  * 将会在独立的线程中被执行，调用者无需等待它的完成，即可继续其他的操作。
  */
@Override
@Async() // 参数为线程池配置时的方法名即对应的bean的id ①
public void testThread() {
    log.info("start test thread");
    System.out.println(Thread.currentThread().getName());
    log.info("end test thread");
}
```

3. 测试类

```java
package com.coder.lion.test;

import com.coder.lion.CoderLionApplication;
import com.coder.lion.demo.service.ImportService;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import javax.annotation.Resource;

/**
 * @author liuzheng
 * @date 2022年12月15日 11:21
 * @Description 线程池测试类
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = CoderLionApplication.class)
public class ThreadTest {

    @Resource
    ImportService importService;

    @Test
    public void test1(){
        importService.testThread();
    }
}
```

输出结果：

![image-20221215144417159](http://lzcoder.cn/image-20221215144417159.png)

从测试的结果可以清晰的看到sayHello方法是由我们定义的线程池中的线程执行的

**注意 因为显示名称长度限制的原因我们看到的是askExecutor–>1,
但是通过在方法中打印当前线程的名字得知确实是我们设置的线程threadPoolTaskExecutor–>1**

## 二、使用ThreadPoolExecutor

在配置类中增加如下配置

```java
@Bean
public Executor myThreadPool() {
    log.info("创建线程池 -- myThreadPool");
    // 设置核心线程数
    int corePoolSize = 5;
    // 设置最大线程数
    int maxPoolSize = 5;
    // 设置工作队列大小
    int queueCapacity = 2000;
    // 最大存活时间
    long keepAliveTime = 30;
    // 设置线程名称前缀
    String threadNamePrefix = "myThreadPool-->";
    // 设置自定义拒绝策略.当工作队列已满,线程数为最大线程数的时候,接收新任务抛出RejectedExecutionException异常
    RejectedExecutionHandler rejectedExecutionHandler = new RejectedExecutionHandler() {
        @Override
        public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
            throw new RejectedExecutionException("自定义的RejectedExecutionHandler");
        }
    };
    // 自定义线程工厂
    ThreadFactory threadFactory = new ThreadFactory() {
        private int i = 1;

        @Override
        public Thread newThread(Runnable r) {
            Thread thread = new Thread(r);
            thread.setName(threadNamePrefix + i);
            i++;
            return thread;
        }
    };
    // 初始化线程池
    ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(corePoolSize, maxPoolSize,
                                                                   keepAliveTime, TimeUnit.SECONDS, new LinkedBlockingQueue<>(queueCapacity),
                                                                   threadFactory, rejectedExecutionHandler);
    return threadPoolExecutor;
}
```

可以看到我们在配置类中配置了两个线程池,如果我们想要指定使用其中一个线程池的需使用如下方式

**当未指明使用哪个线程池的时候会优先使用ThreadPoo		lTaskExecutor，当定义了多个或未定义ThreadPoolTaskExecutor时，默认使用的是SimpleAsyncTaskExecutor**

SimpleAsyncTaskExecutor：不是真的线程池，这个类不重用线程，每次调用都会创建一个新的线程。并发大的时候会产生严重的性能问题。

```java
@Override
@Async("myThreadPool") // 参数为线程池配置时的方法名即对应的bean的id ①
public void testThread() {
    log.info("start test thread");
    System.out.println(Thread.currentThread().getName());
    log.info("end test thread");
}
```

![image-20221215145144040](http://lzcoder.cn/image-20221215145144040.png)

## 二、 自定义ThreadPoolTaskExecutor

1. 创建 MyThreadPoolTaskExecutor

```java
package com.coder.lion.demo.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.util.concurrent.ListenableFuture;

import java.util.concurrent.Callable;
import java.util.concurrent.Future;

/**
 * @author liuzheng
 * @date 2022年12月15日 11:46
 * @Description 自定义ThreadPoolTaskExecutor
 */
public class MyThreadPoolTaskExecutor extends ThreadPoolTaskExecutor {

    Logger logger = LoggerFactory.getLogger(MyThreadPoolTaskExecutor.class);

    @Override
    public void execute(Runnable task) {
        logThreadPoolStatus();
        super.execute(task);
    }

    @Override
    public void execute(Runnable task, long startTimeout) {
        logThreadPoolStatus();
        super.execute(task, startTimeout);
    }

    @Override
    public Future<?> submit(Runnable task) {
        logThreadPoolStatus();
        return super.submit(task);
    }

    @Override
    public <T> Future<T> submit(Callable<T> task) {
        logThreadPoolStatus();
        return super.submit(task);
    }

    @Override
    public ListenableFuture<?> submitListenable(Runnable task) {
        logThreadPoolStatus();
        return super.submitListenable(task);
    }

    @Override
    public <T> ListenableFuture<T> submitListenable(Callable<T> task) {
        logThreadPoolStatus();
        return super.submitListenable(task);
    }

    /**
     * 在线程池运行的时候输出线程池的基本信息
     */
    private void logThreadPoolStatus() {
        logger.info("核心线程数:{}, 最大线程数:{}, 当前线程数: {}, 活跃的线程数: {}",
                    getCorePoolSize(), getMaxPoolSize(), getPoolSize(), getActiveCount());
    }
}
```

> 我们可以在自定义的ThreadPoolTaskExecutor中,输出一些线程池的当前状态,包括所有上面介绍的参数。

2. 在配置类增加 使用 MyThreadPoolTaskExecutor 的 bean

```java
@Bean
public Executor myThreadPoolTaskExecutor() {
    log.info("创建线程池 -- myThreadPoolTaskExecutor");
    ThreadPoolTaskExecutor threadPoolTaskExecutor = new MyThreadPoolTaskExecutor();
    // 设置核心线程数
    threadPoolTaskExecutor.setCorePoolSize(5);
    // 设置最大线程数
    threadPoolTaskExecutor.setMaxPoolSize(5);
    // 设置工作队列大小
    threadPoolTaskExecutor.setQueueCapacity(2000);
    // 设置线程名称前缀
    threadPoolTaskExecutor.setThreadNamePrefix("myThreadPoolTaskExecutor-->");
    // 设置拒绝策略.当工作队列已满,线程数为最大线程数的时候,接收新任务抛出RejectedExecutionException异常
    threadPoolTaskExecutor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());
    // 初始化线程池
    threadPoolTaskExecutor.initialize();
    return threadPoolTaskExecutor;
}
```

[[Java 并发编程：线程池的使用](https://my.oschina.net/MyoldTime/blog/3075650)](https://my.oschina.net/MyoldTime/blog/3075650)

[参考二](https://blog.csdn.net/qq_24983911/article/details/94722569)
