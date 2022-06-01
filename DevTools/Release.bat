@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing source code of System Information
@rem Classes.
@rem
@rem Requirements:
@rem
@rem 1) This script uses the zip.exe program to create the release zip file.
@rem
@rem 2) If the ZIPPATH environment variable exists it must provide the path to
@rem    the directory where zip.exe is located. ZIPPATH *must not* have a
@rem    trailing backslash. If ZIPPATH does not exist then Zip.exe is expected
@rem    to be on the path.
@rem
@rem 3) A release version number may be provided as a parameter to the script.
@rem    When present the version number is included in the name of the zip file
@rem    that is created.
@rem
@rem Any copyright in this file is dedicated to the Public Domain.
@rem http://creativecommons.org/publicdomain/zero/1.0/
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..

set SrcDir=
set DocsDir=Docs
set DemoDir=Demos

set OutFile=Release\dd-sysinfo
if not "%1"  == "" set OutFile=%OutFile%-%1
set OutFile=%OutFile%.zip
echo Output file name = %OutFile%
if exist %OutFile% del %OutFile%

if not "%ZIPPATH%" == "" set ZIPPATH=%ZIPPATH%\
echo Zip path = %ZIPPATH%

if exist Release rmdir /S /Q Release
mkdir Release

%ZIPPATH%Zip.exe -j -9 %OutFile% PJSysInfo.pas

%ZIPPATH%Zip.exe -j -9 %OutFile% CHANGELOG.md
%ZIPPATH%Zip.exe -j -9 %OutFile% README.md
%ZIPPATH%Zip.exe -j -9 %OutFile% %DocsDir%\MPL-2.0.txt
%ZIPPATH%Zip.exe -j -9 %OutFile% %DocsDir%\Documentation.URL

%ZIPPATH%Zip.exe %OutFile% -r -9 %DemoDir%\*.*

endlocal
