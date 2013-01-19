@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing source code of System Information
@rem Classes.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008-2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------


@echo off

setlocal

cd .\..

set OutFile=Release\dd-sysinfo.zip
set SrcDir=
set DocsDir=Docs
set DemoDir=Demos

if exist Release rmdir /S /Q Release
mkdir Release

if exist %OutFile% del %OutFile%

zip -j -9 %OutFile% PJSysInfo.pas

zip -j -9 %OutFile% %DocsDir%\ChangeLog.txt
zip -j -9 %OutFile% %DocsDir%\MPL-2.0.txt
zip -j -9 %OutFile% %DocsDir%\ReadMe.htm
zip -j -9 %OutFile% %DocsDir%\Documentation.URL

zip %OutFile% -r -9 %DemoDir%\*.* -x *.svn\*

endlocal

