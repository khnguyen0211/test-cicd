@ECHO off

SET SOURCE_DIR=%cd%
SET BUILD_DIR=%SOURCE_DIR%\build

IF EXIST %BUILD_DIR% rmdir /s /q %BUILD_DIR%
MKDIR %BUILD_DIR%
MKDIR %BUILD_DIR%\data

IF NOT DEFINED SIGNER ECHO "%%SIGNER%% seem not defined in CI system"

where 7z.exe > nul
IF %ERRORLEVEL% NEQ 0 ECHO "7z is not installed in Windows or not available in PATH" & EXIT /b

IF NOT DEFINED ARTIFACT_DIR (
	echo "%%ARTIFACT_DIR%% not defined in CI system. default value will be set as artifact_dir"
	set ARTIFACT_DIR=artifact_dir
)

ECHO "------------------------Dynamic Environment--------------------"
IF NOT DEFINED BUILD_NUMBER set BUILD_NUMBER=0
IF NOT DEFINED VERSION (
    IF EXIST version.txt (
        SET /p VERSION=<version.txt
    ) ELSE (
        SET VERSION=9.99.99
    )
)

ECHO "--------------Generate bootstrap configuration-----------------"

ECHO "--------------Generate use-case configuration------------------"

ECHO "-------------Generate app-bundle configuration-----------------"


ECHO "------------------------Zip Application package----------------"
CD /D %BUILD_DIR%
CALL 7z a data.zip %BUILD_DIR%/data/*
COPY %BUILD_DIR%\data.zip %SOURCE_DIR%\Installer\data\ /Y

CD /D %BUILD_DIR%
IF DEFINED SIGNER (
    ECHO "Sign NSIS Installer: CorsairOneInstaller.exe"
	CALL %SIGNER% %BUILD_DIR%\CorsairOneInstaller.exe
	IF %ERRORLEVEL% EQU 0 (
		ECHO "Signing CorsairOneInstaller.exe successful."
	) ELSE (
		ECHO "Signing CorsairOneInstaller.exe failed with error code %ERRORLEVEL%."
		EXIT /B %ERRORLEVEL%
	)
)

CALL :getabsolute %ARTIFACT_DIR%
SET ARTIFACT_DIR=%absolute%
IF NOT EXIST "%ARTIFACT_DIR%\%VERSION%" MKDIR "%ARTIFACT_DIR%\%VERSION%"
COPY %BUILD_DIR%\CorsairOneInstaller.exe "%ARTIFACT_DIR%\%VERSION%" /Y
ECHO "------------------------Done-----------------------------------"
GOTO :eof

:getabsolute
SET absolute=%~f1
EXIT /B 0
