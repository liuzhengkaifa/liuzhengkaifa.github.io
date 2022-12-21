---
title: SpringBoot单元测试类编写
tags:
  - 实操
categories:
  - java
abbrlink: 34566
date: 2022-12-20 15:24:04
---

基于springboot项目编写简单单元测试类

<!--more-->

# 1. 编写简单单元测试类

1. 实用idea 生成测试类

![image-20221220152828884](http://lzcoder.cn/image-20221220152828884.png)

![image-20221220153003683](http://lzcoder.cn/image-20221220153003683.png)

2. 编写代码：

`@SpringBootTest`：获取启动类，加载配置，寻找主配置启动类（被 @SpringBootApplication 注解的）

`@RunWith(SpringRunner.class)`：让JUnit运行Spring的测试环境,获得Spring环境的上下文的支持

```java
package com.coder.lion.demo.service.user.service;

import com.coder.lion.CoderLionApplication;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = CoderLionApplication.class,webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ITUserServiceTest {

    @Autowired
    ITUserService itUserService;
    
    @Test
    void getAllUser() {
        itUserService.getAllUser();
    }
}
```

# 2.Assert 用法示例

```java
Assert.notNull(Object object, “object is required”) - 对象非空
Assert.isTrue(Object object, “object must be true”) - 对象必须为true
Assert.notEmpty(Collection collection, “collection must not be empty”) - 集合非空
Assert.hasLength(String text, “text must be specified”) - 字符不为null且字符长度不为0
Assert.hasText(String text, “text must not be empty”) - text 不为null且必须至少包含一个非空格的字符
Assert.isInstanceOf(Class clazz, Object obj, “clazz must be of type [clazz]”) - obj必须能被正确造型成为clazz 指定的类
```

[参考：Springboot+Junit测试Http请求实例包括Get,Post,Put和Delete已及断言Assert的使用](https://blog.csdn.net/u011550710/article/details/76638893)

[参考：Spring Assert教程](https://blog.csdn.net/neweastsun/article/details/80152756)

[插件：自动生成单元测试，太爽了！](https://mp.weixin.qq.com/s/T8jDFRncLb6C0_tPsu88xA)

# 3.阿里开发文档_单元测试规范

1. 【强制】好的单元测试必须遵守 AIR 原则。
说明：单元测试在线上运行时，感觉像空气（AIR）一样感觉不到，但在测试质量的保障上，却是非常关键
的。好的单元测试宏观上来说，具有自动化、独立性、可重复执行的特点。
⚫ A：Automatic（自动化）
⚫ I：Independent（独立性）
⚫ R：Repeatable（可重复）
2. 【强制】单元测试应该是全自动执行的，并且非交互式的。测试用例通常是被定期执行的，执
行过程必须完全自动化才有意义。输出结果需要人工检查的测试不是一个好的单元测试。单元
测试中不准使用 System.out 来进行人肉验证，必须使用 assert 来验证。
3. 【强制】保持单元测试的独立性。为了保证单元测试稳定可靠且便于维护，单元测试用例之间
决不能互相调用，也不能依赖执行的先后次序。
反例：method2 需要依赖 method1 的执行，将执行结果作为 method2 的输入。
4. 【强制】单元测试是可以重复执行的，不能受到外界环境的影响。
说明：单元测试通常会被放到持续集成中，每次有代码 check in 时单元测试都会被执行。如果单测对外部
环境（网络、服务、中间件等）有依赖，容易导致持续集成机制的不可用。
正例：为了不受外界环境影响，要求设计代码时就把 SUT 的依赖改成注入，在测试时用 spring 这样的 DI
框架注入一个本地（内存）实现或者 Mock 实现。
5. 【强制】对于单元测试，要保证测试粒度足够小，有助于精确定位问题。单测粒度至多是类级
别，一般是方法级别。
说明：只有测试粒度小才能在出错时尽快定位到出错位置。单测不负责检查跨类或者跨系统的交互逻辑，
那是集成测试的领域。
6. 【强制】核心业务、核心应用、核心模块的增量代码确保单元测试通过。
说明：新增代码及时补充单元测试，如果新增代码影响了原有单元测试，请及时修正。
7. 【强制】单元测试代码必须写在如下工程目录：src/test/java，不允许写在业务代码目录下。
说明：源码编译时会跳过此目录，而单元测试框架默认是扫描此目录。
8. 【推荐】单元测试的基本目标：语句覆盖率达到 70%；核心模块的语句覆盖率和分支覆盖率都
要达到 100%
说明：在工程规约的应用分层中提到的 DAO 层，Manager 层，可重用度高的 Service，都应该进行单元测
试。
9. 【推荐】编写单元测试代码遵守 BCDE 原则，以保证被测试模块的交付质量。
⚫ B：Border，边界值测试，包括循环边界、特殊取值、特殊时间点、数据顺序等。
⚫ C：Correct，正确的输入，并得到预期的结果。
⚫ D：Design，与设计文档相结合，来编写单元测试。
⚫ E：Error，强制错误信息输入（如：非法数据、异常流程、业务允许外等），并得到预期的结果。
10.【推荐】对于数据库相关的查询，更新，删除等操作，不能假设数据库里的数据是存在的，或
者直接操作数据库把数据插入进去，请使用程序插入或者导入数据的方式来准备数据。
反例：删除某一行数据的单元测试，在数据库中，先直接手动增加一行作为删除目标，但是这一行新增数
据并不符合业务插入规则，导致测试结果异常。
11.【推荐】和数据库相关的单元测试，可以设定自动回滚机制，不给数据库造成脏数据。或者对
单元测试产生的数据有明确的前后缀标识。
正例：在阿里巴巴企业智能事业部的内部单元测试中，使用 ENTERPRISE_INTELLIGENCE _UNIT_TEST_
的前缀来标识单元测试相关代码。
12.【推荐】对于不可测的代码在适当的时机做必要的重构，使代码变得可测，避免为了达到测试
要求而书写不规范测试代码。
13.【推荐】在设计评审阶段，开发人员需要和测试人员一起确定单元测试范围，单元测试最好覆
盖所有测试用例（UC）。
14.【推荐】单元测试作为一种质量保障手段，在项目提测前完成单元测试，不建议项目发布后补
充单元测试用例。
15.【参考】为了更方便地进行单元测试，业务代码应避免以下情况：
⚫ 构造方法中做的事情过多。
⚫ 存在过多的全局变量和静态方法。
⚫ 存在过多的外部依赖。
⚫ 存在过多的条件语句。
说明：多层条件语句建议使用卫语句、策略模式、状态模式等方式重构。
16.【参考】不要对单元测试存在如下误解：
⚫ 那是测试同学干的事情。本文是开发手册，凡是本文内容都是与开发同学强相关的。
⚫ 单元测试代码是多余的。系统的整体功能与各单元部件的测试正常与否是强相关的。
⚫ 单元测试代码不需要维护。一年半载后，那么单元测试几乎处于废弃状态。
⚫ 单元测试与线上故障没有辩证关系。好的单元测试能够最大限度地规避线上故障。
