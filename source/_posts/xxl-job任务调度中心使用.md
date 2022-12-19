---
title: xxl-job任务调度中心使用
abbrlink: 33086
date: 2022-02-09 15:52:07
tags:
  - 教程
categories:
  - 组件
---

使用开源xxl-job分布式任务调度平台 实现定时任务统一调度管理，开发迅速、学习简单、轻量级、易扩展。

<!--more-->

主要参考官方文档内容

[官方文档](https://www.xuxueli.com/xxl-job/)

[github源码仓库地址](https://github.com/xuxueli/xxl-job)

# xxl-架构图

![image-20220707112919996](http://lzcoder.cn/image-20220707112919996.png)

对于一些老项目，可以采用 httpJobHandler方式，通过接口方式实现定时任务实现，也可以作为心跳检查监控项目运行是否正常

![image-20220707113010978](http://lzcoder.cn/image-20220707113010978.png)
