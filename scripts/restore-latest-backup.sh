#!/bin/bash

# Script tự động restore database từ backup đầy đủ

echo "🔍 Sử dụng file backup đầy đủ..."

# File backup đầy đủ
LATEST_BACKUP="db/init/database-full.sql"

if [ ! -f "$LATEST_BACKUP" ]; then
    echo "❌ Không tìm thấy file backup: $LATEST_BACKUP"
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
