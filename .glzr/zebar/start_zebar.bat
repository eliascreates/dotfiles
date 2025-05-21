@echo off
tasklist /FI "IMAGENAME eq zebar.exe" | find /I "zebar.exe" >nul
if not errorlevel 1 (
  exit
)
start "" "C:\Program Files\glzr.io\Zebar\zebar.exe"
exit
