## 通过 shell 自动备份 mysql 到七牛云并发送钉钉消息

### 一、简介

所有功能通过 `shell` 实现

1. 定时备份数据库
1. 使用 `shell` 上传七牛云
1. 上传结果发送钉钉消息

### 设置定时任务

（1） 打开定时任务

```bash
crontab -e
```

（2）编辑定时任务

```bash
# 每天五点开始备份数据库
0 5 * * * cd /root/mysql-backup;/bin/bash /root/mysql-backup/index.sh

```

### 二、shell 文件介绍

#### （1）index.sh

关联三个 `shell`，`mysql`->上传七牛云->上传结果发送钉钉消息，保存日志到 `backup.log`

```bash
set -e

# 日志文件
logFile="backup.log"

# 上传文件
echo "开始数据库备份开始..."
bash backup.sh|xargs bash upload.sh|xargs bash dingding.sh >> $logFile
echo "\n" >> $logFile
```

#### （2）backup.sh

备份数据库 shell

```bash
#!bin/bash
# 数据库用户名和密码
username=****
password=****

# mysql的docker容器ID/名称
dockerId=****

# 备份文件
backupFile="`pwd`/mysql_backup/`date +%Y-%m-%dT%H:%M:%S`.sql.gz"

# 创建保存目录
mkdir -p mysql_backup

# 执行备份任务
docker exec -it $dockerId /usr/bin/mysqldump --all-databases -u"$username" -p"$password" | gzip > $backupFile

echo $backupFile
```

#### （3）upload.sh

用 shell 通过 accesskey/secretkey 获取七牛上传凭证 并上传七牛云

```bash
# 第一个参数为上传文件名字
file=$1
if [ -z $file ]; then
  echo "请指定上传文件!"
  exit
fi

# 上传配置
url=http://upload.qiniup.com  #存储区域见 https://developer.qiniu.com/kodo/manual/1671/region-endpoint
bucket=***
accesskey=****
secretkey=***

# 设置过期时间1小时
deadline=$(echo `date +%s` + 3600| bc )

# 构造JSON格式的上传策略
putPolicy="{\"scope\":\"$bucket\",\"deadline\":$deadline}"

# 对上传策略进行Base64编码
encodedPutPolicy=`echo -n "$putPolicy" | base64 | tr "+/" "-_"`

# 使用访问密钥secretkey对Base64上传策略进行HMAC-SHA1签名，并对签名进行Base64编码
encodedSign=`echo -n "$encodedPutPolicy" | openssl sha1 -hmac $secretkey -binary | base64 | tr "+/" "-_"`

# 拼接token
uploadToken="$accesskey:$encodedSign:$encodedPutPolicy"

# 使用curl上传
curl -s -F "file=@$file" -F "key=$file" -F "token=$uploadToken" $url

# 代码来自github：https://github.com/helphi/qiniu
# 参考
# https://developer.qiniu.com/kodo/manual/1272/form-upload
```

#### （4）dingding.sh

利用 shell 发送钉钉消息

```bash
#!bin/bash

# 发送钉钉消息(安全设置使用关键词)
res=$1

apiUrl="****"
formatDate=`date "+%Y-%m-%d %H:%M:%S"`

title="mysql备份成功"
text="### $title\n$res\n\n$formatDate"

msg="{\"msgtype\":\"markdown\",\"markdown\":{\"title\":\"$title\",\"text\":\"$text\"}}"

curl $apiUrl -H "Content-Type:application/json" -d "$msg"

```
