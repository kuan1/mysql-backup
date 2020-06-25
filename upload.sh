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