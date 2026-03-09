@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "REQUIRED_EMAIL=dangthivan79@gmail.com"
set "PROJECT_ID=autoboostimg-nh2672"
set "FIREBASE_CLI=firebase.cmd"

where %FIREBASE_CLI% >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Khong tim thay Firebase CLI.
  echo [INFO] Cai dat bang lenh: npm i -g firebase-tools
  exit /b 1
)

call :ensure_required_account
if errorlevel 1 exit /b 1

echo [INFO] Dang chon project: %PROJECT_ID%
%FIREBASE_CLI% use %PROJECT_ID%
if errorlevel 1 (
  echo [ERROR] Khong the chon project %PROJECT_ID%.
  exit /b 1
)

echo [INFO] Dang deploy Firebase Hosting...
%FIREBASE_CLI% deploy --only hosting
if errorlevel 1 (
  echo [ERROR] Deploy that bai.
  exit /b 1
)

echo [DONE] Deploy thanh cong cho project %PROJECT_ID%.
exit /b 0

:ensure_required_account
set "ATTEMPT=0"

:retry_login_check
set /a ATTEMPT+=1
call :is_required_current
if errorlevel 1 exit /b 1

if "!IS_CURRENT!"=="1" (
  echo [INFO] Dang su dung dung tai khoan: %REQUIRED_EMAIL%
  exit /b 0
)

if !ATTEMPT! GTR 2 (
  echo [ERROR] Khong the chuyen tai khoan hien tai sang %REQUIRED_EMAIL%.
  echo [INFO] Kiem tra bang lenh: firebase login:list
  exit /b 1
)

echo [INFO] Tai khoan hien tai khong phai %REQUIRED_EMAIL%.
echo [INFO] Mo cua so dang nhap de cap nhat token...
%FIREBASE_CLI% login --reauth
if errorlevel 1 (
  echo [ERROR] Dang nhap Firebase that bai.
  exit /b 1
)
goto :retry_login_check

:is_required_current
set "IS_CURRENT=0"
set "HAS_CURRENT_MARKER=0"
set "LOGIN_LIST_FILE=%TEMP%\firebase_login_list_%RANDOM%%RANDOM%.txt"

%FIREBASE_CLI% login:list > "%LOGIN_LIST_FILE%" 2>&1
if errorlevel 1 (
  del /q "%LOGIN_LIST_FILE%" >nul 2>&1
  echo [WARN] Chua lay duoc danh sach login, thu dang nhap lai...
  %FIREBASE_CLI% login --reauth
  if errorlevel 1 exit /b 1
  %FIREBASE_CLI% login:list > "%LOGIN_LIST_FILE%" 2>&1
  if errorlevel 1 (
    del /q "%LOGIN_LIST_FILE%" >nul 2>&1
    exit /b 1
  )
)

findstr /I /C:"(current)" "%LOGIN_LIST_FILE%" >nul && set "HAS_CURRENT_MARKER=1"

if "!HAS_CURRENT_MARKER!"=="1" (
  findstr /I /C:"%REQUIRED_EMAIL% (current)" "%LOGIN_LIST_FILE%" >nul && set "IS_CURRENT=1"
  if "!IS_CURRENT!"=="0" (
    for /f "usebackq delims=" %%L in ("%LOGIN_LIST_FILE%") do (
      echo %%L | findstr /I /C:"(current)" >nul
      if not errorlevel 1 (
        echo %%L | findstr /I /C:"%REQUIRED_EMAIL%" >nul && set "IS_CURRENT=1"
      )
    )
  )
) else (
  findstr /I /C:"Logged in as %REQUIRED_EMAIL%" "%LOGIN_LIST_FILE%" >nul && set "IS_CURRENT=1"
  if "!IS_CURRENT!"=="0" (
    findstr /I /C:"%REQUIRED_EMAIL%" "%LOGIN_LIST_FILE%" >nul && set "IS_CURRENT=1"
  )
)

del /q "%LOGIN_LIST_FILE%" >nul 2>&1
exit /b 0
