#!/bin/bash
# ===================================================================
# SCRIPT SETUP DATABASE - BIZFLOW 24 BẢNG
# ===================================================================

echo "╔══════════════════════════════════════════════════════════╗"
echo "║       BIZFLOW DATABASE SETUP - 24 BẢNG CHUẨN            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Thông tin kết nối MySQL
DB_USER="root"
DB_NAME="bizflow_db"

# Kiểm tra MySQL đã cài chưa
echo "🔍 Kiểm tra MySQL..."
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL chưa được cài đặt!${NC}"
    echo "Vui lòng cài MySQL trước: https://dev.mysql.com/downloads/mysql/"
    exit 1
fi
echo -e "${GREEN}✅ MySQL đã cài đặt${NC}"
echo ""

# Nhập mật khẩu
echo "🔐 Vui lòng nhập mật khẩu MySQL root:"
read -s DB_PASS
echo ""

# Test kết nối
echo "🔌 Test kết nối MySQL..."
mysql -u $DB_USER -p$DB_PASS -e "SELECT 1" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Không thể kết nối MySQL. Kiểm tra lại username/password!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Kết nối thành công${NC}"
echo ""

# Backup database cũ (nếu tồn tại)
echo "💾 Kiểm tra database cũ..."
DB_EXISTS=$(mysql -u $DB_USER -p$DB_PASS -e "SHOW DATABASES LIKE '$DB_NAME'" | grep $DB_NAME)
if [ ! -z "$DB_EXISTS" ]; then
    echo -e "${YELLOW}⚠️  Database $DB_NAME đã tồn tại!${NC}"
    echo "📦 Tạo backup..."
    BACKUP_FILE="backup_${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"
    mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Backup thành công: $BACKUP_FILE${NC}"
    else
        echo -e "${RED}❌ Backup thất bại!${NC}"
        exit 1
    fi
    echo ""
    
    echo -e "${YELLOW}🗑️  Xóa database cũ...${NC}"
    mysql -u $DB_USER -p$DB_PASS -e "DROP DATABASE IF EXISTS $DB_NAME"
fi

# Tạo schema mới
echo "🏗️  Tạo schema mới (24 bảng)..."
mysql -u $DB_USER -p$DB_PASS < db/init/001_schema_new.sql
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Schema đã tạo thành công${NC}"
else
    echo -e "${RED}❌ Tạo schema thất bại!${NC}"
    exit 1
fi
echo ""

# Import dữ liệu mẫu
echo "📊 Import dữ liệu mẫu..."
mysql -u $DB_USER -p$DB_PASS < db/init/002_seed_new.sql
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dữ liệu mẫu đã import${NC}"
else
    echo -e "${RED}❌ Import dữ liệu thất bại!${NC}"
    exit 1
fi
echo ""

# Kiểm tra số lượng bảng
echo "🔍 Kiểm tra số lượng bảng..."
TABLE_COUNT=$(mysql -u $DB_USER -p$DB_PASS -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME'" | tail -n 1)
echo "Số bảng hiện có: $TABLE_COUNT"

if [ $TABLE_COUNT -ge 24 ]; then
    echo -e "${GREEN}✅ Đã có đủ 24 bảng!${NC}"
else
    echo -e "${RED}❌ Chưa đủ 24 bảng! Có vấn đề xảy ra.${NC}"
    exit 1
fi
echo ""

# Liệt kê tất cả bảng
echo "📋 Danh sách các bảng:"
mysql -u $DB_USER -p$DB_PASS -e "USE $DB_NAME; SHOW TABLES;"
echo ""

# Chạy test
echo "🧪 Chạy test database..."
mysql -u $DB_USER -p$DB_PASS < db/init/test_database.sql > test_results.txt
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test hoàn tất. Xem kết quả trong: test_results.txt${NC}"
else
    echo -e "${YELLOW}⚠️  Test có lỗi, nhưng database đã được tạo${NC}"
fi
echo ""

# Thống kê
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  SETUP HOÀN TẤT ✅                      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "📊 THỐNG KÊ:"
echo "   - Database: $DB_NAME"
echo "   - Số bảng: $TABLE_COUNT"
echo "   - Dữ liệu mẫu: ✅"
echo "   - Backup: ${BACKUP_FILE:-Không cần}"
echo ""
echo "🚀 CÁCH SỬ DỤNG:"
echo "   mysql -u $DB_USER -p $DB_NAME"
echo ""
echo "📖 TÀI LIỆU:"
echo "   - Cấu trúc: DATABASE_STRUCTURE.md"
echo "   - ERD: db/ERD_DIAGRAM.md"
echo "   - Hướng dẫn: db/README.md"
echo "   - Tóm tắt: SUMMARY.md"
echo ""
echo -e "${GREEN}🎉 Chúc mừng! Database đã sẵn sàng để sử dụng!${NC}"
