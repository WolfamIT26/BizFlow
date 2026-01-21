@echo off
chcp 65001 >nul
REM Script tự động restore database từ backup đầy đủ (Windows)

echo 🔍 Sử dụng file backup đầy đủ...

REM File backup đầy đủ
set LATEST_BACKUP=db\init\database-full.sql

if not exist "%LATEST_BACKUP%" (
    echo ❌ Không tìm thấy file backup: %LATEST_BACKUP%
    pause
    exit /b 1
)

echo 📦 File backup: %LATEST_BACKUP%
echo ⏳ Đang restore database...

REM Restore database
docker-compose exec -T mysql mysql -u root -p123456 bizflow_db < "%LATEST_BACKUP%" 2>nul

if %errorlevel% equ 0 (
    echo ✅ Restore database thành công!
    echo 🎉 Database đã có đầy đủ data
) else (
    echo ❌ Restore thất bại. Kiểm tra lại MySQL container có đang chạy không:
    echo    docker-compose ps mysql
)

pause
