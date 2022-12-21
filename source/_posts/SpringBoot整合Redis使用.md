---
title: SpringBoot整合Redis使用
tags:
  - 实操
categories:
  - java
abbrlink: 49945
date: 2022-12-15 16:16:02
---

1. SpringBoot整合redis，用redis存储token，实现一个用户只保存一个token，登录接口再次获取一个新的token后，前一个token则无法使用，解决一个用户可以多次登录的问题。

2. 实现用户登录3次就锁定用户账户，无法再请求登录接口。

<!--more-->

### 1. 增加配置文件

```yaml
server:
  port: 99
spring:
  profiles:
    active: dev
  redis:
    database: 1
    password: lzrm
    host: XX.XX.XX.XX
    post: 6379
    timeout: 5000
```

### 2.redis工具类

```java
package com.coder.lion.demo.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
public class RedisUtils {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    /**
     * 读取缓存
     *
     * @param key
     * @return
     */
    public String get(final String key) {
        return redisTemplate.opsForValue().get(key);
    }

    /**
     * 写入缓存
     */
    public boolean set(final String key, String value) {
        boolean result = false;
        try {
            redisTemplate.opsForValue().set(key, value);
            result = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 写入缓存,并设置过期时间
     *
     * @param key
     * @param value
     * @param timeout
     * @param unit
     * @return
     */
    public boolean set(final String key, String value, long timeout, TimeUnit unit) {
        boolean result = false;
        try {
            redisTemplate.opsForValue().set(key, value, timeout, unit);
            result = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 更新缓存
     */
    public boolean getAndSet(final String key, String value) {
        boolean result = false;
        try {
            redisTemplate.opsForValue().getAndSet(key, value);
            result = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 删除缓存
     */
    public boolean delete(final String key) {
        boolean result = false;
        try {
            redisTemplate.delete(key);
            result = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
}
```

### 3.改造之前的拦截器，从redis中获取

![image-20221220174953530](http://lzcoder.cn/image-20221220174953530.png)

### 4. 改造登录实现类

```java
@Autowired
RedisUtils redisUtils;

@Override
public BaseResponse<HashMap> login(String userName, String passWord) {
    //包装token
    TUser user = new TUser();
    user.setUsername(userName);
    user.setPassword(passWord);
    //省去校验用户密码等逻辑
    String token= TokenUtils.sign(user);
    redisUtils.set(token,userName,5, TimeUnit.MINUTES);
    HashMap<String,Object> hs=new HashMap<>();
    hs.put("token",token);
    return RespGenerator.returnOK(hs);
}
```

### 5.验证效果

1. 登录时，将token和有效时间存入redis

![image-20221220174801967](http://lzcoder.cn/image-20221220174801967.png)

2. 当redis中存在未过期的token数据时，通过拦截器

![image-20221220174846383](http://lzcoder.cn/image-20221220174846383.png)
