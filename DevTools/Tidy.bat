@rem ---------------------------------------------------------------------------
@rem System Information Unit
@rem
@rem Script used to delete temporary files and directories.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008-2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off
setlocal

echo Tidying
echo ~~~~~~~
echo.

set RootDir=..

echo Deleting *.~* from "%RootDir%" and subfolders
del /S %RootDir%\*.~* 
echo.

echo Deleting *.dpp from "%RootDir%" and subfolders
del /S %RootDir%\*.ddp 
echo.

echo Deleting *.dcu from "%RootDir%" and subfolders
del /S %RootDir%\*.dcu 
echo.

echo Deleting *.exe from "%RootDir%" and subfolders
del /S %RootDir%\*.exe 
echo.

echo Deleting *.dsk from "%RootDir%" and subfolders
del /S %RootDir%\*.dsk 
echo.

echo Deleting any Release directory
if exist %RootDir%\Release rmdir /S /Q %RootDir%\Release
echo.

echo Deleting any __history directories
for /F "usebackq" %%i in (`dir /S /B /A:D %RootDir%\__history*`) do rmdir /S /Q %%i
echo.

echo Done.

endlocal
