---
title: 通用sql速查
tags:
  - SQL
categories:
  - 数据库
abbrlink: 13496
date: 2021-11-16 10:02:13
 
---

记录一些常用的sql，便于以后查询实用

<!--more-->



# 一、查询

## 1、查询一张表根据某个字段值有几条重复数据：

```sql
select 字段名,count(1) from 表名 group by 字段名 having count(1)>1;
```

## 2、查询表主键名称

```
select * from user_cons_columns t where t.table_name = '[表名]'
```

## 3、查询表结构以及注释

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

## 4、查看锁表情况及处理

```
select b.owner,b.object_name,a.session_id,a.locked_mode from v$locked_object a,dba_objects b where b.object_id = a.object_id;

select b.username,b.sid,b.serial#,logon_time,b.MACHINE from v$locked_object a,v$session b where a.session_id = b.sid order by b.logon_time;

-- 清除会话，解锁 两个参数分别为：sid 和 serial
alter system kill session'5637,62753';
```

## 5、查询库表内存信息

```sql
SELECT
table_schema  AS  '数据库' ,
SUM(table_rows)  AS  '记录数' ,
SUM(TRUNCATE(data_length/1024/1024, 2))  AS  '数据容量(MB)' ,
SUM(TRUNCATE(index_length/1024/1024, 2))  AS  '索引容量(MB)'
FROM  information_schema.tables
WHERE  table_schema= 'data_sync' ;
```



# 二、增加

## 1、增加主键

```
alter table 表名 add primary key ([字段名1],[字段名2],...)  --重建主键
alter table 表名 add constraint [主键约束名]  primary key ([字段名1],[字段名2],...) --重建主键约束
```

## 2、新增字段

```
alter table 表名 add (字段名 VARCHAR2(500) null);
comment on column 表名.字段名 is '二维码链接地址';
```



# 三、修改

## 1、修改表字段属性

```
alter table table_name modify (col_name nvarchar2(20));
```

## 2、修改字段名称

```
alter table table_name rename column now_col_name to NEW_col_name;
```



# 四、删除

## 1、删除主键

```
alter table [表名] drop primary key --有主键无主键约束名的情形
alter table [表名] drop constraint [主键约束名] --有主键约束名的情形
```

