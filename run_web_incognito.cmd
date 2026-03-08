@echo off
cd /d %~dp0
start "" /B python -m http.server 8112
timeout /t 2 >nul
start chrome --incognito http://localhost:8112/index.html
