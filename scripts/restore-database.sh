#!/bin/bash

# Script restore database từ backup

BACKUP_FILE="${1:-db/init/database-backup.sql}"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Không tìm thấy file backup: $BACKUP_FILE"
    echo "Usage: ./scripts/restore-database.sh [backup-file]"
    exit 1
fi

echo "🔄 Đang restore database từ: $BACKUP_FILE"

# Import vào MySQL container
docker exec -i bizflow-mysql mysql -uroot -p123456 < "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Restore thành công!"
    echo "📌 Mở phpMyAdmin để kiểm tra: http://localhost:8081"
else
    echo "❌ Restore thất bại!"
    exit 1
fi
