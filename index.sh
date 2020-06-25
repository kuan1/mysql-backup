set -e

# 日志文件
logFile="backup.log"

# 上传文件
echo "开始数据库备份开始..."
bash backup.sh|xargs bash upload.sh|xargs bash dingding.sh >> $logFile
echo "\n" >> $logFile