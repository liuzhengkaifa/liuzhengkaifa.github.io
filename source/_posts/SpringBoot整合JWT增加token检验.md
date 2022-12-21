---
title: SpringBoot整合JWT增加token检验
tags:
  - 实操
categories:
  - java
abbrlink: 2551
date: 2022-12-15 16:27:17
---

SpringBoot项目整合JWT对拦截器放过的请求生成token，拦截的请求校验token。达到对接口校验拦截目的。

<!--more-->

### 1.增加配置

```xml
<!-- https://mvnrepository.com/artifact/com.auth0/java-jwt -->
<dependency>
    <groupId>com.auth0</groupId>
    <artifactId>java-jwt</artifactId>
    <version>3.9.0</version>
</dependency>
```

### 2.增加拦截器

#### 1. web请求拦截器

```java
package com.coder.lion.demo.config.interceptor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ConcurrentTaskExecutor;
import org.springframework.web.servlet.config.annotation.AsyncSupportConfigurer;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;

/**
 * @author liuzheng
 * @date 2022年12月20日 16:32
 * @Description web请求拦截器
 */
@Configuration
public class WebConfiguration implements WebMvcConfigurer {

    @Autowired
    private TokenInterceptor tokenInterceptor;

    /**
     * 解决跨域请求
     * @param registry
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedHeaders("*")
                .allowedMethods("*")
//                .allowedOrigins("*")
                .allowedOriginPatterns("*")
                .allowCredentials(true);
    }

    /**
     * 异步请求配置
     * @param configurer
     */
    @Override
    public void configureAsyncSupport(AsyncSupportConfigurer configurer) {
        configurer.setTaskExecutor(new ConcurrentTaskExecutor(Executors.newFixedThreadPool(3)));
        configurer.setDefaultTimeout(30000);
    }

    /**
     * 配置拦截器、拦截路径
     * 每次请求到拦截的路径，就会去执行拦截器中的方法
     * @param registry
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        List<String> excludePath = new ArrayList<>();
        //排除拦截，除了注册登录(此时还没token)，其他都拦截
        excludePath.add("/userinfo/login");  //登录
        excludePath.add("/userinfo/register");     //注册
        excludePath.add("/doc.html");     //swagger
        excludePath.add("/swagger-ui.html");     //swagger
        excludePath.add("/swagger-resources/**");     //swagger
        excludePath.add("/v2/api-docs");     //swagger
        excludePath.add("/webjars/**");     //swagger
//        excludePath.add("/static/**");  //静态资源
//        excludePath.add("/assets/**");  //静态资源
        registry.addInterceptor(tokenInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(excludePath);
        WebMvcConfigurer.super.addInterceptors(registry);

    }
}
```

 注意：addInterceptors方法里面需要按自己情况进行修改，excludePath集合add的是需要放行的接口路径，前几章整合了swagger，所以此处需要放行swagger相关的路径，swagger-ui.html、doc.html、swagger-resources、等等，你再加上自己想要放行的接口路径即可，一般是首页请求的接口以及登录注册的接口（不需要进行token效验的接口）。

#### 2. token 拦截器

```java
package com.coder.lion.demo.config.interceptor;

import com.alibaba.fastjson.JSONObject;
import com.coder.lion.demo.utils.TokenUtils;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author liuzheng
 * @date 2022年12月20日 16:30
 * @Description token 拦截器
 */
@Component
public class TokenInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        //跨域请求会首先发一个option请求，直接返回正常状态并通过拦截器
        if(request.getMethod().equals("OPTIONS")){
            response.setStatus(HttpServletResponse.SC_OK);
            return true;
        }
        response.setCharacterEncoding("utf-8");
        String token = request.getHeader("token");
        if (token!=null){
            boolean result= TokenUtils.verify(token);
            if (result){
                System.out.println("通过拦截器");
                return true;
            }
        }
        response.setContentType("application/json; charset=utf-8");
        try {
            JSONObject json=new JSONObject();
            json.put("msg","token verify fail");
            json.put("code","500");
            response.getWriter().append(json.toString());
            System.out.println("认证失败，未通过拦截器");
        } catch (Exception e) {
            return false;
        }
        /**
         * 还可以在此处检验用户存不存在等操作
         */
        return false;
    }
}
```

**注意：此处token从request里面获取header里面的key值是token，你要根据自己的情况来，你在前端header里面传的token叫什么名称，这里就取什么名字。** 

#### 3. token 工具类

```java
package com.coder.lion.demo.utils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTCreationException;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.coder.lion.demo.model.entity.TUser;

import java.util.Date;

/**
 * @author liuzheng
 * @date 2022年12月20日 16:35
 * @Description TODO
 */
public class TokenUtils {

    //token到期时间10小时
    private static final long EXPIRE_TIME= 10*60*60*1000;
    //密钥盐
    private static final String TOKEN_SECRET="ljdyaishijin**3nkjnj??";

    /**
     * 生成token
     * @param user
     * @return
     */
    public static String sign(TUser user){

        String token=null;
        try {
            Date expireAt=new Date(System.currentTimeMillis()+EXPIRE_TIME);
            token = JWT.create()
                    //发行人
                    .withIssuer("auth0")
                    //存放数据
                    .withClaim("username",user.getUsername())
                    //过期时间
                    .withExpiresAt(expireAt)
                    .sign(Algorithm.HMAC256(TOKEN_SECRET));
        } catch (IllegalArgumentException| JWTCreationException je) {

        }
        return token;
    }


    /**
     * token验证
     * @param token
     * @return
     */
    public static Boolean verify(String token){

        try {
            //创建token验证器
            JWTVerifier jwtVerifier=JWT.require(Algorithm.HMAC256(TOKEN_SECRET)).withIssuer("auth0").build();
            DecodedJWT decodedJWT=jwtVerifier.verify(token);
            System.out.println("认证通过：");
            System.out.println("username: " + decodedJWT.getClaim("username").asString());
            System.out.println("过期时间：      " + decodedJWT.getExpiresAt());
        } catch (IllegalArgumentException | JWTVerificationException e) {
            //抛出错误即为验证不通过
            return false;
        }
        return true;
    }
}
```

注意：此处到期时间可以自定义按情况进行设置，1000是1秒。此处token的生成方法以及效验方法可以根据具体情况进行更改，生成token1是使用的jwt，此处验证方法存在一个用户有多个token的情况（可以同时多次登陆同一账号，重新请求token之后，前一次的token只要没有过期也能使用。），可以整合redis后进行改造（后面会讲到），可以达到一个用户只有一个token的效果（重新请求token之后，前一次的token即使没有过期也不能使用。）


### 3. 验证

1. 未携带token，或token不正确 拦截器拦截，请求失败

![image-20221220170539694](http://lzcoder.cn/image-20221220170539694.png)

2. 使用web拦截器放开的接口，获取token

![image-20221220170800574](http://lzcoder.cn/image-20221220170800574.png)

3. 使用获取的token重新请求接口

![image-20221220170840273](http://lzcoder.cn/image-20221220170840273.png)
