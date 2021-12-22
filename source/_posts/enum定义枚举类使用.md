---
title: enum定义枚举类使用
tags:
  - java
categories:
  - java
abbrlink: 33325
date: 2021-12-15 23:57:54
---

 以往的项目中总会定义一些常量提供使用，当类别较多时并不好理解和维护，jdk5后支持enum使用枚举类，能够更简洁，约束性更强。下面简单介绍下enum枚举类的使用。

<!--more-->

# 一、使用enum定义枚举类的说明

```java
public enum SeasonEnum {
    SPRING("春天","春风又绿江南岸"),
    SUMMER("夏天","映日荷花别样红"),
    AUTUMN("秋天","秋水共长天一色"),
    WINTER("冬天","窗含西岭千秋雪");
    private final String seasonName;
    private final String seasonDesc;
    private SeasonEnum(String seasonName, String seasonDesc) {
        this.seasonName = seasonName;
        this.seasonDesc = seasonDesc;
    }
    public String getSeasonName() {
        return seasonName;
    }
    public String getSeasonDesc() {
        return seasonDesc;
    }
}
```

1. 使用enum定义的枚举类默认继承了java.lang.Enum类，因此**不能够继承其他类**，但可以实现接口
2. 枚举类的构造器只能使用**private**权限修饰符，即不能通过外部生成枚举类对象
3. 枚举类的所**有实例必须在第一行声明，显式列出（,分割；结尾），列出的实例系统会自动添加public static final修饰**
4. jdk1.5中可以在switch表达式中使用Enum定义枚举类的对象作为表达式

# 二、enum类的主要方法

## 1、values()

用于返回枚举实例的对象数组，可以方便遍历当前枚举类的所有枚举值

```java
@Test
public void testEnumValuesMethod(){
    SeasonEnum[] seasonEnums = SeasonEnum.values();
    for(SeasonEnum seasonEnum:seasonEnums){
    	System.out.println(seasonEnum);
    }
}
```

![image-20211216001619105](http://r31aaelmi.hn-bkt.clouddn.com/image-20211216001619105.png)

## 2、ordinal()

返回枚举实例的序数，从0开始

![image-20211216002126994](http://r31aaelmi.hn-bkt.clouddn.com/image-20211216002126994.png)

## 3、name()

用于返回枚举类型实例名称

![image-20211216002352584](http://r31aaelmi.hn-bkt.clouddn.com/image-20211216002352584.png)

## 4、values of()

用于返回指定名称的枚举实例

![image-20211216002824596](http://r31aaelmi.hn-bkt.clouddn.com/image-20211216002824596.png)

## 5、switch

用于switch-case语句中

![image-20211216003038841](http://r31aaelmi.hn-bkt.clouddn.com/image-20211216003038841.png)
