---
title: CompletableFuture异步编程详解
abbrlink: 4426
date: 2022-12-14 17:14:44
tags:
  - 教程
categories:
  - java
---

> CompletableFuture 英 [kəmp'letəbl] 英 [ˈfjuːtʃə(r)] 

CompletableFuture主要是用于异步调用，内部封装了线程池，可以将请求或者处理过程，进行异步处理。

 创建线程有3种方式，直接继承Thread、实现Runnable接口、实现Callable接口。
* Runnable 没有任何返回值

* Future的方式，虽然任务是异步执行的，但是要想获得这个结果，还得需要自己取。

* CompletableFuture，所有事情都是可以自动完成，即可以在完成之后，回调通知，也可以自己去等待。

<!--more-->

[带你了解了解Future和CompletableFuture](https://blog.csdn.net/qq_42820805/article/details/109635001)

## 1. get() / join()  

join() 和 get() 方法都是阻塞调用它们的线程（通常为主线程）来获取CompletableFuture异步之后的返回值。

```java
private static int num = 0;
public static Integer multipart(Integer a){
    try {
        TimeUnit.SECONDS.sleep(3);
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    num=30;
    return a*a;
}

@Test
public void test(){
    CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> multipart(5));
    //System.out.println(future.join());
    System.out.println(num);
}
```

输出结果

```java
0

Process finished with exit code 0

当放开注释时结果：
25
30
Process finished with exit code 0

```

## 2. submit

通常的线程池接口类ExecutorService，其中execute方法的返回值是void，即无法获取异步任务的执行状态，3个重载的submit方法的返回值是Future，可以据此获取任务执行的状态和结果。

```java
@Test
public void test1() throws Exception {
    // 创建异步执行任务:
    ExecutorService executorService= Executors.newSingleThreadExecutor();
    Future<Double> cf = executorService.submit(()->{
        System.out.println(Thread.currentThread()+" start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        if(false){
            throw new RuntimeException("test");
        }else{
            System.out.println(Thread.currentThread()+" exit,time->"+System.currentTimeMillis());
            return 1.2;
        }
    });
    System.out.println("main thread start,time->"+System.currentTimeMillis());
    //等待子任务执行完成,如果已完成则直接返回结果
    //如果执行任务异常，则get方法会把之前捕获的异常重新抛出
    System.out.println("run result->"+cf.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214173822259](http://lzcoder.cn/image-20221214173822259.png)

## 3. supplyAsync / runAsync      (有/无返回值 执行异步任务)

**supplyAsync表示创建带返回值的异步任务的**，相当于ExecutorService submit(Callable  task) 方法，

**runAsync表示创建无返回值的异步任务**，相当于ExecutorService submit(Runnable task)方法，这两方法的效果跟submit是一样的， 这两方法各有一个重载版本，可以指定执行异步任务的Executor实现，如果不指定，默认使用ForkJoinPool.commonPool()，如果机器是单核的，则默认使用ThreadPerTaskExecutor，该类是一个内部类，每次执行execute都会创建一个新线程。

```java
@Test
public void test2() throws Exception {
    ForkJoinPool pool=new ForkJoinPool();
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        if(false){
            throw new RuntimeException("test");
        }else{
            System.out.println(Thread.currentThread()+" exit,time->"+System.currentTimeMillis());
            return 1.2;
        }
    },pool);
    System.out.println("main thread start,time->"+System.currentTimeMillis());
    //等待子任务执行完成
    System.out.println("run result->"+cf.join());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}

@Test
public void test3() throws Exception {
    ExecutorService executorService= Executors.newSingleThreadExecutor();
    // 创建异步执行任务:
    CompletableFuture cf = CompletableFuture.runAsync(()->{
        System.out.println(Thread.currentThread()+" start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        if(false){
            throw new RuntimeException("test");
        }else{
            System.out.println(Thread.currentThread()+" exit,time->"+System.currentTimeMillis());
        }
    },executorService);
    System.out.println("main thread start,time->"+System.currentTimeMillis());
    //等待子任务执行完成
    System.out.println("run result->"+cf.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214174705707](http://lzcoder.cn/image-20221214174705707.png)

![image-20221214174736527](http://lzcoder.cn/image-20221214174736527.png)

## 4 thenApply / thenApplyAsync （任务执行回调方法，可指定Executor）

**thenApply 表示某个任务执行完成后执行的动作，即回调方法，会将该任务的执行结果即方法返回值作为入参传递到回调方法中**

 		测试用例如下： job1执行结束后，将job1的方法返回值作为入参传递到job2中并立即执行job2。 thenApplyAsync与thenApply的区别在于，前者是将job2提交到线程池中异步执行，实际执行job2的线程可能是另外一个线程，后者是由执行job1的线程立即执行job2，即两个job都是同一个线程执行的。

 **thenApplyAsync有一个重载版本，可以指定执行异步任务的Executor实现**，如果不指定，默认使用ForkJoinPool.commonPool()。

```java
@Test
public void test4() throws Exception {
    ForkJoinPool pool=new ForkJoinPool();
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job1,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job1,time->"+System.currentTimeMillis());
        return 1.2;
    },pool);
    //cf关联的异步任务的返回值作为方法入参，传入到thenApply的方法中
    //thenApply这里实际创建了一个新的CompletableFuture实例
    CompletableFuture<String> cf2=cf.thenApplyAsync((result)->{
        System.out.println(Thread.currentThread()+" start job2,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job2,time->"+System.currentTimeMillis());
        return "test:"+result;
    });
    System.out.println("main thread start cf.get(),time->"+System.currentTimeMillis());
    //等待子任务执行完成
    System.out.println("run result->"+cf.get());
    System.out.println("main thread start cf2.get(),time->"+System.currentTimeMillis());
    System.out.println("run result->"+cf2.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214175046062](http://lzcoder.cn/image-20221214175046062.png)

## 5. thenAccept / thenRun (和4基本一致，任务执行回调方法，出入参不同)

thenAccept 同 thenApply 接收上一个任务的返回值作为参数，但是无返回值；

 thenRun 的方法没有入参，也买有返回值，测试用例如下：

```java
@Test
public void test5() throws Exception {
    ForkJoinPool pool=new ForkJoinPool();
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job1,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job1,time->"+System.currentTimeMillis());
        return 1.2;
    },pool);
    //cf关联的异步任务的返回值作为方法入参，传入到thenApply的方法中
    CompletableFuture cf2=cf.thenApply((result)->{
        System.out.println(Thread.currentThread()+" start job2,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job2,time->"+System.currentTimeMillis());
        return "test:"+result;
    }).thenAccept((result)-> { //接收上一个任务的执行结果作为入参，但是没有返回值
        System.out.println(Thread.currentThread()+" start job3,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(result);
        System.out.println(Thread.currentThread()+" exit job3,time->"+System.currentTimeMillis());
    }).thenRun(()->{ //无入参，也没有返回值
        System.out.println(Thread.currentThread()+" start job4,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println("thenRun do something");
        System.out.println(Thread.currentThread()+" exit job4,time->"+System.currentTimeMillis());
    });
    System.out.println("main thread start cf.get(),time->"+System.currentTimeMillis());
    //等待子任务执行完成
    System.out.println("run result->"+cf.get());
    System.out.println("main thread start cf2.get(),time->"+System.currentTimeMillis());
    //cf2 等待最后一个thenRun执行完成
    System.out.println("run result->"+cf2.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214175242008](http://lzcoder.cn/image-20221214175242008.png)

## 6. exceptionally （将抛出异常作为参数传递到回调方法）

exceptionally方法指定某个任务执行异常时执行的回调方法，会将抛出异常作为参数传递到回调方法中，如果该任务正常执行,则exceptionally方法返回的CompletionStage的result就是该任务正常执行的结果

```java
@Test
public void test6() throws Exception {
    ForkJoinPool pool=new ForkJoinPool();
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+"job1 start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        if(true){
            throw new RuntimeException("test");
        }else{
            System.out.println(Thread.currentThread()+"job1 exit,time->"+System.currentTimeMillis());
            return 1.2;
        }
    },pool);
    //cf执行异常时，将抛出的异常作为入参传递给回调方法
    CompletableFuture<Double> cf2= cf.exceptionally((param)->{
        System.out.println(Thread.currentThread()+" start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println("error stack trace->");
        param.printStackTrace();
        System.out.println(Thread.currentThread()+" exit,time->"+System.currentTimeMillis());
        return -1.1;
    });
    //cf正常执行时执行的逻辑，如果执行异常则不调用此逻辑
    CompletableFuture cf3=cf.thenAccept((param)->{
        System.out.println(Thread.currentThread()+"job2 start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println("param->"+param);
        System.out.println(Thread.currentThread()+"job2 exit,time->"+System.currentTimeMillis());
    });
    System.out.println("main thread start,time->"+System.currentTimeMillis());
    //等待子任务执行完成,此处无论是job2和job3都可以实现job2退出，主线程才退出，如果是cf，则主线程不会等待job2执行完成自动退出了
    //cf2.get时，没有异常，但是依然有返回值，就是cf的返回值
    System.out.println("run result->"+cf2.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214175428834](http://lzcoder.cn/image-20221214175428834.png)

## 7. whenComplete （将结果和异常一起传递给回调方法）

whenComplete是当某个任务执行完成后执行的回调方法，会将执行结果或者执行期间抛出的异常传递给回调方法，如果是正常执行则异常为null， 回调方法对应的CompletableFuture的result和该任务一致，如果该任务正常执行，则get方法返回执行结果，如果是执行异常，则get方法抛出异常。测试用例如下

```java
@Test
public void test7() throws Exception {
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+"job1 start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        if(false){
            throw new RuntimeException("test");
        }else{
            System.out.println(Thread.currentThread()+"job1 exit,time->"+System.currentTimeMillis());
            return 1.2;
        }
    });
    //cf执行完成后会将执行结果和执行过程中抛出的异常传入回调方法，如果是正常执行的则传入的异常为null
    CompletableFuture<Double> cf2=cf.whenComplete((a,b)->{
        System.out.println(Thread.currentThread()+"job2 start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        if(b!=null){
            System.out.println("error stack trace->");
            b.printStackTrace();
        }else{
            System.out.println("run succ,result->"+a);
        }
        System.out.println(Thread.currentThread()+"job2 exit,time->"+System.currentTimeMillis());
    });
    //等待子任务执行完成
    System.out.println("main thread start wait,time->"+System.currentTimeMillis());
    //如果cf是正常执行的，cf2.get的结果就是cf执行的结果
    //如果cf是执行异常，则cf2.get会抛出异常
    System.out.println("run result->"+cf2.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214175536655](http://lzcoder.cn/image-20221214175536655.png)

## 8. handle （跟7基本一致，有返回值）

跟whenComplete基本一致，区别在于handle的回调方法有返回值，且handle方法返回的 CompletableFuture的result是回调方法的执行结果或者回调方法执行期间抛出的异常，与原始CompletableFuture的result无关了。测试用例如下

```java
@Test
public void test8() throws Exception {
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+"job1 start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        if(true){
            throw new RuntimeException("test");
        }else{
            System.out.println(Thread.currentThread()+"job1 exit,time->"+System.currentTimeMillis());
            return 1.2;
        }
    });
    //cf执行完成后会将执行结果和执行过程中抛出的异常传入回调方法，如果是正常执行的则传入的异常为null
    CompletableFuture<String> cf2=cf.handle((a,b)->{
        System.out.println(Thread.currentThread()+"job2 start,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        if(b!=null){
            System.out.println("error stack trace->");
            b.printStackTrace();
        }else{
            System.out.println("run succ,result->"+a);
        }
        System.out.println(Thread.currentThread()+"job2 exit,time->"+System.currentTimeMillis());
        if(b!=null){
            return "run error";
        }else{
            return "run succ";
        }
    });
    //等待子任务执行完成
    System.out.println("main thread start wait,time->"+System.currentTimeMillis());
    //get的结果是cf2的返回值，跟cf没关系了
    System.out.println("run result->"+cf2.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214175717210](http://lzcoder.cn/image-20221214175717210.png)

## 9. thenCombine / thenAcceptBoth / runAfterBoth （两个CompletableFuture组合起来，都正常执行才执行某个任务）

这三个方法都是将两个CompletableFuture组合起来，只有这两个都正常执行完了才会执行某个任务， 区别在于，thenCombine会将两个任务的执行结果作为方法入参传递到指定方法中，且该方法有返回值；thenAcceptBoth同样将两个任务的执行结果作为方法入参，但是无返回值； runAfterBoth没有入参，也没有返回值。注意两个任务中只要有一个执行异常，则将该异常信息作为指定任务的执行结果。测试用例如下：

```java
@Test
public void test9() throws Exception {
    ForkJoinPool pool=new ForkJoinPool();
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job1,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job1,time->"+System.currentTimeMillis());
        return 1.2;
    });
    CompletableFuture<Double> cf2 = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job2,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(1500);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job2,time->"+System.currentTimeMillis());
        return 3.2;
    });
    //cf和cf2的异步任务都执行完成后，会将其执行结果作为方法入参传递给cf3,且有返回值
    CompletableFuture<Double> cf3=cf.thenCombine(cf2,(a,b)->{
        System.out.println(Thread.currentThread()+" start job3,time->"+System.currentTimeMillis());
        System.out.println("job3 param a->"+a+",b->"+b);
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job3,time->"+System.currentTimeMillis());
        return a+b;
    });

    //cf和cf2的异步任务都执行完成后，会将其执行结果作为方法入参传递给cf3,无返回值
    CompletableFuture cf4=cf.thenAcceptBoth(cf2,(a,b)->{
        System.out.println(Thread.currentThread()+" start job4,time->"+System.currentTimeMillis());
        System.out.println("job4 param a->"+a+",b->"+b);
        try {
            Thread.sleep(1500);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job4,time->"+System.currentTimeMillis());
    });

    //cf4和cf3都执行完成后，执行cf5，无入参，无返回值
    CompletableFuture cf5=cf4.runAfterBoth(cf3,()->{
        System.out.println(Thread.currentThread()+" start job5,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
        }
        System.out.println("cf5 do something");
        System.out.println(Thread.currentThread()+" exit job5,time->"+System.currentTimeMillis());
    });

    System.out.println("main thread start cf.get(),time->"+System.currentTimeMillis());
    //等待子任务执行完成
    System.out.println("cf run result->"+cf.get());
    System.out.println("main thread start cf5.get(),time->"+System.currentTimeMillis());
    System.out.println("cf5 run result->"+cf5.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214175828801](http://lzcoder.cn/image-20221214175828801.png)

## 10.  applyToEither / acceptEither / runAfterEither （两个CompletableFuture组合起来，一个执行完了就会执行某个任务）

这三个方法都是将两个CompletableFuture组合起来，只要其中一个执行完了就会执行某个任务，其区别在于: 

applyToEither会将已经执行完成的任务的执行结果作为方法**入参，并有返回值**； 

acceptEither同样将已经执行完成的任务的执行结果作为方法**入参，但是没有返回值**；

 runAfterEither**没有方法入参，也没有返回值**。注意两个任务中只要有一个执行异常，则将该异常信息作为指定任务的执行结果。测试用例如下：

```java
@Test
public void test10() throws Exception {
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job1,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job1,time->"+System.currentTimeMillis());
        return 1.2;
    });
    CompletableFuture<Double> cf2 = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job2,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(1500);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job2,time->"+System.currentTimeMillis());
        return 3.2;
    });
    //cf和cf2的异步任务其中一个执行完了，会将其执行结果作为方法入参传递给cf3,且有返回值
    CompletableFuture<Double> cf3=cf.applyToEither(cf2,(result)->{
        System.out.println(Thread.currentThread()+" start job3,time->"+System.currentTimeMillis());
        System.out.println("job3 param result->"+result);
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job3,time->"+System.currentTimeMillis());
        return result;
    });

    //cf和cf2的异步其中一个执行完了，会将其执行结果作为方法入参传递给cf3,无返回值
    CompletableFuture cf4=cf.acceptEither(cf2,(result)->{
        System.out.println(Thread.currentThread()+" start job4,time->"+System.currentTimeMillis());
        System.out.println("job4 param result->"+result);
        try {
            Thread.sleep(1500);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job4,time->"+System.currentTimeMillis());
    });

    //cf4和cf3其中一个执行完了，执行cf5，无入参，无返回值
    CompletableFuture cf5=cf4.runAfterEither(cf3,()->{
        System.out.println(Thread.currentThread()+" start job5,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
        }
        System.out.println("cf5 do something");
        System.out.println(Thread.currentThread()+" exit job5,time->"+System.currentTimeMillis());
    });

    System.out.println("main thread start cf.get(),time->"+System.currentTimeMillis());
    //等待子任务执行完成
    System.out.println("cf run result->"+cf.get());
    System.out.println("main thread start cf5.get(),time->"+System.currentTimeMillis());
    System.out.println("cf5 run result->"+cf5.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214180046137](http://lzcoder.cn/image-20221214180046137.png)

## 11. thenCompose 

方法会在某个任务执行完成后，将该任务的执行结果作为方法入参然后执行指定的方法，该方法会返回一个新的CompletableFuture实例， 如果该CompletableFuture实例的result不为null，则返回一个基于该result的新的CompletableFuture实例； 如果该CompletableFuture实例为null，则，然后执行这个新任务

```java
@Test
public void test11() throws Exception {
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job1,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job1,time->"+System.currentTimeMillis());
        return 1.2;
    });
    CompletableFuture<String> cf2= cf.thenCompose((param)->{
        System.out.println(Thread.currentThread()+" start job2,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job2,time->"+System.currentTimeMillis());
        return CompletableFuture.supplyAsync(()->{
            System.out.println(Thread.currentThread()+" start job3,time->"+System.currentTimeMillis());
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
            }
            System.out.println(Thread.currentThread()+" exit job3,time->"+System.currentTimeMillis());
            return "job3 test";
        });
    });
    System.out.println("main thread start cf.get(),time->"+System.currentTimeMillis());
    //等待子任务执行完成
    System.out.println("cf run result->"+cf.get());
    System.out.println("main thread start cf2.get(),time->"+System.currentTimeMillis());
    System.out.println("cf2 run result->"+cf2.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

![image-20221214180204729](http://lzcoder.cn/image-20221214180204729.png)

## 12. allof / anyof （等待 所有任务/一个任务 执行完成才执行）

allof等待所有任务执行完成才执行cf4，如果有一个任务异常终止，则cf4.get时会抛出异常；如果都是正常执行，cf4.get返回null 

anyOf是只有一个任务执行完成，无论是正常执行或者执行异常，都会执行cf4，cf4.get的结果就是已执行完成的任务的执行结果

```java
@Test
public void test12() throws Exception {
    // 创建异步执行任务:
    CompletableFuture<Double> cf = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job1,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job1,time->"+System.currentTimeMillis());
        return 1.2;
    });
    CompletableFuture<Double> cf2 = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job2,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(1500);
        } catch (InterruptedException e) {
        }
        System.out.println(Thread.currentThread()+" exit job2,time->"+System.currentTimeMillis());
        return 3.2;
    });
    CompletableFuture<Double> cf3 = CompletableFuture.supplyAsync(()->{
        System.out.println(Thread.currentThread()+" start job3,time->"+System.currentTimeMillis());
        try {
            Thread.sleep(1300);
        } catch (InterruptedException e) {
        }
        //            throw new RuntimeException("test");
        System.out.println(Thread.currentThread()+" exit job3,time->"+System.currentTimeMillis());
        return 2.2;
    });
    //allof等待所有任务执行完成才执行cf4，如果有一个任务异常终止，则cf4.get时会抛出异常；如果都是正常执行，cf4.get返回null
    //anyOf是只有一个任务执行完成，无论是正常执行或者执行异常，都会执行cf4，cf4.get的结果就是已执行完成的任务的执行结果
    CompletableFuture cf4=CompletableFuture.anyOf(cf,cf2,cf3).whenComplete((a,b)->{
        if(b!=null){
            System.out.println("error stack trace->");
            b.printStackTrace();
        }else{
            System.out.println("run succ,result->"+a);
        }
    });

    System.out.println("main thread start cf4.get(),time->"+System.currentTimeMillis());
    //等待子任务执行完成
    System.out.println("cf4 run result->"+cf4.get());
    System.out.println("main thread exit,time->"+System.currentTimeMillis());
}
```

