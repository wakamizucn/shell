#!/bin/bash
# Author: wakamizu
# Website: www.wakamizu.cn
# Describe: 备份MySQL数据库，支持多数据库单独备份，成功后删除两天前的备份文件
 
 
# MySQL连接信息
DB_USER="root"
DB_PASSWORD=""
# 如果DB_NAME为空数组，则备份全部数据库
# DB_NAME=("test1" "test2")  
# 如需备份所有数据库请留空：DB_NAME=()
 
# 备份路径
BACKUP_DIR="/backups/"
 
# 日志文件路径
LOG_FILE="$BACKUP_DIR/backup.log"
 
# 获取当前日期（用于备份文件命名）
CURRENT_DATE=$(date +"%Y%m%d_%H%M%S")
TWO_DAYS_AGO=$(date -d "2 days ago" +"%Y%m%d")
 
# 初始化备份状态
dump_ok=0
backup_type=""
 
# 确保备份目录存在
mkdir -p "$BACKUP_DIR" &> /dev/null
 
# 定义日志记录函数
log_entry() {
    local db_name="$1"
    local status="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp--$db_name database backup $status" >> "$LOG_FILE"
}
 
# 判断备份类型（全库或单个数据库）
if [ ${#DB_NAME[@]} -eq 0 ]; then
    # 全库备份
    backup_type="all"
    log_entry "all_databases" "start"
    mysqldump -u"$DB_USER" -p"$DB_PASSWORD" --all-databases > "$BACKUP_DIR/mysqlbak.$CURRENT_DATE.sql" 2>/dev/null
    current_ok=$?
    if [ $current_ok -eq 0 ]; then
        log_entry "all_databases" "successful"
    else
        log_entry "all_databases" "failed"
        dump_ok=$current_ok
    fi
else
    # 逐个备份每个数据库
    backup_type="individual"
    for db_name in "${DB_NAME[@]}"; do
        log_entry "$db_name" "start"
        mysqldump -u"$DB_USER" -p"$DB_PASSWORD" "$db_name" > "$BACKUP_DIR/${db_name}.$CURRENT_DATE.sql" 2>/dev/null
        current_ok=$?
        if [ $current_ok -eq 0 ]; then
            log_entry "$db_name" "successful"
        else
            log_entry "$db_name" "failed"
            dump_ok=$current_ok
        fi
    done
fi
 
# 检查备份是否成功
if [ $dump_ok -eq 0 ]; then
    log_entry "summary" "completed successfully"
 
    # 删除两天前的备份文件
    if [ "$backup_type" = "all" ]; then
        rm -f "$BACKUP_DIR/mysqlbak.$TWO_DAYS_AGO"*.sql
    else
        for db_name in "${DB_NAME[@]}"; do
            rm -f "$BACKUP_DIR/${db_name}.$TWO_DAYS_AGO"*.sql
        done
    fi
else
    log_entry "summary" "failed"
    exit 1
fi
