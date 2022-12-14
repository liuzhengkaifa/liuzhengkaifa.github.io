---
title: springboot整合swagger
abbrlink: 32019
date: 2022-09-29 21:55:12
tags:
---

基于SpringBoot项目使用Swagger文档

<!-- more-->



# 第一步：创建一个SpringBoot项目

![image-20220929224450396](http://lzcoder.cn/image-20220929224450396.png)

# 第二步：导入依赖

```java
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <!--swagger -->
        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger2</artifactId>
            <version>2.9.2</version>
        </dependency>
        <!--swagger-ui.html模式        -->
        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger-ui</artifactId>
            <version>2.9.2</version>
        </dependency>
        <!--doc.html模式        -->
        <dependency>
            <groupId>com.github.xiaoymin</groupId>
            <artifactId>swagger-bootstrap-ui</artifactId>
            <version>1.9.2</version>
        </dependency>
```

# 第三步：修改文件

1. 启动类添加注解  `@EnableSwagger2` 目的是开启默认配置的swagger，也可自定义swagger配置

![image-20220929220705945](http://lzcoder.cn/image-20220929220705945.png)

2. 修改配置文件，pathmatch 配置是因为 Spring Boot 2.6及 更高版本使用的是PathPatternMatcher，而Springfox使用的路径匹配是基于AntPathMatcher的，所以需要配置。端口可以自定义

```
server:
  port: 99

spring:
  mvc:
    pathmatch:
      matching-strategy: ANT_PATH_MATCHER
```

本地输入：http://localhost:99/doc.html 即可访问

# 第四步：实例接口

```java
@Api(tags = "用户接口")
@RestController
@RequestMapping("/userinfo")
public class UserInfoController {

    @ApiOperation(value = "修改用户信息")
    @PostMapping("/updateUserMessage")
    public BaseResponse<Integer> updateUserMessage(@RequestBody UpdateUserTO updateUserTO) {
        return RespGenerator.returnOK("成功");
    }
}


@Data
@ApiModel("修改用户信息传入VO类")
public class UpdateUserTO {
    @ApiModelProperty(value = "用户ID")
    private String uid;

    @ApiModelProperty(value = "用户密码")
    private String password;
}
```

![image-20220929224322619](http://lzcoder.cn/image-20220929224322619.png)

# 第五步：自定义配置类



场景：当在[swagger](https://so.csdn.net/so/search?q=swagger&spm=1001.2101.3001.7020)上进行接口测试时，想要新增token，swagger的默认配置是不行的（直接在启动类上面加@EnableSwagger2注解开启）



```java
package com.coder.lion.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.RestController;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.ParameterBuilder;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.schema.ModelRef;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Parameter;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

import java.util.ArrayList;
import java.util.List;

/**
 * @author liuzheng
 * @date 2022年09月29日 22:47
 * @Description swagger配置类
 */
@Configuration
@EnableSwagger2
@Profile("dev")
public class SwaggerConfig {
    /**
     * 创建API应用 apiInfo() 增加API相关信息
     * 通过select()函数返回一个ApiSelectorBuilder实例,用来控制哪些接口暴露给Swagger来展现，
     * 本例采用指定扫描的包路径来定义指定要建立API的目录。
     *
     * @return
     */
    @Bean
    public Docket createRestApi() {
        // 选择那些路径和api会生成document
        return new Docket(DocumentationType.SWAGGER_2).apiInfo(apiInfo()).pathMapping("/").select()
                // 对所有api进行监控
                .apis(RequestHandlerSelectors.any())
                .apis(RequestHandlerSelectors.withClassAnnotation(RestController.class)).build()
                // 配置token
                .globalOperationParameters(setHeaderToken());
    }

    /**
     * 配置token
     *
     * @return
     */
    private List<Parameter> setHeaderToken() {
        ParameterBuilder tokenPar = new ParameterBuilder();
        List<Parameter> pars = new ArrayList<>();
        tokenPar.name("Authorization").description("token").modelRef(new ModelRef("string")).parameterType("header")
                .required(false).build();
        pars.add(tokenPar.build());
        return pars;
    }

    /**
     * 创建该API的基本信息（这些基本信息会展现在文档页面中）
     *
     * @return
     */
    private ApiInfo apiInfo() {
        return new ApiInfoBuilder().title("测试接口文档").description("测试接口文档").version("1.0").build();
    }
}

```

> @Configuration：用于定义配置类，可替换xml配置文件，被注解的类内部包含有一个或多个被@Bean注解的方法，这些方法将会被AnnotationConfigApplicationContext或AnnotationConfigWebApplicationContext类进行扫描，并用于构建bean定义，初始化Spring容器，简而言之就是在Spring启动时会将该类识别成一个配置类。
> @EnableSwagger2：开启swagger，此处也需要使用。
>
> 到此处即可完成使用自定义的swagger，若有其他需求修改该配置类即可，另外此处另外提到一个注解Profile，此处可以不使用，在实际开发中可能存在多个环境，测试环境，正式环境等，可能需要使用不同的配置，此时可以使用Profile注解。
> @Profile("swagger")：指定组件在哪个环境的情况下才能被注册到容器中，不指定，任何环境下都能注册这个组件。
>
> yml配置文件在开发时可能存在多个，因此可以指定具体哪一个环境可以开启该配置
