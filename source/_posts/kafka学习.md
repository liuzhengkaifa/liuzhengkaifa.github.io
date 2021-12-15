---
title: kafka学习
abbrlink: 7063
date: 2021-12-15 14:40:55
tags:
---





<!--more-->



```
--查看消费组group
kafka-consumer-groups.sh --bootstrap-server 47.97.25.49:9092 --list

--查看偏移量情况
kafka-consumer-groups.sh --bootstrap-server 47.97.25.49:9092 --describe --group test-consumer-group

--偏移量向前偏移10个
kafka-consumer-groups.sh --bootstrap-server 47.97.25.49:9092 --reset-offsets --group test-consumer-group --topic error_log_collect_topic:0,1 --shift-by -10 --execute

--将偏移量设置为最早的
kafka-consumer-groups.sh --bootstrap-server 47.97.25.49:9092 --reset-offsets --group test-consumer-group --to-earliest --topic error_log_collect_topic --execute

--将偏移量设置为最新的
kafka-consumer-groups.sh --bootstrap-server 47.97.25.49:9092 --reset-offsets --group test-consumer-group --to-latest --topic error_log_collect_topic --execute
```

