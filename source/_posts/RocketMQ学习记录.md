---
title: RocketMQ学习记录
abbrlink: 15460
date: 2022-04-02 15:12:39
tags: 
---

这篇文章旨在主要记录如何快速上手rocketmq

<!-- more-->

参考博文：

[消息中间件的使用场景有哪些](https://www.php.cn/faq/453886.html)

[RocketMq安装(windows环境)与Rocketmq-dashboard的web管理页面部署](https://www.cnblogs.com/luckyplj/p/16007605.html)

[RocketMQ消息存储之刷盘机制（原理篇）](https://blog.csdn.net/datastructure18/article/details/124538735)

[RabbitMQ的ack机制](https://blog.csdn.net/sangjunhong/article/details/124147696)

# 一、生产者示例

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

# 二、消费者示例

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

