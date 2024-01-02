# Change Log for System Information Unit

## _Next Release_

+ Fixed error in `CHANGLOG.md` relating to release v5.26.0.

## v5.26.0 of 02 January 2024

+ Updated TPJOSInfo to detect various Windows 10 and 11 builds and revisions released in December 2023:
  + Windows 10 version 21H2 & 22H2 public release revisions.
  + Windows 11 21H2, 22H2 & 23H2 public release revisions.
  + Windows 11 Dev & Canary channel revisions.
  + Windows Future Component Update builds.
+ Brought testing information up to date in `README.md` and `Docs/ReadMe.txt`.
+ Updated license copyright date in `README.md` and `PJSysInfo.pas`.
+ Fixed some errors in `CHANGELOG.md`.

## v5.25.0 of 03 December 2023

+ Updated TPJOSInfo to detect various Windows 10 and 11 builds and revisions released in November 2023:
  + Windows 10 version 21H2 & 22H2 public & release preview revisions.
  + Windows 11 21H2, 22H2 & 23H2 public, beta & release preview channel revisions.
  + Windows 11 Dev & Canary channel revisions.
  + Windows 11 Future Component Update Beta builds.

## v5.24.0 of 03 November 2023

+ Updated TPJOSInfo:
  + Added detection of various Windows 10 and 11 builds and revisions released between 01 July and 02 November 2023:
    + Windows 10 21H2 public & release preview revisions.
    + Windows 10 22H2 public & release preview revisions.
    + Windows 11 21H2 public & release preview revisions.
    + Windows 11 22H2 public, release preview & beta channel revisions.
    + New Windows 11 22H3 public, release preview & beta channel revisions.
    + Windows 11 Dev & Canary channel builds.
    + Windows 11 Future Component Update Beta builds.
  + Removed support for detecting Windows Dev channel builds that expired in September 2023.
+ Updated some comments.
+ Minor formatting inconsistencies fixed in `CHANGELOG.md`.

## v5.23.0 of 01 July 2023

+ Updated TPJOSInfo to detect various Windows 10 and 11 builds and revisions released in June 2023:
  + Windows 10 21H2 public revisions.
  + Windows 10 22H2 public & release preview revisions.
  + Windows 11 21H2 public revisions.
  + Windows 11 22H2 public, release preview, beta channel revisions.
  + Added detection and reporting of Windows 11 22H2 "Moment 4".
  + Windows 11 Future Component Update Beta builds.
  + Windows 11 Dev & Canary channel builds.
  + Changed from version string 22H2 to 22H3 for Canary channel builds from build 25375.
+ Fixed TPJOSInfo errors re:
  + Some incorrect version strings used in various Windows 10 & 11 builds.
  + Some comments.

## v5.22.0 of 01 June 2023

+ Updated TPJOSInfo to detect various Windows 10 and 11 builds and revisions released in May 2023:
  + Final release of Windows 10 20H2.
  + Windows 11 build 22624 becomes "Windows 11 May 23 Component Update".
  + New Windows 11 build 22631 "Windows 11 Future Component Update".
  + Windows 11 22H2 public, release preview channel & beta channel revisions.
  + Windows 11 21H2 public & release preview channel revisions.
  + Added detection and reporting of Windows 11 22H2 "Moment" releases 1, 2 and 3.
  + Removed detection of expired Win 10 versions 1507, 1511 and 1607 preview builds.
+ Update comments to TPJOSInfo comment with new references.

## v5.21.1 of 02 May 2023

+ Fixed bug in TPJOSInfo where one of the build numbers used to detect Windows 11 Canary channel builds was wrong.

## v5.21.0 of 01 May 2023

+ Updated TPJOSInfo to detect various Windows builds and revisions released between 1 April and 30th April 2023, including:
  + Windows 11 22H2 public, release preview channel & beta channel revisions
  + Windows 11 21H2 public & release preview channel revisions
  + Windows 11 Future component update channel revisions
  + Windows 11 Dev channel builds
  + Windows 11 Canary channel builds
  + Windows 10 22H2 public & release preview channel revisions
  + Windows 10 21H2 public revisions
+ Some rename refactoring
+ Corrected and improved comments

## v5.20.0 of 01 April 2023

+ Updated TPJOSInfo to detect various Windows 10 and 11 builds released between 1 January and 31st March 2023, including:
  + public patches
  + release previews
  + Dev and Canary channel preview builds

## v5.19.0 of 01 January 2023

+ Updated TPJOSInfo OS detection:
  + Updated Windows 10 21H1, 21H2 & 22H2 and Windows 11 21H2 & 22H2 with pre-release & public builds released in December 2022.
  + Added detection of preview builds for Windows 10 Version 1507 through to Version 20H2.
  + Removed detection of expired Windows 10 & Windows 11 builds in Fast Ring and Dev channels.
  + Generally improved accuracy in detection of Windows 10 & 11 release & preview builds, reducing liklihood of false positives for unknown releases.
  + Changed to report certain v6.4 builds as being Windows 10 Version 1507 pre-releases. Reported OS for such builds is now Windows 10.
  + Added PROCESSOR_ARCHITECTURE_ARM64 constant.
  + Added some PRODUCT_* constants defined by Microsoft but missing from `PJSysInfo.pas`.
  + Updated and corrected product descriptions so there is a decription for each PRODUCT_* constant.
  + Fixed problem, starting from Windows 10 21H1, where some un-released preview builds were being reported as public releases.
+ Updated and tidied commenting in `PJSysInfo.pas`, including:
  + Added back URLs of some sources that were removed in a previous release.
  + Added tables providing information about end of life for Windows Vista to Windows 11 and all Windows Server releases.

## v5.18.0 of 01 December 2022

+ Updated TPJOSInfo to detect various builds of Windows 11 Version 22H2 that were released, either to the public or on the dev and release preview channels, in November 2022.

## v5.17.0 of 01 November 2022

+ Updated TPJOSInfo OS detection re:
  + Public release of Windows 10 Version 22H2
  + Win 10 & 11 Beta, release preview & dev channel builds from 1-31 October 2022.
+ Update change log for release 5.16.0

## v5.16.0 of 01 October 2022

+ Updated TPJOSInfo OS detection re:
  + Public release of Windows 11 Version 22H2.
  + Windows 11 Beta & release preview channel builds in from 2-30 Sepetember 2022.
  + Added build & revision numbers to text reported for Windows 10 Version 22H2 release previews.
+ Add `.gitignore` file.
+ Updated documentation:
  + Updated `README.md` "Effect of changes to the Windows API" sub-section.
  + Fix errors & update `Acknowledgements.md`.

## v5.15.0 of 02 September 2022

+ Updated TPJOSInfo detection of Win 11 Dev builds, 22H2 beta & release channel and alternative 22H2 beta channel builds to include all those released in August 2022 and on 1st September 2022.

## v5.14.0 of 01 August 2022

+ Updates to TPJOSInfo:
  + Added detection of Win 10 22H2 release preview build.
  + Added detection of alternative Win 11 22H2 beta build.
  + Added detection of Win 11 Dev channel and 22H2 revisions released in July 2022
  + Revised descriptions of Win 11 21H2 and 22H2 dev, beta and release
    preview revisions.
+ Updated URLs referenced in comments, removing broken URLs.

## v5.13.0 of 01 July 2022

+ Updates to TPJOSInfo:
  + Added support for detecting Windows 11 Dev channel and 22H2 Beta & Release Preview builds released in June 2022.
  + Improved reporting of unrecognised Windows 11 21H2 and 22H2 builds.
  + Fixed _**serious bug**_ in detection of known Windows 11 21H2 builds.
  + Fixed bug in detecting various OSs that report  v10.0  (i.e. Windows 10 & 11 along with Windows Server products from Windows Server 2016 to Windows Server 2022). The bug was causing either Windows 10 or Windows 2016 server to be reported if build number detection failed, regardless of the OSs true build number.
  + Some refactoring.
  + Updated and clarified comments.

## v5.12.0 of 01 June 2022

+ Updates to TPJOSInfo:
  + Added support for detecting Dev and Beta releases of Windows 11 made during May 2022.
  + Refactored some OS detection code to reduce the amount of code used to test for various versions of OSs that report v10.0.
+ Documentation changes:
  + Replaced `/Docs/ReadMe.htm` with markdown formatted `/README.md`. Also expanded, brought up to date with recent changes, and fixed errors.
  + Replaced `/Docs/ChangeLog.txt` with markdown formatted `/CHANGELOG.md`. Also removed or struck out references to issues on Google Code.
  + Restored MPL v2 license file.
  + Updated documentation URL in the documentation shortcut file to a redirection URL on `delphidabbler.com`.
  + Deleted redundant `/Docs/Using RtlGetVersion.txt` file.
  + Fix some errors and omissions in this change log.
+ Revised `Release.bat`:
  + to take a version number as parameter to use in the release file name
  + to use the correct file in the release, following renaming.
  + re change from SVN Git
  + to permit `Zip.exe` to be called with no directory name when on the path.

## v5.11.0 of 01 May 2022

+ Fixed compilation bug that was preventing compilation with older versions of Delphi, probably those before Delphi XE7. Replaced all constant dynamic array declarations with initialised constant fixed size arrays.
+ Updates to TPJOSInfo:
  + Adds detection of Windows 11 Dev & Beta channel builds released since v5.10.0.
  + Refactored detection of Windows 2019 Server Insider Preview builds.

## v5.10.0 of 04 April 2022

+ Updates to TPJOSInfo:
  + Adds detection of recent Windows 11 Dev Channel releases.
  + Removes detection of build 22395 as Windows 10 22H2 preview build - available documentation does not support this.
  + Revised how Windows 11 Dev Channel builds are processed and reported, in line with newly found documentation.
  + Added detection of Windows 10 Fast Ring and Dev Channel releases.
  + Added detection of Windows 10 21H1 beta and 21H2 preview builds.

## v5.9.0 of 02 February 2022

+ Updates to TPJOSInfo:
  + Fixed mis-named Windows 2019 Server versions that should report as "Windows Server". Added new TPJOSProduct.osWinServer value and ammended code to detect and report the new "Windows Server" product type.
  + Added support for detecting Windows 10 version 22H1 preview builds.
  + Changed Windows 11 RSPRERELESE build 22509 to report "Windows 11 Insider Preview" instead of "Windows 11 Version 21H2".
+ Updated demo programs to be able to report osWinServer product type added to TPJOSInfo at this release.
+ Removed MPL2 license file.

## v5.8.0 of 01 January 2022

+ Fixed bug that was failing to detect KB updates to Windows 11 as valid production Windows 11 OS builds.
+ Added support for detecting newly released Windows 11 pre-release builds.
+ Some refactoring of OS build number detection code.

## v5.7.1 of 27 November 2021

+ Updated internal code following official release of Windows 10 21H2. No change to functionality from user's perspective.
+ Fixed a minor bug in Windows 11 detection code that is unlikely to have had any adverse effect.
+ Some refactoring.
+ General source code tidying.

## v5.7.0 of 05 October 2021

+ Updated TPJOSInfo to detect 1st release of Windows 11 (i.e. Windows 11 Version 21H2).

## v5.6.2 of 14 September 2021

+ Replaced non-ANSI dash characters with ASCII "-" characters to prevent possible problems compiling on old ANSI versions of Delphi. ~~Fixes issue #41~~

## v5.6.1 of 12 September 2021

+ Made following methods inline, where supported: TPJOSInfo.IsWin9x, TPJOSInfo.IsWinNT, TPJOSInfo.IsWin32s, TPJOSInfo.ServicePackMajor, TPJOSInfo.ServicePackMinor & TPJComputerInfo.Is64Bit. Did not make any methods inline that would require extra units in uses clause of interface section of including units.
+ Documentation updates:
  + Fixed bug ~~#39~~ "Change log not updated for sysinfo v5.6" by adding the required release information.
  + Removed acknowledgements from PJSysUtils.pas header comments into a new Docs/Acknowledgements.md document.
  + Added new "Acknowledgements" section to `Docs/ReadMe.htm` that links to Acknowledgements.md on SourceForge.

## v5.6.0 of 12 September 2021

+ Add detection of following Windows & Windows Server versions:
  + Windows 10 Version 21H1
  + Windows 10 Version 21H2 (provisional build number: due late 2021)
  + DEV, Insider preview and beta versions of Windows 11
  + Windows 2018 Server Versions 2004 and 20H2
  + Windows 2022 Server Version 21H2
+ Add new code to get OS' revision number, accessible via:
  + New TPJOSInfo.RevisionNumber method
  + New Win32RevisionNumber global variable
+ Modify format of TPJOSInfo.Description when returning info about Win 2000 and later
+ Update list of web pages used to source build numbers of various Windows versions
+ Update VCL and FMX demo programs re support for detecting Windows 11 & Windows Server 2022 and to display result of calling new TPJOSInfo.RevisionNumber method and Win32RevisionNumber global variable.

## v5.5.0 of 31 October 2020

+ Updated to detect Windows 10 version 20H2, October 2020 update.

## v5.4.0 of 19 March 2020

+ Updated to detect Windows 10 updates from RS2 (version 1703) to 20H2 (version 2004) and added "marketing names" for updates from TH2 (version 1511) to 19H2 (version 1909)
+ Updated to detect 1st public release and all updates of Windows 2016 Server (i.e. up to version 1803)
+ Added detection of all Windows 2019 Server previews, 1st public release and all updates up to version 1909.
+ Added new TPJComputerInfo.ProcessorSpeedMHz method to return processor speed in MHz.
+ Updated demo programs re support for detecting Windows 2019 Server and to display result of new TPJComputerInfo.ProcessorSpeedMHz method.
+ Minor update to content and style of read-me file.

## v5.3.0 of 12 September 2016

+ Added support for detecting Windows 10 RS1 update - "Version 1607".
+ Renamed name of Windows 10 TH2 update from "November Update" to MSs new name - "Version 1511".
+ Added support for detecting Windows 2016 Server technical previews 1 to 5.
+ Revised TPJOSInfo.Description to include information from ServicePackEx method instead of ServicePack.
+ Minor update to read-me file.

## v5.2.0 of 30 November 2015

+ Added support for detecting build number of Windows 10 TH2 "November Update".
+ Added new TPJOSInfo.ServicePackEx method that reports any OS service packs present just like TPJOSInfo.ServicePack but also returns the name of any significant, detectable, update that does not declare itself as a service pack. This method was added to enable Windows 10 TH2 "November Update" to be reported since it does not report itself as a service pack.
+ Changed behaviour of the TPJOSInfo.BuildNumber method. When not using the GetVersionEx API the code tries to deduce the build number from other information. If this fails BuildNumber now returns 0 instead of attempting to read the build number from the registry. The registry was found to be returning incorrect build numbers.
+ Updated read-me file re changes.

## v5.1.0 of 11 September 2015

+ Added support for detecting Windows 10 for suitably manifested host applications.
+ Added new TPJOSInfo.IsReallyWindows10OrGreater method.
+ Changed so that Windows 8, in addition to Windows 8.1 and now Windows 10 can't be "spoofed". This was required so that Windows 8 will be reported when an un-manifested application is running on Windows 10, per Microsoft documentation. This is a breaking change from release 5.0.x.
+ Updated demo programs re support for detecting Windows 10 and to display result of new TPJOSInfo.IsReallyWindows10OrGreater method. Also added Windows 10 compatible manifest to each demo's resources.
+ Updated documentation re changes.
+ Updated URL of documentation in Documentation.URL shortcut file to reference `delphidabbler/ddab-lib-docs` repository.

## v5.0.2 of 30 October 2014

+ Fixed issue ~~#31~~ "PJSysInfo v5.0.1 does not work on earlier OSs" where TPJOSInfo was causing an access violation when run on Windows 98.
+ Fixed issue ~~#33~~ "IsServer and IsWindowsServer return True on Windows 98".

## v5.0.1 of 04 April 2014

+ Fixed issue ~~#29~~ "Out of range error" that occurred when using Windows 8.1 or Windows Server 2012 R2.
+ Added support for DEBUG symbol to force range checking to be on for debugging purposes.
+ Minor changes to documentation.

## v5.0.0 of 27 February 2014

+ Changed how operating system information is obtained and reported when running on Windows 8.1 (and later) in order to conform to API changes introduced by Microsoft in Windows 8.1. As a consequence when running on Windows 8.1 and later OS information for the installed OS will always be reported regardless of whether the host program is running in compatibility. On Windows 8 and earlier running in a compatibility mode will continue to cause OS information to be "spoofed" to reflect the emulated OS.
+ New compile option to help debug the Windows 8.1 method of OS information when using any OS back to Windows Vista.
+ Added new TPJOSInfo.CanSpoof method that indicates if compatibility mode will affect (spoof) reported OS information on the current operating system.
+ Windows 8.1 and Windows 2012 Server R2 are now detected and reported.
+ Windows XP Home Edition is now detected correctly.
+ Numerous new methods added to TPJOSInfo that can detect if the current OS is greater than or equal to a given OS. These methods are not affected by compatibility mode regardless of the compile option used. There is one method for every OS version and service pack from Windows 2000 onwards.
+ New TPJOSInfo.IsWindowsServer method that detects if the OS is a server in a manner not affected by compatibility mode for Windows 2000 and later.
+ New TPJOSInfo.InstallationDate method that returns the date the OS is installed.
+ New global variables added that are analogues of the SysUtils Win32*** variables but that are not affected by compatibility mode when run on Windows 8.1 or later.
+ New constants relating to obtaining version information not defined by all supported versions of Delphi have been added to the unit's interface section.
+ Updated demos:
  + Both VCL and FireMonkey 2 demos revised to display output of all new TPJOSInfo methods and new global variables.
  + VCL demo no longer scrolls when displaying lists of information that exceed window height.
+ Delphi 3 is no longer supported by the unit.
+ Updated documentation.

## v4.0.3 of 11 January 2014

+ Fixed problem with compiler directives in System Information Unit that was causing compilation to fail on Delphi XE5.
+ Minor documentation tweaks and corrections.

## v4.0.2 of 29 October 2013

+ Fixed potential registry access bug that may appear on Windows 2000 and earlier. ~~See comment #1 of issue #14.~~

## v4.0.1 of 28 January 2013

+ Fixed bug in TPJOSInfo.RegisteredOrganisation ~~(issue #23)~~

## v4.0.0 of 20 January 2013

+ `PJSysInfo.pas` is now compatible with Delphi 32 and 64 bit compilers and will compile with both VCL and FireMonkey 2 frameworks on Windows.
+ Added numerous new methods:
  + TPJComputerInfo: "IsAdmin", "IsUACActive", "BiosVendor", "ProcessorIdentifier", "ProcessorName", "SystemManufacturer" & "SystemProductName".
  + TPJSystemFolders: "ProgramFilesX86", "ProgramFilesRedirect", "CommonFilesX86" & "CommonFilesRedirect".
  + TPJOSInfo: "RegisteredOrganisation" & "RegisteredOwner".
+ All previously deprecated code removed, i.e.:
  + TPJSysInfo component and associated glyph file `PJSysInfo.dcr`.
  + All SIGetXXXX functions.
+ Used unit names are now qualified with namespace name on Delphi XE2 and later.
+ Changed original SysInfoDemo VCL project:
  + Default window font changed.
  + Form is no longer scaled.
  + Displayed text no longer word-wraps.
  + Added example output for all new methods.
  + Added manifest to resources to request themed controls and set elevation level.
  + New project configuration files with option to compile for 32 bit or 64 Windows targets on Delphi XE2 and later.
+ Added new FireMonkey 2 demo project with same basic functionality as revised SysInfoDemo project that can also be compiled for either 32 bit or 64 bit Windows targets.
+ Some refactoring.
+ WinHelp file removed.
+ Revised documentation and changed link to online help.
+ Demos placed in public domain.

## v3.4.0 of 24 October 2012

+ Modified TPJOSInfo to detect Windows 8 and Windows 2012 Server.
+ Added new PRODUCT_* constants and descriptions.
+ Updated demo to display newly added OS versions.
+ Changed license to Mozilla Public License v2.0
+ Updated help file re addition of Windows 8 / Windows 20012 Server and re change of license.
+ Updated documentation.

## v3.3.1 of 07 April 2010

+ Fixed bug ~~(issue #14)~~ to correctly read from registry on Windows 64 systems. NOTE: This bug may persist when compiled with old Delphis (pre Delphi 6).
+ Corrected buffer sizes used when TPJComputerInfo's ComputerName and UserName methods access Windows API functions.

## v3.3.0 of 31 December 2009

+ Added new TPJOSInfo.IsRemoteSession method to check if the executable is running under Windows Terminal Server as a remote session.
+ Updated help file accordingly.

## v3.2.2 of 16 December 2009

+ Fixed bug ~~(issue #1)~~ which prevented the unit from compiling with Delphi 5.

## v3.2.1 of 14 November 2009

+ Prevented warnings on Delphi 4 when compiling without deprecated components.
+ Updated documentation.

## v3.2.0 of 27 September 2009

+ Added some further PRODUCT_* constants that are new for Windows 7 / 2008 Server R2.
+ Changed character set handling to take account of Unicode and non-Unicode compilers.
+ Unit, but not demo, can now be compiled on Delphi 3.
+ Removed compiler warnings in Delphi 7.
+ All exceptions raised are now of type EPJsysInfo.
+ Updated documentation.

## v3.1.0 of 13 April 2009

+ Updated help file re revised static classes.
+ Revised demo program by adding output for new methods.
+ Added further PROCESSOR_ARCHITECTURE_XXX, PROCESSOR_XXX and PRODUCT_XXX constants.
+ Made default OS data structures use Unicode versions when UNICODE is defined by compiler.
+ Changed to use GetNativeSystemInfo API function to get processor architecture if possible.
+ Modified TPJOSInfo to detect Windows 7 and Windows 2008 Server R2. Also changed a few OS and product descriptions.
+ Modified TPJOSInfo.Edition to add 64bit qualification to OS edition information for OSs running on 64 bit systems and using GetProductInfo API.
+ Added BootMode and IsNetworkPresent methods to TPJComputerInfo.
+ Added TPJSystemFolders.SystemWow64 method.
+ Product name of unknown later Windows version now contains major and minor version numbers.

## v3.0.0 of 15 April 2008

+ Added support for GetProductInfo API (Vista)
+ Added support for Windows 2008 server and 2003 server R2.
+ Rewrote code that gets OS edition.
+ Added further VER_SUITE_ flags.
+ Added new PRODUCT_XXX and PROCESSOR_XXX flags.
+ Added new SM_STARTER and SM_SERVER2 constants.
+ Added Unicode version of OSVERSIONINFOEX and expanded number of types referring to ANSI and Unicode versions of these structures.
+ Added new methods to TPJOSInfo class.
+ Added new processor related methods to TPJComputerInfo.
+ Added new Win32XXX global variables relating to availability and value of product information.
+ Deprecated TPJSysInfo component and SIGetXXX are now compiled only if a special symbol is defined. By default they are not compiled and the component is not registered.
+ Updated help file re revised static class and removed topics for deprecated component and functions.
+ Revised demo program:
  + Added output for new methods.
  + Removed demo of deprecated code.

## v2.1.0 of 15 October 2006

+ Added new TPJComputerInfo.MACAddress method that gets the MAC address of the first available network card.

## v2.0.1 of 07 January 2006

+ Fixed bug in TPJOSInfo.ProductName method when running on Windows 2003.

## v2.0.0 of 13 November 2005

+ Added new static classes that duplicate and extend the features of the TPJSysInfo component:
  + TPJComputerInfo: provides information about the host computer;
  + TPJSystemFolders: gets paths to system folders;
  + TPJOSInfo: provides operating system information.
+ Added new features to the TOSInfo classes:
  + getting Windows product ID;
  + detection of Windows Vista, XP Media Edition and XP Tablet Edition;
  + detection of WOW64 sub-system;
  + further operating system detection features.
+ Added new global Win32* variables to provide extended operating system version information in style of variables from SysUtils unit.
+ Re-implemented TPJSysInfo and SIGet* functions in terms of new static classes.
+ Flagged TPJSysInfo and the SIGet* functions as deprecated. New static classes should now be used instead.
+ Made TOSVersionInfoEx type and VER_NT_* and VER_SUITE_* constants public.
+ Updated help file.
+ Added A-link keywords file for integration into Delphi 6/7 help systems.
+ Updated demo program re new features.

## v1.2.0 of 30 June 2003

+ Updated palette name to "DelphiDabbler" from "PJ Stuff".
+ Added support for Windows 2003 server to OS detection functions.
+ Removed requirement for Registry unit by accessing registry via Windows API where required.
+ Made TOSVersionInfoEx record definition into packed record.
+ GetOSProduct, GetOSProductType & GetOSServicePack updated according to latest example on MSDN.
+ Used resource strings for exception messages.
+ Updated help file.
+ Added new demo application.

## v1.1.0 of 25 November 2001

+ Added functions and component properties to retrieve Program Files and Common Files folders.

## v1.0.0 of 10 November 2001

+ Original version.
