@echo off
title Push Smart Kitchen Flutter App to GitHub
cd /d "%~dp0"
echo ========================================================
echo  Pushing to https://github.com/yathendranadh/yathendranadh-flutter
echo ========================================================
git branch -M main
git push -u origin main
echo ========================================================
if %errorlevel% equ 0 (
    echo  SUCCESS! Project pushed to GitHub successfully.
) else (
    echo  If it failed:
    echo  1. Make sure you created 'yathendranadh-flutter' repo on GitHub:
    echo     https://github.com/new
    echo  2. Ensure you are logged into your GitHub account: yathendranadh
)
echo ========================================================
pause
