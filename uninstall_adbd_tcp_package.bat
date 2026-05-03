@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PACKAGE_DIR=%SCRIPT_DIR%packages\adbd-tcp-arm64"
set "UPLOAD_TOOL=%SCRIPT_DIR%tools\sftp_sync.py"
set "SSH_TOOL=%SCRIPT_DIR%tools\ssh_exec.py"
set "REMOTE_DIR=/tmp/adbd-tcp-arm64"
set "IP_FILE=%SCRIPT_DIR%ip.txt"

set "HOST=%~1"
if not defined HOST (
    if exist "%IP_FILE%" (
        set /p HOST=<"%IP_FILE%"
    )
)
if not defined HOST (
    echo Missing target host. Set it in ip.txt or pass it as the first argument.
    exit /b 1
)

set "SSH_USER=%~2"
if not defined SSH_USER set "SSH_USER=user"

set "SSH_PASSWORD=%~3"
if not defined SSH_PASSWORD set "SSH_PASSWORD=myt"

set "ROOT_PASSWORD=%~4"
if not defined ROOT_PASSWORD set "ROOT_PASSWORD=myt"

set "ADB_PORT=%~5"
if not defined ADB_PORT set "ADB_PORT=5555"

echo Target host: %HOST%
echo SSH user: %SSH_USER%

if not exist "%PACKAGE_DIR%\uninstall.sh" (
    echo Package not found: %PACKAGE_DIR%
    exit /b 1
)

if not exist "%UPLOAD_TOOL%" (
    echo Missing upload tool: %UPLOAD_TOOL%
    exit /b 1
)

if not exist "%SSH_TOOL%" (
    echo Missing SSH tool: %SSH_TOOL%
    exit /b 1
)

python --version >nul 2>&1
if errorlevel 1 (
    echo Python is required but was not found in PATH.
    exit /b 1
)

echo Uploading package to %HOST% ...
python "%UPLOAD_TOOL%" --host %HOST% --user %SSH_USER% --password %SSH_PASSWORD% --local "%PACKAGE_DIR%" --remote %REMOTE_DIR%
if errorlevel 1 (
    echo Upload failed.
    exit /b 1
)

echo Running uninstall.sh on %HOST% ...
python "%SSH_TOOL%" --host %HOST% --user %SSH_USER% --password %SSH_PASSWORD% --root-password %ROOT_PASSWORD% --command "cd %REMOTE_DIR%; chmod +x install.sh uninstall.sh; ./uninstall.sh; ps -ef | grep '[a]dbd' || true; /etc/init.d/adbd-tcp status 2>/dev/null || true"
if errorlevel 1 (
    echo Remote uninstall failed.
    exit /b 1
)

echo Disconnecting ADB TCP on %HOST%:%ADB_PORT% ...
adb disconnect %HOST%:%ADB_PORT% >nul 2>&1

echo Checking that ADB TCP is no longer reachable ...
set "ADB_CONNECT_OUTPUT="
for /f "delims=" %%I in ('adb connect %HOST%:%ADB_PORT% 2^>^&1') do (
    echo %%I
    set "ADB_CONNECT_OUTPUT=!ADB_CONNECT_OUTPUT!%%I"
)

echo !ADB_CONNECT_OUTPUT! | findstr /i "cannot connect failed refused unable" >nul
if not errorlevel 1 (
    echo Uninstall finished successfully.
    exit /b 0
)

echo Warning: adb connect still succeeded. The service may still be running.
exit /b 1