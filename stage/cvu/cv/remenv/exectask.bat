@echo off
REM
REM WINDOWS file
REM
REM $Header: exectask.sbs 22-jul-2004.09:38:53 smishra Exp $
REM
REM exectask.sbs
REM
REM Copyright (c) 2004, Oracle. All rights reserved.  
REM
REM    NAME
REM      exectask.sbs - The script which sets the env to run exectask at 
REM      the remote location.
REM
REM    DESCRIPTION
REM      <short description of component this file declares/defines>
REM
REM    NOTES
REM      This is a WINDOWS file
REM
REM    MODIFIED   (MM/DD/YY)
REM    smishra     07/22/04 - removed the exec cmd
REM    smishra     06/03/04 - fixed for NT 
REM    dsaggi      05/19/04 - dsaggi_merge4
REM    smishra     12/16/03 - Creation
REM

Rem Gather command-line arguments.
:arg
@set USER_ARGS=
:loop
if (%1)==() goto parsed
 @set USER_ARGS=%USER_ARGS% %1
 shift
goto loop
:parsed

exectask.exe %USER_ARGS% 


