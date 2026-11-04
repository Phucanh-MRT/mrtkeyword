@echo off
rem MRT Keyword - nhap dup file nay de cai dat. Can mang Internet, lan dau mat 15-30 phut.
echo ==========================================
echo   MRT KEYWORD - CAI DAT TU DONG
echo ==========================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0cai-dat.ps1"
if errorlevel 1 (
  echo.
  echo Cai dat chua xong. Doc dong bao loi o tren, sua roi nhap dup CAI-DAT.bat lan nua.
)
echo.
pause
