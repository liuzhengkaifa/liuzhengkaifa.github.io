---
title: MyBatisPlus使用
tags:
  - MyBatisPlus
categories:
  - java
abbrlink: 13718
date: 2021-12-28 11:21:02
---

MyBatis-Plus是MyBatis的增强版，使用MyBatis-Plus可以快速开发，SQL语句都不用写了，分页也是自动完成，真香~

<!--more-->

# 一、数据库准备

这里创建一张简单的用户表供测试使用，可直接执行以下sql执行生成

```sql
CREATE TABLE tbl_user
(
    user_id   BIGINT(20)
        NOT NULL COMMENT
        '主键ID',
    user_name VARCHAR(30)
        NULL DEFAULT NULL COMMENT
        '姓名',
    user_age  INT(11)
        NULL DEFAULT NULL COMMENT
        '年龄',
    PRIMARY KEY (user_id)
) charset =utf8;
```

# 二、MyBatis-Plus加持

## 1、工程搭建

## 2、pom依赖导入

这里主要导入mybatis-plus依赖，lombok依赖，Druid和mysql连接依赖

![image-20211228113444901](http://lzcoder.cn/image-20211228113444901.png)



# 三、业务编写

# 四、实际实验

# 五、分页实现





