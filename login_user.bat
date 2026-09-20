@echo off
set PATH=%LOCALAPPDATA%\Pub\Cache\bin;%PATH%
echo ===================================================
echo Logging in as: singarapuyathendranadh8@gmail.com
echo ===================================================
echo.
echo Browser will open now. Please select:
echo singarapuyathendranadh8@gmail.com
echo.
call firebase login:add singarapuyathendranadh8@gmail.com
call firebase login:use singarapuyathendranadh8@gmail.com
echo.
echo Now configuring Flutter app for project planning-with-ai-972d8...
call flutterfire configure --project=planning-with-ai-972d8 --platforms=android,web -y
echo.
echo Deploying Firestore rules and Auth configuration...
call firebase deploy --only auth,firestore:rules --project planning-with-ai-972d8
echo.
echo ===================================================
echo Finished! You can press any key to close this.
echo ===================================================
pause
