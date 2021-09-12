@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing source code of System Information
@rem Classes.
@rem
@rem Requirements:
@rem
@rem 1) This script uses the zip.exe program to create the release zip file.
@rem
@rem 2) The ZIPPath environment variable must exist and store the path to the
@rem    directory where zip.exe is located. ZIPPATH must not have a trailing
@rem    backslash.
@rem
@rem Any copyright in this file is dedicated to the Public Domain.
@rem http://creativecommons.org/publicdomain/zero/1.0/
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------


@echo off

setlocal

cd ..

set OutFile=Release\dd-sysinfo.zip
set SrcDir=
set DocsDir=Docs
set DemoDir=Demos

if exist Release rmdir /S /Q Release
mkdir Release

echo "OUTFILE=%OutFile%"
if exist %OutFile% del %OutFile%

%ZIPPATH%\Zip.exe -j -9 %OutFile% PJSysInfo.pas

%ZIPPATH%\Zip.exe -j -9 %OutFile% %DocsDir%\ChangeLog.txt
%ZIPPATH%\Zip.exe -j -9 %OutFile% %DocsDir%\MPL-2.0.txt
%ZIPPATH%\Zip.exe -j -9 %OutFile% %DocsDir%\ReadMe.htm
%ZIPPATH%\Zip.exe -j -9 %OutFile% %DocsDir%\Documentation.URL

%ZIPPATH%\Zip.exe %OutFile% -r -9 %DemoDir%\*.* -x *.svn\*

endlocal
