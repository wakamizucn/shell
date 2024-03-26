#!/bin/bash
#Author:wakamizulee
#Website:www.wakamizu.cn
#describe:备份mysql数据库，成功后删除两天前的备份文件

#mysql连接信息
DB_USER=""
DB_PASSWORD=""
#如果DB_NAME为空，则备份全部
DB_NAME="" 

#备份路径
BACKUP_DIR="/backups/"

#获取当前日期
CURRENT_DATE=$(date +"%Y%m%d")

if [ -z "$DB_NAME" ]; then
    DB_NAME="--all-databases"
fi

mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > "$BACKUP_DIR/mysqlbak.$CURRENT_DATE.sql"

#检查备份是否成功
if [ $? -eq 0 ]; then
    echo "mysql backup completed successfully."
    # 如果成功备份删除两天前的备份文件
    TWO_DAYS_AGO=$(date -d "2 days ago" +"%Y%m%d")
    rm -f "$BACKUP_DIR/mysqlbak.$TWO_DAYS_AGO.sql"
    echo "2 days ago old backup file deleted."
else
    echo "mysql backup failed."
fi
