@echo off
setlocal
cd /d "%~dp0"

echo =======================================
echo Starting SQL Database Backup and Push
echo Date: %DATE% %TIME%
echo =======================================

echo.
echo [1/2] Extracting database schema structure...
python backup_db_schema.py

if %ERRORLEVEL% neq 0 (
    echo =======================================
    echo ERROR: Database schema extraction failed!
    echo =======================================
    exit /b %ERRORLEVEL%
)

echo.
echo [2/2] Pushing schema updates to GitHub...
python git_push_backup.py

if %ERRORLEVEL% neq 0 (
    echo =======================================
    echo ERROR: Git push failed!
    echo =======================================
    exit /b %ERRORLEVEL%
)

echo =======================================
echo Backup and Push Completed Successfully!
echo =======================================

exit /b 0
