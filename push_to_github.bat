@echo off
title Push Smart Kitchen Flutter App to GitHub
cd /d "%~dp0"
echo ========================================================
echo  Pushing to https://github.com/monishguntsboina-stack/yathendranadh-flutter
echo ========================================================
git branch -M main
git push -u origin main
echo ========================================================
if %errorlevel% equ 0 (
    echo.
    echo  [SUCCESS] Project pushed to GitHub successfully!
    echo.
) else (
    echo.
    echo  [ERROR] Push failed. Check your internet connection or GitHub credentials.
    echo.
)
echo ========================================================
pause
