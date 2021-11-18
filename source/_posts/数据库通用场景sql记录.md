---
title: 数据库通用场景sql记录
tags:
  - sql
categories:
  - 数据库
abbrlink: 13496
date: 2021-11-16 10:02:13
 
---

记录一些常用的sql，便于以后查询实用

<!--more-->



# 一、查询





查询一张表根据某个字段值有几条重复数据：

```sql
select 字段名,count(1) from 表名 group by 字段名 having count(1)>1;
```





Oracle：

```sql
--1.获取表字段字典
select
t.COLUMN_NAME as "字段名",
decode(c.COMMENTS, null, ' ', c.COMMENTS) as "含义",
decode(t.DATA_TYPE, 'TIMESTAMP(6)', t.DATA_TYPE, 'NUMBER', (t.DATA_TYPE || '(' || t.DATA_PRECISION || ')'),
    'DATE', t.DATA_TYPE, (t.DATA_TYPE || '(' || t.CHAR_LENGTH || ')')) as "长度",
-- t.DATA_TYPE || '(' || t.CHAR_LENGTH || ')' as "类型(长度)",
--  t.CHAR_LENGTH as "字段长度",
t.NULLABLE AS "是否为空"
from USER_TAB_COLUMNS t join USER_COL_COMMENTS c on c.TABLE_NAME = t.TABLE_NAME and t.COLUMN_NAME = c.COLUMN_NAME
where c.TABLE_NAME = 'SK_COLLECT_INFO' --表名应该大写  
order by t.COLUMN_ID;
```



# 二、增加



# 三、修改

数据表新增字段

Oracle：

```
alter table 表名 add (字段名 VARCHAR2(500) null);
comment on column 表名.字段名 is '二维码链接地址';
```



# 四、删除