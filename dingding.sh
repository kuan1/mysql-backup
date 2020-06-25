#!bin/bash

# 发送钉钉消息(安全设置使用关键词)
res=$1

apiUrl="****"
formatDate=`date "+%Y-%m-%d %H:%M:%S"` 

title="mysql备份成功"
text="### $title\n$res\n\n$formatDate"

msg="{\"msgtype\":\"markdown\",\"markdown\":{\"title\":\"$title\",\"text\":\"$text\"}}"

curl $apiUrl -H "Content-Type:application/json" -d "$msg"
