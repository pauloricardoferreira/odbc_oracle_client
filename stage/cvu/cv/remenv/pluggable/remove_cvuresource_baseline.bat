@echo off
if (%1)==()  (
   echo XML DIRECTORY NOT SPECIFIED
   goto :EOF
)
pushd %1
setlocal
set CV_XMLCOUNT=0
for /f %%i in ('dir /b /a-d /o-d *') do call :my_delete %%i
popd
endlocal
goto :EOF

:my_delete
set /a CV_XMLCOUNT=%CV_XMLCOUNT% + 1
if %CV_XMLCOUNT% GEQ 5 del %1
goto :EOF
~

~

