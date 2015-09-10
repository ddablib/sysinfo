Demo Programs for the PJSysInfo unit.

There are two demo programs, one in each of the VCL and FMX directories. Both
demos display the result of calling every method of TPJComputerInfo, TPJOSInfo
and TPJSystemFolders along with the values of all the Win32xxxx global
variables.

1) VCL Directory

   The demo in the VCL directory compiles as a VCL program.

   It is known to compile with Delphi XE and later. An attempt has made to make
   the program compilable with Delphi 4 to 2010 but this has not been tested.
   Some unsupported form properties may need to be removed when opening the
   project's form in earlier compilers, but this should do no harm. The program
   definitely will not compile with Delphi 3.

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

   The demo was initially created using Delphi XE3 and updated using Delphi XE4.
   It should compile with Delphi XE3 but some form properties may need to be
   ignored. Delphi XE2 is not supported.

   Both 32 bit and 64 bit Windows targets are supported, with 64 bit being the
   default. The binaries are written to the Win32 and Win64 sub-directories
   respectively.

## Note about manifests ##

At least for Windows 10, TPJOSInfo returns different results depending on
whether the host application is manifested to be compatible with that OS (this
is a Microsoft "feature", no matter how ridiculous we may find it).

Because of this each of the demo apps has a .manifest file that is included in
its resources by means of a {$R 'Manifest.res} directive in the app's project
file. To see how the values returned from TPJOSInfo methods change when there is
no manifest simply comment out the {$R 'Manifest.res'} line and recompile.
