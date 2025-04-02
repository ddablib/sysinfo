# System Information Unit

## Contents

* [Description](#description)
* [Installation](#installation)
* [Documentation](#documentation)
* [Demo Projects](#demo-projects)
* [Update History](#update-history)
* [Acknowledgements](#acknowledgements)
* [License](#license)
* [Bugs and Feature Requests](#bugs-and-feature-requests)
* [About the Author](#about-the-author)

This document applies to _System Information Unit_ v5.25.0 and later.

## Description

This unit contains a group of classes and some global variables that provide information about the user's computer system and operating system. Some useful constants and type definitions are also included. The classes are:

* _TPJComputerInfo_ – static class that provides information about the host computer and the current user.
* _TPJSystemFolders_ – static class that gets the full path to certain system folders.
* _TPJOSInfo_ – static class that supplies information about the operating system.
* _TPJBiosInfo_ - class that provides information about the computer's BIOS.

In addition, the unit extends and enhances the OS version information provided by the `SysUtils` unit's _Win32xxx_ variables (such as _Win32Platform_) by defining further _Win32xxx_ variables that store the extended operating system information available on later OSs.

### Effect of changes to the Windows API

With the release of Windows 8.1, Microsoft made a controversial decision to deprecate the _GetVersion_ API functions. These functions have always been used by the _System Information Unit_ to retrieve OS version formation. A new method of checking the operating system version was recommended, which was to use the _VerifyVersionInfo_ API. Unbelievably, this API itself became deprecated in Windows 10, but no viable alternative was introduced. In fact, the Windows 10 SDK still uses the newly deprecated API!

If the old _GetVersion_ approach is used then Windows 8.1 represents itself as Windows 8, unless the host program has a [special manifest](https://docs.microsoft.com/en-gb/windows/win32/sysinfo/targeting-your-application-at-windows-8-1). Using the _VerifyVersionInfo_ API gets round that problem and Windows 8.1 reports itself as the correct version, with or without the manifest.

For this reason, release 5.0 of the _System Information Unit_ was revised to use the _VerifyVersionInfo_ API for Windows 8.1 and later while retaining the _GetVersion_ API for Windows 8 and earlier.

With Windows 10, the _VerifyVersionInfo_ API only reports Windows 10 correctly if the host program is [manifested](https://docs.microsoft.com/en-gb/windows/win32/sysinfo/targeting-your-application-at-windows-8-1) correctly. If there is no suitable manifest then Windows 10 reports itself as Windows 8, regardless of the API used. Believe it or not, this behaviour is as designed by Microsoft.

Unfortunately, the decision made in release 5.0 to apply _VerifyVersionInfo_ only to Windows 8.1 and later resulted in un-manifested applications running on Windows 10 reporting Windows 7 instead of Windows 8 as documented by Microsoft. To fix this problem the _VerifyVersionInfo_ API is now also used when running on Windows 8.

Apart from being more cumbersome and slower, the _VerifyVersionInfo_ API approach differs from the old approach in an important respect. When a program is run in compatibility mode the old _GetVersion_ API functions would be fooled (or"spoofed") by Windows into reporting the version of the operating system emulated by the compatibility mode (more or less!). This is the way the unit has always behaved in the past. The new approach used for Windows 8.1 (introduced in v5.0 of this unit) always returns information about the true operating system, regardless of any active compatibility mode. As noted above, when adding support for Windows 10 (in version 5.1) the use of _VerifyVersionInfo_ was extended to Windows 8. As a consequence Windows 8, 8.1 and 10 cannot be spoofed. This is a change to the behaviour of v5.0 for Windows 8, meaning some code that depended on being able to spoof Windows 8 may no longer work.

To make things easier for users of Windows 2000 and later (i.e. just about everyone) a bunch of interrogation functions that can't be spoofed have been added to _TPJOSInfo_. You can also find out if OS spoofing is enabled for the host operating system by examining the _CanSpoof_ method of _TPJOSInfo_.

In summary, we have several inconsistencies in _TPJOSInfo_, all because of some incomprehensible decisions made by Microsoft. They are:

* For OSs up to and including Windows 7 SP 1, the reported operating system can be "spoofed" by setting the host program's compatibility mode. The exception is that the _TPJOSInfo.IsReallyWindowsXXXOrGreater_ methods for Windows 2000 to 8.1 will detect the actual underlying operating system version.

* For Windows 8 and 8.1 the reported operating system cannot be spoofed using compatibility modes. Furthermore, the presence or absence of a suitable manifest file doesn't affect the returned values. This also applies to the relevant _TPJOSInfo.IsReallyWindowsXXXOrGreater_ methods.

* For Windows 10 and 11, the reported operating system cannot be spoofed, regardless of whether or not a suitable manifest is compiled into resources. However, in the absence of such a manifest, the version is _always_ reported as Windows 8! This also affects the _TPJOSInfo.IsReallyWindows10OrGreater_ method, meaning that it's not so well named any more!

After exploring and testing a lot of options this really is the best solution I can find. **Thanks a bundle Microsoft!**

To add insult to injury, when Microsoft released the Windows 10 "November Update" (a.k.a TH2 a.k.a. Version 1511) they bumped the OS's build number but didn't update the service pack version information. Therefore existing code didn't report the update other than via the change in build number. I didn't want to break the existing _TPJOSInfo.ServicePack_ method by pretending that TH2 was really a service pack, so I added a new _ServicePackEx_ method to report any significant updates that don't declare themselves as service packs. Ho hum!

Unbelievably Windows 11 still declares itself as v10.0, making it indistinguishable from Windows 10. In fact the release of Windows 11 was only distinguished by a change in revision to a certain build number. _TPJOSInfo_ looks out for that change and reports Windows 11 correctly. They really don't make it easy do they?

Sorry that this is all so complicated - but it's ***complicated***!! And, IMHO, deeply stupid.

### Debug Mode

To help with debugging, developers can define the `DEBUG` symbol. Range checking is forced on when `DEBUG` is defined.

Normally, the _VerifyVersionInfo_ API is used only when detecting Windows 8 and later. To enable code using this API to be tested on machines running Windows Vista or Windows 7, developers can temporarily define the `DEBUG_NEW_API` symbol. This causes the _VerifyVersionInfo_ API to be used for detection of Windows Vista and Windows 7. `DEBUG_NEW_API` is less useful than it was when Windows 8 was new: the symbol may be removed from future relesses.

### Deleted Code

Version 2 and earlier of the unit provided the _TPJSysInfo_ component and various _SIGetxxx_ functions. As of v3.0 these were deprecated and finally removed at v4.0.

### Compatibility

This unit is designed for compilation with the 32 bit and 64 bit Windows Delphi compilers. The latest version has been tested with Delphi XE, Delphi 11.0 Alexandria and Delphi 12 Athens only. An attempt has been made to retain compatibility back to Delphi 4, but this has not been tested for some time, so it's not guaranteed.

Compilation on old Delphi versions that do not support setting registry access flags via _TRegistry_ is not recommended since parts of the code may not work correctly on 64 bit Windows.

The unit is not compatible with .NET.

The unit _should_ operate correctly on the following platforms:

* Windows 95 to Me
* All 32 bit NT platform operating systems.
* Windows 64 bit, either as part of a 32 bit or 64 bit process.

While every effort is made to keep the code as compatible with all OSs as possible, I'm only able to test on my one and only Windows OS: currently Windows 11.

The code is not suitable for non-Windows operating systems since it depends on the Windows API.

## Installation

The _System Information Unit_ and demo programs are supplied in a zip file. Before installing you need to extract all the files, preserving the directory structure. The following files will be extracted:

* **`PJSysInfo.pas`** – Source code of the classes, global variables, constants and type definitions.
* `README.md` – This read-me file.
* `CHANGELOG.md` – The unit's change log.
* `MPL-2.0.txt` – Mozilla Public Licence v2.0.
* `Documentation.URL` – Short-cut to online documentation.

In addition to the above files you will find the source code of two demo projects and their read-me file in the `Demos` directory.

There are four possible ways to use the unit.

1. The simplest way is to add `PJSysInfo.pas` to your projects as you need it.
2. To make the unit easier to re-use you can either copy it to a folder on your Delphi search path, or add the folder where you extracted the unit to the search path. You then simply use the unit as required without needing to add it to your project.
3. For maximum portability you can add the unit to a Delphi package.
4. If you use Git you can added the [`ddablib/sysinfo`](https://github.com/ddablib/sysinfo) GitHub repository as a Git submodule and add it to your project. Obviously, it's safer if you fork the repo and use your copy, just in case `ddablib/sysinfo` ever goes away.

## Documentation

The _System Information Unit_ is fully [documented online](https://delphidabbler.com/url/sysinfo-docs).

## Demo Projects

Two demo projects are included in the download in the `Demos\VCL` and the `Demos\FMX` directories. The former compiles to a VCL application using Delphi XE (and possibly even Delphi 4) or later while the latter uses the FireMonkey 2 framework and requires Delphi XE3 as a minimum. Both projects can be compiled to either Windows 32 bit or 64 bit targets.

Each project contains a tab set where each tab displays the information from one of the classes or the global variables.

## Update History

A complete change log is provided in [`CHANGELOG.md`](https://github.com/ddablib/sysinfo/blob/main/CHANGELOG.md) that is included in the download.

## Acknowledgements

Information from numerous websites has been used while developing this code. Several individuals have also suggested solutions or contributed code.

Full details are provided in the file [`Acknowledgements.md`](https://github.com/ddablib/sysinfo/blob/main/Docs/Acknowledgements.md) in the `./Docs` subdirectory of the [`ddablib/sysinfo`](https://github.com/ddablib/sysinfo) GitHub repository.

## License

The _System Information Unit_ is copyright © 2001-2025 [Peter D Johnson](https://gravatar.com/delphidabbler) and is released under the terms of the [Mozilla Public License, v2.0](https://www.mozilla.org/MPL/2.0/).

## Bugs and Feature Requests

Bugs can be reported or new features requested via the [Issue Tracker](https://github.com/ddablib/sysinfo/issues). A GitHub account is required.

## About the Author

I'm Peter Johnson – a hobbyist programmer living in Ceredigion in West Wales, UK, writing mainly in Delphi. My programs and other library code are available from: [https://delphidabbler.com/](https://delphidabbler.com/).

This document is copyright © 2005-2025, [Peter D Johnson](https://gravatar.com/delphidabbler).
