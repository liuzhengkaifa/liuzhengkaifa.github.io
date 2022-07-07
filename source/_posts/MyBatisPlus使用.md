---
title: MyBatisPlus使用
tags:
  - MyBatisPlus
categories:
  - java
abbrlink: 13718
date: 2021-12-28 11:21:02
---

MyBatis-Plus是MyBatis的增强版，简称（MP），在MyBatis的基础上只做增强，不做改变，为简化而生，提高开发效率。

<!--more-->

# 一、MyBatis-Plus简介

[官网地址](http://mp.baomidou.com)

[GitHub](https://github.com/baomidou/mybatis-plus)

[Gitee](https://gitee.com/baomidou/mybatis-plus)
[文档发布地址](https://baomidou.com/pages/24112f  )  

## 1.框架结构

![framework](http://lzcoder.cn/mybatis-plus-framework.jpg)

## 2.特性

- **无侵入**：只做增强不做改变，引入它不会对现有工程产生影响，如丝般顺滑
- **损耗小**：启动即会自动注入基本 CURD，性能基本无损耗，直接面向对象操作
- **强大的 CRUD 操作**：内置通用 Mapper、通用 Service，仅仅通过少量配置即可实现单表大部分 CRUD 操作，更有强大的条件构造器，满足各类使用需求
- **支持 Lambda 形式调用**：通过 Lambda 表达式，方便的编写各类查询条件，无需再担心字段写错
- **支持主键自动生成**：支持多达 4 种主键策略（内含分布式唯一 ID 生成器 - Sequence），可自由配置，完美解决主键问题
- **支持 ActiveRecord 模式**：支持 ActiveRecord 形式调用，实体类只需继承 Model 类即可进行强大的 CRUD 操作
- **支持自定义全局通用操作**：支持全局通用方法注入（ Write once, use anywhere ）
- **内置代码生成器**：采用代码或者 Maven 插件可快速生成 Mapper 、 Model 、 Service 、 Controller 层代码，支持模板引擎，更有超多自定义配置等您来使用
- **内置分页插件**：基于 MyBatis 物理分页，开发者无需关心具体操作，配置好插件之后，写分页等同于普通 List 查询
- **分页插件支持多种数据库**：支持 MySQL、MariaDB、Oracle、DB2、H2、HSQL、SQLite、Postgre、SQLServer 等多种数据库
- **内置性能分析插件**：可输出 SQL 语句以及其执行时间，建议开发测试时启用该功能，能快速揪出慢查询
- **内置全局拦截插件**：提供全表 delete 、 update 操作智能分析阻断，也可自定义拦截规则，预防误操作

## 3.支持数据库

> 任何能使用 `MyBatis` 进行 CRUD, 并且支持标准 SQL 的数据库，具体支持情况如下，如果不在下列表查看分页部分教程 PR 您的支持。

- MySQL，Oracle，DB2，H2，HSQL，SQLite，PostgreSQL，SQLServer，Phoenix，Gauss ，ClickHouse，Sybase，OceanBase，Firebird，Cubrid，Goldilocks，csiidb
- 达梦数据库，虚谷数据库，人大金仓数据库，南大通用(华库)数据库，南大通用数据库，神通数据库，瀚高数据库

# 二、快速开始

## 1.数据准备

```sql
-- 创建表
CREATE DATABASE `mybatis_plus` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
    use `mybatis_plus`;
    CREATE TABLE `user` (
    `id` bigint(20) NOT NULL COMMENT '主键ID',
    `name` varchar(30) DEFAULT NULL COMMENT '姓名',
    `age` int(11) DEFAULT NULL COMMENT '年龄',
    `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 插入数据
INSERT INTO user (id, name, age, email) VALUES
(1, 'Jone', 18, 'test1@baomidou.com'),
(2, 'Jack', 20, 'test2@baomidou.com'),
(3, 'Tom', 28, 'test3@baomidou.com'),
(4, 'Sandy', 21, 'test4@baomidou.com'),
(5, 'Billie', 24, 'test5@baomidou.com');
```

## 2.工程环境准备

1. 创建一个SpringBoot项目
2. 导入pom依赖

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>mybatis-plus-boot-starter</artifactId>
        <version>3.5.1</version>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <scope>runtime</scope>
    </dependency>
</dependencies>
```

3. 配置application.yml，添加数据源

```yaml
spring:
# 配置数据源信息
  datasource:
# 配置数据源类型
    type: com.zaxxer.hikari.HikariDataSource
# 配置连接数据库信息
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/mybatis_plus?characterEncoding=utf-8&useSSL=false
    username: root
    password: 123456
```

注意：

> MySQL5.7版本的url：
> jdbc:mysql://localhost:3306/mybatis_plus?characterEncoding=utf-8&useSSL=false
> MySQL8.0版本的url：
> jdbc:mysql://localhost:3306/mybatis_plus?serverTimezone=GMT%2B8&characterEncoding=utf-8&useSSL=false  

4. 编写实体类

```java
@Data
public class User {
    private Long id;

    private String name;

    private Integer age;

    private String email;
}
```

5. 编写mapper

```java
@Repository
public interface UserMapper extends BaseMapper<User> {
}
```

* @Repository 为了让idea不显示错误
* BaseMapper是MyBatis-Plus提供的模板mapper，包含了基本的CRUD操作，泛型为要操作的实体类型

6. 添加扫描

```java
@SpringBootApplication
@MapperScan("com.lz.mybatisplus.mapper")
public class MybatisPlusApplication {
    public static void main(String[] args) {
        SpringApplication.run(MybatisPlusApplication.class, args);
    }

}
```

7. 测试

```java
@SpringBootTest
public class MybatisPlusTest {
    @Autowired
    UserMapper userMapper;

    @Test
    public void testQueryList(){
        List<User> users = userMapper.selectList(null);
        users.stream().forEach(System.out::println);
    }
}
```

# 三、基本CRUD方法

## 1.查询

```java
T selectById(Serializable id);

List<T> selectBatchIds(@Param("coll") Collection<? extends Serializable> idList);

List<T> selectByMap(@Param("cm") Map<String, Object> columnMap);

default T selectOne(@Param("ew") Wrapper<T> queryWrapper) {
    List<T> ts = this.selectList(queryWrapper);
    if (CollectionUtils.isNotEmpty(ts)) {
        if (ts.size() != 1) {
            throw ExceptionUtils.mpe("One record is expected, but the query result is multiple records", new Object[0]);
        } else {
            return ts.get(0);
        }
    } else {
        return null;
    }
}

default boolean exists(Wrapper<T> queryWrapper) {
    Long count = this.selectCount(queryWrapper);
    return null != count && count > 0L;
}

Long selectCount(@Param("ew") Wrapper<T> queryWrapper);

List<T> selectList(@Param("ew") Wrapper<T> queryWrapper);

List<Map<String, Object>> selectMaps(@Param("ew") Wrapper<T> queryWrapper);

List<Object> selectObjs(@Param("ew") Wrapper<T> queryWrapper);

<P extends IPage<T>> P selectPage(P page, @Param("ew") Wrapper<T> queryWrapper);

    <P extends IPage<Map<String, Object>>> P selectMapsPage(P page, @Param("ew") Wrapper<T> queryWrapper);
```



## 2.增加

```java
//增加
int insert(T entity);
```

## 3.删除

```java
int deleteById(Serializable id);

int deleteById(T entity);

int deleteByMap(@Param("cm") Map<String, Object> columnMap);

int delete(@Param("ew") Wrapper<T> queryWrapper);

int deleteBatchIds(@Param("coll") Collection<?> idList);
```

## 4.修改

```java
int updateById(@Param("et") T entity);

int update(@Param("et") T entity, @Param("ew") Wrapper<T> updateWrapper);
```

# 四、通用service

- 通用 Service CRUD 封装[ IService](https://gitee.com/baomidou/mybatis-plus/blob/3.0/mybatis-plus-extension/src/main/java/com/baomidou/mybatisplus/extension/service/IService.java)接口，进一步封装 CRUD 采用 `get 查询单行` `remove 删除` `list 查询集合` `page 分页` 前缀命名方式区分 `Mapper` 层避免混淆，
- 泛型 `T` 为任意实体对象
- 建议如果存在自定义通用 Service 方法的可能，请创建自己的 `IBaseService` 继承 `Mybatis-Plus` 提供的基类
- 对象 `Wrapper` 为 [条件构造器](https://baomidou.com/01.指南/02.核心功能/wrapper.html)

## 1.save

```java
// 插入一条记录（选择字段，策略插入）
boolean save(T entity);
// 插入（批量）
boolean saveBatch(Collection<T> entityList);
// 插入（批量）
boolean saveBatch(Collection<T> entityList, int batchSize);
```

## 2.saveOrUpdate

```java
// TableId 注解存在更新记录，否插入一条记录
boolean saveOrUpdate(T entity);
// 根据updateWrapper尝试更新，否继续执行saveOrUpdate(T)方法
boolean saveOrUpdate(T entity, Wrapper<T> updateWrapper);
// 批量修改插入
boolean saveOrUpdateBatch(Collection<T> entityList);
// 批量修改插入
boolean saveOrUpdateBatch(Collection<T> entityList, int batchSize);
```

## 3.remove

```java
// 根据 entity 条件，删除记录
boolean remove(Wrapper<T> queryWrapper);
// 根据 ID 删除
boolean removeById(Serializable id);
// 根据 columnMap 条件，删除记录
boolean removeByMap(Map<String, Object> columnMap);
// 删除（根据ID 批量删除）
boolean removeByIds(Collection<? extends Serializable> idList);
```

## 4.update

```java
// 根据 UpdateWrapper 条件，更新记录 需要设置sqlset
boolean update(Wrapper<T> updateWrapper);
// 根据 whereWrapper 条件，更新记录
boolean update(T updateEntity, Wrapper<T> whereWrapper);
// 根据 ID 选择修改
boolean updateById(T entity);
// 根据ID 批量更新
boolean updateBatchById(Collection<T> entityList);
// 根据ID 批量更新
boolean updateBatchById(Collection<T> entityList, int batchSize);
```

# 五、常用注解

## 1.@TableName  

> 在实体类类型上添加@TableName("t_user")，标识实体类对应的表  

## 2.@TableId

> 经过以上的测试，MyBatis-Plus在实现CRUD时，会默认将id作为主键列，并在插入数据时，默认基于雪花算法的策略生成id 
>
> 在实体类中uid属性上通过@TableId将其标识为主键    



**常用的主键策略**

| 值                        | 描述                                                         |
| ------------------------- | ------------------------------------------------------------ |
| IdType.ASSIGN_ID（默 认） | 基于雪花算法的策略生成数据id，与数据库id是否设置自增无关     |
| IdType.AUTO               | 使用数据库的自增策略，注意，该类型请确保数据库设置了id自增， 否则无效 |

## 3.@TableField 

> MyBatis-Plus会自动将下划线命名风格转化为驼峰命名风格  
>
> 如实体类属性name，表中字段username
> 此时需要在实体类属性上使用@TableField("username")设置属性所对应的字段名  



## 4.@TableLogic 

物理删除：从数据库表中真实删除数据

逻辑删除：通过数据库表字段值区分数据状态为已删除和未删除

**通过@TableLogic注解实现逻辑删除**

1. 表添加字段用于存储删除状态，且设置默认值0

![image-20220405092838361](http://lzcoder.cn/image-20220405092838361.png)

2. 实体类添加该对应字段，并在该字段上添加注解@TableLogic，即实现逻辑删除

```java
@Data
public class User {
    private Long id;

    private String name;

    private Integer age;

    private String email;
    
    @TableLogic
    private Integer isDeleted;
}
```

# 六、条件构造器和常用接口

## 1.Wrapper介绍

![image-20220405093616098](http://lzcoder.cn/image-20220405093616098.png)

* Wrapper ： 条件构造抽象类，最顶端父类
  * AbstractWrapper ： 用于查询条件封装，生成 sql 的 where 条件
    * QueryWrapper ： 查询条件封装
    * UpdateWrapper ： Update 条件封装
    * AbstractLambdaWrapper ： 使用Lambda 语法
      * LambdaQueryWrapper ：用于Lambda语法使用的查询Wrapper
        * LambdaUpdateWrapper ： Lambda 更新封装Wrapper  

## 2.QueryWrapper

### （一）组装查询条件

```java
@Test
public void test01(){
    //查询用户名包含a，年龄在20到30之间，并且邮箱不为null的用户信息
    //SELECT id,username AS name,age,email,is_deleted FROM t_user WHERE
    is_deleted=0 AND (username LIKE ? AND age BETWEEN ? AND ? AND email IS NOT NULL)
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.like("username", "a")
    .between("age", 20, 30)
    .isNotNull("email");
    List<User> list = userMapper.selectList(queryWrapper);
    list.forEach(System.out::println);
}
```

### （二）组装删除条件

```java
//删除email为空的用户
//DELETE FROM t_user WHERE (email IS NULL)
QueryWrapper<User> queryWrapper = new QueryWrapper<>();
queryWrapper.isNull("email");
//条件构造器也可以构建删除语句的条件
int result = userMapper.delete(queryWrapper);
System.out.println("受影响的行数：" + result);
```

### （三）条件优先级

```java
@Test
public void test04() {
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    //将（年龄大于20并且用户名中包含有a）或邮箱为null的用户信息修改
    //UPDATE t_user SET age=?, email=? WHERE (username LIKE ? AND age > ? OR
    email IS NULL)
    queryWrapper
    .like("username", "a")
    .gt("age", 20)
    .or()
    .isNull("email");
    User user = new User();
    user.setAge(18);
    user.setEmail("user@atguigu.com");
    int result = userMapper.update(user, queryWrapper);
    System.out.println("受影响的行数：" + result);
}


@Test
public void test04() {
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    //将用户名中包含有a并且（年龄大于20或邮箱为null）的用户信息修改
    //UPDATE t_user SET age=?, email=? WHERE (username LIKE ? AND (age > ? OR
    email IS NULL))
    //lambda表达式内的逻辑优先运算
    queryWrapper.like("username", "a")
    .and(i -> i.gt("age", 20).or().isNull("email"));
    User user = new User();
    user.setAge(18);
    user.setEmail("user@atguigu.com");
    int result = userMapper.update(user, queryWrapper);
    System.out.println("受影响的行数：" + result);
}
```



### （四）组装Select子句

```java
@Test
public void test05() {
    //查询用户信息的username和age字段
    //SELECT username,age FROM t_user
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.select("username", "age");
    //selectMaps()返回Map集合列表，通常配合select()使用，避免User对象中没有被查询到的列值
    为null
    List<Map<String, Object>> maps = userMapper.selectMaps(queryWrapper);
    maps.forEach(System.out::println);
}
```

### （五）组装排序条件

```java
QueryWrapper<User> queryWrapper = new QueryWrapper<>();
queryWrapper
.orderByDesc("age")
.orderByAsc("id");
```

### （六）实现子查询

```java
@Test
public void test06() {
    //查询id小于等于3的用户信息
    //SELECT id,username AS name,age,email,is_deleted FROM t_user WHERE (id IN
    (select id from t_user where id <= 3))
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.inSql("id", "select id from t_user where id <= 3");
    List<User> list = userMapper.selectList(queryWrapper);
    list.forEach(System.out::println);
}
```

### （七）常用的条件参数

| 查询方式   | 说明                                                         |
| ---------- | ------------------------------------------------------------ |
| eq         | 等于 =                                                       |
| ne         | 不等于<>                                                     |
| gt         | 大于>                                                        |
| ge         | 大于等于>=                                                   |
| lt         | 小于<                                                        |
| le         | 小于等于                                                     |
| like       | 模糊查询LIKE '%值%'                                          |
| likeLeft   | Like '%值'                                                   |
| likeRigth  | Like '值%'                                                   |
| notLike    | 模糊查询 NOT LIKE                                            |
| in         | in(v0,v1……)                                                  |
| notin      | not in (v0,v1……)                                             |
| inSql      | in (SQL语句)                                                 |
| notInSql   | not in (SQL语句)                                             |
| isNull     | NULL值查询                                                   |
| isNotNull  | not Null值查询                                               |
| groupBy    | group by                                                     |
| orderBy    | 排序                                                         |
| orderByAsc | orderByAsc                                                   |
| exists     | EXISTS 条件语句                                              |
| between    | between                                                      |
| last       | 无视优化规则直接拼接到 sql 的最后 !!!只能调用一次,多次调用以最后一次为准 有sql注入的风险,请谨慎使用 |



## 3.UpdateWrapper

```java
@Test
public void test07() {
    //将（年龄大于20或邮箱为null）并且用户名中包含有a的用户信息修改
    //组装set子句以及修改条件
    UpdateWrapper<User> updateWrapper = new UpdateWrapper<>();
    //lambda表达式内的逻辑优先运算
    updateWrapper
    .set("age", 18)
    .set("email", "user@atguigu.com")
    .like("username", "a")
    .and(i -> i.gt("age", 20).or().isNull("email"));
    //这里必须要创建User对象，否则无法应用自动填充。如果没有自动填充，可以设置为null
    //UPDATE t_user SET username=?, age=?,email=? WHERE (username LIKE ? AND
    (age > ? OR email IS NULL))
    //User user = new User();
    //user.setName("张三");
    //int result = userMapper.update(user, updateWrapper);
    //UPDATE t_user SET age=?,email=? WHERE (username LIKE ? AND (age > ? OR
    email IS NULL))
    int result = userMapper.update(null, updateWrapper);
    System.out.println(result);
}
```

## 4.Condition

> 先判断用户是否选择了这些条件，若选择则需要组装该条件，若没有选择则一定不能组装，以免影响SQL执行的结果  

```java
@Test
public void test08UseCondition() {
    //定义查询条件，有可能为null（用户未输入或未选择）
    String username = null;
    Integer ageBegin = 10;
    Integer ageEnd = 24;
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    //StringUtils.isNotBlank()判断某字符串是否不为空且长度不为0且不由空白符(whitespace)
    构成
    queryWrapper
    .like(StringUtils.isNotBlank(username), "username", "a")
    .ge(ageBegin != null, "age", ageBegin)
    .le(ageEnd != null, "age", ageEnd);
    //SELECT id,username AS name,age,email,is_deleted FROM t_user WHERE (age >=
    ? AND age <= ?)
    List<User> users = userMapper.selectList(queryWrapper);
    users.forEach(System.out::println);
}
```

## 5.LambdaQueryWrapper  

```java
@Test
public void test09() {
    //定义查询条件，有可能为null（用户未输入）
    String username = "a";
    Integer ageBegin = 10;
    Integer ageEnd = 24;
    LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
    //避免使用字符串表示字段，防止运行时错误
    queryWrapper
    .like(StringUtils.isNotBlank(username), User::getName, username)
    .ge(ageBegin != null, User::getAge, ageBegin)
    .le(ageEnd != null, User::getAge, ageEnd);
    List<User> users = userMapper.selectList(queryWrapper);
    users.forEach(System.out::println);
}
```

## 6.LambdaUpdateWrapper  

```java
@Test
public void test10() {
    //组装set子句
    LambdaUpdateWrapper<User> updateWrapper = new LambdaUpdateWrapper<>();
    updateWrapper
    .set(User::getAge, 18)
    .set(User::getEmail, "user@atguigu.com")
    .like(User::getName, "a")
    .and(i -> i.lt(User::getAge, 24).or().isNull(User::getEmail)); //lambda
    表达式内的逻辑优先运算
    User user = new User();
    int result = userMapper.update(user, updateWrapper);
    System.out.println("受影响的行数：" + result);
}
```

# 七、插件

## 一、分页插件

> Mybatis-Plus自带分页插件，只需简单配置即可实现

**添加配置类**

```java
@Configuration
@MapperScan("com.atguigu.mybatisplus.mapper") //可以将主类中的注解移到此处
public class MybatisPlusConfig {
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new
        PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
}
```

**测试**

```java
@Test
public void testPage(){
    //设置分页参数
    Page<User> page = new Page<>(1, 5);
    userMapper.selectPage(page, null);
    //获取分页数据
    List<User> list = page.getRecords();
    list.forEach(System.out::println);
    System.out.println("当前页："+page.getCurrent());
    System.out.println("每页显示的条数："+page.getSize());
    System.out.println("总记录数："+page.getTotal());
    System.out.println("总页数："+page.getPages());
    System.out.println("是否有上一页："+page.hasPrevious());
    System.out.println("是否有下一页："+page.hasNext());
}
```

自定义Sql实现分页

1. UserMapper接口定义接口方法

```java
/
**
* 根据年龄查询用户列表，分页显示
* @param page 分页对象,xml中可以从里面进行取值,传递参数 Page 即自动分页,必须放在第一位
* @param age 年龄
* @return
*/
I
Page<User> selectPageVo(@Param("page") Page<User> page, @Param("age")
Integer age);
```

2. UserMapper.xml添加SQL

```xml
<!--SQL片段，记录基础字段-->
<sql id="BaseColumns">id,username,age,email</sql>
<!--IPage<User> selectPageVo(Page<User> page, Integer age);-->
<select id="selectPageVo" resultType="User">
SELECT <include refid="BaseColumns"></include> FROM t_user WHERE age > #
{age}
</select>
```

## 二、乐观锁

悲观锁：在进行写操作是，会将数据列锁起来，等当前连接操作完下一个连接才可以继续操作

乐观锁：不会锁表，会在执行时检查数据是否被修改过，如果被修改过则获重新获取数据再进行操作

**乐观锁实现流程**

1. 数据库中添加version字段  
2. 取出记录时，获取当前version  

```sql
SELECT id,`name`,price,`version` FROM product WHERE id=1
```

3. 更新时，version + 1，如果where语句中的version版本不对，则更新失败

```sql
UPDATE product SET price=price+50, `version`=`version` + 1 WHERE id=1 AND `version`=1
```

  **MyBatis-Plus实现乐观锁**

1. 修改实体类，对应版本号字段添加@Version注解

```java
package com.atguigu.mybatisplus.entity;
import com.baomidou.mybatisplus.annotation.Version;
import lombok.Data;
@Data
public class Product {
    private Long id;
    private String name;
    private Integer price;
    @Version
    private Integer version;
}
```

2. 添加乐观锁插件

```java
/**
 * Date:2022/2/14
 * Author:liuzheng
 * Description:
 */
@Configuration
//扫描mapper接口所在的包
@MapperScan("com.atguigu.mybatisplus.mapper")
public class MyBatisPlusConfig {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor(){
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        //添加分页插件
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        //添加乐观锁插件
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        return interceptor;
    }

}

```

# 八、代码生成器

## 1.导入依赖

```xml
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-generator</artifactId>
    <version>3.5.1</version>
    </dependency>
<dependency>
    <groupId>org.freemarker</groupId>
    <artifactId>freemarker</artifactId>
    <version>2.3.31</version>
</dependency>
```

## 2.快速生成

```java
public class FastAutoGeneratorTest {
    public static void main(String[] args) {
        FastAutoGenerator.create("jdbc:mysql://127.0.0.1:3306/mybatis_plus?
        characterEncoding=utf-8&userSSL=false", "root", "123456")
        .globalConfig(builder -> {
        builder.author("atguigu") // 设置作者
        //.enableSwagger() // 开启 swagger 模式
        .fileOverride() // 覆盖已生成文件
        .outputDir("D://mybatis_plus"); // 指定输出目录
        })
        .packageConfig(builder -> {
        builder.parent("com.atguigu") // 设置父包名
        .moduleName("mybatisplus") // 设置父包模块名
        .pathInfo(Collections.singletonMap(OutputFile.mapperXml, "D://mybatis_plus"));
        // 设置mapperXml生成路径
        })
        .strategyConfig(builder -> {
        builder.addInclude("t_user") // 设置需要生成的表名
        .addTablePrefix("t_", "c_"); // 设置过滤表前缀
        })
        .templateEngine(new FreemarkerTemplateEngine()) // 使用Freemarker
        引擎模板，默认的是Velocity引擎模板
        .execute();
    }
}
```

# 九、多数据源

1. 导入依赖

```xml
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>dynamic-datasource-spring-boot-starter</artifactId>
    <version>3.5.0</version>
</dependency>
```

2. 配置application.yml

```yml
spring:
# 配置数据源信息
  datasource:
# 配置数据源类型
    dynamic:
      # 设置默认的数据源或者数据源组,默认值即为master
	   primary: master
      # 严格匹配数据源,默认false.true未匹配到指定数据源时抛异常,false使用默认数据源
      strict: false
      datasource:
        master:
          # 配置连接数据库信息
          driver-class-name: com.mysql.cj.jdbc.Driver
          url: jdbc:mysql://101.132.140.20:3306/mybatis_plus?characterEncoding=utf-8&useSSL=false
          username: root
          password: lz1024cx
        slave_1:
          # 配置连接数据库信息
          driver-class-name: com.mysql.cj.jdbc.Driver
          url: jdbc:mysql://101.132.140.20:3306/mybatis_plus?characterEncoding=utf-8&useSSL=false
          username: root
          password: lz1024cx
```

3. 使用数据源

```java
@DS("master") //指定所操作的数据源,也可以使用在方法上
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements
UserService {
}
```

# 十、MyBatisX插件

[用法](https://baomidou.com/pages/ba5b24/)
