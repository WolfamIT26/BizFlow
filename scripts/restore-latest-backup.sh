#!/bin/bash

# Script tự động restore database backup mới nhất

echo "🔍 Tìm file backup mới nhất..."

# Tìm file backup mới nhất trong db/backups/
LATEST_BACKUP=$(ls -t db/backups/bizflow_backup_*.sql 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Không tìm thấy file backup nào trong db/backups/"
    exit 1
fi

echo "📦 File backup: $LATEST_BACKUP"
echo "⏳ Đang restore database..."

# Restore database
docker-compose exec -T mysql mysql -u root -p123456 bizflow_db < "$LATEST_BACKUP" 2>&1 | grep -v "Warning"

if [ $? -eq 0 ]; then
    echo "✅ Restore database thành công!"
    echo "🎉 Database đã có đầy đủ data"
else
    echo "❌ Restore thất bại. Kiểm tra lại MySQL container có đang chạy không:"
    echo "   docker-compose ps mysql"
fi
