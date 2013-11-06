Demo Programs for the PJSysInfo unit.

There are two demo programs, one in each of the VCL and FMX directories. Both
demos display the result of calling every method of TPJComputerInfo, TPJOSInfo
and TPJSystemFolders along with the values of all the Win32xxxx global
variables.

1) VCL Directory

   The demo in the VCL directory compiles as a VCL program.

   It is known to compile with Delphi 7 and later. An attempt has made to make
   the program compilable with Delphi 4 to 6 but this has not been tested. The
   program definitely will not compile with Delphi 3.

   Some compilers need some extra steps to be taken to compile the program.

   * For Delphi 2006 and earlier you need to manually create a Win32 sub-
     directory of VCL to receive the output binaries.

   * Delphi 2007 cannot understand the project file. Delete the .dproj file and
     open the .bdsproj file instead.

   All supported compilers will output a Windows 32 bit program by default, in
   the Win32 sub-directory.

   Delphi XE2 and later can also create a 64 bit version of the program if the
   Windows 64 bit target is selected. This compiles to the Win64 sub-directory.

2) FMX Directory

   This directory contains a demo program that compiles for the FireMonkey 2
   framework.

   The program must be compiled with Delphi XE3 or later. Delphi XE2 is not
   supported.

   Both 32 bit and 64 bit Windows targets are supported, with 64 bit being the
   default. The binaries are written to the Win32 and Win64 sub-directories
   respectively.
