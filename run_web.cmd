@echo off
setlocal
cd /d %~dp0

set "PORT=8112"
set "URL=http://localhost:%PORT%/index.html"

start "AutoBoostImg Server" /B python -m http.server %PORT%

for /L %%i in (1,1,15) do (
    powershell -NoProfile -Command "try { $client = New-Object Net.Sockets.TcpClient('127.0.0.1',%PORT%); $client.Close(); exit 0 } catch { exit 1 }"
    if not errorlevel 1 goto :open_browser
    timeout /t 1 >nul
)

echo Khong the ket noi server tai cong %PORT%.
goto :eof

:open_browser
start "" "%URL%"
echo Server da chay: %URL%