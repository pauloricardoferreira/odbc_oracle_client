@echo off
rem
rem WINDOWS file
rem
rem cvuhelper.sbs 
rem
rem Copyright (c) 2003, 2016, Oracle and/or its affiliates. 
rem All rights reserved.
rem
rem    NAME
rem      cvuhelper.bat - executes heavy weight APIs in compatible way
rem
rem    DESCRIPTION
rem      This requires these environmental variables.
rem      GI_HOME: clustware home
rem      CVUHELPER_VERSION: version of cvuhelper to use
rem      JAR_FILE_PATH: location of cvuhelper*.jar to use
rem      CV_HOME: home for CV tools
rem      Command and args: The command to execute and arugments for that command
rem      OR
rem      -client: flag indicating an earlier version trying to run a command
rem      CV_HOME_VERSION: version of the client
rem
rem    NOTES
rem      THIS IS A WINDOWS SPECIFIC FILE
rem
rem    MODIFIED   090325


if (%5) == () (
echo ^<CVH_EMSG^>
echo.
echo ERROR:
echo Usage %0 ^<GI_HOME^> ^<CVUHELPER_VERSION^> ^<JAR_PATH^> ^<CV_HOME^> ^<COMMAND^> [^<args^>]
echo Earlier version CVU will call cvuhelper with following arguments
echo Usage %0 -client ^<GI_HOME^> ^<GI_VERSION^> ^<CV_HOME^> ^<CV_HOME_VERSION^> ^<COMMAND^> [^<args^>]
echo ^</CVH_EMSG^>^<CVH_ERES^>2^</CVH_ERES^>^<CVH_VRES^>2^</CVH_VRES^>
goto ERROR
)

if (%1)==(-client) goto CLIENT_PROCESSING

@set ORACLE_HOME=%1
@set CVUHELPER_CLASS=helper%2.CVUHelper%2
@set CVUHELPERJAR_PATH=%3
@set CV_HOME=%4
goto SHIFT_ARGS

rem process -client args
:CLIENT_PROCESSING
@set ORACLE_HOME=%2
@set GI_VERSION=%3
@set CV_HOME=%4
@set CV_HOME_VERSION=%5
@set CVUHELPER_CLASS=helper12201.CVUHelper12201
@set CVUHELPERJAR_PATH=%ORACLE_HOME%\jlib\cvuhelper122.jar
shift

:SHIFT_ARGS
rem pop four args
shift
shift
shift
shift

setlocal
set all_arg=
:begin
if (%1) == () goto :done_arg 
set all_arg=%all_arg% %1
shift
goto begin
:done_arg

set REM_ENV=-DCV_HOME=%CV_HOME% -DGI_HOME=%ORACLE_HOME%

@set JAVA_OPTS=
if not "%_JAVA_OPTIONS%"=="" (
    @set JAVA_OPTS=%_JAVA_OPTIONS%
    @set _JAVA_OPTIONS=
)

if exist %ORACLE_hOME%\jdk\jre set JREDIR=%ORACLE_HOME%\jdk\jre

if not exist %ORACLE_HOME%\jdk\bin\java.exe (
    @echo ^<CVH_EMSG^>set ORACLE_HOME variable so that %ORACLE_HOME%\jdk\jre points to a valid JRE location^</CVH_EMSG^>^<CVH_ERES^>2^</CVH_ERES^>^<CVH_VRES^>2^</CVH_VRES^>
    goto ERROR
)

REM SRVM jar file
@set SRVMJAR=%ORACLE_HOME%\jlib\srvm.jar

@set LDAPJAR=%ORACLE_HOME%\jlib\ldapjclnt12.jar
@set NETCFGJAR=%ORACLE_HOME%\jlib\netcfg.jar
@set INSTALLJAR=%ORACLE_HOME%\oui\jlib\OraInstaller.jar
@set PREREQJAR=%ORACLE_HOME%\oui\jlib\OraPrereq.jar
@set FIXUPJAR=%ORACLE_HOME%\oui\jlib\prov_fixup.jar
@set XMLPARSERJAR=%ORACLE_HOME%\oui\jlib\xmlparserv2.jar
@set SHAREJAR=%ORACLE_HOME%\oui\jlib\share.jar
@set MAPPINGJAR=%ORACLE_HOME%\oui\jlib\orai18n-mapping.jar
@set SRVMHASJAR=%ORACLE_HOME%\jlib\srvmhas.jar
@set SRVMASMJAR=%ORACLE_HOME%\jlib\srvmasm.jar
@set GNSJAR=%ORACLE_HOME%\jlib\gns.jar
@set OUI_LIBRARY_PATH=%ORACLE_HOME%\oui\lib\win64

if not exist %OUI_LIBRARY_PATH% (
  @set OUI_LIBRARY_PATH=%ORACLE_HOME%\oui\lib\win32
)

REM JRE Executable and Class File Variables
@set JRE=%ORACLE_HOME%\jdk\bin\java.exe
@set JREJAR=%ORACLE_HOME%\jdk\lib\rt.jar

for /F "tokens=3" %%i in ('%JRE% -version 2^>^&1') do (
   @set RJDKVER=%%i && goto found
)
:found

@set JDBCVER=
for /F "tokens=1,2 delims=." %%a in (%RJDKVER%) do (
   @set JDBCVER=%%a%%b
   if not '%JDBCVER%'=='14' (
     @set JDBCVER=%%b
   )
)
@set OJDBCJAR=%ORACLE_HOME%\jdbc\lib\ojdbc%JDBCVER%.jar

rem in ADE view, the opatch is located in %ORACLE_HOME%\opatch\OPatch
@set OPATCH_LOC=%ORACLE_HOME%\opatch\OPatch

rem in an actual shiphome, the opatch is located in %ORACLE_HOME%\OPatch
if not exist '%OPATCH_LOC%' (
  @set OPATCH_LOC=%ORACLE_HOME%\OPatch
)

@set OPATCH_JARS=

rem first include all opatch jars
for /F %%f in ('dir /b /s %OPATCH_LOC%\jlib\*.jar') do call :concat %%f

rem include oplan jars
if exist %OPATCH_LOC%\opatchauto-dir\opatchautocore\jlib (
  for /F  %%f in ('dir /b /s %OPATCH_LOC%\opatchauto-dir\opatchautocore\jlib\*.jar') do call :concat %%f
) else (
if exist %OPATCH_LOC%\oplan\jlib (
  for /F  %%f in ('dir /b /s %OPATCH_LOC%\oplan\jlib\*.jar') do call :concat %%f  
)
)

goto :next

:concat
@set OPATCH_JARS=%OPATCH_JARS%%1;
goto :eof

:next

@set CLASSPATH=%JREJAR%;%CVUHELPERJAR_PATH%;%SRVMJAR%;%INSTALLJAR%;%PREREQJAR%;%FIXUPJAR%;%XMLPARSERJAR%;%SHAREJAR%;%MAPPINGJAR%;%SRVMHASJAR%;%SRVMASMJAR%;%GNSJAR%;%NETCFGJAR%;%LDAPJAR%;%OJDBCJAR%;%OPATCH_JARS%;
@set PATH=%ORACLE_HOME%\bin;%PATH%;

REM set tracing info
@set TRACE=
@set TRACEOPT=

if not '%SRVM_TRACE%'=='' (
  if /I '%SRVM_TRACE%' == 'false' (
    @set TRACE=-DTRACING.ENABLED=false
  ) else (
    if not '%SRVM_TRACE_LEVEL%' == '' (
      @set TRACE=-DTRACING.ENABLED=true -DTRACING.LEVEL=%SRVM_TRACE_LEVEL%
    ) else (
      @set TRACE=-DTRACING.ENABLED=true -DTRACING.LEVEL=2
    )
  )
)

REM Run cvuhelper

%JRE% -classpath %CLASSPATH% %REM_ENV% %TRACE% %JAVA_OPTS% -Djava.net.preferIPv4Stack=true oracle.ops.verification.helper.%CVUHELPER_CLASS% %all_arg%

exit /B %errorlevel%
goto :EOF

:ERROR
endlocal
exit /B 1
