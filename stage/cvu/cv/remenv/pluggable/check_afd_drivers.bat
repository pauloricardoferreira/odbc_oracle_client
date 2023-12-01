@echo off
Rem
Rem
Rem check_afd_drivers.sh
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      check_afd_drivers.bat - check if afd driver files are present
Rem
Rem    DESCRIPTION
Rem      Checks for ASM filter driver files in a pre install/upgrade scenario
Rem
Rem    NOTES
Rem      takes two arguments.
Rem      1. AFD driver name
Rem      2. AFD lib file name
Rem

for /f %%i in ('hostname') do @set HOST=%%i

Rem set library/driver file locations and names

Rem names of files to be checked are passed as executable arguments
@set DRV_NAME="Oracle AFD"
@set DLL_FILE_NAME=%2

@set DLL_FILE_LOC=%SYSTEMDRIVE%\oracle\extapi\64

Rem check if the argument is passed or not. if not then exit with the error.
if "X%DLL_FILE_NAME%" == "X" goto ARGS_NOT_SET
  
goto ARGS_SET

:ARGS_NOT_SET
@echo "<RESULT>VFAIL</RESULT><TRACE>Argument is empty</TRACE><NLS_MSG><FACILITY>Prve</FACILITY><ID>0018</ID></NLS_MSG>"
exit /b 1

:ARGS_SET 

@set AFD_FILES=

Rem check if there are any stray AFD files

setlocal EnableDelayedExpansion

if exist "%DLL_FILE_LOC%" (
    for /f %%a in ('DIR /b/s %DLL_FILE_LOC%\%DLL_FILE_NAME%') do (
        @set AFD_FILES=!AFD_FILES!,%%a
    )
)

sc query "%DRV_NAME%" | findstr /i "RUNNING" 1>nul 2>&1 && (
  @set DRV_LOADED=TRUE
) || (
  @set DRV_LOADED=
)

@set TRACE_LIB_FOUND=
@set ERROR_LIB_FOUND=
@set TRACE_DRV_FOUND=
@set ERROR_DRV_FOUND=

if NOT "X%AFD_FILES%" == "X" goto FAILURE
if NOT "X%DRV_LOADED%" == "X" goto FAILURE

@echo "<RESULT>SUCC</RESULT><TRACE>ASM Filter driver files were not found</TRACE><NLS_MSG><FACILITY>Prve</FACILITY><ID>10236</ID></NLS_MSG>"

exit /b 0

:FAILURE

@set ERROR_STATUS="<RESULT>VFAIL</RESULT>"

if NOT "X%AFD_FILES%" == "X" (
  @set AFD_FILES=!AFD_FILES:~1!
  @set TRACLE_LIB_FOUND=ASM Filter driver files !AFD_FILES! were found on node %HOST%
  @set ERROR_LIB_FOUND="<NLS_MSG><FACILITY>Prve</FACILITY><ID>10237</ID><MSG_DATA><DATA>%HOST%</DATA><DATA>!AFD_FILES!</DATA></MSG_DATA></NLS_MSG>"

)

if NOT "X%DRV_LOADED%" == "X" (
  @set TRACE_DRV_FOUND=ASM Filter driver found loaded on node %HOST%
  @set ERROR_DRV_FOUND="<NLS_MSG><FACILITY>Prve</FACILITY><ID>10239</ID><MSG_DATA><DATA>%HOST%</DATA><DATA>%DRV_NAME%</DATA></MSG_DATA></NLS_MSG>"

)

@echo %ERROR_STATUS%"<TRACE>%TRACE_LIB_FOUND%%TRACE_DRV_FOUND%</TRACE>"%ERROR_LIB_FOUND%%ERROR_DRV_FOUND%

