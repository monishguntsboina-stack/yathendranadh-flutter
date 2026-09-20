@echo off
set PATH=%LOCALAPPDATA%\Pub\Cache\bin;%PATH%
echo ===================================================
echo Connecting Flutter App to Firebase Project:
echo planning-with-ai-972d8
echo ===================================================
echo.
echo [1/3] Authorizing Firebase CLI with your Google account...
call firebase login:add
echo.
echo [2/3] Configuring FlutterFire for Android and Web...
call flutterfire configure --project=planning-with-ai-972d8 --platforms=android,web -y
echo.
echo [3/3] Deploying Auth settings and Firestore Security Rules...
call firebase deploy --only auth,firestore:rules --project planning-with-ai-972d8
echo.
echo ===================================================
echo Setup finished! You can now close this window.
echo ===================================================
pause
