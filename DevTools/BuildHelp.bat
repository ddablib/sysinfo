@rem ---------------------------------------------------------------------------
@rem Script used to create help file for System Information Classes.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008-2009
@rem
@rem Requires evironment variable HC set to full file path to MS WinHelp
@rem compiler (HCRTF.exe).
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------


@echo off

setlocal

set HelpDir=..\Help
set HelpFile=PJSysInfo.hlp
set ErrorMsg=

if not "%HC%" == "" set ErrorMsg=Environment variable HC not set
if not %ErrorMsg% == "" goto error

%HC% -x %HelpDir%\%HelpFile%
if errorlevel 1 set ErrorMsg=Compilation failed
if not "%ErrorMsg%"=="" goto error
goto success

:error
echo *** ERROR: %ErrorMsg%
goto end

:success
echo Succeeded

:end

endlocal
