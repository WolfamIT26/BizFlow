@echo off
REM Script restore database - version don gian khong co emoji

echo [INFO] Tim file backup database...

set LATEST_BACKUP=db\init\database-full.sql

if not exist "%LATEST_BACKUP%" (
    echo [ERROR] Khong tim thay file backup: %LATEST_BACKUP%
    pause
    exit /b 1
)

echo [INFO] File backup: %LATEST_BACKUP%
echo [INFO] Dang restore database...

docker-compose exec -T mysql mysql -u root -p123456 bizflow_db < "%LATEST_BACKUP%" 2>nul

if %errorlevel% equ 0 (
    echo [SUCCESS] Restore database thanh cong!
    echo [INFO] Database da co day du data
) else (
    echo [ERROR] Restore that bai. Kiem tra MySQL container:
    echo         docker-compose ps mysql
)

pause
