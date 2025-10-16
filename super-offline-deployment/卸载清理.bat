@echo off
REM ================================================================
REM FaceImgMat - Cleanup and optional Python uninstall (ASCII only)
REM ================================================================
setlocal EnableExtensions EnableDelayedExpansion

echo.
echo FaceImgMat - Cleanup
echo ------------------------------------------------
echo This will remove:
echo   - Project virtualenv (.venv)
echo   - Database file (instance/*.db)
echo   - Uploaded files (static/uploads/*)
echo   - Log files (logs/*)
echo   - Model cache (models/*)
echo Optional:
echo   - Try to auto-uninstall Python 3.12
echo   - Remove D:\Python312 and D:\Python312-Temp
echo ------------------------------------------------
echo.

set /p CONFIRM="Proceed with cleanup? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Aborted.
    goto :eof
)

set "SCRIPT_DIR=%~dp0"
REM Resolve project root under folder that starts with "02-" (name may be non-ASCII). Avoid hardcoding exact name.
for /f "delims=" %%I in ('powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%SCRIPT_DIR%' -Directory | Where-Object { $_.Name -like '02-*' } | Select-Object -ExpandProperty Name -First 1"') do set "SRC_FOLDER=%%I"
if not defined SRC_FOLDER (
    echo [ERROR] Cannot locate folder starting with "02-" under %SCRIPT_DIR%
    goto :eof
)
set "PROJECT_DIR=%SCRIPT_DIR%%SRC_FOLDER%\FaceImgMat"

echo.
echo [1/5] Remove virtualenv
if exist "%PROJECT_DIR%\.venv" (
    rmdir /s /q "%PROJECT_DIR%\.venv"
    echo   - .venv removed
) else (
    echo   - .venv not found
)

echo.
echo [2/5] Remove database
if exist "%PROJECT_DIR%\instance\face_matching.db" (
    del /f /q "%PROJECT_DIR%\instance\face_matching.db"
    echo   - database removed
) else (
    echo   - database not found
)

echo.
echo [3/5] Clean uploads and logs
if exist "%PROJECT_DIR%\static\uploads" (
    del /f /q "%PROJECT_DIR%\static\uploads\*.*" 2>nul
    echo   - uploads cleaned
) else (
    echo   - uploads folder not found
)
if exist "%PROJECT_DIR%\logs" (
    del /f /q "%PROJECT_DIR%\logs\*.*" 2>nul
    echo   - logs cleaned
) else (
    echo   - logs folder not found
)

echo.
echo [4/5] Reset models folder
if exist "%PROJECT_DIR%\models" (
    rmdir /s /q "%PROJECT_DIR%\models" 2>nul
    mkdir "%PROJECT_DIR%\models" 2>nul
    echo   - models folder reset
) else (
    echo   - models folder not found
)

echo.
set /p CLEAN_INSIGHT="Remove user InsightFace cache (%USERPROFILE%\.insightface)? (Y/N): "
if /i "%CLEAN_INSIGHT%"=="Y" (
    if exist "%USERPROFILE%\.insightface" (
        rmdir /s /q "%USERPROFILE%\.insightface"
        echo   - InsightFace cache removed
    ) else (
        echo   - InsightFace cache not found
    )
) else (
    echo   - Skip InsightFace cache
)

echo.
echo [5/5] Python uninstall
set /p UNINSTALL_PYTHON="Try to auto-uninstall Python 3.12? (Y/N): "
if /i "%UNINSTALL_PYTHON%"=="Y" (
    call :AUTO_UNINSTALL_PY
) else (
    echo   - Skip Python uninstall
)

echo.
set /p CLEAN_DPY="Remove D:\Python312 and D:\Python312-Temp directories? (Y/N): "
if /i "%CLEAN_DPY%"=="Y" (
    if exist "D:\Python312" rmdir /s /q "D:\Python312"
    if exist "D:\Python312-Temp" rmdir /s /q "D:\Python312-Temp"
    echo   - D: Python folders removed (if present)
) else (
    echo   - Kept D: Python folders
)

echo.
echo Done. You can now re-run the one-click deploy script if needed.
echo.
pause
goto :eof

:AUTO_UNINSTALL_PY
echo   - Attempting auto-uninstall of Python 3.12 (may require admin)...
set "__PS_FILE=%TEMP%\uninstall_py312.ps1"
> "%__PS_FILE%" echo $ErrorActionPreference='SilentlyContinue'
>>"%__PS_FILE%" echo $targets=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall')
>>"%__PS_FILE%" echo $entries=@()
>>"%__PS_FILE%" echo foreach($k in $targets){ if(Test-Path $k){ $entries += Get-ChildItem $k ^| ForEach-Object { Get-ItemProperty $_.PsPath } } }
>>"%__PS_FILE%" echo $py=$entries ^| Where-Object { $_.DisplayName -and ( $_.DisplayName -match '^Python 3\.12' -or ($_.DisplayName -like '*Python*' -and $_.DisplayName -like '*3.12*') ) }
>>"%__PS_FILE%" echo foreach($p in $py){
>>"%__PS_FILE%" echo   $u=$p.UninstallString; if(-not $u){ continue }
>>"%__PS_FILE%" echo   Write-Host ('[INFO] Uninstalling: ' + $p.DisplayName)
>>"%__PS_FILE%" echo   if($u -match '^\"([^\"]+)\"(.*)$'){ $exe=$matches[1]; $args=$matches[2].Trim() } else { $sp=$u.IndexOf(' '); if($sp -gt 0){ $exe=$u.Substring(0,$sp); $args=$u.Substring($sp+1) } else { $exe=$u; $args='' } }
>>"%__PS_FILE%" echo   if($exe -like '*Uninstall.exe'){ if($args -notmatch '/uninstall'){ $args = ($args + ' /uninstall').Trim() }; if($args -notmatch '/quiet'){ $args = ($args + ' /quiet').Trim() } } elseif($exe -like '*msiexec*'){ if($args -notmatch '/quiet'){ $args = ($args + ' /quiet').Trim() } }
>>"%__PS_FILE%" echo   try { $p2 = Start-Process -FilePath $exe -ArgumentList $args -Wait -PassThru -NoNewWindow; Write-Host ('[INFO] ExitCode: ' + $p2.ExitCode) } catch { Write-Host ('[WARN] Failed: ' + $_.Exception.Message) }
>>"%__PS_FILE%" echo }
>>"%__PS_FILE%" echo $extra=@('D:\\Python312\\Uninstall.exe','C:\\Program Files\\Python312\\Uninstall.exe', "$env:LOCALAPPDATA\\Programs\\Python\\Python312\\Uninstall.exe")
>>"%__PS_FILE%" echo foreach($e in $extra){ if(Test-Path $e){ Write-Host ('[INFO] Try: ' + $e + ' /uninstall /quiet'); try{ $p3 = Start-Process -FilePath $e -ArgumentList '/uninstall','/quiet' -Wait -PassThru -NoNewWindow; Write-Host ('[INFO] ExitCode: ' + $p3.ExitCode) } catch { Write-Host ('[WARN] Failed: ' + $_.Exception.Message) } } }

powershell -ExecutionPolicy Bypass -NoProfile -File "%__PS_FILE%"
set "__PS_RC=%ERRORLEVEL%"
del "%__PS_FILE%" >nul 2>&1
if not "%__PS_RC%"=="0" (
    echo   - Auto-uninstall may not have completed successfully (admin may be required)
) else (
    echo   - Auto-uninstall script finished
)
exit /b 0
