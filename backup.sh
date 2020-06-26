#!bin/bash
# 数据库用户名和密码
username=***
password=***

# mysql的docker容器ID
dockerId=***

# 备份文件
backupFile="mysql_backup/`date +%Y_%m_%dT%H_%M_%Ss`.sql.gz"

# 创建保存目录
mkdir -p mysql_backup

# 执行备份任务
docker exec $dockerId /usr/bin/mysqldump --all-databases -u"$username" -p"$password" | gzip > $backupFile

echo $backupFile
