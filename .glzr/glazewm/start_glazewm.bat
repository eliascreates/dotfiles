@echo off
tasklist /FI "IMAGENAME eq glazewm.exe" | find /I "glazewm.exe" >nul
if not errorlevel 1 (
  exit
)
start "" "C:\Program Files\glzr.io\GlazeWM\glazewm.exe"
exit
