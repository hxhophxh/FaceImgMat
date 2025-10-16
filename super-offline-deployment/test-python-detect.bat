@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo Testing Python detection...
echo.

set "PYTHON_CMD="

REM Test 1: Check PATH python
python --version >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo Found Python in PATH: !PYTHON_VERSION!
    echo !PYTHON_VERSION! | findstr /R "^3\.12\." >nul
    if !errorlevel! equ 0 (
        set "PYTHON_CMD=python"
        echo [OK] Will use: python
        goto :FOUND
    ) else (
        echo [WARN] Not 3.12.x, checking other locations...
    )
)

REM Test 2: Check D:\Python312
if exist "D:\Python312\python.exe" (
    for /f "tokens=2" %%j in ('"D:\Python312\python.exe" --version 2^>^&1') do set PV=%%j
    echo Found: D:\Python312\python.exe (version !PV!)
    set "PYTHON_CMD=D:\Python312\python.exe"
    goto :FOUND
)

echo [ERROR] Python 3.12 not found!
set "PYTHON_CMD="
goto :END

:FOUND
echo.
echo [SUCCESS] PYTHON_CMD is set to: !PYTHON_CMD!
goto :END

:END
echo.
echo Final PYTHON_CMD value: !PYTHON_CMD!
if not defined PYTHON_CMD (
    echo [ERROR] Variable is empty!
) else (
    echo [OK] Variable is set
)
pause
