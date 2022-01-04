---
title: MySQL时间查询不走索引了？
tags:
  - MySQL
  - 索引
categories:
  - MySQL
abbrlink: 19588
date: 2021-11-29 22:53:22
---

今天在根据时间查询表数据时，赶紧查询效率慢，于是在时间字段加了普通索引，然而查询效率仍然慢，于是Explain下发现走的仍然是全表扫描，为什么呢？加了索引为什么没生效？索引的失效条件好像也没说有时间相关内容，本着追根溯源的求知欲，于是有了这篇短记。

<!--more-->

# 一、情景复现

数据表`error_log_info`大约有87760条数据记录

通过添加普通索引

```
CREATE INDEX error_date_index on error_log_info(errordate);
```

为errordate字段添加了索引，然后执行

```
EXPLAIN SELECT * from error_log_info where errordate > '2021-11-29 12:00:22';
```

explain结果发现 type:ALL，走的是全表扫描查询，key为空代表未使用索引，rows:82247行，估计的扫描行数近似于全表行数。显示在该查询中确实没有走建立的时间索引而是走了全表扫描

![image-20211129230326737](http://lzcoder.cn/image-20211129230326737.png)

然后我将时间缩短，让查询出的记录数变少

```
EXPLAIN SELECT * from error_log_info where errordate > '2021-11-29 22:00:22';
```

![image-20211129231057523](http://lzcoder.cn/image-20211129231057523.png)

explain结果发现type:range，没有走全表扫描查询，key：error_date_index走了添加的时间索引，rows:2847,显示预估的扫描行数也比之前少了很多，这种情况下发现确实又走了索引。

到底是什么情况，只是查询的范围不一样，为什么会有时走索引有事不走呢？

# 二、索引失效的几种原因

先回顾下几种使得索引失效的原因：

1. where中索引列有运算
2. where中索引使用了函数方法
3. 复合索引未用左列字段
4. like 以 %开头
5. 条件有or关键字
6. 需要类型转换
7. MySQL觉得全表扫描更快

几种不推荐使用索引的场景：

1. 数据唯一性差（一个字段的取值只有几种时）的字段不要使用索引
2. 频繁更新的字段
3. 字段不在where语句出现时不要添加索引,如果where后含IS NULL /IS NOT NULL/ like ‘%输入符%’等条件，不建议使用索引
4.  where 子句里对索引列使用不等于（<>），使用索引效果一般

[点击跳转参考博客](https://www.cnblogs.com/liehen2046/p/11052666.html)

# 三、结论

经过查证官网

![image-20211129232313911](http://lzcoder.cn/image-20211129232313911.png)

大意是：

> Each table index is queried, and the best index is used unless the optimizer believes that it is more efficient to use a table scan.

表中的每个索引都会被访问，当中最佳的那个则会被使用，除非优化器认为使用全表查询比使用所有查询更高效。(也就是上面列的第七条)

> At one time, a scan was used based on whether the best index spanned more than 30% of the table, but a fixed percentage no longer determines the choice between using an index or a scan.

曾经，是否进行全表扫描取决于使用最好的索引查出来的数据是否超过表的30%的数据，但是现在这个固定百分比(30%)不再决定使用索引还是全表扫描了。

> The optimizer now is more complex and bases its estimate on additional factors such as table size, number of rows, and I/O block size.

优化器现在变得更复杂，它考虑的因素更多，比如表大小、行数量、IO块大小。



通俗点讲：

我们建的索引并不是总会起作用的，中间有查询优化器插足，它会判断一个查询SQL是否走索引查得更快，若是，就走索引，否则做全表扫描。

以前有个百分比(30%)决定SQL是走索引还是走全表扫描，就是说如果总共有100行记录，走索引查询出来的记录超过30条，那还不如不走索引了。

但是现在MySQL不这么干了，不只通过这个百分比来决定走不走索引，而是要参考更多因素来做决定。



**最终得出的结论是，索引失效并不是因为字段类型为时间类型，而是因为查询优化器会对SQL的执行计划进行判断，选择一个最优最快的查询方式，当走索引的代价高于全表扫描时就不会采取走索引的方式去执行SQL。**
