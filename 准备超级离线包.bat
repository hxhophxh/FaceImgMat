@echo off
REM ====================================================================
REM ׼���������߰� - ������������
REM ��������Ļ���������
REM ====================================================================
chcp 65001 >nul

echo.
echo ================================================================
echo.
echo   ׼�� FaceImgMat �������߲����
echo.
echo   ���ű�������Python��װ�������������
echo   ��Ҫ�������ӣ�Ԥ�ƺ�ʱ 20-30 ����
echo.
echo ================================================================
echo.

REM ���±���PowerShell�ű��Խ��������������
echo [��ʾ] ����׼���ű�...
powershell -ExecutionPolicy Bypass -NoProfile -Command "Get-Content '%~dp0prepare-super-package.ps1' -Raw -Encoding UTF8 | Set-Content '%~dp0prepare-super-package-temp.ps1' -Encoding UTF8"

REM �������±����Ľű�����Ĭģʽ��
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0prepare-super-package-temp.ps1" -Silent

set SCRIPT_EXIT_CODE=%errorlevel%

REM ������ʱ�ļ�
del "%~dp0prepare-super-package-temp.ps1" >nul 2>&1

if %SCRIPT_EXIT_CODE% neq 0 (
    echo.
    echo [����] ���߰�׼��ʧ�ܣ�
    pause
    exit /b 1
)

echo.
echo [���] ��������˳�...
pause >nul