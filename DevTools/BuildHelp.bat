@rem ---------------------------------------------------------------------------
@rem Script used to create help file for System Information Classes.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008-2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------


@echo off

set HelpDir=..\Help
set HelpBase=HelpAuthor
set HelpHAP=%HelpBase%.hap
set HelpRTF=%HelpBase%.rtf
set HelpHPJ=%HelpBase%.hpj
set HelpMAP=%HelpBase%.map
set HelpHLP=%HelpBase%.hlp
set HelpCNT=%HelpBase%.cnt

rem Check that required files exist

set ErrorMsg=

rem Build help file into exe folder
%DELPHI7%\Help\Tools\HCRTF.exe -x %HelpDir%\PJSysInfo.hlp
if errorlevel 1 set ErrorMsg=Compilation failed
if not "%ErrorMsg%"=="" goto error
goto success

:error
rem Display error message
echo *** ERROR: %ErrorMsg%
goto end

:success
echo Succeeded

:end
rem All done
