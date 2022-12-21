---
title: SpringBoot自定义全局异常处理
tags:
  - 实操
categories:
  - java
abbrlink: 16282
date: 2022-12-21 09:18:13
---

SpringBoot自定义全局异常  如果可以统一一个全局异常，是什么错误就返回什么信息和code码给前端，前端更便于处理。

<!--more-->

自定义全局异常主要以下步骤

1. 自定义异常接口类
2. 自定义异常枚举类
3. 自定义异常类
4. 自定义异常处理类
5. 自定义全局响应类

### 1. 自定义异常接口类

```java
/**
 * 定义全局异常类所需的方法
 */
public interface BaseError {

     String getCode();

    String getMessage();
}
```

### 2. 自定义异常枚举类

```java
import com.coder.lion.demo.config.error.BaseError;

/**
 * @author liuzheng
 * @date 2022年12月21日 9:43
 * @Description 自定义异常枚举，实现接口
 */

public enum BaseErrorEnum implements BaseError {
    SUCCESS("200","成功！"),
    NOT_FOUND("404","请求资源不存在")
    ;

    private String code;

    private String message;

    BaseErrorEnum(String code,String message){
        this.code = code;
        this.message = message;
    }


    @Override
    public String getCode() {
        return this.code;
    }
    @Override
    public String getMessage() {
        return this.message;
    }
}
```

### 3. 自定义异常类

```java
@Data
public class BaseException extends RuntimeException {

    //错误码
    private String code;

    //错误信息
    private String message;

    public BaseException(){
        super();
    }

    public BaseException(BaseErrorEnum baseErrorEnum){
        super(baseErrorEnum.getMessage());
        this.code = baseErrorEnum.getCode();
        this.message = baseErrorEnum.getMessage();
    }
}
```

### 4. 自定义异常处理类

```java
/**
 * @author liuzheng
 * @date 2022年12月21日 9:55
 * @Description 自定义异常处理类
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 处理自定义异常
     * @param baseException
     * @return
     */
    @ExceptionHandler(value = BaseException.class)
    public BaseResponse<Object> baseExceptionHandler(BaseException baseException){
        log.info("业务处理异常，原因是 {}",baseException.getMessage());
        return RespGenerator.returnError(baseException.getCode(),baseException.getMessage());
    }
}
```

@RestControllerAdvice注解是@ResponseBody和@ControllerAdvice的组合。

@ResponseBody注解：通常用来将java对象转成JSON对象，返回给前端JSON数据。
@ControllerAdvice注解：结合方法型注解@ExceptionHandler，用于捕获Controller中抛出的指定类型的异常，从而达到不同类型的异常区别处理的目的。
 @ExceptionHandler注解统一处理某一类异常，从而能够减少代码重复率和复杂度，value值为什么异常类型，就处理什么异常类型的逻辑。

### 5. 封装的请求返回包装类

  BaseResponse类和RespGenerator类都是属于规范方法返回值结构体的类，也有利于一致化后端所有接口的返回结构，方便前端读取所需要的数据。

```java
/**
 * @author liuzheng
 * @date 2022年09月29日 22:19
 * @Description 统一响应
 */
@Data
public class BaseResponse<T> {

    private String code;

    private String message;

    private T data;


    /**
     * 默认构造方法
     *
     * @param code 状态码
     * @param message 接口信息
     * @param data 接口数据
     */
    public BaseResponse(String code, String message, T data) {
        super();
        this.code = code;
        this.message = message;
        this.data = data;
    }

    public BaseResponse(){
        super();
    }
}
```



```java
/**
 * @author liuzheng
 * @date 2022年09月29日 22:22
 * @Description TODO
 */
public class RespGenerator {
    /**
     * 接口调用成功时出参
     * @param data 接口返回数据
     * @return
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public static BaseResponse returnOK(Object data) {
        return new BaseResponse("200", "接口调用成功!", data);
    }

    /**
     * 调用失败
     *
     * @param code 错误码
     * @param message错误信息
     * @return
     */
    public static BaseResponse<Object> returnError(String code, String message) {
        return new BaseResponse<Object>(code, message, null);
    }

    /**
     * 调用失败
     *
     * @param message 错误信息
     * @return
     */
    public static BaseResponse<Object> returnError(String message) {
        return new BaseResponse<Object>("-1", message, null);
    }
}
```

### 6. 演示效果

![image-20221221101142025](http://lzcoder.cn/image-20221221101142025.png)

![image-20221221100733596](http://lzcoder.cn/image-20221221100733596.png)
