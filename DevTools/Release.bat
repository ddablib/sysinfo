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

set OutFile=Releases\dd-sysinfo.zip
set SrcDir=
set DocsDir=Docs
set DemoDir=Demo
set HelpDir=Help

if exist Releases rmdir /S /Q Releases
mkdir Releases

if exist %OutFile% del %OutFile%

zip -j -9 %OutFile% PJSysInfo.pas
zip -j -9 %OutFile% PJSysInfo.dcr

zip -j -9 %OutFile% %HelpDir%\PJSysInfo.hlp
zip -j -9 %OutFile% %HelpDir%\PJSysInfo.als

zip -j -9 %OutFile% %DocsDir%\ChangeLog.txt
zip -j -9 %OutFile% %DocsDir%\MPL.txt
zip -j -9 %OutFile% %DocsDir%\ReadMe.htm

zip -9 %OutFile% %DemoDir%\SysInfoDemo.dpr
zip -9 %OutFile% %DemoDir%\SysInfoDemo.res
zip -9 %OutFile% %DemoDir%\FmDemo.pas
zip -9 %OutFile% %DemoDir%\FmDemo.dfm
zip -9 %OutFile% %DemoDir%\DelphiDabbler.ico

endlocal

