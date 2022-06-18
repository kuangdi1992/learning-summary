# HTTP协议

## 介绍

http协议：一种无状态的、应用层的、以请求/应答方式运行的协议，使用可扩展的语义和自描述消息格式，与基于网络的超文本信息系统灵活的互动。



## http消息的格式

![http1](F:\git资料\Learning-summary\Picture\网络\http1.png)

左边为请求行，右边为响应行。

## ABNF操作符

空白字符：用来分隔定义中的各个元素。method SP request-target SP HTTP-version CRLF

选择/：表示多个规则都是可供选择的规则。start-line = request-line / status-line

