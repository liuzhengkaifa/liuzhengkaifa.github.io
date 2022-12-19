---
title: elasticsearch学习与实用
abbrlink: 42050
date: 2022-12-15 10:27:42
tags:
  - 教程
categories:
  - java
---

学习springboot整合ElasticSearch 7.X版本并通过小demo实现基本的增删改查

<!--more-->

1. 引入依赖

```yaml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-data-elasticsearch</artifactId>
</dependency>
```

2. 修改配置文件

```yaml
spring:
  application:
    rest:
      uris: http://xx.XX.XX.XX:9200/
```

3. 新增一些实体类、to类

```java
//实体类
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("t_user")
public class TUser implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private LocalDate birthday;

    private String gender;

    private String username;

    private String password;

    private String remark;

    private String station;

    private String telephone;
    
}

//es实体类
@Data
@Document(indexName = "user_info")
public class UserInfoTO {
    @Id
    private Integer id;

    private LocalDate birthday;

    private String gender;

    private String username;

    private String password;

    private String remark;

    private String station;

    private String telephone;
}
```



4. 实用es新增用户

```java
// 1.创建一个 elasticsearch 持久层接口，类似MP,内置了 es 增删改查方法
@Repository
public interface ITUserEsSevice extends ElasticsearchRepository<UserInfoTO,Integer> {
}

// 2.定义swagger接口
@ApiOperation(value = "新增用户")
@PostMapping("/saveUser")
public void saveUser(@RequestBody TUser tUser){
    itUserService.saveUser(tUser);
}

// 3.实现新增接口
@Autowired
ITUserEsSevice itUserEsSevice;

@Override
public void saveUser(TUser tUser) {
    UserInfoTO userInfoTO = new UserInfoTO();
    BeanUtils.copyProperties(tUser,userInfoTO);
    //保存到Es上
    // itUserEsSevice.save(userInfoTO);
    itUserEsSevice.delete(userInfoTO);
}
```

[参考一：Linux环境下安装Elasticsearch](https://blog.csdn.net/smilehappiness/article/details/118466378)

[参考二：Linux安装Kibana详细教程](https://blog.csdn.net/qq_29917503/article/details/126768884)

[参考三：springboot整合ElasticSearch实战](https://blog.csdn.net/weixin_56995925/article/details/123873580)

[参考四：Spring Data Elasticsearch 实体类注解说明](https://blog.csdn.net/m0_62866192/article/details/121765083) 此博主包含 Elasticsearch 其它系列博文
