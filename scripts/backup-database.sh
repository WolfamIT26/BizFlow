#!/bin/bash

# Script tự động backup database MySQL từ Docker container

echo "🔄 Đang backup database..."

# Backup vào file với timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="db/backups/bizflow_backup_${TIMESTAMP}.sql"

# Tạo folder backups nếu chưa có
mkdir -p db/backups

# Backup database
docker exec bizflow-mysql mysqldump -uroot -p123456 \
  --databases bizflow_db \
  --no-tablespaces \
  --skip-comments \
  --skip-extended-insert > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup thành công: $BACKUP_FILE"
    
    # Cập nhật file backup chính để push lên GitHub (không có timestamp)
    cp "$BACKUP_FILE" db/init/database-backup.sql
    echo "✅ Đã cập nhật db/init/database-backup.sql"
    
    # Hiển thị kích thước file
    ls -lh "$BACKUP_FILE"
    
    echo ""
    echo "📌 Để push lên GitHub, chạy:"
    echo "   git add db/init/database-backup.sql"
    echo "   git commit -m \"Update database backup\""
    echo "   git push origin main"
else
    echo "❌ Backup thất bại!"
    exit 1
fi
