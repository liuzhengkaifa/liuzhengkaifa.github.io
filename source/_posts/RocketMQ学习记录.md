---
title: RocketMQ学习记录
abbrlink: 15460
date: 2022-04-02 15:12:39
tags:
  - 教程
categories:
  - 组件
---

这篇文章旨在主要记录如何快速上手rocketmq

<!-- more-->

参考博文：

[消息中间件的使用场景有哪些](https://www.php.cn/faq/453886.html)

[Kafka、ActiveMQ、RabbitMQ、RocketMQ 区别以及高可用原理 ](https://www.sohu.com/a/289890927_120045139)

[RocketMq安装(windows环境)与Rocketmq-dashboard的web管理页面部署](https://www.cnblogs.com/luckyplj/p/16007605.html)

[RocketMQ消息存储之刷盘机制（原理篇）](https://blog.csdn.net/datastructure18/article/details/124538735)

[RabbitMQ的ack机制](https://blog.csdn.net/sangjunhong/article/details/124147696)



> 如果对于消息队列的功能和性能要求不是很高，那么RabbitMQ就够了，开箱即用。
>
> 如果系统使用消息队列主要场景是处理在线业务，比如在交易系统中用消息队列传递订单，RocketMQ 的低延迟和金融级的稳定性就可以满足。[官网](https://rocketmq.apache.org/)
>
> 要处理海量的消息，像收集日志、监控信息或是前端的埋点这类数据，或是你的应用场景大量使用 了大数据、流计算相关的开源产品，那 Kafka 就是最合适的了。

# 一、部署架构

![image-20220722093028523](http://lzcoder.cn/image-20220722093028523.png)

**角色介绍**

1. Producer：消息的发送者；举例：发信者
2. Consumer：消息接收者；举例：收信者
3. Broker：暂存和传输消息；举例：邮局
4. NameServer：管理Broker；举例：各个邮局的管理机构
5. Topic：区分消息的种类；一个发送者可以发送消息给一个或者多个Topic；一个消息的接收者可以订阅一个或者多个Topic消息
6. Message Queue：相当于是Topic的分区；用于并行发送和接收消息

**角色交互解释**

* NameServer是一个几乎无状态节点，可集群部署，节点之间无任何信息同步。
* Broker部署相对复杂，Broker分为Master与Slave，一个Master可以对应多个Slave，但是一个Slave只能对应一个Master，Master与Slave的对应关系通过指定相同的BrokerName，不同的BrokerId来定义，BrokerId为0表示Master，非0表示Slave。Master也可以部署多个。
* 每个Broker与NameServer集群中的所有节点建立长连接，定时注册Topic信息到所有NameServer。 注意：当前RocketMQ版本在部署架构上支持一Master多Slave，但只有BrokerId=1的从服务器才会参与消息的读负载。
* Producer与NameServer集群中的其中一个节点（随机选择）建立长连接，定期从NameServer获取Topic路由信息，并向提供Topic 服务的Master建立长连接，且定时向Master发送心跳。Producer完全无状态，可集群部署。
* Consumer与NameServer集群中的其中一个节点（随机选择）建立长连接，定期从NameServer获取Topic路由信息，并向提供Topic服务的Master、Slave建立长连接，且定时向Master、Slave发送心跳。Consumer既可以从Master订阅消息，也可以从Slave订阅消息，消费者在向Master拉取消息时，Master服务器会根据拉取偏移量与最大偏移量的距离（判断是否读老消息，产生读I/O），以及从服务器是否可读等因素建议下一次是从Master还是Slave拉取。

**执行流程**

1. 启动NameServer，NameServer起来后监听端口，等待Broker、Producer、Consumer连上来，相当于一个路由控制中心。
2. Broker启动，跟所有的NameServer保持长连接，定时发送心跳包。心跳包中包含当前Broker信息(IP+端口等)以及存储所有Topic信息。注册成功后，NameServer集群中就有Topic跟Broker的映射关系。
3. 收发消息前，先创建Topic，创建Topic时需要指定该Topic要存储在哪些Broker上，也可以在发送消息时自动创建Topic。
4. Producer发送消息，启动时先跟NameServer集群中的其中一台建立长连接，并从NameServer中获取当前发送的Topic存在哪些Broker上，轮询从队列列表中选择一个队列，然后与队列所在的Broker建立长连接从而向Broker发消息。
5. Consumer跟Producer类似，跟其中一台NameServer建立长连接，获取当前订阅Topic存在哪些Broker上，然后直接跟Broker建立连接通道，开始消费消息

## 一、生产者示例

```java
package com.lz.coder.controller;

import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.apache.rocketmq.client.exception.MQClientException;
import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.common.message.Message;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;	
import java.time.format.DateTimeFormatter;
import java.util.Random;

/**
 * @author liuzheng
 * @date 2022年07月19日 17:52
 * @Description TODO
 */

@Slf4j
@RestController
@RequestMapping("/rocketmq")
public class TestRocket {
    @PostMapping("/sendMq")
    public void sendMq(){
        // 1 获取消息生产者
        DefaultMQProducer defaultMQProducer = getRocketMqProducer();

        // 2 启动生产者
        try {
            defaultMQProducer.start();
        } catch (MQClientException e) {
            e.printStackTrace();
        }
        // 3 构建消息对象，主要是设置消息的主题、标签、内容
        JSONObject jsonObject = generateMsgContent();
        Message message = new Message("lucky-topic", "lucky-tag", jsonObject.toString().getBytes());
        // 4 发送消息
        SendResult result = null;
        try {
            result = defaultMQProducer.send(message);
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("SendResult-->" + result);
        // TODO 6 关闭生产者
        defaultMQProducer.shutdown();
    }

    /**
     * 读取配置文件中设置的rocketmq相关属性，创建消息生产者
     */
    private DefaultMQProducer getRocketMqProducer(){
        String mqAddress = "127.0.0.1:9876";
        String groupId = "FLEP_FILE";
        String msgTimeout = "10000";
        String retryWhenSendFailed = "3";
        // 1 创建消息生产者，指定生成组名
        DefaultMQProducer defaultMQProducer = new DefaultMQProducer(groupId);
        // 2 指定NameServer的地址
        defaultMQProducer.setNamesrvAddr(mqAddress);
        // 3 设置消息超时时间
        defaultMQProducer.setSendMsgTimeout(Integer.parseInt(msgTimeout));
        // 4 同步发送消息，如果SendMsgTimeout时间内没有发送成功，则重试retryWhenSendFailed次
        defaultMQProducer.setRetryTimesWhenSendFailed(Integer.parseInt(retryWhenSendFailed));
        return defaultMQProducer;

    }

    /**
     * 模拟生成消息体的内容
     */
    private JSONObject generateMsgContent(){
        JSONObject jsonObject=new JSONObject();
        Random random=new Random();
        int fileId = random.nextInt(10000);
        jsonObject.put("fileId",String.valueOf(fileId));
        LocalDateTime localDateTime=LocalDateTime.now();
        String fileCreateDate = localDateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        jsonObject.put("fileCreateDate",fileCreateDate );
        return jsonObject;
    }
}
```

## 二、消费者示例

```java
package com.lz.coder.controller;
import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import org.apache.rocketmq.client.exception.MQClientException;
import org.apache.rocketmq.common.message.MessageExt;
import org.apache.rocketmq.remoting.common.RemotingHelper;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

/**
 * @author liuzheng
 * @date 2022年07月19日 18:14
 * @Description TODO
 */
@Slf4j
@RestController
@RequestMapping("/rocketmq2")
public class ReceiveRocketMsg {

    @PostMapping("/receiveMqMsg")
    public void receiveMqMsg(){
        // 1 获取消息消费者
        DefaultMQPushConsumer defaultMQPushConsumer = getRocketMqConsumer();

        // 2 进行订阅：注册回调函数，编写处理消息的逻辑
        defaultMQPushConsumer.registerMessageListener((List<MessageExt> list, ConsumeConcurrentlyContext context) -> {

            // try catch(throwable)确保不会因为业务逻辑的异常，导致消息出现重复消费的现象
            // org.apache.rocketmq.client.impl.consumer.ConsumeMessageConcurrentlyService.ConsumeRequest.run()中会对Throwable进行捕获，
            //并且返回ConsumeConcurrentlyStatus.RECONSUME_LATER
            try {
                System.out.println("收到消息--》" + list);
                for (MessageExt messageExt : list) {
                    String message=new String(messageExt.getBody(),RemotingHelper.DEFAULT_CHARSET);
                    JSONObject object=JSONObject.parseObject(message);
                    String fileId = (String) object.get("fileId");
                    String fileCreateDate = (String) object.get("fileCreateDate");
                    log.info(fileId+":"+fileCreateDate);
                }

            } catch (Throwable throwable) {
                throwable.printStackTrace();
            }

            return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
        });

        // 5 启动消费者
        try {
            defaultMQPushConsumer.start();
        } catch (MQClientException e) {
            e.printStackTrace();
        }
        System.out.println("消费者启动成功。。。");

    }

    private DefaultMQPushConsumer getRocketMqConsumer(){

        String mqAddress = "127.0.0.1:9876";
        String consumerGroup = "FLEP-CONSUMER-TEST";

        // 1 创建消费者，指定所属的消费者组名
        DefaultMQPushConsumer defaultMQPushConsumer = new DefaultMQPushConsumer(consumerGroup);
        // 2 指定NameServer的地址
        defaultMQPushConsumer.setNamesrvAddr(mqAddress);
        // 3 指定消费者订阅的主题和标签
        try {
            defaultMQPushConsumer.subscribe("lucky-topic", "*");
        } catch (MQClientException e) {
            e.printStackTrace();
        }
        return defaultMQPushConsumer;
    }
}
```

