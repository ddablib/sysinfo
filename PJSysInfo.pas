{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2001-2025, Peter Johnson (https://gravatar.com/delphidabbler).
 *
 * Except TPJOSInfo.DecodedDigitalProductIDWin8AndUp which is copyright (c) 2020
 * Pavel Hruska, MIT license (See https://tinyurl.com/35jybnem).
 *
 * This unit contains various static classes, constants, type definitions and
 * global variables for use in providing information about the host computer and
 * operating system.
 *
 * NOTES
 *
 *  1: When compiled with old versions of Delphi that do not support setting
 *     registry access flags via the TRegistry object, some of this code may not
 *     work correctly when running on 64 bit Windows.
 *
 *  2: The code has been tested with the Delphi 64 bit compiler (introduced
 *     in Delphi XE2) and functions correctly.
 *
 *  3: When run on operating systems up to and including Windows 8 running the
 *     host program in compatibility mode causes some variables and TPJOSInfo
 *     methods to be "spoofed" into returning information about the emulated
 *     OS. When run on Windows 8.1 details of the actual host operating system
 *     are always returned and the emulated OS is ignored.
 *
 *  4: On Windows 10 and later the correct operating system will only be
 *     reported if the application declares the operating systems it supports
 *     in its manifest.
 *
 * ACKNOWLEDGEMENTS
 *
 * See Docs/Acknowledgements.md
}


unit PJSysInfo;


// Define DEBUG whenever debugging.
// *** IMPORTANT: Ensure that DEBUG is NOT defined in production code.
{.$DEFINE DEBUG}

// Define DEBUG_NEW_API if debugging on Windows Vista to Windows 8 in order to
// check that the new version API used for Windows 8.1 and later is working.
// This will cause the new API to be used for Windows Vista and later instead
// of only Windows 8.1 and later.
// *** IMPORTANT: Ensure that DEBUG_NEW_API is NOT defined in production code.
{.$DEFINE DEBUG_NEW_API}


// Conditional defines
// ===================

// Assume all required facilities available
{$DEFINE REGACCESSFLAGS}      // TRegistry access flags available
{$DEFINE WARNDIRS}            // $WARN compiler directives available
{$DEFINE EXCLUDETRAILING}     // SysUtils.ExcludeTrailingPathDelimiter available
{$UNDEF RTLNAMESPACES}        // No support for RTL namespaces in unit names
{$UNDEF HASUNIT64}            // UInt64 type not defined
{$UNDEF INLINEMETHODS}        // No support for inline methods
{$UNDEF HASTBYTES}            // TBytes not defined
{$UNDEF STRLENDEPRECATED}     // StrLen in SysUtils moved to AnsiStrings

// Undefine facilities not available in earlier compilers
// Note: Delphi 1 to 3 is not included since the code will not compile on these
// compilers
{$IFDEF VER120} // Delphi 4
  {$UNDEF REGACCESSFLAGS}
  {$UNDEF WARNDIRS}
  {$UNDEF EXCLUDETRAILING}
{$ENDIF}
{$IFDEF VER130} // Delphi 5
  {$UNDEF REGACCESSFLAGS}
  {$UNDEF WARNDIRS}
  {$UNDEF EXCLUDETRAILING}  // ** fix by Rich Habedank
{$ENDIF}
{$IFDEF VER140} // Delphi 6
  {$UNDEF WARNDIRS}
{$ENDIF}
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 24.0} // Delphi XE3 and later
    {$LEGACYIFEND ON}  // NOTE: this must come before all $IFEND directives
  {$IFEND}
  {$IF CompilerVersion >= 25.0}
    {$DEFINE STRLENDEPRECATED}  // Delphi XE4 and later
  {$IFEND}
  {$IF CompilerVersion >= 18.5} // Delphi 2007 Win32 and later
    {$DEFINE HASTBYTES}
  {$IFEND}
  {$IF CompilerVersion >= 23.0} // Delphi XE2 and later
    {$DEFINE RTLNAMESPACES}
  {$IFEND}
  {$IF CompilerVersion >= 17.0} // Delphi 2005 and later
    {$DEFINE INLINEMETHODS}
  {$IFEND}
  {$IF Declared(UInt64)}
    {$DEFINE HASUINT64}
  {$IFEND}
{$ENDIF}

{$WRITEABLECONST OFF}

// Switch off "unsafe" warnings for this unit
{$IFDEF WARNDIRS}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CODE OFF}
{$ENDIF}

// Switch on range checking when debugging. In production code it's the user's
// choice whether to use range checking or not
{$IFDEF DEBUG}
  {$RANGECHECKS ON}
{$ENDIF}


interface


uses
  // Delphi
  {$IFNDEF RTLNAMESPACES}
  SysUtils, Classes, Windows;
  {$ELSE}
  System.SysUtils,
  {$IFDEF STRLENDEPRECATED}
  System.AnsiStrings,
  {$ENDIF}
  System.Classes,
  Winapi.Windows;
  {$ENDIF}

{$IFNDEF HASTBYTES}
// Compiler doesn't have TBytes: define it
type
  TBytes = array of Byte;
{$ENDIF}

type
  // Windows types not defined in all supported Delphi VCLs

  // ANSI versions of the Win API OSVERSIONINFOEX structure and pointers
  _OSVERSIONINFOEXA = packed record
    dwOSVersionInfoSize: DWORD;               // size of structure
    dwMajorVersion: DWORD;                    // major OS version number
    dwMinorVersion: DWORD;                    // minor OS version number
    dwBuildNumber: DWORD;                     // OS build number
    dwPlatformId: DWORD;                      // OS platform identifier
    szCSDVersion: array[0..127] of AnsiChar;  // service pack or extra info
    wServicePackMajor: WORD;                  // service pack major version no.
    wServicePackMinor: WORD;                  // service pack minor version no.
    wSuiteMask: WORD;                         // bitmask that stores OS suite(s)
    wProductType: Byte;                       // additional info about system
    wReserved: Byte;                          // reserved for future use
  end;
  OSVERSIONINFOEXA = _OSVERSIONINFOEXA;
  {$EXTERNALSYM OSVERSIONINFOEXA}
  TOSVersionInfoExA = _OSVERSIONINFOEXA;
  POSVersionInfoExA = ^TOSVersionInfoExA;

  // Unicode versions of the Win API OSVERSIONINFOEX structure and pointers
  _OSVERSIONINFOEXW = packed record
    dwOSVersionInfoSize: DWORD;               // size of structure
    dwMajorVersion: DWORD;                    // major OS version number
    dwMinorVersion: DWORD;                    // minor OS version number
    dwBuildNumber: DWORD;                     // OS build number
    dwPlatformId: DWORD;                      // OS platform identifier
    szCSDVersion: array[0..127] of WideChar;  // service pack or extra info
    wServicePackMajor: WORD;                  // service pack major version no.
    wServicePackMinor: WORD;                  // service pack minor version no.
    wSuiteMask: WORD;                         // bitmask that stores OS suite(s)
    wProductType: Byte;                       // additional info about system
    wReserved: Byte;                          // reserved for future use
  end;
  OSVERSIONINFOEXW = _OSVERSIONINFOEXW;
  {$EXTERNALSYM OSVERSIONINFOEXW}
  TOSVersionInfoExW = _OSVERSIONINFOEXW;
  POSVersionInfoExW = ^TOSVersionInfoExW;

  // Default version of the Win API OSVERSIONINFOEX structure.
  // UNICODE is defined when the Unicode API is used, so we use this to decide
  // which structure to use as default.
  {$IFDEF UNICODE}
  _OSVERSIONINFOEX = _OSVERSIONINFOEXW;
  {$EXTERNALSYM _OSVERSIONINFOEXW}
  OSVERSIONINFOEX = OSVERSIONINFOEXW;
  {$EXTERNALSYM OSVERSIONINFOEX}
  TOSVersionInfoEx = TOSVersionInfoExW;
  POSVersionInfoEx = POSVersionInfoExW;
  {$ELSE}
  _OSVERSIONINFOEX = _OSVERSIONINFOEXA;
  {$EXTERNALSYM _OSVERSIONINFOEXA}
  OSVERSIONINFOEX = OSVERSIONINFOEXA;
  {$EXTERNALSYM OSVERSIONINFOEX}
  TOSVersionInfoEx = TOSVersionInfoExA;
  POSVersionInfoEx = POSVersionInfoExA;
  {$ENDIF}

const

  // Windows constants possibly not defined in all supported Delphi VCLs

  // Conditional consts used in VerSetConditionMask calls
  VER_EQUAL         = 1; // current value = specified value.
  {$EXTERNALSYM VER_EQUAL}
  VER_GREATER       = 2; // current value > specified value.
  {$EXTERNALSYM VER_GREATER}
  VER_GREATER_EQUAL = 3; // current value >= specified value.
  {$EXTERNALSYM VER_GREATER_EQUAL}
  VER_LESS          = 4; // current value < specified value.
  {$EXTERNALSYM VER_LESS}
  VER_LESS_EQUAL    = 5; // current value <= specified value.
  {$EXTERNALSYM VER_LESS_EQUAL}

  // Platform ID defines
  // these are not included in Windows unit of all supported Delphis
  VER_BUILDNUMBER       = $00000004;
  {$EXTERNALSYM VER_BUILDNUMBER}
  VER_MAJORVERSION      = $00000002;
  {$EXTERNALSYM VER_MAJORVERSION}
  VER_MINORVERSION      = $00000001;
  {$EXTERNALSYM VER_MINORVERSION}
  VER_PLATFORMID        = $00000008;
  {$EXTERNALSYM VER_PLATFORMID}
  VER_SERVICEPACKMAJOR  = $00000020;
  {$EXTERNALSYM VER_SERVICEPACKMAJOR}
  VER_SERVICEPACKMINOR  = $00000010;
  {$EXTERNALSYM VER_SERVICEPACKMINOR}
  VER_SUITENAME         = $00000040;
  {$EXTERNALSYM VER_SUITENAME}
  VER_PRODUCT_TYPE      = $00000080;
  {$EXTERNALSYM VER_PRODUCT_TYPE}

  // Constants from sdkddkver.h
  _WIN32_WINNT_NT4          = $0400; // Windows NT 4
  {$EXTERNALSYM _WIN32_WINNT_NT4}
  _WIN32_WINNT_WIN2K        = $0500; // Windows 2000
  {$EXTERNALSYM _WIN32_WINNT_WIN2K}
  _WIN32_WINNT_WINXP        = $0501; // Windows XP
  {$EXTERNALSYM _WIN32_WINNT_WINXP}
  _WIN32_WINNT_WS03         = $0502; // Windows Server 2003
  {$EXTERNALSYM _WIN32_WINNT_WS03}
  _WIN32_WINNT_WIN6         = $0600; // Windows Vista
  {$EXTERNALSYM _WIN32_WINNT_WIN6}
  _WIN32_WINNT_VISTA        = $0600; // Windows Vista
  {$EXTERNALSYM _WIN32_WINNT_VISTA}
  _WIN32_WINNT_WS08         = $0600; // Windows Server 2008
  {$EXTERNALSYM _WIN32_WINNT_WS08}
  _WIN32_WINNT_LONGHORN     = $0600; // Windows Vista
  {$EXTERNALSYM _WIN32_WINNT_LONGHORN}
  _WIN32_WINNT_WIN7         = $0601; // Windows 7
  {$EXTERNALSYM _WIN32_WINNT_WIN7}
  _WIN32_WINNT_WIN8         = $0602; // Windows 8
  {$EXTERNALSYM _WIN32_WINNT_WIN8}
  _WIN32_WINNT_WINBLUE      = $0603; // Windows 8.1
  {$EXTERNALSYM _WIN32_WINNT_WINBLUE}
  _WIN32_WINNT_WINTHRESHOLD = $0A00; // Windows 10
  {$EXTERNALSYM _WIN32_WINNT_WINTHRESHOLD}
  _WIN32_WINNT_WIN10        = $0A00; // Windows 10
  {$EXTERNALSYM _WIN32_WINNT_WIN10}


  // These Windows-defined constants are required for use with TOSVersionInfoEx
  // NT Product types
  VER_NT_WORKSTATION                          = 1;
  {$EXTERNALSYM VER_NT_WORKSTATION}
  VER_NT_DOMAIN_CONTROLLER                    = 2;
  {$EXTERNALSYM VER_NT_DOMAIN_CONTROLLER}
  VER_NT_SERVER                               = 3;
  {$EXTERNALSYM VER_NT_SERVER}
  // Mask representing NT product suites
  VER_SUITE_SMALLBUSINESS                     = $00000001;
  {$EXTERNALSYM VER_SUITE_SMALLBUSINESS}
  VER_SUITE_ENTERPRISE                        = $00000002;
  {$EXTERNALSYM VER_SUITE_ENTERPRISE}
  VER_SUITE_BACKOFFICE                        = $00000004;
  {$EXTERNALSYM VER_SUITE_BACKOFFICE}
  VER_SUITE_COMMUNICATIONS                    = $00000008;
  {$EXTERNALSYM VER_SUITE_COMMUNICATIONS}
  VER_SUITE_TERMINAL                          = $00000010;
  {$EXTERNALSYM VER_SUITE_TERMINAL}
  VER_SUITE_SMALLBUSINESS_RESTRICTED          = $00000020;
  {$EXTERNALSYM VER_SUITE_SMALLBUSINESS_RESTRICTED}
  VER_SUITE_EMBEDDEDNT                        = $00000040;
  {$EXTERNALSYM VER_SUITE_EMBEDDEDNT}
  VER_SUITE_DATACENTER                        = $00000080;
  {$EXTERNALSYM VER_SUITE_DATACENTER}
  VER_SUITE_SINGLEUSERTS                      = $00000100;
  {$EXTERNALSYM VER_SUITE_SINGLEUSERTS}
  VER_SUITE_PERSONAL                          = $00000200;
  {$EXTERNALSYM VER_SUITE_PERSONAL}
  VER_SUITE_SERVERAPPLIANCE                   = $00000400;
  {$EXTERNALSYM VER_SUITE_SERVERAPPLIANCE}
  VER_SUITE_BLADE                             = VER_SUITE_SERVERAPPLIANCE;
  {$EXTERNALSYM VER_SUITE_BLADE}
  VER_SUITE_EMBEDDED_RESTRICTED               = $00000800;
  {$EXTERNALSYM VER_SUITE_EMBEDDED_RESTRICTED}
  VER_SUITE_SECURITY_APPLIANCE                = $00001000;
  {$EXTERNALSYM VER_SUITE_SECURITY_APPLIANCE}
  VER_SUITE_STORAGE_SERVER                    = $00002000;
  {$EXTERNALSYM VER_SUITE_STORAGE_SERVER}
  VER_SUITE_COMPUTE_SERVER                    = $00004000;
  {$EXTERNALSYM VER_SUITE_COMPUTE_SERVER}
  VER_SUITE_WH_SERVER                         = $00008000;
  {$EXTERNALSYM VER_SUITE_WH_SERVER}

  // These Windows-defined constants are required for use with the
  // GetProductInfo API call used with Windows Vista and later
  // NOTE: PRODUCT_xxx constants marked with an asterisk comment have no
  //       associated description hard wired into this unit.
  // ** Thanks to Laurent Pierre for providing these definitions originally.
  // ** Subsequent additions were obtained from https://tinyurl.com/3rhhbs2z
  // ** and the Windows 11 24H2 SDK
  PRODUCT_UNDEFINED                             = $00000000;
  {$EXTERNALSYM PRODUCT_UNDEFINED}
  PRODUCT_ULTIMATE                              = $00000001;
  {$EXTERNALSYM PRODUCT_ULTIMATE}
  PRODUCT_HOME_BASIC                            = $00000002;
  {$EXTERNALSYM PRODUCT_HOME_BASIC}
  PRODUCT_HOME_PREMIUM                          = $00000003;
  {$EXTERNALSYM PRODUCT_HOME_PREMIUM}
  PRODUCT_ENTERPRISE                            = $00000004;
  {$EXTERNALSYM PRODUCT_ENTERPRISE}
  PRODUCT_HOME_BASIC_N                          = $00000005;
  {$EXTERNALSYM PRODUCT_HOME_BASIC_N}
  PRODUCT_BUSINESS                              = $00000006;
  {$EXTERNALSYM PRODUCT_BUSINESS}
  PRODUCT_STANDARD_SERVER                       = $00000007;
  {$EXTERNALSYM PRODUCT_STANDARD_SERVER}
  PRODUCT_DATACENTER_SERVER                     = $00000008;
  {$EXTERNALSYM PRODUCT_DATACENTER_SERVER}
  PRODUCT_SMALLBUSINESS_SERVER                  = $00000009;
  {$EXTERNALSYM PRODUCT_SMALLBUSINESS_SERVER}
  PRODUCT_ENTERPRISE_SERVER                     = $0000000A;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_SERVER}
  PRODUCT_STARTER                               = $0000000B;
  {$EXTERNALSYM PRODUCT_STARTER}
  PRODUCT_DATACENTER_SERVER_CORE                = $0000000C;
  {$EXTERNALSYM PRODUCT_DATACENTER_SERVER_CORE}
  PRODUCT_STANDARD_SERVER_CORE                  = $0000000D;
  {$EXTERNALSYM PRODUCT_STANDARD_SERVER_CORE}
  PRODUCT_ENTERPRISE_SERVER_CORE                = $0000000E;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_SERVER_CORE}
  PRODUCT_ENTERPRISE_SERVER_IA64                = $0000000F;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_SERVER_IA64}
  PRODUCT_BUSINESS_N                            = $00000010;
  {$EXTERNALSYM PRODUCT_BUSINESS_N}
  PRODUCT_WEB_SERVER                            = $00000011;
  {$EXTERNALSYM PRODUCT_WEB_SERVER}
  PRODUCT_CLUSTER_SERVER                        = $00000012;
  {$EXTERNALSYM PRODUCT_CLUSTER_SERVER}
  PRODUCT_HOME_SERVER                           = $00000013;
  {$EXTERNALSYM PRODUCT_HOME_SERVER}
  PRODUCT_STORAGE_EXPRESS_SERVER                = $00000014;
  {$EXTERNALSYM PRODUCT_STORAGE_EXPRESS_SERVER}
  PRODUCT_STORAGE_STANDARD_SERVER               = $00000015;
  {$EXTERNALSYM PRODUCT_STORAGE_STANDARD_SERVER}
  PRODUCT_STORAGE_WORKGROUP_SERVER              = $00000016;
  {$EXTERNALSYM PRODUCT_STORAGE_WORKGROUP_SERVER}
  PRODUCT_STORAGE_ENTERPRISE_SERVER             = $00000017;
  {$EXTERNALSYM PRODUCT_STORAGE_ENTERPRISE_SERVER}
  PRODUCT_SERVER_FOR_SMALLBUSINESS              = $00000018;
  {$EXTERNALSYM PRODUCT_SERVER_FOR_SMALLBUSINESS}
  PRODUCT_SMALLBUSINESS_SERVER_PREMIUM          = $00000019;
  {$EXTERNALSYM PRODUCT_SMALLBUSINESS_SERVER_PREMIUM}
  PRODUCT_HOME_PREMIUM_N                        = $0000001A;
  {$EXTERNALSYM PRODUCT_HOME_PREMIUM_N}
  PRODUCT_ENTERPRISE_N                          = $0000001B;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_N}
  PRODUCT_ULTIMATE_N                            = $0000001C;
  {$EXTERNALSYM PRODUCT_ULTIMATE_N}
  PRODUCT_WEB_SERVER_CORE                       = $0000001D;
  {$EXTERNALSYM PRODUCT_WEB_SERVER_CORE}
  PRODUCT_MEDIUMBUSINESS_SERVER_MANAGEMENT      = $0000001E;
  {$EXTERNALSYM PRODUCT_MEDIUMBUSINESS_SERVER_MANAGEMENT}
  PRODUCT_MEDIUMBUSINESS_SERVER_SECURITY        = $0000001F;
  {$EXTERNALSYM PRODUCT_MEDIUMBUSINESS_SERVER_SECURITY}
  PRODUCT_MEDIUMBUSINESS_SERVER_MESSAGING       = $00000020;
  {$EXTERNALSYM PRODUCT_MEDIUMBUSINESS_SERVER_MESSAGING}
  PRODUCT_SERVER_FOUNDATION                     = $00000021;
  {$EXTERNALSYM PRODUCT_SERVER_FOUNDATION}
  PRODUCT_HOME_PREMIUM_SERVER                   = $00000022;
  {$EXTERNALSYM PRODUCT_HOME_PREMIUM_SERVER}
  PRODUCT_SERVER_FOR_SMALLBUSINESS_V            = $00000023;
  {$EXTERNALSYM PRODUCT_SERVER_FOR_SMALLBUSINESS_V}
  PRODUCT_STANDARD_SERVER_V                     = $00000024;
  {$EXTERNALSYM PRODUCT_STANDARD_SERVER_V}
  PRODUCT_DATACENTER_SERVER_V                   = $00000025;
  {$EXTERNALSYM PRODUCT_DATACENTER_SERVER_V}
  PRODUCT_ENTERPRISE_SERVER_V                   = $00000026;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_SERVER_V}
  PRODUCT_DATACENTER_SERVER_CORE_V              = $00000027;
  {$EXTERNALSYM PRODUCT_DATACENTER_SERVER_CORE_V}
  PRODUCT_STANDARD_SERVER_CORE_V                = $00000028;
  {$EXTERNALSYM PRODUCT_STANDARD_SERVER_CORE_V}
  PRODUCT_ENTERPRISE_SERVER_CORE_V              = $00000029;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_SERVER_CORE_V}
  PRODUCT_HYPERV                                = $0000002A;
  {$EXTERNALSYM PRODUCT_HYPERV}
  PRODUCT_STORAGE_EXPRESS_SERVER_CORE           = $0000002B;
  {$EXTERNALSYM PRODUCT_STORAGE_EXPRESS_SERVER_CORE}
  PRODUCT_STORAGE_STANDARD_SERVER_CORE          = $0000002C;
  {$EXTERNALSYM PRODUCT_STORAGE_STANDARD_SERVER_CORE}
  PRODUCT_STORAGE_WORKGROUP_SERVER_CORE         = $0000002D;
  {$EXTERNALSYM PRODUCT_STORAGE_WORKGROUP_SERVER_CORE}
  PRODUCT_STORAGE_ENTERPRISE_SERVER_CORE        = $0000002E;
  {$EXTERNALSYM PRODUCT_STORAGE_ENTERPRISE_SERVER_CORE}
  PRODUCT_STARTER_N                             = $0000002F;
  {$EXTERNALSYM PRODUCT_STARTER_N}
  PRODUCT_PROFESSIONAL                          = $00000030;
  {$EXTERNALSYM PRODUCT_PROFESSIONAL}
  PRODUCT_PROFESSIONAL_N                        = $00000031;
  {$EXTERNALSYM PRODUCT_PROFESSIONAL_N}
  PRODUCT_SB_SOLUTION_SERVER                    = $00000032;
  {$EXTERNALSYM PRODUCT_SB_SOLUTION_SERVER}
  PRODUCT_SERVER_FOR_SB_SOLUTIONS               = $00000033;
  {$EXTERNALSYM PRODUCT_SERVER_FOR_SB_SOLUTIONS}
  PRODUCT_STANDARD_SERVER_SOLUTIONS             = $00000034;
  {$EXTERNALSYM PRODUCT_STANDARD_SERVER_SOLUTIONS}
  PRODUCT_STANDARD_SERVER_SOLUTIONS_CORE        = $00000035;
  {$EXTERNALSYM PRODUCT_STANDARD_SERVER_SOLUTIONS_CORE}
  PRODUCT_SB_SOLUTION_SERVER_EM                 = $00000036;
  {$EXTERNALSYM PRODUCT_SB_SOLUTION_SERVER_EM}
  PRODUCT_SERVER_FOR_SB_SOLUTIONS_EM            = $00000037;
  {$EXTERNALSYM PRODUCT_SERVER_FOR_SB_SOLUTIONS_EM}
  PRODUCT_SOLUTION_EMBEDDEDSERVER               = $00000038;
  {$EXTERNALSYM PRODUCT_SOLUTION_EMBEDDEDSERVER}
  PRODUCT_SOLUTION_EMBEDDEDSERVER_CORE          = $00000039; // *
  {$EXTERNALSYM PRODUCT_SOLUTION_EMBEDDEDSERVER_CORE}
  PRODUCT_PROFESSIONAL_EMBEDDED                 = $0000003A; // *
  {$EXTERNALSYM PRODUCT_PROFESSIONAL_EMBEDDED}
  PRODUCT_ESSENTIALBUSINESS_SERVER_MGMT         = $0000003B;
  {$EXTERNALSYM PRODUCT_ESSENTIALBUSINESS_SERVER_MGMT}
  PRODUCT_ESSENTIALBUSINESS_SERVER_ADDL         = $0000003C;
  {$EXTERNALSYM PRODUCT_ESSENTIALBUSINESS_SERVER_ADDL}
  PRODUCT_ESSENTIALBUSINESS_SERVER_MGMTSVC      = $0000003D;
  {$EXTERNALSYM PRODUCT_ESSENTIALBUSINESS_SERVER_MGMTSVC}
  PRODUCT_ESSENTIALBUSINESS_SERVER_ADDLSVC      = $0000003E;
  {$EXTERNALSYM PRODUCT_ESSENTIALBUSINESS_SERVER_ADDLSVC}
  PRODUCT_SMALLBUSINESS_SERVER_PREMIUM_CORE     = $0000003F;
  {$EXTERNALSYM PRODUCT_SMALLBUSINESS_SERVER_PREMIUM_CORE}
  PRODUCT_CLUSTER_SERVER_V                      = $00000040;
  {$EXTERNALSYM PRODUCT_CLUSTER_SERVER_V}
  PRODUCT_EMBEDDED                              = $00000041; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED}
  PRODUCT_STARTER_E                             = $00000042;
  {$EXTERNALSYM PRODUCT_STARTER_E}
  PRODUCT_HOME_BASIC_E                          = $00000043;
  {$EXTERNALSYM PRODUCT_HOME_BASIC_E}
  PRODUCT_HOME_PREMIUM_E                        = $00000044;
  {$EXTERNALSYM PRODUCT_HOME_PREMIUM_E}
  PRODUCT_PROFESSIONAL_E                        = $00000045;
  {$EXTERNALSYM PRODUCT_PROFESSIONAL_E}
  PRODUCT_ENTERPRISE_E                          = $00000046;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_E}
  PRODUCT_ULTIMATE_E                            = $00000047;
  {$EXTERNALSYM PRODUCT_ULTIMATE_E}
  PRODUCT_ENTERPRISE_EVALUATION                 = $00000048;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_EVALUATION}
  PRODUCT_MULTIPOINT_STANDARD_SERVER            = $0000004C;
  {$EXTERNALSYM PRODUCT_MULTIPOINT_STANDARD_SERVER}
  PRODUCT_MULTIPOINT_PREMIUM_SERVER             = $0000004D;
  {$EXTERNALSYM PRODUCT_MULTIPOINT_PREMIUM_SERVER}
  PRODUCT_STANDARD_EVALUATION_SERVER            = $0000004F;
  {$EXTERNALSYM PRODUCT_STANDARD_EVALUATION_SERVER}
  PRODUCT_DATACENTER_EVALUATION_SERVER          = $00000050;
  {$EXTERNALSYM PRODUCT_DATACENTER_EVALUATION_SERVER}
  PRODUCT_ENTERPRISE_N_EVALUATION               = $00000054;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_N_EVALUATION}
  PRODUCT_EMBEDDED_AUTOMOTIVE                   = $00000055; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_AUTOMOTIVE}
  PRODUCT_EMBEDDED_INDUSTRY_A                   = $00000056; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_INDUSTRY_A}
  PRODUCT_THINPC                                = $00000057; // *
  {$EXTERNALSYM PRODUCT_THINPC}
  PRODUCT_EMBEDDED_A                            = $00000058; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_A}
  PRODUCT_EMBEDDED_INDUSTRY                     = $00000059; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_INDUSTRY}
  PRODUCT_EMBEDDED_E                            = $0000005A; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_E}
  PRODUCT_EMBEDDED_INDUSTRY_E                   = $0000005B; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_INDUSTRY_E}
  PRODUCT_EMBEDDED_INDUSTRY_A_E                 = $0000005C; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_INDUSTRY_A_E}
  PRODUCT_STORAGE_WORKGROUP_EVALUATION_SERVER   = $0000005F;
  {$EXTERNALSYM PRODUCT_STORAGE_WORKGROUP_EVALUATION_SERVER}
  PRODUCT_STORAGE_STANDARD_EVALUATION_SERVER    = $00000060;
  {$EXTERNALSYM PRODUCT_STORAGE_STANDARD_EVALUATION_SERVER}
  PRODUCT_CORE_ARM                              = $00000061;
  {$EXTERNALSYM PRODUCT_CORE_ARM}
  PRODUCT_CORE_N                                = $00000062;
  {$EXTERNALSYM PRODUCT_CORE_N}
  PRODUCT_CORE_COUNTRYSPECIFIC                  = $00000063;
  {$EXTERNALSYM PRODUCT_CORE_COUNTRYSPECIFIC}
  PRODUCT_CORE_SINGLELANGUAGE                   = $00000064;
  {$EXTERNALSYM PRODUCT_CORE_SINGLELANGUAGE}
  PRODUCT_CORE                                  = $00000065;
  {$EXTERNALSYM PRODUCT_CORE}
  PRODUCT_PROFESSIONAL_WMC                      = $00000067;
  {$EXTERNALSYM PRODUCT_PROFESSIONAL_WMC}
  PRODUCT_MOBILE_CORE                           = $00000068;
  {$EXTERNALSYM PRODUCT_MOBILE_CORE}
  PRODUCT_EMBEDDED_INDUSTRY_EVAL                = $00000069; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_INDUSTRY_EVAL}
  PRODUCT_EMBEDDED_INDUSTRY_E_EVAL              = $0000006A; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_INDUSTRY_E_EVAL}
  PRODUCT_EMBEDDED_EVAL                         = $0000006B; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_EVAL}
  PRODUCT_EMBEDDED_E_EVAL                       = $0000006C; // *
  {$EXTERNALSYM PRODUCT_EMBEDDED_E_EVAL}
  PRODUCT_NANO_SERVER                           = $0000006D; // *
  {$EXTERNALSYM PRODUCT_NANO_SERVER}
  PRODUCT_CLOUD_STORAGE_SERVER                  = $0000006E; // *
  {$EXTERNALSYM PRODUCT_CLOUD_STORAGE_SERVER}
  PRODUCT_CORE_CONNECTED                        = $0000006F; // *
  {$EXTERNALSYM PRODUCT_CORE_CONNECTED}
  PRODUCT_PROFESSIONAL_STUDENT                  = $00000070; // *
  {$EXTERNALSYM PRODUCT_PROFESSIONAL_STUDENT}
  PRODUCT_CORE_CONNECTED_N                      = $00000071; // *
  {$EXTERNALSYM PRODUCT_CORE_CONNECTED_N}
  PRODUCT_PROFESSIONAL_STUDENT_N                = $00000072; // *
  {$EXTERNALSYM PRODUCT_PROFESSIONAL_STUDENT_N}
  PRODUCT_CORE_CONNECTED_SINGLELANGUAGE         = $00000073; // *
  {$EXTERNALSYM PRODUCT_CORE_CONNECTED_SINGLELANGUAGE}
  PRODUCT_CORE_CONNECTED_COUNTRYSPECIFIC        = $00000074; // *
  {$EXTERNALSYM PRODUCT_CORE_CONNECTED_COUNTRYSPECIFIC}
  PRODUCT_CONNECTED_CAR                         = $00000075; // *
  {$EXTERNALSYM PRODUCT_CONNECTED_CAR}
  PRODUCT_INDUSTRY_HANDHELD                     = $00000076; // *
  {$EXTERNALSYM PRODUCT_INDUSTRY_HANDHELD}
  PRODUCT_PPI_PRO                               = $00000077; // *
  {$EXTERNALSYM PRODUCT_PPI_PRO}
  PRODUCT_ARM64_SERVER                          = $00000078; // *
  {$EXTERNALSYM PRODUCT_ARM64_SERVER}
  PRODUCT_EDUCATION                             = $00000079;
  {$EXTERNALSYM PRODUCT_EDUCATION}
  PRODUCT_EDUCATION_N                           = $0000007A;
  {$EXTERNALSYM PRODUCT_EDUCATION_N}
  PRODUCT_IOTUAP                                = $0000007B;
  {$EXTERNALSYM PRODUCT_IOTUAP}
  PRODUCT_CLOUD_HOST_INFRASTRUCTURE_SERVER      = $0000007C; // *
  {$EXTERNALSYM PRODUCT_CLOUD_HOST_INFRASTRUCTURE_SERVER}
  PRODUCT_ENTERPRISE_S                          = $0000007D;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_S}
  PRODUCT_ENTERPRISE_S_N                        = $0000007E;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_S_N}
  PRODUCT_PROFESSIONAL_S                        = $0000007F; // *
  {$EXTERNALSYM PRODUCT_PROFESSIONAL_S}
  PRODUCT_PROFESSIONAL_S_N                      = $00000080; // *
  {$EXTERNALSYM PRODUCT_PROFESSIONAL_S_N}
  PRODUCT_ENTERPRISE_S_EVALUATION               = $00000081;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_S_EVALUATION}
  PRODUCT_ENTERPRISE_S_N_EVALUATION             = $00000082;
  {$EXTERNALSYM PRODUCT_ENTERPRISE_S_N_EVALUATION}
  PRODUCT_IOTUAPCOMMERCIAL                      = $00000083;
  {$EXTERNALSYM PRODUCT_IOTUAPCOMMERCIAL}
  PRODUCT_MOBILE_ENTERPRISE                     = $00000085;
  {$EXTERNALSYM PRODUCT_MOBILE_ENTERPRISE}
  PRODUCT_HOLOGRAPHIC                           = $00000087; // *
  {$EXTERNALSYM PRODUCT_HOLOGRAPHIC}
  PRODUCT_HOLOGRAPHIC_BUSINESS                  = $00000088; // *
  {$EXTERNALSYM PRODUCT_HOLOGRAPHIC_BUSINESS}
  PRODUCT_PRO_SINGLE_LANGUAGE                   = $0000008A; // *
  {$EXTERNALSYM PRODUCT_PRO_SINGLE_LANGUAGE}
  PRODUCT_PRO_CHINA                             = $0000008B; // *
  {$EXTERNALSYM PRODUCT_PRO_CHINA}
  PRODUCT_ENTERPRISE_SUBSCRIPTION               = $0000008C; // *
  {$EXTERNALSYM PRODUCT_ENTERPRISE_SUBSCRIPTION}
  PRODUCT_ENTERPRISE_SUBSCRIPTION_N             = $0000008D; // *
  {$EXTERNALSYM PRODUCT_ENTERPRISE_SUBSCRIPTION_N}
  PRODUCT_DATACENTER_NANO_SERVER                = $0000008F;
  {$EXTERNALSYM PRODUCT_DATACENTER_NANO_SERVER}
  PRODUCT_STANDARD_NANO_SERVER                  = $00000090;
  {$EXTERNALSYM PRODUCT_STANDARD_NANO_SERVER}
  PRODUCT_DATACENTER_A_SERVER_CORE              = $00000091;
  {$EXTERNALSYM PRODUCT_DATACENTER_A_SERVER_CORE}
  PRODUCT_STANDARD_A_SERVER_CORE                = $00000092;
  {$EXTERNALSYM PRODUCT_STANDARD_A_SERVER_CORE}
  PRODUCT_DATACENTER_WS_SERVER_CORE             = $00000093;
  {$EXTERNALSYM PRODUCT_DATACENTER_WS_SERVER_CORE}
  PRODUCT_STANDARD_WS_SERVER_CORE               = $00000094;
  {$EXTERNALSYM PRODUCT_STANDARD_WS_SERVER_CORE}
  PRODUCT_UTILITY_VM                            = $00000095; // *
  {$EXTERNALSYM PRODUCT_UTILITY_VM}
  PRODUCT_DATACENTER_EVALUATION_SERVER_CORE     = $0000009F; // *
  {$EXTERNALSYM PRODUCT_DATACENTER_EVALUATION_SERVER_CORE}
  PRODUCT_STANDARD_EVALUATION_SERVER_CORE       = $000000A0; // *
  {$EXTERNALSYM PRODUCT_STANDARD_EVALUATION_SERVER_CORE}
  PRODUCT_PRO_WORKSTATION                       = $000000A1;
  {$EXTERNALSYM PRODUCT_PRO_WORKSTATION}
  PRODUCT_PRO_WORKSTATION_N                     = $000000A2;
  {$EXTERNALSYM PRODUCT_PRO_WORKSTATION_N}
  PRODUCT_PRO_FOR_EDUCATION                     = $000000A4;
  {$EXTERNALSYM PRODUCT_PRO_FOR_EDUCATION}
  PRODUCT_PRO_FOR_EDUCATION_N                   = $000000A5; // *
  {$EXTERNALSYM PRODUCT_PRO_FOR_EDUCATION_N}
  PRODUCT_AZURE_SERVER_CORE                     = $000000A8; // *
  {$EXTERNALSYM PRODUCT_AZURE_SERVER_CORE}
  PRODUCT_AZURE_NANO_SERVER                     = $000000A9; // *
  {$EXTERNALSYM PRODUCT_AZURE_NANO_SERVER}
  PRODUCT_ENTERPRISEG                           = $000000AB; // *
  {$EXTERNALSYM PRODUCT_ENTERPRISEG}
  PRODUCT_ENTERPRISEGN                          = $000000AC; // *
  {$EXTERNALSYM PRODUCT_ENTERPRISEGN}
  PRODUCT_SERVERRDSH                            = $000000AF;
  {$EXTERNALSYM PRODUCT_SERVERRDSH}
  PRODUCT_CLOUD                                 = $000000B2; // *
  {$EXTERNALSYM PRODUCT_CLOUD}
  PRODUCT_CLOUDN                                = $000000B3; // *
  {$EXTERNALSYM PRODUCT_CLOUDN}
  PRODUCT_HUBOS                                 = $000000B4; // *
  {$EXTERNALSYM PRODUCT_HUBOS}
  PRODUCT_ONECOREUPDATEOS                       = $000000B6; // *
  {$EXTERNALSYM PRODUCT_ONECOREUPDATEOS}
  PRODUCT_CLOUDE                                = $000000B7; // *
  {$EXTERNALSYM PRODUCT_CLOUDE}
  PRODUCT_IOTOS                                 = $000000B9; // *
  {$EXTERNALSYM PRODUCT_IOTOS}
  PRODUCT_CLOUDEN                               = $000000BA; // *
  {$EXTERNALSYM PRODUCT_CLOUDEN}
  PRODUCT_IOTEDGEOS                             = $000000BB; // *
  {$EXTERNALSYM PRODUCT_IOTEDGEOS}
  PRODUCT_IOTENTERPRISE                         = $000000BC;
  {$EXTERNALSYM PRODUCT_IOTENTERPRISE}
  PRODUCT_LITE                                  = $000000BD; // *
  {$EXTERNALSYM PRODUCT_LITE}
  PRODUCT_IOTENTERPRISE_S                       = $000000BF;
  {$EXTERNALSYM PRODUCT_IOTENTERPRISE_S}
  PRODUCT_XBOX_SYSTEMOS                         = $000000C0; // *
  {$EXTERNALSYM PRODUCT_XBOX_SYSTEMOS}
  PRODUCT_XBOX_GAMEOS                           = $000000C2; // *
  {$EXTERNALSYM PRODUCT_XBOX_GAMEOS}
  PRODUCT_XBOX_ERAOS                            = $000000C3; // *
  {$EXTERNALSYM PRODUCT_XBOX_ERAOS}
  PRODUCT_XBOX_DURANGOHOSTOS                    = $000000C4; // *
  {$EXTERNALSYM PRODUCT_XBOX_DURANGOHOSTOS}
  PRODUCT_XBOX_SCARLETTHOSTOS                   = $000000C5; // *
  {$EXTERNALSYM PRODUCT_XBOX_SCARLETTHOSTOS}
  PRODUCT_XBOX_KEYSTONE                         = $000000C6; // *
  {$EXTERNALSYM PRODUCT_XBOX_KEYSTONE}
  PRODUCT_AZURE_SERVER_CLOUDHOST                = $000000C7; // *
  {$EXTERNALSYM PRODUCT_AZURE_SERVER_CLOUDHOST}
  PRODUCT_AZURE_SERVER_CLOUDMOS                 = $000000C8; // *
  {$EXTERNALSYM PRODUCT_AZURE_SERVER_CLOUDMOS}
  PRODUCT_CLOUDEDITIONN                         = $000000CA; // *
  {$EXTERNALSYM PRODUCT_CLOUDEDITIONN}
  PRODUCT_CLOUDEDITION                          = $000000CB; // *
  {$EXTERNALSYM PRODUCT_CLOUDEDITION}
  PRODUCT_VALIDATION                            = $000000CC; // *
  {$EXTERNALSYM PRODUCT_VALIDATION}
  PRODUCT_IOTENTERPRISESK                       = $000000CD; // *
  {$EXTERNALSYM PRODUCT_IOTENTERPRISESK}
  PRODUCT_IOTENTERPRISEK                        = $000000CE; // *
  {$EXTERNALSYM PRODUCT_IOTENTERPRISEK}
  PRODUCT_IOTENTERPRISESEVAL                    = $000000CF; // *
  {$EXTERNALSYM PRODUCT_IOTENTERPRISESEVAL}
  PRODUCT_AZURE_SERVER_AGENTBRIDGE              = $000000D0; // *
  {$EXTERNALSYM PRODUCT_AZURE_SERVER_AGENTBRIDGE}
  PRODUCT_AZURE_SERVER_NANOHOST                 = $000000D1; // *
  {$EXTERNALSYM PRODUCT_AZURE_SERVER_NANOHOST}
  PRODUCT_WNC                                   = $000000D2; // *
  {$EXTERNALSYM PRODUCT_WNC}
  PRODUCT_AZURESTACKHCI_SERVER_CORE             = $00000196; // *
  {$EXTERNALSYM PRODUCT_AZURESTACKHCI_SERVER_CORE}
  PRODUCT_DATACENTER_SERVER_AZURE_EDITION       = $00000197;
  {$EXTERNALSYM PRODUCT_DATACENTER_SERVER_AZURE_EDITION}
  PRODUCT_DATACENTER_SERVER_CORE_AZURE_EDITION  = $00000198; // *
  {$EXTERNALSYM PRODUCT_DATACENTER_SERVER_CORE_AZURE_EDITION}
  PRODUCT_UNLICENSED                            = $ABCDABCD;
  {$EXTERNALSYM PRODUCT_UNLICENSED}

  // These constants are required for use with GetSystemMetrics to detect
  // certain editions. GetSystemMetrics returns non-zero when passed these flags
  // if the associated edition is present.
  // Obtained from https://msdn.microsoft.com/en-us/library/ms724385
  SM_TABLETPC       = 86;     // Detects XP Tablet Edition
  {$EXTERNALSYM SM_TABLETPC}
  SM_MEDIACENTER    = 87;     // Detects XP Media Center Edition
  {$EXTERNALSYM SM_MEDIACENTER}
  SM_STARTER        = 88;     // Detects XP Starter Edition
  {$EXTERNALSYM SM_STARTER}
  SM_SERVERR2       = 89;     // Detects Windows Server 2003 R2
  {$EXTERNALSYM SM_SERVERR2}
  SM_REMOTESESSION  = $1000;  // Detects a remote terminal server session
  {$EXTERNALSYM SM_REMOTESESSION}

  // These constants are required when examining the
  // TSystemInfo.wProcessorArchitecture member.
  // Only constants marked ** are defined in MS docs at 2022-12-31
  PROCESSOR_ARCHITECTURE_UNKNOWN    = $FFFF; // Unknown architecture *
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_UNKNOWN}
  PROCESSOR_ARCHITECTURE_INTEL          = 0; // x86 *
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_INTEL}
  PROCESSOR_ARCHITECTURE_MIPS           = 1; // MIPS architecture
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_MIPS}
  PROCESSOR_ARCHITECTURE_ALPHA          = 2; // Alpha architecture
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_ALPHA}
  PROCESSOR_ARCHITECTURE_PPC            = 3; // PPC architecture
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_PPC}
  PROCESSOR_ARCHITECTURE_SHX            = 4; // SHX architecture
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_SHX}
  PROCESSOR_ARCHITECTURE_ARM            = 5; // ARM architecture *
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_ARM}
  PROCESSOR_ARCHITECTURE_IA64           = 6; // Intel Itanium based *
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_IA64}
  PROCESSOR_ARCHITECTURE_ALPHA64        = 7; // Alpha64 architecture
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_ALPHA64}
  PROCESSOR_ARCHITECTURE_MSIL           = 8; // MSIL architecture
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_MSIL}
  PROCESSOR_ARCHITECTURE_AMD64          = 9; // x64 (AMD or Intel) *
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_AMD64}
  PROCESSOR_ARCHITECTURE_IA32_ON_WIN64 = 10; // IA32 on Win64 architecture
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_IA32_ON_WIN64}
  PROCESSOR_ARCHITECTURE_ARM64         = 12; // ARM64 architecture *
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_ARM64}

  // These constants are provided in case the obsolete
  // TSystemInfo.dwProcessorType needs to be used.
  // Constants marked Windows CE are only used on Windows mobile and are only
  // provided here for completeness.
  // Only constants marked * are defined in MS SDK 6.1
  PROCESSOR_INTEL_386     = 386;   // Intel i386 processor *
  {$EXTERNALSYM PROCESSOR_INTEL_386}
  PROCESSOR_INTEL_486     = 486;   // Intel i486 processor *
  {$EXTERNALSYM PROCESSOR_INTEL_486}
  PROCESSOR_INTEL_PENTIUM = 586;   // Intel Pentium processor *
  {$EXTERNALSYM PROCESSOR_INTEL_PENTIUM}
  PROCESSOR_INTEL_IA64    = 2200;  // Intel IA64 processor *
  {$EXTERNALSYM PROCESSOR_INTEL_IA64}
  PROCESSOR_AMD_X8664     = 8664;  // AMD X86 64 processor *
  {$EXTERNALSYM PROCESSOR_AMD_X8664}
  PROCESSOR_MIPS_R4000    = 4000;  // MIPS R4000, R4101, R3910 processor
  {$EXTERNALSYM PROCESSOR_MIPS_R4000}
  PROCESSOR_ALPHA_21064   = 21064; // Alpha 210 64 processor
  {$EXTERNALSYM PROCESSOR_ALPHA_21064}
  PROCESSOR_PPC_601       = 601;   // PPC 601 processor
  {$EXTERNALSYM PROCESSOR_PPC_601}
  PROCESSOR_PPC_603       = 603;   // PPC 603 processor
  {$EXTERNALSYM PROCESSOR_PPC_603}
  PROCESSOR_PPC_604       = 604;   // PPC 604 processor
  {$EXTERNALSYM PROCESSOR_PPC_604}
  PROCESSOR_PPC_620       = 620;   // PPC 620 processor
  {$EXTERNALSYM PROCESSOR_PPC_620}
  PROCESSOR_HITACHI_SH3   = 10003; // Hitachi SH3 processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_HITACHI_SH3}
  PROCESSOR_HITACHI_SH3E  = 10004; // Hitachi SH3E processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_HITACHI_SH3E}
  PROCESSOR_HITACHI_SH4   = 10005; // Hitachi SH4 processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_HITACHI_SH4}
  PROCESSOR_MOTOROLA_821  = 821;   // Motorola 821 processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_MOTOROLA_821}
  PROCESSOR_SHx_SH3       = 103;   // SHx SH3 processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_SHx_SH3}
  PROCESSOR_SHx_SH4       = 104;   // SHx SH4 processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_SHx_SH4}
  PROCESSOR_STRONGARM     = 2577;  // StrongARM processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_STRONGARM}
  PROCESSOR_ARM720        = 1824;  // ARM 720 processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_ARM720}
  PROCESSOR_ARM820        = 2080;  // ARM 820 processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_ARM820}
  PROCESSOR_ARM920        = 2336;  // ARM 920 processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_ARM920}
  PROCESSOR_ARM_7TDMI     = 70001; // ARM 7TDMI processor (Windows CE)
  {$EXTERNALSYM PROCESSOR_ARM_7TDMI}
  PROCESSOR_OPTIL         = $494F; // MSIL processor
  {$EXTERNALSYM PROCESSOR_OPTIL}

type
  ///  <summary>Enumeration of OS platforms.</summary>
  TPJOSPlatform = (
    ospWinNT,               // Windows NT platform
    ospWin9x,               // Windows 9x platform
    ospWin32s               // Win32s platform
  );

type
  ///  <summary>Enumeration identifying OS product.</summary>
  ///  <remarks>New values are always appended to the end of the enumeration so
  ///  as not to destroy any existing code that depends on the ordinal value of
  ///  the existing values.</remarks>
  TPJOSProduct = (
    osUnknownWinNT,         // Unknown Windows NT OS
    osWinNT,                // Windows NT (up to v4)
    osWin2K,                // Windows 2000
    osWinXP,                // Windows XP
    osUnknownWin9x,         // Unknown Windows 9x OS
    osWin95,                // Windows 95
    osWin98,                // Windows 98
    osWinMe,                // Windows Me
    osUnknownWin32s,        // Unknown OS running Win32s
    osWinSvr2003,           // Windows Server 2003
    osUnknown,              // Completely unknown Windows
    osWinVista,             // Windows Vista
    osWinSvr2003R2,         // Windows Server 2003 R2
    osWinSvr2008,           // Windows Server 2008
    osWinLater,             // A later version of Windows than v6.1
    osWin7,                 // Windows 7
    osWinSvr2008R2,         // Windows Server 2008 R2
    osWin8,                 // Windows 8
    osWinSvr2012,           // Windows Server 2012
    osWin8Point1,           // Windows 8.1
    osWinSvr2012R2,         // Windows Server 2012 R2
    osWin10,                // Windows 10
    osWin10Svr,             // Windows 2016 Server
    osWinSvr2019,           // Windows 2019 Server
    osWin11,                // Windows 11
    osWinSvr2022,           // Windows 2022 Server
    osWinServer,            // Windows Server (between Server 2019 & 2022)
    osWinSvr2025,           // Windows 2025 Server
    osWinSvrLater           // Later Windows Server
  );

type
  ///  <summary>Enumeration identifying processor architecture.</summary>
  TPJProcessorArchitecture = (
    paUnknown,              // Unknown architecture
    paX64,                  // X64 (AMD or Intel)
    paIA64,                 // Intel Itanium processor family (IPF)
    paX86                   // Intel 32 bit
  );

type
  ///  <summary>Enumeration identifying system boot modes.</summary>
  TPJBootMode = (
    bmUnknown,              // Unknown boot mode
    bmNormal,               // Normal boot
    bmSafeMode,             // Booted in safe mode
    bmSafeModeNetwork       // Booted in safe node with networking
  );

type
  ///  <summary>Enumeration identifying the possible reasons for a computer to
  ///  be powered on.</summary>
  ///  <remarks>For details of the values see the SMBIOS reference specification
  ///  v3.7.0 at https://tinyurl.com/4mhpy4xz, section 7.2.2.</remarks>
  TPJBiosWakeupType = (
    wutReserved,        // 0
    wutOther,           // 1
    wutUnknown,         // 2
    wutAPMTimer,        // 3
    wutModemRing,       // 4
    wutLANRemote,       // 5
    wutPowerSwitch,     // 6
    wutPCIPME,          // 7
    wutACPowerRestored  // 8
  );

type
  // Various Windows 10 & 11 release versions
  TPJWin10PlusVersion = (
    win10plusNA,
    win10plusUnknown,
    win10v1507, win10v1511, win10v1607, win10v1703, win10v1709, win10v1803,
    win10v1809, win10v1903, win10v1909, win10v2004, win10v20H2, win10v21H1,
    win10v21H2, win10v22H2,
    win11v21H2, win11v22H2, win11v23H2, win11v24H2
  );

type
  ///  <summary>Class of exception raised by code in this unit.</summary>
  EPJSysInfo = class(Exception);

type
  ///  <summary>Static class that provides operating system version information.
  ///  </summary>
  TPJOSInfo = class(TObject)
  private
    ///  <summary>Gets description of OS product edition from value returned
    ///  from GetProductInfo API.</summary>
    class function EditionFromProductInfo: string;

    ///  <summary>Checks if a given suite is installed on an NT system.
    ///  </summary>
    ///  <param name="Suite">Integer [in] One of the VER_SUITE_* flags.</param>
    ///  <returns>True if suite is installed, False if not installed or not an
    ///  NT platform OS.</returns>
    class function CheckSuite(const Suite: Integer): Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Gets product edition from registry for NT4 pre SP6.</remarks>
    class function NTEditionFromReg: string;

    ///  <summary>Gets edition ID from registry.</summary>
    class function EditionIDFromReg: string;

    ///  <summary>Checks registry to see if NT4 Service Pack 6a is installed.
    ///  </summary>
    class function IsNT4SP6a: Boolean;

    ///  <summary>Gets code describing product type from registry.</summary>
    ///  <remarks>Used to get product type for NT4 SP5 and earlier.</remarks>
    class function ProductTypeFromReg: string;

    ///  <summary>Checks if the underlying operating system either has the given
    ///  major and minor version number and service pack major version numbers
    ///  or is a later version.</summary>
    ///  <remarks>
    ///  <para>MajorVersion version must be greater than or equal to 5,
    ///  otherwise the method always returns False.</para>
    ///  <para>This method is immune to spoofing: it always returns information
    ///  about the actual operating system.</para>
    ///  </remarks>
    class function IsReallyWindowsVersionOrGreater(MajorVersion, MinorVersion,
      ServicePackMajor: Word): Boolean;

    ///  <summary>Checks if the operating system is Windows 10 or later, with a
    ///  version identifier the same or later than the given version identifier.
    ///  </summary>
    ///  <remarks>
    ///  <para>WARNING: Windows 11 versions are always considered to be later
    ///  Windows 10 versions, even if the Windows 10 version was released after
    ///  the Windows 11 version.</para>
    ///  <para><c>AVersion</c> must not be one of <c>win10plusNA</c> or
    ///  <c>win10plusUnknown</c>.</para>
    class function IsWindows10PlusVersionOrLater(
      const AVersion: TPJWin10PlusVersion): Boolean;

    ///  <summary>Returns the string containing the decoded digital product ID
    ///  of the host OS on Windows 8 and later only, or an empty string if
    ///  the digital product ID is not valid.</summary>
    ///  <remarks>The caller must check the OS version before calling this
    ///  method.</remarks>
    class function DecodedDigitalProductIDWin8AndUp: string;

    ///  <summary>Returns the string containing the decoded digital product ID
    ///  of the host OS on Windows 7 and earlier only, or an empty string if
    ///  the digital product ID is not valid.</summary>
    ///  <remarks>The caller must check the OS version before calling this
    ///  method.</remarks>
    class function DecodedDigitalProductIDWin7AndDown: string;

  public

    ///  <summary>Checks if the OS can be "spoofed" by specifying a
    ///  compatibility mode for the program.</summary>
    ///  <remarks>When this method returns True public methods of TPJOSInfo
    ///  will return the details of OS emulated by the compatibility mode OS
    ///  instead of the actual OS, unless the method is documented to the
    ///  contrary. When False is returned the reported OS is the real underlying
    ///  OS and any compatibility mode is ignored.</remarks>
    class function CanSpoof: Boolean;

    ///  <summary>Checks if the OS is on the Windows 9x platform.</summary>
    class function IsWin9x: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks if the OS is on the Windows NT platform.</summary>
    class function IsWinNT: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks if the program is hosted on Win32s.</summary>
    ///  <remarks>This is unlikely to ever return True since Delphi does not run
    ///  on Win32s.</remarks>
    class function IsWin32s: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks if a 32 bit program is running under WOW64 on a 64 bit
    ///  operating system.</summary>
    class function IsWow64: Boolean;

    ///  <summary>Checks if the program is running on a server operating system.
    ///  </summary>
    ///  <remarks>Use IsWindowsServer in preference.</remarks>
    class function IsServer: Boolean;

    ///  <summary>Checks if Windows Media Center is installed.</summary>
    class function IsMediaCenter: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks if the program is running on a tablet PC OS.</summary>
    class function IsTabletPC: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks if the program is running under Windows Terminal Server
    ///  as a client session.</summary>
    class function IsRemoteSession: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks of the host operating system has pen extensions
    ///  installed.</summary>
    class function HasPenExtensions: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Returns the host OS platform identifier.</summary>
    class function Platform: TPJOSPlatform;

    ///  <summary>Returns the host OS product identifier.</summary>
    class function Product: TPJOSProduct;

    ///  <summary>Returns the product name of the host OS.</summary>
    class function ProductName: string;

    ///  <summary>Returns the major version number of the host OS.</summary>
    class function MajorVersion: Integer;

    ///  <summary>Returns the minor version number of the host OS.</summary>
    class function MinorVersion: Integer;

    ///  <summary>Returns the host OS's build number.</summary>
    ///  <remarks>A return value of 0 indicates that the build number can't be
    ///  found.</remarks>
    class function BuildNumber: Integer;

    ///  <summary>Returns the name of any installed OS service pack.</summary>
    class function ServicePack: string;

    ///  <summary>Returns the name of any installed OS service pack along with
    ///  other similar, detectable, updates.</summary>
    ///  <remarks>
    ///  <para>Windows has added significant OS updates that bump the build
    ///  number but do not declare themselves as service packs: e.g. the Windows
    ///  10 TH2 update, aka Version 1511.</para>
    ///  <para>This method is used to report such updates in addition to
    ///  updates that declare themselves as service packs, while the ServicePack
    ///  method only reports declared 'official' service packs.</para>
    ///  </remarks>
    class function ServicePackEx: string;

    ///  <summary>Returns the major version number of any NT platform service
    ///  pack.</summary>
    ///  <remarks>0 is returned in no service pack is installed, if the host OS
    ///  is not on the NT platform.</remarks>
    class function ServicePackMajor: Integer;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Returns the minor version number of any NT platform service
    ///  pack.</summary>
    ///  <remarks>Invalid if ServicePackMajor returns 0.</remarks>
    class function ServicePackMinor: Integer;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Returns the product edition for an NT platform OS.</summary>
    ///  <remarks>The empty string is returned if the OS is not on the NT
    ///  platform.</remarks>
    class function Edition: string;

    ///  <summary>Returns a full description of the host OS.</summary>
    class function Description: string;

    ///  <summary>Returns the Windows product ID of the host OS.</summary>
    class function ProductID: string;

    ///  <summary>Returns the digital product ID of the host OS.</summary>
    class function DigitalProductID: TBytes;

    ///  <summary>Returns the string containing the decoded digital product ID
    ///  of the host OS, or an empty string if the digital product ID contains
    ///  insufficient data.</summary>
    class function DecodedDigitalProductID: string;

    ///  <summary>Organisation to which Windows is registered, if any.</summary>
    class function RegisteredOrganisation: string;

    ///  <summary>Owner to which Windows is registered.</summary>
    class function RegisteredOwner: string;

    ///  <summary>Date the operating system was installed.</summary>
    ///  <remarks>If this information is not available then <c>0.0</c> is
    ///  returned (i.e. 1899/12/30).</remarks>
    class function InstallationDate: TDateTime;

    ///  <summary>Checks whether the OS is Windows 2000 or greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force.</remarks>
    class function IsReallyWindows2000OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 2000 Service Pack 1 or
    ///  greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force.</remarks>
    class function IsReallyWindows2000SP1OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 2000 Service Pack 2 or
    ///  greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force.</remarks>
    class function IsReallyWindows2000SP2OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 2000 Service Pack 3 or
    ///  greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force.</remarks>
    class function IsReallyWindows2000SP3OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 2000 Service Pack 4 or
    ///  greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force.</remarks>
    class function IsReallyWindows2000SP4OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows XP or greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindowsXPOrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows XP Service Pack 1 or greater.
    ///  </summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindowsXPSP1OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows XP Service Pack 2 or greater.
    ///  </summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindowsXPSP2OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows XP Service Pack 3 or greater.
    ///  </summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindowsXPSP3OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows Vista or greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindowsVistaOrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows Vista Service Pack 1 or
    ///  greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindowsVistaSP1OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows Vista Service Pack 2 or
    ///  greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindowsVistaSP2OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 7 or greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindows7OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 7 Service Pack 1 or greater.
    ///  </summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindows7SP1OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 8 or greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindows8OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 8.1 or greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force or whether a suitable
    ///  manifest file is present.</remarks>
    class function IsReallyWindows8Point1OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks whether the OS is Windows 10 or greater.</summary>
    ///  <remarks>This method always returns information about the true OS,
    ///  regardless of any compatibility mode in force, but DOES require that
    ///  the correct manifest file is present.</remarks>
    class function IsReallyWindows10OrGreater: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Returns an identifier representing a Windows 10 or 11
    ///  version.</summary>
    ///  <remarks>If the OS is earlier than Windows 10 then <c>win10plusNA</c>
    ///  is returned. If the OS is Windows 10 or later but is a dev, beta etc.
    ///  build whose version can't be detected then <c>win10plusUnknown</c> is
    ///  returned.</remarks>
    class function Windows10PlusVersion: TPJWin10PlusVersion;

    ///  <summary>Returns the version name of a the current operating system, if
    ///  it is Windows 10 or later.</summary>
    ///  <remarks>
    ///  <para>NOTE: some Windows 10 and 11 versions have the same string.
    ///  </para>
    ///  <para>If the OS is earlier than Windows 10 then an empty string is
    ///  returned. If the OS is Windows 10 or later but is a dev, beta etc.
    ///  build whose version can't be detected then 'Unknown' is returned.
    ///  </para>
    ///  </remarks>
    class function Windows10PlusVersionName: string;

    ///  <summary>Checks if the operating system is Windows 10 or later, with a
    ///  version identifier the same or later than <c>AVersion</c>.
    ///  </summary>
    ///  <remarks><c>AVersion</c> must be a valid Windows 10 version
    ///  identifier, with a name that begins with <c>win10v</c>.</remarks>
    ///  <exception><c>EPJSysInfo</c> raised if <c>AVersion</c> is not a valid
    ///  Windows 10 version identifier.</exception>
    class function IsWindows10VersionOrLater(
      const AVersion: TPJWin10PlusVersion): Boolean;

    ///  <summary>Checks if the operating system is Windows 11 or later, with a
    ///  version identifier the same or later than <c>AVersion</c>.
    ///  </summary>
    ///  <remarks><c>AVersion</c> must be a valid Windows 11 version
    ///  identifier, with a name that begins with <c>win11v</c>.</remarks>
    ///  <exception><c>EPJSysInfo</c> raised if <c>AVersion</c> is not a valid
    ///  Windows 11 version identifier.</exception>
    class function IsWindows11VersionOrLater(
      const AVersion: TPJWin10PlusVersion): Boolean;

    ///  <summary>Checks if the OS is a server version.</summary>
    ///  <remarks>
    ///  <para>For Windows 2000 and later the result always relates to the
    ///  actual OS, regardless of any compatibility mode in force. For versions
    ///  prior to Windows 2000 this method will take note of compatibility modes
    ///  and returns the same value as TPJOSInfo.IsServer.</para>
    ///  <para>WARNING: For Windows 10 this method is likely to succeed only if
    ///  the application is correctly manifested.</para>
    class function IsWindowsServer: Boolean;

    ///  <summary>Returns any revision number for the OS.</summary>
    ///  <remarks>
    ///  <para>If the OS does not provide any revision information then zero is
    ///  returned.</para>
    ///  <para>This value is read fromt he registry therefore it is possible
    ///  that this value could be spoofed.</para>
    ///  </remarks>
    class function RevisionNumber: Integer;

    ///  <summary>Returns the repository branch from which the OS release was]
    ///  built.</summary>
    ///  <remarks>Returns the empty string if no build branch information is
    ///  available.</remarks>
    class function BuildBranch: string;
  end;

type
  ///  <summary>Static class that provides information about the host computer.
  ///  </summary>
  TPJComputerInfo = class(TObject)
  public
    ///  <summary>Returns name of host computer.</summary>
    class function ComputerName: string;

    ///  <summary>Returns name of currently logged on user.</summary>
    class function UserName: string;

    ///  <summary>Returns MAC address of 1st Ethernet adapter on host computer.
    ///  or empty string if no such adapter is found.
    ///  </summary>
    ///  <remarks>**WARNING** may be unreliable - see comments in
    ///  implementation. </remarks>
    class function MACAddress: string;

    ///  <summary>Returns processor architecture of host computer.</summary>
    class function Processor: TPJProcessorArchitecture;

    ///  <summary>Returns number of processors (or cores) in the host computer.
    ///  </summary>
    class function ProcessorCount: Cardinal;

    ///  <summary>Returns the identifier of the computer's processor.</summary>
    ///  <remarks>On multi-processor systems this is the identifier of the 1st
    ///  processor.</remarks>
    class function ProcessorIdentifier: string;

    ///  <summary>Returns the name of the computer's processor.</summary>
    ///  <remarks>On multi-processor systems this is the name of the 1st
    ///  processor.</remarks>
    class function ProcessorName: string;

    ///  <summary>Returns the speed of the computer's processor in MHz.
    ///  </summary>
    ///  <remarks>
    ///  <para>On multi-processor systems this is the speed of the 1st
    ///  processor.</para>
    ///  <para>0 is returned if the information is not a available.</para>
    ///  </remarks>
    class function ProcessorSpeedMHz: Cardinal;

    ///  <summary>Checks if the host computer has a 64 bit processor.</summary>
    class function Is64Bit: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Checks if a network is present on host computer.</summary>
    class function IsNetworkPresent: Boolean;
      {$IFDEF INLINEMETHODS}inline;{$ENDIF}

    ///  <summary>Returns the OS mode used when host computer was last booted.
    ///  </summary>
    class function BootMode: TPJBootMode;

    ///  <summary>Checks if the current user has administrator privileges.
    ///  </summary>
    ///  <remarks>
    ///  <para>Always returns True on the Windows 9x platform.</para>
    ///  <para>WARNING: True is also returned when running in Windows 9x
    ///  compatibility mode on a Windows NT platform system, regardless of
    ///  whether the user has admin privileges or not.</para>
    ///  <para>Based on a former Embarcadero article.</para>
    ///  </remarks>
    class function IsAdmin: Boolean;

    ///  <summary>Checks if UAC is active on the computer.</summary>
    ///  <remarks>
    ///  <para>UAC requires Windows Vista or later. Returns False on earlier
    ///  operating systems.</para>
    ///  <para>WARNING: False is also returned when running in Windows XP or
    ///  earlier compatibility mode on Windows Vista or later, regardless of
    ///  whether UAC is enabled or not.</para>
    ///  <para>Based on code on Stack Overflow, answer by norgepaul, at
    ///  https://tinyurl.com/avlztmg</para>
    ///  </remarks>
    class function IsUACActive: Boolean;

    ///  <summary>Returns the name of the computer's BIOS vendor.</summary>
    class function BiosVendor: string;

    ///  <summary>Returns the name of the computer's manufacturer.</summary>
    class function SystemManufacturer: string;

    ///  <summary>Returns the computer's product or model name.</summary>
    class function SystemProductName: string;

  end;

type
  ///  <summary>Structure of SMBIOS data.</summary>
  ///  <remarks>The <c>Data</c> field is a placeholder for the variable length
  ///  BIOS data.</remarks>
  TPJSMBiosData = packed record
    Used20CallingMethod: Byte;
    MajorVersion: Byte;
    MinorVersion: Byte;
    Revision: Byte;
    Length: DWORD;
    Data: array[0..0] of Byte;
  end;
  ///  <summary>Pointer to a <c>TPJSMBiosData</c> structure of SMBIOS data
  ///  </summary>
  PPJSMBiosData = ^TPJSMBiosData;

type
  ///  <summary>Class that returns information extracted from the computer BIOS.
  ///  </summary>
  ///  <remarks>
  ///  <para>Portions of the code of this class are based on code by Strive Sun
  ///  of their answer to the question on Stack Overflow:
  ///  https://tinyurl.com/cvbx792t.</para>
  ///  <para>NOTE 1: Requires a BIOS that conforms the the SMBIOS reference
  ///  specification v2.0 or later (see https://tinyurl.com/4mhpy4xz). Some
  ///  features require compliance with later versions of the specification.
  ///  Many methods of this class also require that the BIOS supports the SMBIOS
  ///  System Information structure (type 1).</para>
  ///  <para>NOTE 2: Requires operating system support for the Windows kernel
  ///  <c>GetSystemFirmwareTable</c> API function.</para>
  ///  </remarks>
  TPJBiosInfo = class(TObject)
  private
    ///  <summary>Pointer to memory storing the SMBIOS data or <c>nil</c> if the
    ///  data cannot be read.</summary>
    fData: PPJSMBiosData;
    ///  <summary>Size of the memory block pointed to by <c>fData</c> or 0 if
    ///  the data cannot be read.</summary>
    fDataSize: Cardinal;
    ///  <summary>Loads the SMBIOS data.</summary>
    ///  <returns><c>Boolean</c>. <c>True</c> if the data was loaded
    ///  successfully or <c>False</c> on error.</returns>
    function LoadData: Boolean;
    ///  <summary>Frees the memory used to store the SMBIOS data.</summary>
    procedure FreeData;
    ///  <summary>Returns a pointer to a given SMBIOS structure in the SMBIOS
    ///  data table.</summary>
    ///  <param name="StructType"><c>Byte</c>. Type number of the required
    ///  SMBIOS structure.</param>
    function FindStruct(const StructType: Byte): PByte;
    ///  <summary>Returns a specified string from a given SMBIOS structure.
    ///  </summary>
    ///  <param name="StructType"><c>Byte</c>. Type number of the SMBIOS
    ///  structure containing the string.</param>
    ///  <param name="Offset"><c>Byte</c> [in] Offset in the required structure
    ///  of the byte that identifies the correct string.</param>
    ///  <param name="MinVer"><c>Word</c> [in] Minimum version of the SMBIOS
    ///  specification that supports the required string.</param>
    ///  <returns><c>string</c>. The required string or an empty string if an
    ///  error occurred or if the required SMBIOS specification version is not
    ///  supported.</returns>
    function GetString(const StructType, Offset: Byte; const MinVer: Word):
      string;
  public
    ///  <summary>Object constructor. Reads BIOS information into memory.
    ///  </summary>
    constructor Create;

    ///  <summary>Object destructor. Tidies up memory allocations.</summary>
    destructor Destroy; override;

    ///  <summary>Checks whether the BIOS is supported or not.</summary>
    ///  <returns><c>Boolean</c>. <c>True</c> if the BIOS is supported,
    ///  <c>False</c> if not.</returns>
    ///  <remarks>If this method returns <c>False</c> then no BIOS information
    ///  is returned and all methods return suitable null values.</remarks>
    function IsBiosSupported: Boolean;

    ///  <summary>Returns the version of the SMBIOS specification supported by
    ///  the BIOS.</summary>
    ///  <returns><c>Word</c>. The version number is encoded into a <c>Word</c>
    ///  value. The high byte contains the major version number and the low byte
    ///  contains the minor version number. Returns <c>0</c> if the BIOS is not
    ///  supported.</returns>
    function SMBiosSpecVersion: Word;

    ///  <summary>Returns the name of the BIOS vendor.</summary>
    ///  <returns><c>string</c>. Name of the BIOS vendor or an empty string on
    ///  failure or if no name is provided.</returns>
    ///  <remarks>
    ///  <para>The returned value may be the same as that returned by
    ///  <c>TPJComputerInfo.BiosVendor</c>.</para>
    ///  <para>Requires support for SMBIOS v2.0 or later.</para>
    ///  </remarks>
    function BiosVendor: string;

    ///  <summary>Returns the BIOS release version number.</summary>
    ///  <returns><c>Word</c>. The version number encoded into a <c>Word</c>
    ///  value. The high byte contains the major version number and the low byte
    ///  contains the minor version number. <c>0</c> is returned on failure or
    ///  if no value is provided by the BIOS.</returns>
    ///  <remarks>Requires support for SMBIOS v2.4 or later.</remarks>
    function BiosVersion: Word;

    ///  <summary>Returns a string representation of the BIOS version.</summary>
    ///  <returns><c>string</c>. Version string or an empty string on failure or
    ///  if no version string is provided by the BIOS.</returns>
    ///  <remarks>
    ///  <para>The version number returned in this string may not necessarily
    ///  align with that returned by <c>BiosVersion</c>.</para>
    ///  <para>Requires support for SMBIOS v2.0 or later.</para>
    ///  </remarks>
    function BiosVersionStr: string;

    ///  <summary>Returns the release version number of the BIOS' Embedded
    ///  Controller Firmware.</summary>
    ///  <returns><c>Word</c>. The version number encoded into a <c>Word</c>
    ///  value. The high byte contains the major version number and the low byte
    ///  contains the minor version number. <c>$FFFF</c> is returned if the
    ///  system does not have field upgradeable embedded controller firmware.
    ///  <c>0</c> is returned on failure or if no version number is provided by
    ///  the BIOS.</returns>
    ///  <remarks>Requires support for SMBIOS v2.4 or later.</remarks>
    function BiosECFirmwareVersion: Word;

    ///  <summary>Returns the BIOS release date.</summary>
    ///  <returns><c>TDate</c>. The required date or <c>0.0</c> on failure or if
    ///  no release date is provided by the BIOS.</returns>
    ///  <remarks>
    ///  <para>Use this method to get the release date in a format suitable for
    ///  formatting correctly for a specific locale.</para>
    ///  <para>If the date string is required in exactly the same format as used
    ///  in the BIOS use the <c>BiosReleaseDateInvariant</c> method instead.
    ///  </para>
    ///  <para>Requires support for SMBIOS v2.0 or later.</para>
    ///  </remarks>
    function BiosReleaseDate: TDate;

    ///  <summary>Returns a string representation of the BIOS release date in
    ///  USA format, regardless of the locale.</summary>
    ///  <returns><c>string</c>. A date string in mm/dd/yyyy or mm/dd/yy format
    ///  or an empty string on failure or if no release date is provided by the
    ///  BIOS.</returns>
    ///  <remarks>
    ///  <para>This method returns the date string exactly as stored in the
    ///  BIOS. To get the date in binary format suitable for formatting
    ///  correctly for any locale, use the <c>BiosReleaseDate</c> method
    ///  instead.</para>
    ///  <para>If the returned date is in mm/dd/yy format the year is assumed to
    ///  be 19yy. mm/dd/yyyy format is required for SMBIOS v2.3 or later.</para>
    ///  <para>Requires support for SMBIOS v2.0 or later.</para>
    ///  </remarks>
    function BiosReleaseDateInvariant: string;

    ///  <summary>Returns the BIOS' UUID as an array of bytes.</summary>
    ///  <returns><c>TBytes</c>. A sixteen byte array on success or an empty
    ///  array on failure.</returns>
    ///  <remarks>
    ///  <para>If all 16 bytes of the returned array are <c>0</c> then the BIOS
    ///  has no UUID.</para>
    ///  <para>If all 16 bytes of the returned array are <c>$FF</c> then the
    ///  BIOS does not currently have a UUID but one could be set in future.
    ///  </para>
    ///  <para>Requires support for SMBIOS v2.1 or later.</para>
    ///  </remarks>
    function SystemUuidRaw: TBytes;

    ///  <summary>Returns the BIOS' ID encoded in the format required by the
    ///  SMBIOS specification.</summary>
    ///  <returns><c>TGUID</c>. The required UUID on success or a <c>TGUID</c>
    ///  with all elements set to zero on failure.</returns>
    ///  <remarks>
    ///  <para>If all bytes of the returned <c>TGUID</c> are <c>0</c> then
    ///  either the method call failed or the call succeeded but the BIOS has no
    ///  UUID.</para>
    ///  <para>If all bytes of the returned <c>TGUID</c> are <c>$FF</c> then the
    ///  BIOS does not currently have a UUID but one could be set in future.
    ///  </para>
    ///  <para>Requires support for SMBIOS v2.1 or later.</para>
    ///  </remarks>
    function SystemUuid: TGUID;

    ///  <summary>Returns the BIOS' ID as a string formatted according to the
    ///  one of the two formats required by the SMBIOS specification.</summary>
    ///  <param name="UseRFC4122ByteOrdering"><c>Boolean</c>. When <c>True</c>
    ///  the returned string is formatted according to RFC4122, with all bytes
    ///  in network order. When <c>False</c> (the default) the string is
    ///  formatted according PC industry practice, with the 1st three fields of
    ///  the UUID formatted in little endian byte encoding and the remaining
    ///  fields formatted in network byte order.</param>
    ///  <returns><c>string</c>. The formatted string on success or an empty
    ///  string on failure.</returns>
    ///  <remarks>Requires support for SMBIOS v2.1 or later.</remarks>
    function SystemUuidStr(const UseRFC4122ByteOrdering: Boolean = False):
      string;

    ///  <summary>Returns the name of the computer's manufacturer.</summary>
    ///  <returns><c>string</c>. Name of the manufacturer or an empty string on
    ///  failure or if no name is provided by the BIOS.</returns>
    ///  <remarks>
    ///  <para>The returned value may be the same as that returned by
    ///  <c>TPJComputerInfo.SystemManufacturer</c>.</para>
    ///  <para>Requires support for SMBIOS v2.0 or later.</para>
    ///  </remarks>
    function SystemManufacturer: string;

    ///  <summary>Returns the computer's product name.</summary>
    ///  <returns><c>string</c>. Product name or an empty string on failure or
    ///  if no name is provided by the BIOS.</returns>
    ///  <remarks>
    ///  <para>The returned value may be the same as that returned by
    ///  <c>TPJComputerInfo.SystemProductName</c>.</para>
    ///  <para>Requires support for SMBIOS v2.0 or later.</para>
    ///  </remarks>
    function SystemProductName: string;

    ///  <summary>Returns an OEM specific version number.</summary>
    ///  <returns><c>string</c>. An OEM specific version string or an empty
    ///  string on failure or if no version string is provided by the BIOS.
    ///  </returns>
    ///  <remarks>
    ///  <para>This value does not relate to the BIOS version or the SMBIOS
    ///  specification version.</para>
    ///  <para>Requires support for SMBIOS v2.0 or later.</para>
    ///  </remarks>
    function SystemOEMVersion: string;

    ///  <summary>Returns the computer's serial number.</summary>
    ///  <returns><c>string</c>. The serial number or an empty string on
    ///  failure or if no serial number is provided by the BIOS.</returns>
    ///  <remarks>Requires support for SMBIOS v2.0 or later.</remarks>
    function SystemSerialNumber: string;

    ///  <summary>Returns the computer's SKU number, aka product ID.</summary>
    ///  <returns><c>string</c>. The SKU number or an empty string on failure or
    ///  if no SKU number is provided by the BIOS.</returns>
    ///  <remarks>Requires support for SMBIOS v2.4 or later.</remarks>
    function SystemSKUNumber: string;

    ///  <summary>Returns the name of the computer's product family.</summary>
    ///  <returns><c>string</c>. The product family or an empty string on
    ///  failure or if no value is provided by the BIOS.</returns>
    ///  <remarks>Requires support for SMBIOS v2.4 or later.</remarks>
    function SystemFamily: string;

    ///  <summary>Identifies the event that caused the computer to power up.
    ///  </summary>
    ///  <returns><c>TPJBiosWakeupType</c>. Value that describes the type of
    ///  of wake-up event. <c>wutUnknown</c> is returned on failure.</returns>
    ///  <remarks>Requires support for SMBIOS v2.1 or later.</remarks>
    function SystemWakeupType: TPJBiosWakeupType;
  end;


type
  ///  <summary>Static class that provides the paths of the system's standard
  ///  folders.</summary>
  TPJSystemFolders = class(TObject)
  public
    ///  <summary>Returns the fully qualified name of the Common Files folder.
    ///  </summary>
    class function CommonFiles: string;

    ///  <summary>Returns the fully qualified name of the Common Files x86
    ///  folder.</summary>
    ///  <remarks>
    ///  <para>Returns the empty string on 32 bit Windows since there is no
    ///  such folder.</para>
    ///  <para>This folder is used common files for 32 bit programs on 64 bit
    ///  Windows systems.</para>
    ///  </remarks>
    class function CommonFilesX86: string;

    ///  <summary>Returns the fully qualified name of the Common Files folder
    ///  according to whether the host program and operating system are 32 or 64
    ///  bit.</summary>
    ///  <remarks>For a 32 bit program on 32 bit Windows or 64 bit program on
    ///  64 bit windows the return value is the same as CommonFiles. For a 32
    ///  bit program running on 64 bit Windows the return value is the same as
    ///  CommonFilesX86.</remarks>
    class function CommonFilesRedirect: string;

    ///  <summary>Returns the fully qualified name of the Program Files folder.
    ///  </summary>
    class function ProgramFiles: string;

    ///  <summary>Returns the fully qualified name of the Program Files x86
    ///  folder, if present.</summary>
    ///  <remarks>
    ///  <para>Returns the empty string on 32 bit Windows since there is no
    ///  such folder.</para>
    ///  <para>This folder is used to install 32 bit programs on 64 bit
    ///  Windows systems.</para>
    ///  </remarks>
    class function ProgramFilesX86: string;

    ///  <summary>Returns the fully qualified name of the Program Files folder
    ///  according to whether the host program and operating system are 32 or 64
    ///  bit.</summary>
    ///  <remarks>For a 32 bit program on 32 bit Windows or 64 bit program on
    ///  64 bit windows the return value is the same as ProgramFiles. For a 32
    ///  bit program running on 64 bit Windows the return value is the same as
    ///  ProgramFilesX86.</remarks>
    class function ProgramFilesRedirect: string;

    ///  <summary>Returns the fully qualified name of the Windows folder.
    ///  </summary>
    class function Windows: string;

    ///  <summary>Returns the fully qualified name of the Windows System folder.
    ///  </summary>
    class function System: string;

    ///  <summary>Returns the fully qualified name of the folder used to store
    ///  shared 32 bit code on 64 bit Windows.</summary>
    class function SystemWow64: string;

    ///  <summary>Returns the fully qualified name of the system's temporary
    ///  folder.</summary>
    class function Temp: string;
  end;

var
  // Global variables providing extended information about the OS version

  // The following five variables are analogues of the similarly named variables
  // (without the "Ex" appendix) from SysUtils. If the OS is spoofed and
  // TOSInfo.CanSpoof = False then these variable will reflect the values from
  // the true OS, whereas their SysUtils equivalents will have the spoof values.
  // When TOSInfo.CanSpoof = True then both sets of variables will have the
  // same value.

  // OS platform: one of VER_PLATFORM_WIN32_NT, VER_PLATFORM_WIN32_WINDOWS or
  // (very unlikely) VER_PLATFORM_WIN32s.
  Win32PlatformEx: Integer = 0;
  // Major version number of OS.
  Win32MajorVersionEx: LongWord = 0;
  // Minor version number of OS.
  Win32MinorVersionEx: LongWord = 0;
  // OS Build number.
  Win32BuildNumberEx: Integer = 0;
  // Description of any OS service pack.
  Win32CSDVersionEx: string = '';

  // OS Revision number. Zero if revision number not available.
  Win32RevisionNumber: Integer = 0;
  // Flag that indicates if extended version information is available.
  Win32HaveExInfo: Boolean = False;
  // Major version number of the latest Service Pack installed on the system. If
  // no service pack has been installed the value is 0. Invalid if
  // Win32HaveExInfo is False.
  Win32ServicePackMajor: Word = 0;
  // Minor version number of the latest Service Pack installed on the system.
  // Invalid if Win32HaveExInfo is False.
  Win32ServicePackMinor: Word = 0;
  // Bit flags that identify the product suites available on the system. Value
  // is a combination of the VER_SUITE_* flags defined above. Invalid if
  // Win32HaveExInfo is False.
  Win32SuiteMask: Integer = 0;
  // Additional information about the system. Value is one of the VER_NT_* flags
  // defined above. Invalid if Win32HaveExInfo is False.
  Win32ProductType: Integer = 0;

  // Flag that indicates if product information is available on the OS, i.e. if
  // the GetProductInfo API function is available.
  Win32HaveProductInfo: Boolean = False;
  // Product info for the operating system. Set to 0 if Win32HaveProductInfo
  // is False.
  Win32ProductInfo: LongWord = 0;


implementation


uses
  // Delphi
  {$IFNDEF RTLNAMESPACES}
  Registry, Nb30;
  {$ELSE}
  System.Win.Registry, Winapi.Nb30;
  {$ENDIF}


resourcestring
  // Error messages
  sUnknownPlatform = 'Unrecognised operating system platform';
  sUnknownProduct = 'Unrecognised operating system product';
  sBadRegType =  'Unsupported registry type';
  sBadRegIntType = 'Integer value expected in registry';
  sBadRegBinType = 'Binary value expected in registry';
  sBadProcHandle = 'Bad process handle';


{$IFNDEF HASUINT64}
// Defined a fake UInt64 of correct size for used with compilers that don't
// define the type.
type
  UInt64 = Int64;
{$ENDIF}

const
  // Map of product codes per GetProductInfo API to product names
  // Names are not available for all PRODUCT_xxx values.
  // ** Laurent Pierre supplied original code on which this map is based
  //    It has been modified and extended using MSDN documentation at
  //    https://msdn.microsoft.com/en-us/library/ms724358 and
  //    https://tinyurl.com/5684558v (learn.microsoft.com)
  cProductMap: array[1..107] of record
    Id: Cardinal; // product ID
    Name: string; // product name
  end = (
    (Id: PRODUCT_BUSINESS;
      Name: 'Business';),
    (Id: PRODUCT_BUSINESS_N;
      Name: 'Business N';),
    (Id: PRODUCT_CLUSTER_SERVER;
      Name: 'Cluster Server / HPC';),
    (Id: PRODUCT_CLUSTER_SERVER_V;
      Name: 'Server Hyper Core V';),
    (Id: PRODUCT_CORE;
      Name: 'Home (Core)';),
    (Id: PRODUCT_CORE_COUNTRYSPECIFIC;
      Name: 'Home (Core) China';),
    (Id: PRODUCT_CORE_N;
      Name: 'Home (Core) N';),
    (Id: PRODUCT_CORE_SINGLELANGUAGE;
      Name: 'Home (Core) Single Language';),
    (Id: PRODUCT_DATACENTER_EVALUATION_SERVER;
      Name: 'Server Datacenter (evaluation installation)';),
    (Id: PRODUCT_DATACENTER_A_SERVER_CORE;
      Name: 'Server Datacenter, Semi-Annual Channel (core installation)';),
    (Id: PRODUCT_STANDARD_A_SERVER_CORE;
      Name: 'Server Standard, Semi-Annual Channel (core installation)';),
    (Id: PRODUCT_DATACENTER_SERVER;
      Name: 'Server Datacenter (full installation)';),
    (Id: PRODUCT_DATACENTER_SERVER_CORE;
      Name: 'Server Datacenter (core installation)';),
    (Id: PRODUCT_DATACENTER_SERVER_CORE_V;
      Name: 'Server Datacenter without Hyper-V (core installation)';),
    (Id: PRODUCT_DATACENTER_SERVER_V;
      Name: 'Server Datacenter without Hyper-V (full installation)';),
    (Id: PRODUCT_EDUCATION;
      Name: 'Education'),
    (Id: PRODUCT_EDUCATION_N;
      Name: 'Education N'),
    (Id: PRODUCT_ENTERPRISE;
      Name: 'Enterprise';),
    (Id: PRODUCT_ENTERPRISE_E;
      Name: 'Enterprise E';),
    (Id: PRODUCT_ENTERPRISE_EVALUATION;
      Name: 'Server Enterprise (evaluation installation)';),
    (Id: PRODUCT_ENTERPRISE_N;
      Name: 'Enterprise N';),
    (Id: PRODUCT_ENTERPRISE_N_EVALUATION;
      Name: 'Enterprise N (evaluation installation)';),
    (Id: PRODUCT_ENTERPRISE_S;
      Name: 'Enterprise 2015 LTSB';),
    (Id: PRODUCT_ENTERPRISE_S_EVALUATION;
      Name: 'Enterprise 2015 LTSB Evaluation';),
    (Id: PRODUCT_ENTERPRISE_S_N;
      Name: 'Enterprise 2015 LTSB N';),
    (Id: PRODUCT_ENTERPRISE_S_N_EVALUATION;
      Name: 'Enterprise 2015 LTSB N Evaluation';),
    (Id: PRODUCT_ENTERPRISE_SERVER;
      Name: 'Server Enterprise (full installation)';),
    (Id: PRODUCT_ENTERPRISE_SERVER_CORE;
      Name: 'Server Enterprise (core installation)';),
    (Id: PRODUCT_ENTERPRISE_SERVER_CORE_V;
      Name: 'Server Enterprise without Hyper-V (core installation)';),
    (Id: PRODUCT_ENTERPRISE_SERVER_IA64;
      Name: 'Server Enterprise for Itanium-based Systems';),
    (Id: PRODUCT_ENTERPRISE_SERVER_V;
      Name: 'Server Enterprise without Hyper-V (full installation)';),
    (Id: PRODUCT_ESSENTIALBUSINESS_SERVER_ADDL;
      Name: 'Windows Essential Server Solution Additional'),
    (Id: PRODUCT_ESSENTIALBUSINESS_SERVER_ADDLSVC;
      Name: 'Windows Essential Server Solution Additional SVC'),
    (Id: PRODUCT_ESSENTIALBUSINESS_SERVER_MGMT;
      Name: 'Windows Essential Server Solution Management'),
    (Id: PRODUCT_ESSENTIALBUSINESS_SERVER_MGMTSVC;
      Name: 'Windows Essential Server Solution Management SVC'),
    (Id: PRODUCT_HOME_BASIC;
      Name: 'Home Basic';),
    (Id: PRODUCT_HOME_BASIC_E;
      Name: 'Home Basic E';),
    (Id: PRODUCT_HOME_BASIC_N;
      Name: 'Home Basic N';),
    (Id: PRODUCT_HOME_PREMIUM;
      Name: 'Home Premium';),
    (Id: PRODUCT_HOME_PREMIUM_E;
      Name: 'Home Premium E';),
    (Id: PRODUCT_HOME_PREMIUM_N;
      Name: 'Home Premium N';),
    (Id: PRODUCT_HOME_PREMIUM_SERVER;
      Name: 'Home Server';),
    (Id: PRODUCT_HOME_SERVER;
      Name: 'Home Storage Server';),
    (Id: PRODUCT_HYPERV;
      Name: 'Hyper-V Server';),
    (Id: PRODUCT_IOTENTERPRISE;
      Name: 'IoT Enterprise';),
    (Id: PRODUCT_IOTENTERPRISE_S;
      Name: 'IoT Enterprise LTSC'),
    (Id: PRODUCT_IOTUAP;
      Name: 'IoT Core';),
    (Id: PRODUCT_IOTUAPCOMMERCIAL;
      Name: 'IoT Core Commercial';),
    (Id: PRODUCT_MEDIUMBUSINESS_SERVER_MANAGEMENT;
      Name: 'Essential Business Server Management Server';),
    (Id: PRODUCT_MEDIUMBUSINESS_SERVER_MESSAGING;
      Name: 'Essential Business Server Messaging Server';),
    (Id: PRODUCT_MEDIUMBUSINESS_SERVER_SECURITY;
      Name: 'Essential Business Server Security Server';),
    (Id: PRODUCT_MOBILE_CORE;
      Name: 'Mobile'),
    (Id: PRODUCT_MOBILE_ENTERPRISE;
      Name: 'Mobile Enterprise'),
    (Id: PRODUCT_MULTIPOINT_PREMIUM_SERVER;
      Name: 'MultiPoint Server Premium (full installation)';),
    (Id: PRODUCT_MULTIPOINT_STANDARD_SERVER;
      Name: 'MultiPoint Server Standard (full installation)';),
    (Id: PRODUCT_PRO_WORKSTATION;
      Name: 'Pro for Workstations';),
    (Id: PRODUCT_PRO_WORKSTATION_N;
      Name: 'Pro for Workstations N';),
    (Id: PRODUCT_PROFESSIONAL;
      Name: 'Pro (Professional)';),
    (Id: PRODUCT_PROFESSIONAL_E;
      Name: 'Professional E';),
    (Id: PRODUCT_PROFESSIONAL_N;
      Name: 'Pro (Professional) N';),
    (Id: PRODUCT_PROFESSIONAL_WMC;
      Name: 'Professional with Media Center';),
    (Id: PRODUCT_SB_SOLUTION_SERVER;
      Name: 'Small Business Server Essentials';),
    (Id: PRODUCT_SB_SOLUTION_SERVER_EM;
      Name: 'Server For SB Solutions EM';),
    (Id: PRODUCT_SERVER_FOR_SB_SOLUTIONS;
      Name: 'Server For SB Solutions';),
    (Id: PRODUCT_SERVER_FOR_SB_SOLUTIONS_EM;
      Name: 'Server For SB Solutions EM';),
    (Id: PRODUCT_SERVER_FOR_SMALLBUSINESS;
      Name: 'Server for Essential Server Solutions';),
    (Id: PRODUCT_SERVER_FOR_SMALLBUSINESS_V;
      Name: 'Server without Hyper-V for Essential Server Solutions';),
    (Id: PRODUCT_SERVER_FOUNDATION;
      Name: 'Server Foundation';),
    (Id: PRODUCT_SMALLBUSINESS_SERVER;
      Name: 'Small Business Server';),
    (Id: PRODUCT_SMALLBUSINESS_SERVER_PREMIUM;
      Name: 'Small Business Server Premium';),
    (Id: PRODUCT_SMALLBUSINESS_SERVER_PREMIUM_CORE;
      Name: 'Small Business Server Premium (core installation)';),
    (Id: PRODUCT_SOLUTION_EMBEDDEDSERVER;
      Name: 'Windows MultiPoint Server';),
    (Id: PRODUCT_STANDARD_EVALUATION_SERVER;
      Name: 'Server Standard (evaluation installation)';),
    (Id: PRODUCT_STANDARD_SERVER;
      Name: 'Server Standard';),
    (Id: PRODUCT_STANDARD_SERVER_CORE;
      Name: 'Server Standard (core installation)';),
    (Id: PRODUCT_STANDARD_SERVER_CORE_V;
      Name: 'Server Standard without Hyper-V (core installation)';),
    (Id: PRODUCT_STANDARD_SERVER_V;
      Name: 'Server Standard without Hyper-V';),
    (Id: PRODUCT_STANDARD_SERVER_SOLUTIONS;
      Name: 'Server Solutions Premium';),
    (Id: PRODUCT_STANDARD_SERVER_SOLUTIONS_CORE;
      Name: 'Server Solutions Premium (core installation)';),
    (Id: PRODUCT_STARTER;
      Name: 'Starter';),
    (Id: PRODUCT_STARTER_E;
      Name: 'Starter E';),
    (Id: PRODUCT_STARTER_N;
      Name: 'Starter N';),
    (Id: PRODUCT_STORAGE_ENTERPRISE_SERVER;
      Name: 'Storage Server Enterprise';),
    (Id: PRODUCT_STORAGE_ENTERPRISE_SERVER_CORE;
      Name: 'Storage Server Enterprise (core installation)';),
    (Id: PRODUCT_STORAGE_EXPRESS_SERVER;
      Name: 'Storage Server Express';),
    (Id: PRODUCT_STORAGE_EXPRESS_SERVER_CORE;
      Name: 'Storage Server Express (core installation)';),
    (Id: PRODUCT_STORAGE_STANDARD_EVALUATION_SERVER;
      Name: 'Storage Server Standard (evaluation installation)';),
    (Id: PRODUCT_STORAGE_STANDARD_SERVER;
      Name: 'Storage Server Standard';),
    (Id: PRODUCT_STORAGE_STANDARD_SERVER_CORE;
      Name: 'Storage Server Standard (core installation)';),
    (Id: PRODUCT_STORAGE_WORKGROUP_EVALUATION_SERVER;
      Name: 'Storage Server Workgroup (evaluation installation)';),
    (Id: PRODUCT_STORAGE_WORKGROUP_SERVER;
      Name: 'Storage Server Workgroup';),
    (Id: PRODUCT_STORAGE_WORKGROUP_SERVER_CORE;
      Name: 'Storage Server Workgroup (core installation)';),
    (Id: PRODUCT_ULTIMATE;
      Name: 'Ultimate';),
    (Id: PRODUCT_ULTIMATE_E;
      Name: 'Ultimate E';),
    (Id: PRODUCT_ULTIMATE_N;
      Name: 'Ultimate N';),
    (Id: PRODUCT_UNDEFINED;
      Name: 'An unknown product';),
    (Id: PRODUCT_WEB_SERVER;
      Name: 'Web Server (full installation)';),
    (Id: PRODUCT_WEB_SERVER_CORE;
      Name: 'Web Server (core installation)';),
    (Id: PRODUCT_CORE_ARM;
      Name: 'Windows RT';),
    (Id: PRODUCT_DATACENTER_NANO_SERVER;
      Name: 'Windows Server Datacenter Edition (Nano Server installation)';),
    (Id: PRODUCT_STANDARD_NANO_SERVER;
      Name: 'Windows Server Standard Edition (Nano Server installation)';),
    (Id: PRODUCT_DATACENTER_WS_SERVER_CORE;
      Name: 'Windows Server Datacenter Edition (Server Core installation)';),
    (Id: PRODUCT_STANDARD_WS_SERVER_CORE;
      Name: 'Windows Server Standard Edition (Server Core installation)';),
    (Id: PRODUCT_PRO_FOR_EDUCATION;
      Name: 'Windows 10 Pro Education';),
    (Id: PRODUCT_SERVERRDSH;
      Name: 'Windows 10 Enterprise for Virtual Desktops';),
    (Id: PRODUCT_DATACENTER_SERVER_AZURE_EDITION;
      Name: 'Windows Server Datacenter: Azure Edition';),
    (Id: Cardinal(PRODUCT_UNLICENSED);
      Name: 'Unlicensed product';)
  );

const
  // Array of "current version" registry sub-keys that vary with platform.
  // "False" value is for Window 9x and "True" value is for Windows NT.
  CurrentVersionRegKeys: array[Boolean] of string = (
    'Software\Microsoft\Windows\CurrentVersion',
    'Software\Microsoft\Windows NT\CurrentVersion'
  );

type
  // Record used to map a build number to a release name
  // Generally used in arrays
  TBuildNameMap = record
    Build: Integer;
    LoRev: Integer;
    Name: string;
    Version: Word;
  end;

  TWin10PlusVersionSet = set of TPJWin10PlusVersion;

const
  {
    Known windows build numbers.
    Sources:
      https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions
      https://en.wikipedia.org/wiki/Windows_NT
      https://en.wikipedia.org/wiki/Windows_10_version_history
      https://en.wikipedia.org/wiki/Windows_11_version_history
      https://blogs.windows.com/windows-insider/tag/windows-insider-program/
      https://en.wikipedia.org/wiki/Windows_Server
      https://en.wikipedia.org/wiki/Windows_Server_2019
      https://en.wikipedia.org/wiki/Windows_Server_2016
      https://en.wikipedia.org/wiki/Windows_Server_2022
      https://en.wikipedia.org/wiki/Windows_Server_2025
      https://tinyurl.com/y8tfadm2 (MS Windows Server release information)
      https://docs.microsoft.com/en-us/lifecycle/products/windows-server-2022
      https://learn.microsoft.com/en-us/lifecycle/products/windows-server-2025
      https://tinyurl.com/yj5e72jt (MS Win 10 release info)
      https://tinyurl.com/kd3weeu7 (MS Server release info)

    Note:
      For Vista and Win 7 we have to add service pack number to these values to
      get actual build number. For Win 8 onwards we just use the build numbers
      as is.

    References:
      [^1] MS community blog post https://tinyurl.com/3c8e3hsc
      [^2] https://en.wikipedia.org/wiki/Windows_11_version_history
  }

  {
    End of support (EOS) information for Windows Vista to Windows 8.1

    Version | Mainstream EOS | Extended EOS
    --------|----------------|-------------
    Vista   | 2012-04-10     | 2017-04-11
    7       | 2015-01-13     | 2020-01-14
    8       | N/a            | 2016-01-12
    8.1     | 2018-01-09     | 2023-01-10

    See below for Windows 10 & 11 end of support information.
  }


  // Windows Vista -------------------------------------------------------------
  WinVista_Base_Build = 6000;

  // Windows 7 -----------------------------------------------------------------
  Win7_Base_Build = 7600;

  // Windows 8 -----------------------------------------------------------------
  Win8_Build = 9200;        // Build number used for all Win 8/Svr 2012
  Win8Point1_Build = 9600;  // Build number used for all Win 8.1/Svr 2012 R2

  // Windows 10 ----------------------------------------------------------------

  // Version 1507 preview builds
  //   Preview builds with major/minor version number 6.4
  //     Expired by 2015-04-30 [^1]:
  //       9841, 9860, 9879
  //   Preview builds with major/minor version number 10.0
  //     Expired by 2015-10-15 [^1]:
  //       9926, 10041, 10049, 10061, 10074, 10122, 10130, 10158, 10159, 10162,
  //       10166

  // Version 1511 preview builds
  //   Expired by 2016-07-30 [^1]:
  //     10525, 10532, 10547, 10565, 10576

  // Version 1607 previews
  Win10_1607_Preview_Builds: array[0..5] of Integer = (
    // Expired 2016-07-30 [^1]:
    //   11082, 11099
    // Expired 2016-08-01 [^1]:
    //   11102, 14251, 14257, 14267, 14271, 14279, 14291, 14295, 14316, 14328,
    //   14332, 14342, 14352, 14361
    // Expired 2016-10-15 [^1]:
    //   14366, 14367, 14371, 14372,
    14376, 14379, 14383, 14385, // unknown expiry date [^1]
    14388, 14390                // permanently activated [^1]
  );

  // Version 1703 previews
  Win10_1703_Preview_Builds: array[0..26] of Integer = (
    14901, 14905, 14915, 14926, 14931, 14936, 14942, 14946, 14951, 14955,
    14959, 14965, 14971, 14986, 15002, 15007, 15014, 15019, 15025, 15031,
    15042, 15046, 15048, 15055, 15058, 15060, 15061
  );

  // Version 1709 previews
  Win10_1709_Preview_Builds: array[0..23] of Integer = (
    16170, 16176, 16179, 16184, 16188, 16193, 16199, 16212, 16215, 16226,
    16232, 16237, 16241, 16251, 16257, 16273, 16275, 16278, 16281, 16288,
    16291, 16294, 16296, 16299 {rev 0 only}
  );

  // Version 1803 previews
  Win10_1803_Preview_Builds: array[0..21] of Integer = (
    16353, 16362, 17004, 17017, 17025, 17035, 17040, 17046, 17063, 17074,
    17083, 17093, 17101, 17107, 17110, 17112, 17115, 17120, 17123, 17127,
    17128, 17133
  );

  // Version 1809 previews
  Win10_1809_Preview_Builds: array[0..33] of Integer = (
    17604, 17618, 17623, 17627, 17634, 17639, 17643, 17650, 17655, 17661,
    17666, 17672, 17677, 17682, 17686, 17692, 17704, 17711, 17713, 17723,
    17728, 17730, 17733, 17735, 17738, 17741, 17744, 17746, 17751, 17754,
    17755, 17758, 17760, 17763 {rev 0 only}
  );

  // Version 1903 previews
  Win10_1903_Preview_Builds: array[0..30] of Integer = (
    18204, 18214, 18219, 18234, 18237, 18242, 18247, 18252, 18262, 18267,
    18272, 18277, 18282, 18290, 18298, 18305, 18309, 18312, 18317, 18323,
    18329, 18334, 18342, 18343, 18346, 18348, 18351, 18353, 18356, 18358,
    18361
  );

  // Version 1909 previews used version 1903 build 18362 rev 10000 and later

  // Version 2004 previews
  Win10_2004_Preview_Builds: array[0..43] of Integer = (
    18836, 18841, 18845, 18850, 18855, 18860, 18865, 18875, 18885, 18890,
    18894, 18895, 18898, 18908, 18912, 18917, 18922, 18932, 18936, 18941,
    18945, 18950, 18956, 18963, 18965, 18970, 18975, 18980, 18985, 18990,
    18995, 18999, 19002, 19008, 19013, 19018, 19023, 19025, 19028, 19030,
    19033, 19035, 19037,
    19041 {revs 0, 21, 84, 113, 153, 172, 173, 207, 208 only}
  );

  // Version 20H2 previews: all used 19042, also used for release
  Win10_20H2_Preview_Builds: array[0..0] of Integer = (
    19042
  );

  {
    End of support information for Windows 10 versions (as of 2024-10-01).
      GAC = General Availablity Channel.
      LTSC = Long Term Support Channel.

    Version | GAC        | LTSC
    --------|------------|------------
    1507    | ended      | 2025-10-14
    1511    | ended      | N/a
    1607    | ended      | 2026-10-13
    1703    | ended      | N/a
    1709    | ended      | N/a
    1803    | ended      | N/a
    1809    | ended      | 2029-01-09
    1903    | ended      | N/a
    1909    | ended      | N/a
    2004    | ended      | N/a
    20H2    | ended      | N/a
    21H1    | ended      | N/a
    21H2    | ended      | 2032-01-13
    22H2    | 2025-10-14 | N/a
  }

  // Win 10 release build numbers
  Win10_1507_Build = 10240;
  Win10_1511_Build = 10586;
  Win10_1607_Build = 14393;
  Win10_1703_Build = 15063;
  Win10_1709_Build = 16299;
  Win10_1803_Build = 17134;
  Win10_1809_Build = 17763;
  Win10_1903_Build = 18362;
  Win10_1909_Build = 18363;
  Win10_2004_Build = 19041;
  Win10_20H2_Build = 19042;
  Win10_21H1_Build = 19043; // See **REF3** End of service @ rev 2364
  Win10_21H2_Build = 19044; // See **REF4**
  Win10_22H2_Build = 19045; // See **REF5**

  // Map of Win 10 builds from 1st release (version 1507) to version 20H2,
  // excluding version 1903.
  // Version 1903 and Win 10 releases after 20H2 have special handling and
  // aren't in the build map
  Win10_BuildMap: array[0..9] of TBuildNameMap = (
    (Build: Win10_1507_Build; LoRev: 16484;
      Name: 'Version 1507'; Version: Ord(win10v1507)),
    (Build: Win10_1511_Build; LoRev: 0;
      Name: 'Version 1511: November Update'; Version: Ord(win10v1511)),
    (Build: Win10_1607_Build; LoRev: 0;
      Name: 'Version 1607: Anniversary Update'; Version: Ord(win10v1607)),
    (Build: Win10_1703_Build; LoRev: 0;
      Name: 'Version 1703: Creators Update'; Version: Ord(win10v1703)),
    (Build: Win10_1709_Build; LoRev: 15;
      Name: 'Version 1709: Fall Creators Update'; Version: Ord(win10v1709)),
    (Build: Win10_1803_Build; LoRev: 1;
      Name: 'Version 1803: April 2018 Update'; Version: Ord(win10v1803)),
    (Build: Win10_1809_Build; LoRev: 1;
      Name: 'Version 1809: October 2018 Update'; Version: Ord(win10v1809)),
    (Build: Win10_1909_Build; LoRev: 327;
      Name: 'Version 1909: November 2019 Update'; Version: Ord(win10v1909)),
    (Build: Win10_2004_Build; LoRev: 264;
      Name: 'Version 2004: May 2020 Update'; Version: Ord(win10v2004)),
    (Build: Win10_20H2_Build; LoRev: 572;
      Name: 'Version 20H2: October 2020 Update'; Version: Ord(win10v20H2))
  );

  // Set of Windows 10 version identifiers
  Win10_Versions: TWin10PlusVersionSet = [
    win10v1507, win10v1511, win10v1607, win10v1703, win10v1709, win10v1803,
    win10v1809, win10v1903, win10v1909, win10v2004, win10v20H2, win10v21H1,
    win10v21H2, win10v22H2
  ];

  // Windows 10 slow ring, fast ring and skip-ahead channels were all expired
  // well before 2022-12-31 and are not detected. (In fact there was never any
  // detection of the slow ring and skip-ahead channels).

  // Windows 11 ----------------------------------------------------------------

  // NOTE: All releases of Windows 11 report version 10.0

  {
    End of support (EOS) information for Windows 11 versions (as of 2024-10-01).

    Version | Home, Pro  | Education,
            | etc EOS    | Enterprise
            |            | etc EOS
    --------|------------|------------
    21H2    | ENDED      | ENDED
    22H2    | ENDED      | ENDED
    23H2    | ENDED      | 2026-11-10
    24H2    | 2026-10-13 | 2027-10-12
    25H2    | 2027-10-12 | 2028-10-10
  }

  // 1st build released branded as Windows 11
  // Insider version, Dev channel, v10.0.21996.1
  Win11_Dev_Build = 21996;

  // Windows 11 version 21H2 - reached end of service
  // See **REF6** in implementation for details
  Win11_21H2_Build = 22000;

  // Windows 11 version 22H2
  //
  // Build 22621 was the original beta build. Same build used for releases and
  // various other channels.
  // See **REF1** in implementation
  Win11_22H2_Build = 22621;

  // Windows 11 version 22H3
  // See **REF10** in implementation
  Win11_23H2_Build = 22631;

  // Windows 11 version 22H4
  // See **REF11** in implementation
  Win11_24H2_Build = 26100;

  // Preview Builds of October 2022 component update in Beta Channel
  // See **REF2** in implementation
  Win11_Oct22Component_BetaChannel_Build = 22622;

  // Preview Builds of February 2023 component update in Beta Channel
  // See **REF7** in implementation
  Win11_Feb23Component_BetaChannel_Build = 22623;

  // Preview builds of May 2023 component update in Beta Channel
  // See **REF8** in implementation
  Win11_May23Component_BetaChannel_Build = 22624;

  // Preview builds of future component update in Beta Channel
  // See **REF9** in implementation
  Win11_23H2_FutureComponent_Beta_Build = 22635;

  // Preview builds of 24H2 future component update in Dev, Beta or both
  // channels (ge_release)
  // See **REF12** in implementation
  Win11_24H2_FutureComponent_Rel_Build = 26120;

  // Preview builds of 24H2 future component update in Dev channel
  // (ge_prerelease)
  // See **REF13** in implementation
  Win11_24H2_FutureComponent_PreRel_Build = 26200;

  // Preview builds of 24H2 future component update in Dev & Beta channels
  // (ge_release)
  // See **REF14** in implementation
  Win11_25H2_FutureComponent_Rel_Build = 26220;

  // Windows 11 Dev channel releases with version string "Dev" [^2]
  // pre Win 11 release (expired 2021/10/31):
  //   22449, 22454, 22458, 22463,
  // pre Win 11 release (expired 2022/09/15):
  //   22468,
  // post Win 11 release, pre Win 11 22H2 beta release (expired 2022/09/15):
  //   22471, 22478, 22483, 22489, 22494, 22499, 22504, 22509, 22518, 22523,
  //   22526, 22533, 22538, 22543, 22557, 22563,

  // Windows 11 Dev channel releases with version string "22H2" [^2]
  // pre Win 11 22H2 beta release (expired 2022/09/15):
  //   22567, 22572, 22579
  // post Win 11 22H2 beta release (expired 2022/09/15):
  //   25115, 25120, 25126, 25131, 25136, 25140, 25145, 25151, 25158, 25163,
  //   25169, 25174, 25179,
  // post Win 11 22H2 beta release (expired 2023/09/15):
  //    25182, 25188, 25193, 25197, 25201, 25206, 25211,
  // post Win 11 22H2 release, ni_release string (expired 2023/09/15):
  //    25217, 25227, 25231, 25236, 25247, 25252, 25262, 25267, 25272, 25276,
  //    25281, 25284, 25290, 25295, 25300, 25309,
  // post Win 11 22H2 release, ni_prerelease string (expired 2023/09/15):
  //    23403, 23419, 23424, 23430, 23435, 23440, 23451, 23466, 23471, 23475,
  //    23481, 23486, 23493, 23506, 23511, 23516, 23521,
  // post Win 11 22H2 release, ni_prerelease string (expired 2024-09-15):
  //    23526, 23531, 23536, 23541, 23545, 23550, 23555, 23560, 23565, 23570,
  //    23575, 23580, 23585, 23590, 23595, 23601, 23606, 23612, 23615, 23619,
  //    23620

  // Preview builds of Windows 11 in the Canary Channel with version string
  // "22H2" [^2]
  // expired 2023-09-15:
  //    25314, 25324, 25330, 25336, 25346, 25352, 25357, 25370,

  // Preview builds of Windows 11 in the Canary Channel with version string
  // "23H2" [^2]
  // Expired 2023-09-15:
  //    25375, 25381, 25387, 25393, 25905, 25915, 25921, 25926,
  // Expired 2024-09-15:
  //    25931, 25936, 25941, 25947, 25951, 25967, 25977, 25982, 25987, 25992,
  //    25997, 26002, 26010, 26016, 26020, 26040, 26063, 26200, 26212, 26217,
  //    26227, 26231, 26236, 26241, 26244, 26252, 26257, 27686.

  // Windows 11 Dev & Beta channel builds with version string "22H2" [^2]
  Win11_22H2_DevAndBetaChannel_Builds: array[0..1] of Integer = (
    // Expired 2022/09/15:
    //   22581, 22593, 22598
    // Unknown expiry date:
    22610, 22616
  );

  // Windows 11 Preview, Dev & Canary channel builds with version "24H2" [^2]
  Win11_24H2_DevAndCanaryChannel_Builds: array[0..1] of Integer = (
    // Expired 2024-09-15:
    //   26052, 26058, 26080, 26085,
    // Unknown expiry date:
    26090 {Dev revs:1,112; Canary revs: 1},
    26100 {Dev revs:1,268; Canary revs: 1}
  );

  Win11_24H2_CanaryChannel_Builds: array[0..0] of Integer = (
    // expired 2024-09-15
    //   27686
    // expired 2025-09-15:
    //   27695, 27718, 27723, 27729, 27744, 27749, 27754, 27758, 27764, 27766,
    //   27768, 27774, 27783, 27788, 27802, 27808, 27813, 27818, 27823, 27842,
    //   27858, 27863, 27868, 27871
    // expiring 2026-08-11
    27881
  );

  Win11_First_Build = Win11_Dev_Build;  // First build number of Windows 11

  // Set of Windows 10 version identifiers
  Win11_Versions: TWin10PlusVersionSet = [
    win11v21H2, win11v22H2, win11v23H2, win11v24H2
  ];

  // Windows server v10.0 version ----------------------------------------------

  // These are the Windows server versions that (with one exception) report
  // version 10.0. There's always an exception with Windows versioning!

  // Last build numbers of each "major" release before moving on to the next
  Win2016_Last_Build = 17134;
  Win2019_Last_Build = 18363;
  WinServer_Last_Build = 19042;
  Win2022_Build = 20348;
  Win2025_Build = 26100;

  {
    End of support information for all Windows Server versions.

    Version                            | End date
    -----------------------------------|------------
    Windows NT 3.1                     | 2000-12-31
    Windows NT 3.5                     | 2001-12-31
    Windows NT 3.51                    | 2001-12-31
    Windows NT 4.0                     | 2004-12-31
    Windows 2000                       | 2010-07-13
    Windows Server 2003                | 2015-07-14
    Windows Server 2003 R2             | 2015-07-14
    Windows Server 2008                | 2020-01-14
    Windows Server 2008 R2             | 2020-01-14
    Windows Server 2012                | 2023-10-10
    Windows Server 2012 R2             | 2023-10-10
    Windows Server 2016, version 1607  | 2027-01-12
    Windows Server 2016, version 1709  | 2019-04-09
    Windows Server 2016, version 1803  | 2019-11-12
    Windows Server 2019, version 1809  | 2029-01-09
    Windows Server 2019, version 1903  | 2020-12-08
    Windows Server 2019, version 1909  | 2021-05-11
    Windows Server, version 2004       | 2021-12-14
    Windows Server, version 20H2       | 2022-08-09
    Windows Server 2022, version 21H2  | 2031-10-14
    Windows Server 2025                | 2034-10-10
  }

  // Map of Windows server releases that are named straightforwardly
  WinServerSimpleBuildMap: array[0..13] of TBuildNameMap = (
    // Windows Server 2016
    (Build: 10074; LoRev: 0; Name: 'Technical Preview 2'; Version: 0),
    (Build: 10514; LoRev: 0; Name: 'Technical Preview 3'; Version: 0),
    (Build: 10586; LoRev: 0; Name: 'Technical Preview 4'; Version: 0),
    (Build: 14300; LoRev: 0; Name: 'Technical Preview 5'; Version: 0),
    (Build: 14393; LoRev: 0; Name: 'Version 1607'; Version: 0),
    (Build: 16299; LoRev: 0; Name: 'Version 1709'; Version: 0),
    (Build: Win2016_Last_Build; LoRev: 0; Name: 'Version 1803'; Version: 0),
    // Windows Server 2019
    (Build: 17763; LoRev: 0; Name: 'Version 1809'; Version: 0),
    (Build: 18362; LoRev: 0; Name: 'Version 1903'; Version: 0),
    (Build: Win2019_Last_Build; LoRev: 0; Name: 'Version 1909'; Version: 0),
    // Windows Server (no year number)
    (Build: 19041; LoRev: 0; Name: 'Version 2004'; Version: 0),
    (Build: WinServer_Last_Build; LoRev: 0; Name: 'Version 20H2'; Version: 0),
    // Windows Server 2022
    (Build: Win2022_Build; LoRev: 0; Name: 'Version 21H2'; Version: 0),
    // Windows Server 2025
    (Build: Win2025_Build; LoRev: 0; Name: ''; Version: 0)
  );

  // Windows server releases needing special handling

  // Server 2016 Technical Preview 1: reports version 6.4 instead of 10.0!
  Win2016_TP1_Build = 9841;

  // Server 2019 Insider Preview builds: require format strings in names
  Win2019_IP_Builds: array[0..9] of Integer = (
    17623, 17627, 17666, 17692, 17709, 17713, 17723, 17733, 17738, 17744
  );


type
  // Function type of the GetNativeSystemInfo and GetSystemInfo functions
  TGetSystemInfo = procedure(var lpSystemInfo: TSystemInfo); stdcall;
  // Function type of the VerSetConditionMask API function
  TVerSetConditionMask = function(dwlConditionMask: UInt64;
    dwTypeBitMask: LongWord; dwConditionMask: Byte): UInt64; stdcall;
  // Function type of the VerifyVersionInfo API function
  TVerifyVersionInfo = function(lpVersionInfo: POSVersionInfoEx;
    dwTypeMask: LongWord; dwlConditionMask: UInt64): LongBool; stdcall;

  // Header of a structure within SMBIOS data
  TSMBiosStructureHeader = packed record
    Kind: Byte;
    Length: Byte;
    Handle: Word;
  end;
  PSMBiosStructureHeader = ^TSMBiosStructureHeader;

const
  // SMBIOS related constants
  SMBiosMinVersion = Word($0200);       // min SMBIOS version supported
  UuidSupportMinVersion = Word($0201);  // min SMBIOS version that supports UUID
  UuidDataSize = 16;                    // size of BIOS UUID in bytes

var
  // Function used to get system info: initialised to GetNativeSystemInfo API
  // function if available, otherwise set to GetSystemInfo API function.
  GetSystemInfoFn: TGetSystemInfo;

  // Function used to specify conditional to use in tests in VerifyVersionInfo:
  // initialised to VerSetConditionMask API function if available, undefined
  // otherwise.
  VerSetConditionMask: TVerSetConditionMask;

  // Function used to query operating system version: initialised to
  // VerifyVersionInfo API function if available, undefined otherwise.
  VerifyVersionInfo: TVerifyVersionInfo;

var
  // Internal variables recording version information.
  // When using the GetVersionEx API function to get version information these
  // variables have the same value as the similarly named Win32XXX function in
  // SysUtils. When the old API function aren't being used these value *may*
  // vary from the SysUtils versions.
  InternalPlatform: Integer = 0;
  InternalMajorVersion: LongWord = 0;
  InternalMinorVersion: LongWord = 0;
  InternalBuildNumber: Integer = 0;
  InternalCSDVersion: string = '';
  InternalRevisionNumber: Integer = 0;
  // Internal variable recording processor architecture information
  InternalProcessorArchitecture: Word = 0;
  // Internal variable recording additional update information.
  // ** This was added because Windows 10 TH2 doesn't declare itself as a
  //    service pack, but is a significant update.
  // ** At present this variable is only used for Windows 10.
  InternalExtraUpdateInfo: string = '';

  InternalWin1011Version: TPJWin10PlusVersion = win10plusNA;

// Flag required when opening registry with specified access flags
{$IFDEF REGACCESSFLAGS}
const
  KEY_WOW64_64KEY = $0100;  // registry access flag not defined in all Delphis
{$ENDIF}

// Checks if integer V is in the range of values defined by VLo and VHi,
// inclusive.
function IsInRange(const V, VLo, VHi: Integer): Boolean;
begin
  Assert(VLo <= VHi);
  Result := (V >= VLo) and (V <= VHi);
end;

// Tests Windows version (major, minor, service pack major & service pack minor)
// against the given values using the given comparison condition and return
// True if the given version matches the current one or False if not
// Assumes VerifyVersionInfo & VerSetConditionMask APIs functions are available
// Adapted from code from VersionHelpers.pas
// by Achim Kalwa <delphi@achim-kalwa.de> 2014-01-05
function TestWindowsVersion(wMajorVersion, wMinorVersion,
  wServicePackMajor, wServicePackMinor: Word; Condition: Byte): Boolean;
var
  OSVI: TOSVersionInfoEx;
  POSVI: POSVersionInfoEx;
  ConditionalMask: UInt64;
begin
  Assert(Assigned(VerSetConditionMask) and Assigned(VerifyVersionInfo));
  FillChar(OSVI, SizeOf(OSVI), 0);
  OSVI.dwOSVersionInfoSize := SizeOf(OSVI);
  OSVI.dwMajorVersion := wMajorVersion;
  OSVI.dwMinorVersion := wMinorVersion;
  OSVI.wServicePackMajor := wServicePackMajor;
  OSVI.wServicePackMinor := wServicePackMinor;
  POSVI := @OSVI;
  ConditionalMask :=
    VerSetConditionMask(
      VerSetConditionMask(
        VerSetConditionMask(
          VerSetConditionMask(
            0,
            VER_MAJORVERSION,
            Condition
          ),
          VER_MINORVERSION,
          Condition
        ),
        VER_SERVICEPACKMAJOR,
        Condition
      ),
      VER_SERVICEPACKMINOR,
      Condition
    );
  Result := VerifyVersionInfo(
    POSVI,
    VER_MAJORVERSION or VER_MINORVERSION
      or VER_SERVICEPACKMAJOR or VER_SERVICEPACKMINOR,
    ConditionalMask
  );
end;

// Checks how the OS build number compares to the given TestBuildNumber
// according to operator Op.
// Op must be one of VER_EQUAL, VER_GREATER, VER_GREATER_EQUAL, VER_LESS or
// VER_LESS_EQUAL.
// Assumes VerifyVersionInfo & VerSetConditionMask APIs functions are available.
function TestBuildNumber(Op, TestBuildNumber: DWORD): Boolean;
var
  OSVI: TOSVersionInfoEx;
  POSVI: POSVersionInfoEx;
  ConditionalMask: UInt64;
begin
  Assert(Assigned(VerSetConditionMask) and Assigned(VerifyVersionInfo));
  FillChar(OSVI, SizeOf(OSVI), 0);
  OSVI.dwOSVersionInfoSize := SizeOf(OSVI);
  OSVI.dwBuildNumber := TestBuildNumber;
  POSVI := @OSVI;
  ConditionalMask := VerSetConditionMask(0, VER_BUILDNUMBER, Op);
  Result := VerifyVersionInfo(POSVI, VER_BUILDNUMBER, ConditionalMask);
end;

// Checks if given build number matches that of the current OS.
// Assumes VerifyVersionInfo & VerSetConditionMask APIs functions are available.
function IsBuildNumber(BuildNumber: DWORD): Boolean;
  {$IFDEF INLINEMETHODS}inline;{$ENDIF}
begin
  Result := TestBuildNumber(VER_EQUAL, BuildNumber);
end;

// Checks if any of the given build numbers match that of the current OS.
// If current build number is in the list, FoundBN is set to the found build
// number and True is returned. Otherwise False is returned and FoundBN is set
// to zero.
function FindBuildNumberFrom(const BNs: array of Integer; var FoundBN: Integer):
  Boolean;
var
  I: Integer;
begin
  FoundBN := 0;
  Result := False;
  for I := Low(BNs) to High(BNs) do
  begin
    if IsBuildNumber(BNs[I]) then
    begin
      FoundBN := BNs[I];
      Result := True;
      Break;
    end;
  end;
end;

// Checks if any of the build numbers in the given array match that of the
// current OS AND if the OS revision number is in the specified range. If so
// then the build number that was found then True is returned, and the build
// number and it's associated text are passed back in the FoundBN and FoundExtra
// parameters respectively. Otherwise False is returned, FoundBN is set to 0 and
// FoundExtra is set to ''.
function FindBuildNameAndExtraFrom(const Infos: array of TBuildNameMap;
  var FoundBN: Integer; var FoundExtra: string; var FoundVersion: Word):
  Boolean;
var
  I: Integer;
begin
  FoundBN := 0;
  FoundExtra := '';
  FoundVersion := 0;
  Result := False;
  for I := Low(Infos) to High(Infos) do
  begin
    if IsBuildNumber(Infos[I].Build) and
      IsInRange(InternalRevisionNumber, Infos[I].LoRev, MaxInt) then
    begin
      FoundBN := Infos[I].Build;
      FoundExtra := Infos[I].Name;
      FoundVersion := Infos[I].Version;
      Result := True;
      Break;
    end;
  end;
end;

function FindWin10PreviewBuildNameAndExtraFrom(const Builds: array of Integer;
  const Win10Version: string; var FoundBN: Integer; var FoundExtra: string):
  Boolean;
var
  I: Integer;
begin
  FoundBN := 0;
  FoundExtra := '';
  Result := False;
  for I := Low(Builds) to High(Builds) do
  begin
    if IsBuildNumber(Builds[I]) then
    begin
      FoundBN := Builds[I];
      FoundExtra := Format(
        'Version %s Preview Build %d', [Win10Version, FoundBN]
      );
      Result := True;
      Break;
    end;
  end;
end;

// Checks if the OS has the given product type.
// Assumes VerifyVersionInfo & VerSetConditionMask APIs functions are available
function IsWindowsProductType(ProductType: Byte): Boolean;
var
  ConditionalMask: UInt64;
  OSVI: TOSVersionInfoEx;
  POSVI: POSVersionInfoEx;
begin
  FillChar(OSVI, SizeOf(OSVI), 0);
  OSVI.dwOSVersionInfoSize := SizeOf(OSVI);
  OSVI.wProductType := ProductType;
  POSVI := @OSVI;
  ConditionalMask := VerSetConditionMask(0, VER_PRODUCT_TYPE, VER_EQUAL);
  Result := VerifyVersionInfo(POSVI, VER_PRODUCT_TYPE, ConditionalMask);
end;

// Checks if we are to use the GetVersionEx API function to get version
// information. (GetVersionEx was deprecated in Windows 8.1).
function UseGetVersionAPI: Boolean;

  // Checks if the current OS major and minor version is strictly less than the
  // given major and minor version numbers
  function TestOSLT(Major, Minor: LongWord): Boolean;
  begin
    Result := not Assigned(VerSetConditionMask)
      or not Assigned(VerifyVersionInfo)
      or TestWindowsVersion(Major, Minor, 0, 0, VER_LESS);
  end;

begin
  {$IFNDEF DEBUG_NEW_API}
  // Production code uses GetVersionEx if OS earlier than Windows 8.0
  Result := TestOSLT(6, 2);
  {$ELSE}
  // Debug code uses GetVersionEx if OS earlier than Windows Vista
  Result := TestOSLT(6, 0);
  {$ENDIF}
end;

// Gets Windows version by probing for possible versions
procedure NewGetVersion(out Major, Minor: LongWord; out SPMajor, SPMinor: Word);
begin
  Major := 6;   // lowest version to use this code has major version 6
  Minor := High(Word);
  SPMajor := High(Word);
  SPMinor := High(Word);
  while TestWindowsVersion(Major, Minor, SPMajor, SPMinor, VER_GREATER) do
    Inc(Major);
  Minor := 0;
  while TestWindowsVersion(Major, Minor, SPMajor, SPMinor, VER_GREATER) do
    Inc(Minor);
  SPMajor := 0;
  while TestWindowsVersion(Major, Minor, SPMajor, SPMinor, VER_GREATER) do
    Inc(SPMajor);
  SPMinor := 0;
  while TestWindowsVersion(Major, Minor, SPMajor, SPMinor, VER_GREATER) do
    Inc(SPMinor);
end;

// Loads a function from the OS kernel.
function LoadKernelFunc(const FuncName: string): Pointer;
const
  cKernel = 'kernel32.dll'; // kernel DLL
begin
  Result := GetProcAddress(GetModuleHandle(cKernel), PChar(FuncName));
end;

{$IFNDEF EXCLUDETRAILING}
// Removes any trailing '\' from given directory or path. Used for versions of
// Delphi that don't implement this routine in SysUtils.
function ExcludeTrailingPathDelimiter(const DirOrPath: string) : string;
begin
  Result := DirOrPath;
  while (Result <> '') and (Result[Length(Result)] = '\') do
    Result := Copy(Result, 1, Length(Result) - 1);
end;
{$ENDIF}

// Returns the value of the given environment variable.
function GetEnvVar(const VarName: string): string;
var
  BufSize: Integer;
begin
  BufSize := GetEnvironmentVariable(PChar(VarName), nil, 0);
  if BufSize > 0 then
  begin
    SetLength(Result, BufSize - 1);
    GetEnvironmentVariable(PChar(VarName), PChar(Result), BufSize);
  end
  else
    Result := '';
end;

// Checks if host OS is Windows 2000 or earlier, including any Win9x OS.
// This is a helper function for RegCreate and RegOpenKeyReadOnly and avoids
// using TPJOSInfo to ensure that an infinite loop is not set up with TPJOSInfo
// calling back into RegCreate.
function IsWin2000OrEarlier: Boolean;
begin
  // NOTE: all Win9x OSs have InternalMajorVersion < 5, so we don't need to
  // check platform.
  Result := (InternalMajorVersion < 5) or
    ((InternalMajorVersion = 5) and (InternalMinorVersion = 0));
end;

// Creates a read only TRegistry instance. On versions of Delphi or OSs that
// don't support passing access flags to TRegistry constructor, registry is
// opened normally for read/write access.
function RegCreate: TRegistry;
begin
  {$IFDEF REGACCESSFLAGS}
  //! Fix for issue #14 (https://sourceforge.net/p/ddablib/tickets/14/)
  //! suggested by Steffen Schaff.
  //! Later modified to allow for fact that Windows 2000 fails if
  //! KEY_WOW64_64KEY is used.
  if IsWin2000OrEarlier then
    Result := TRegistry.Create
  else
    Result := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  {$ELSE}
  Result := TRegistry.Create;
  {$ENDIF}
end;

// Uses registry object to open a key as read only. On versions of Delphi that
// can't open keys as read only the key is opened normally.
function RegOpenKeyReadOnly(const Reg: TRegistry; const Key: string): Boolean;
begin
  {$IFDEF REGACCESSFLAGS}
  //! Fix for problem with OpenKeyReadOnly on 64 bit Windows requires Reg has
  //! (KEY_READ or KEY_WOW64_64KEY) access flags.
  //! Even though these flags aren't provided on Windows 2000 and earlier, the
  //! following code should still work
  if IsWin2000OrEarlier then
    Result := Reg.OpenKeyReadOnly(Key)
  else
    Result := Reg.OpenKey(Key, False);
  {$ELSE}
  // Can't fix Win 64 problem since this version of Delphi does not support
  // customisation of registry access flags.
  Result := Reg.OpenKeyReadOnly(Key);
  {$ENDIF}
end;

// Gets a string value from the given registry sub-key and value within the
// given root key (hive).
function GetRegistryString(const RootKey: HKEY;
  const SubKey, Name: string): string;
var
  Reg: TRegistry;          // registry access object
  ValueInfo: TRegDataInfo; // info about registry value
begin
  Result := '';
  // Open registry at required root key
  Reg := RegCreate;
  try
    Reg.RootKey := RootKey;
    // Open registry key and check value exists
    if RegOpenKeyReadOnly(Reg, SubKey) and Reg.ValueExists(Name) then
    begin
      // Check if registry value is string or integer
      Reg.GetDataInfo(Name, ValueInfo);
      case ValueInfo.RegData of
        rdString, rdExpandString:
          // string value: just return it
          Result := Reg.ReadString(Name);
        rdInteger:
          // integer value: convert to string
          Result := IntToStr(Reg.ReadInteger(Name));
        else
          // unsupported value: raise exception
          raise EPJSysInfo.Create(sBadRegType);
      end;
    end;
  finally
    // Close registry
    Reg.CloseKey;
    Reg.Free;
  end;
end;

function GetRegistryInt(const RootKey: HKEY; const SubKey, Name: string):
  Integer;
var
  Reg: TRegistry;          // registry access object
  ValueInfo: TRegDataInfo; // info about registry value
begin
  Result := 0;
  // Open registry at required root key
  Reg := RegCreate;
  try
    Reg.RootKey := RootKey;
    if RegOpenKeyReadOnly(Reg, SubKey) and Reg.ValueExists(Name) then
    begin
      // Check if registry value is integer
      Reg.GetDataInfo(Name, ValueInfo);
      if ValueInfo.RegData <> rdInteger then
        raise EPJSysInfo.Create(sBadRegIntType);
      Result := Reg.ReadInteger(Name);
    end;
  finally
    // Close registry
    Reg.CloseKey;
    Reg.Free;
  end;
end;

function GetRegistryBytes(const RootKey: HKEY; const SubKey, Name: string):
  TBytes;
var
  Reg: TRegistry;          // registry access object
  ValueInfo: TRegDataInfo; // info about registry value
begin
  SetLength(Result, 0);
  // Open registry at required root key
  Reg := RegCreate;
  try
    Reg.RootKey := RootKey;
    if RegOpenKeyReadOnly(Reg, SubKey) and Reg.ValueExists(Name) then
    begin
      // Check if registry value is integer
      Reg.GetDataInfo(Name, ValueInfo);
      if ValueInfo.RegData <> rdBinary then
        raise EPJSysInfo.Create(sBadRegBinType);
      SetLength(Result, ValueInfo.DataSize);
      Reg.ReadBinaryData(Name, Result[0], Length(Result));
    end;
  finally
    // Close registry
    Reg.CloseKey;
    Reg.Free;
  end;
end;

// Gets string info for given value from Windows current version key in
// registry.
function GetCurrentVersionRegStr(ValName: string): string;
const
  // required registry string
  cWdwCurrentVer = '\Software\Microsoft\Windows\CurrentVersion';
begin
  Result := GetRegistryString(HKEY_LOCAL_MACHINE, cWdwCurrentVer, ValName);
end;

// Initialise global variables with extended OS version information if possible.
procedure InitPlatformIdEx;

type
  // Function type of the GetProductInfo API function
  TGetProductInfo = function(OSMajor, OSMinor, SPMajor, SPMinor: DWORD;
    out ProductType: DWORD): BOOL; stdcall;
  // Function type of the GetVersionEx API function
  TGetVersionEx = function(var lpVersionInformation: TOSVersionInfoEx): BOOL;
    stdcall;
var
  OSVI: TOSVersionInfoEx;           // extended OS version info structure
  GetVersionEx: TGetVersionEx;      // pointer to GetVersionEx API function
  GetProductInfo: TGetProductInfo;  // pointer to GetProductInfo API function
  SI: TSystemInfo;                  // structure from GetSystemInfo API call
  VersionEx: Word;                  // gets extra version info (Win 10/11)

  // Get OS's revision number from registry.
  function GetOSRevisionNumber(const IsNT: Boolean): Integer;
  begin
    Result := GetRegistryInt(
      HKEY_LOCAL_MACHINE, CurrentVersionRegKeys[IsNT], 'UBR'
    );
  end;

  // Append "Moment N" to InternalExtraUpdateInfo
  procedure AppendMomentToInternalExtraUpdateInfo(N: Cardinal);
  begin
    InternalExtraUpdateInfo := InternalExtraUpdateInfo
      + ' Moment ' + IntToStr(N);
  end;

begin
  // Load version query functions used externally to this routine
  VerSetConditionMask := LoadKernelFunc('VerSetConditionMask');
  {$IFDEF UNICODE}
  VerifyVersionInfo := LoadKernelFunc('VerifyVersionInfoW');
  {$ELSE}
  VerifyVersionInfo := LoadKernelFunc('VerifyVersionInfoA');
  {$ENDIF}

  if not UseGetVersionAPI then
  begin
    // Not using GetVersion and GetVersionEx functions to get version info
    InternalMajorVersion := 0;
    InternalMinorVersion := 0;
    InternalBuildNumber := 0;
    InternalCSDVersion := '';
    Win32ServicePackMajor := 0;
    Win32ServicePackMinor := 0;
    // we don't use suite mask any more!
    Win32SuiteMask := 0;
    // platform for all OSs tested for this way is always NT: the NewGetVersion
    // calls below indirectly call VerifyVersionInfo API, which is only defined
    // for Windows 2000 and later.
    InternalPlatform := VER_PLATFORM_WIN32_NT;
    InternalRevisionNumber := GetOSRevisionNumber(True);
    Win32HaveExInfo := True;
    NewGetVersion(
      InternalMajorVersion, InternalMinorVersion,
      Win32ServicePackMajor, Win32ServicePackMinor
    );
    // Test possible product types to see which one we have
    if IsWindowsProductType(VER_NT_WORKSTATION) then
      Win32ProductType := VER_NT_WORKSTATION
    else if IsWindowsProductType(VER_NT_DOMAIN_CONTROLLER) then
      Win32ProductType := VER_NT_DOMAIN_CONTROLLER
    else if IsWindowsProductType(VER_NT_SERVER) then
      Win32ProductType := VER_NT_SERVER
    else
      Win32ProductType := 0;
    // NOTE: It's going to be very slow to test for all possible build numbers,
    // so I've narrowed the search down using the information at
    // https://en.wikipedia.org/wiki/Windows_NT
    case InternalMajorVersion of
      6:
      begin
        case InternalMinorVersion of
          0:
            // Vista
            InternalBuildNumber := WinVista_Base_Build + Win32ServicePackMajor;
          1:
            // Windows 7
            InternalBuildNumber := Win7_Base_Build + Win32ServicePackMajor;
          2:
            // Windows 8 (no known SPs)
            if Win32ServicePackMajor = 0 then
              InternalBuildNumber := Win8_Build;
          3:
            // Windows 8.1 (no known SPs)
            if Win32ServicePackMajor = 0 then
              InternalBuildNumber := Win8Point1_Build;
          4:
            if (Win32ProductType = VER_NT_DOMAIN_CONTROLLER)
              or (Win32ProductType = VER_NT_SERVER) then
            begin
              // Windows 2016 Server tech preview 1
              InternalBuildNumber := Win2016_TP1_Build;
              InternalExtraUpdateInfo := 'Technical Preview 6';
            end;
        end;
        if Win32ServicePackMajor > 0 then
          // ** Tried to read this info from registry, but for some weird
          //    reason the required value is reported as non-existant by
          //    TRegistry, even though it is present in registry.
          // ** Seems there is some kind of registry "spoofing" going on (see
          //    below.
          InternalCSDVersion := Format(
            'Service Pack %d', [Win32ServicePackMajor]
          );
      end;
      10:
      begin
        case InternalMinorVersion of
          0:
          // ** As of 2022/06/01 all releases of Windows 10 **and**
          //    Windows 11 report major version 10 and minor version 0
          //    Well that's helpful!!
          if (Win32ProductType <> VER_NT_DOMAIN_CONTROLLER)
            and (Win32ProductType <> VER_NT_SERVER) then
          begin
            if FindBuildNameAndExtraFrom(
              Win10_BuildMap, InternalBuildNumber, InternalExtraUpdateInfo,
              VersionEx
            ) then
            begin
              InternalWin1011Version := TPJWin10PlusVersion(VersionEx);
            end
            else if IsBuildNumber(Win10_21H1_Build) then
            begin
              // **REF3**
              InternalBuildNumber := Win10_21H1_Build;
              InternalWin1011Version := win10v21H1;
              case InternalRevisionNumber of
                985, 1023, 1052, 1055, 1081, 1082, 1083, 1110, 1151, 1165, 1202,
                1237, 1266, 1288, 1320, 1348, 1387, 1415, 1466, 1469, 1503,
                1526, 1566, 1586, 1620, 1645, 1682, 1706, 1708, 1741, 1766,
                1767, 1806, 1826, 1865, 1889, 1949, 2006, 2075, 2130, 2132,
                2193, 2194, 2251, 2311, 2364 {final build}:
                  InternalExtraUpdateInfo := 'Version 21H1';
                1147, 1149, 1200, 1263, 1319, 1379, 1381:
                  InternalExtraUpdateInfo := Format(
                    'Version 21H1 [Release Preview Channel v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                844, 867, 899, 906, 928, 962, 964:
                  InternalExtraUpdateInfo := Format(
                    'Version 21H1 [Beta Channel v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Version 21H1 [Unknown release v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win10_21H2_Build) then
            begin
              // **REF4**
              // From 21H2 Windows 10 moves from a 6 monthly update cycle to a
              // yearly cycle
              InternalBuildNumber := Win10_21H2_Build;
              InternalWin1011Version := win10v21H2;
              case InternalRevisionNumber of
                1288, 1348, 1387, 1415, 1466, 1469, 1503, 1526, 1566, 1586,
                1620, 1645, 1682, 1706, 1708, 1741, 1766, 1767, 1806, 1826,
                1865, 1889, 1949, 2006, 2075, 2130, 2132, 2193, 2194, 2251,
                2311, 2364, 2486, 2546, 2604, 2673, 2728, 2788, 2846, 2965,
                3086, 3208, 3324, 3448, 3570, 3693, 3803, 3930, 4046, 4170,
                4291, 4412, 4529, 4651, 4780, 4894, 5011, 5131, 5247 .. MaxInt:
                  InternalExtraUpdateInfo := 'Version 21H2';
                1147, 1149, 1151, 1165, 1200, 1202, 1237, 1263, 1266, 1319,
                1320, 1379, 1381, 1499, 1618, 1679, 1737, 1739, 1862,
                1947, 2192, 2545:
                  InternalExtraUpdateInfo := Format(
                    'Version 21H2 [Release Preview Channel v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Version 21H2 [Unknown release v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win10_22H2_Build) then
            begin
              // **REF5**
              InternalBuildNumber := Win10_22H2_Build;
              InternalWin1011Version := win10v22H2;
              case InternalBuildNumber of
                2006, 2130, 2132, 2193, 2194, 2251, 2311, 2364, 2486, 2546,
                2604, 2673, 2728, 2788, 2846, 2913, 2965, 3031, 3086, 3208,
                3271, 3324, 3393, 3448, 3516, 3570, 3636, 3693, 3758, 3803,
                3930, 3996, 4046, 4123, 4170, 4239, 4291, 4355, 4412, 4474,
                4529, 4598, 4651, 4717, 4780, 4842, 4894, 4957, 5011, 5073,
                5131, 5198, 5247 .. MaxInt:
                  InternalExtraUpdateInfo := 'Version 22H2';
                1865, 1889, 1949, 2075, 2301, 2670, 2787, 2908, 3030, 3154,
                3155, 3269, 3391, 3513, 3754, 3757, 3992, 4116, 4233, 4235,
                4353, 4472:
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [Release Preview Channel v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                4593, 4713, 4955, 5070, 5194, 5196:
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 '
                    + '[Beta and Release Preview Channels v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [Unknown release v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            // Win 11 releases are reporting v10.0
            // Details taken from: https://tinyurl.com/usupsz4a
            else if IsBuildNumber(Win11_Dev_Build) then
            begin
              InternalBuildNumber := Win11_Dev_Build;
              InternalWin1011Version := win10plusUnknown;
              InternalExtraUpdateInfo := Format(
                'Dev [Insider v10.0.%d.%d]',
                [InternalBuildNumber, InternalRevisionNumber]
              )
            end
            else if IsBuildNumber(Win11_21H2_Build) then
            begin
              // **REF6**
              // There are several Win 11 releases with this build number
              // Which release we're talking about depends on the revision
              // number.
              // *** Amazingly one of them, revision 194, is the 1st public
              //     release of Win 11 -- well hidden eh?!
              // *** Reached end of support 2024-10-08
              InternalBuildNumber := Win11_21H2_Build;
              InternalWin1011Version := win11v21H2;
              case InternalRevisionNumber of
                194, 258, 282, 348, 376, 434, 438, 469, 493, 527, 556, 593, 613,
                652, 675, 708, 739, 740, 778, 795, 832, 856, 918, 978, 1042,
                1098, 1100, 1165, 1219, 1281, 1335, 1455, 1516, 1574, 1641,
                1696, 1761, 1817, 1880, 1936, 2003, 2057, 2124, 2176, 2245,
                2295, 2360, 2416, 2482, 2538, 2600, 2652, 2713, 2777,
                2836, 2899, 2960, 3019, 3079, 3147, 3197, 3260:
                  // Public releases of Windows 11
                  InternalExtraUpdateInfo := 'Version 21H2';
                51, 65, 71:
                  InternalExtraUpdateInfo := Format(
                    'Version 21H2 [Dev Channel v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                100, 120, 132, 160, 168:
                  InternalExtraUpdateInfo := Format(
                    'Version 21H2 [Dev & Beta Channels v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                176, 184, 346, 466, 526, 588:
                  InternalExtraUpdateInfo := Format(
                    'Version 21H2 '
                      + '[Beta & Release Preview Channels v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                651, 706, 776, 829, 917, 1041, 1163, 1279, 1515, 1639, 1757,
                1879, 2001, 2121, 2243, 2359, 2479:
                  InternalExtraUpdateInfo := Format(
                    'Version 21H2 Release Preview Channel v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Version 21H2 [Unknown release v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win11_22H2_Build) then
            begin
              // **REF1**
              InternalBuildNumber := Win11_22H2_Build;
              InternalWin1011Version := win11v22H2;
              case InternalRevisionNumber of
                382, 521, 525, 608, 674, 675, 755, 819, 900, 963, 1105, 1194,
                1265, 1344, 1413, 1485, 1555, 1635, 1702, 1778, 1848, 1926,
                1928, 1992, 2070, 2134, 2215, 2283, 2361, 2428, 2506, 2715,
                2792, 2861, 3007, 3085, 3155, 3235, 3296, 3374, 3447, 3527,
                3593, 3672, 3737, 3810, 3880, 3958, 4037, 4112, 4169, 4249,
                4317, 4391, 4460, 4541, 4602, 4751, 4830, 4890, 4974, 5039,
                5126, 5191, 5192, 5262, 5335, 5413, 5415, 5472, 5549, 5624,
                5768, 5771, 5909, 6060 .. MaxInt:
                begin
                  InternalExtraUpdateInfo := 'Version 22H2';
                  case InternalRevisionNumber of
                    675:  AppendMomentToInternalExtraUpdateInfo(1);
                    1344: AppendMomentToInternalExtraUpdateInfo(2);
                    1778: AppendMomentToInternalExtraUpdateInfo(3);
                    2361: AppendMomentToInternalExtraUpdateInfo(4);
                    3235: AppendMomentToInternalExtraUpdateInfo(5);
                  end;
                end;
                1:
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [Beta & Release Preview v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                105, 169, 232, 317, 457, 607, 754, 898, 1192, 1343, 1483, 1631,
                1776, 2066, 2213, 2359, 2500, 2787, 3078, 3227, 3371, 3520,
                3668, 3807, 3951, 4108, 4247:
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [Release Preview v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                160, 290, 436, 440, 450, 575, 586, 590, 598, 601, 730, 741, 746,
                870, 875, 885, 891, 1020, 1028, 1037, 1095, 1180, 1245, 1250,
                1255, 1325, 1391, 1465, 1470, 1537, 1546, 1616, 1680, 1690,
                1755, 1825, 1830, 1835, 1900, 1906, 1972, 2048, 2050, 2115,
                2129, 2191, 2199, 2262, 2265, 2271, 2338:
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [Unknown release v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win11_23H2_Build) then
            begin
              // **REF10**
              InternalBuildNumber := Win11_23H2_Build;
              InternalWin1011Version := win11v23H2;
              case InternalRevisionNumber of
                2428, 2506, 2715, 2792, 2861, 3007, 3085, 3155, 3235 {Moment 5},
                3296, 3374, 3447, 3527, 3593, 3672, 3737, 3810, 3880, 3958,
                4037, 4112, 4169, 4249, 4317, 4391, 4460, 4541, 4602, 4751,
                4830, 4890, 4974, 5039, 5126, 5189, 5192, 5262, 5335, 5413,
                5415, 5472, 5549, 5624, 5699, 5768, 5771, 5840, 5909, 5984,
                6060, 6133, 6199,
                Succ(6269) {after latest release channel release} .. MaxInt:
                  InternalExtraUpdateInfo := 'Version 23H2';
                1825, 1830, 1835, 1900, 1906, 1972:
                begin
                  // revisions 1825..1972 had version string "22H2"
                  InternalWin1011Version := win11v22H2;
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                end;
                2048, 2050, 2115, 2129, 2191, 2199, 2262, 2265, 2271, 2338:
                  InternalExtraUpdateInfo := Format(
                    'Version 23H2 [Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                2361, 2787, 3078, 3227, 3371, 3520, 3668, 3807, 3951, 4108,
                4247, 4387, 4534, 4825, 4969, 5116, 5261, 5409, 5545, 5548,
                5696, 5837, 5982, 6130, 6132, 6269:
                  InternalExtraUpdateInfo := Format(
                    'Version 23H2 [Release Preview v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Version 23H2 [Unknown release v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win11_24H2_Build) then
            begin
              // **REF11**
              InternalBuildNumber := Win11_24H2_Build;
              InternalWin1011Version := win11v24H2;
              case InternalRevisionNumber of
                1742, 1882, 2033, 2161, 2240, 2314, 2454, 2528, 2605, 2894,
                3037, 3107, 3194, 3323, 3403, 3476, 3624, 3775, 3781, 3981,
                3983, 4061, 4066, 4202, 4270, 4349, 4351, 4484, 4652, 4656,
                4770, 4851, 4946, 5074, 6508, 6584, 6588, 6725, 6899, 6901,
                6905, 7019, 7092, 7171,
                Succ(7309) {after last release preview rev} .. MaxInt:
                  InternalExtraUpdateInfo := 'Version 24H2';
                560, 712, 1297, 1586, 1876, 2152, 2448, 3025, 3321, 3613, 3902,
                3909, 3915, 4188, 4482, 4762, 4767, 5061, 5067, 6713, 6718,
                7015, 7296, 7309:
                  InternalExtraUpdateInfo := Format(
                    'Version 24H2 [Release Preview v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                863, 994, 1000, 1150, 1301, 1457, 1591:
                  InternalExtraUpdateInfo := Format(
                    'Version 24H2 [Release Preview & Copilot+ PCs v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                1:
                  InternalExtraUpdateInfo := Format(
                    'Version 24H2 [Dev & Canary Channel v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                268:
                  InternalExtraUpdateInfo := Format(
                    'Version 24H2 [Dev Channel v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Version 24H2 [Unknown release v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if FindBuildNumberFrom(
              Win11_24H2_DevAndCanaryChannel_Builds, InternalBuildNumber
            ) then
            begin
              // Win11 builds in Canary, Dev & Preview channels with version
              // string "24H2"
              InternalWin1011Version := win10plusUnknown;
              InternalExtraUpdateInfo := Format(
                'Dev or Canary Channel Version 24H2 v10.0.%d.%d',
                [InternalBuildNumber, InternalRevisionNumber]
              );
            end
            else if FindBuildNumberFrom(
              Win11_24H2_CanaryChannel_Builds, InternalBuildNumber
            ) then
            begin
              // Win11 builds in Canary channel with version string "24H2"
              InternalWin1011Version := win10plusUnknown;
              InternalExtraUpdateInfo := Format(
                'Canary Channel Version 24H2 v10.0.%d.%d',
                [InternalBuildNumber, InternalRevisionNumber]
              );
            end
            else if IsBuildNumber(Win11_Oct22Component_BetaChannel_Build) then
            begin
              // **REF2**
              InternalBuildNumber := Win11_Oct22Component_BetaChannel_Build;
              InternalWin1011Version := win10plusUnknown;
              case InternalRevisionNumber of
                290, 436, 440, 450, 575, 586, 590, 598, 601:
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [October Component Update v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Version 22H2 [Unknown release v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if FindBuildNumberFrom(
              Win11_22H2_DevAndBetaChannel_Builds, InternalBuildNumber
            ) then
            begin
              // Win 11 Dev & Beta channel builds with version string "22H2"
              InternalWin1011Version := win10plusUnknown;
              InternalExtraUpdateInfo := Format(
                'Dev & Beta Channels v10.0.%d.%d (22H2)',
                [InternalBuildNumber, InternalRevisionNumber]
              );
            end
            else if IsBuildNumber(Win11_Feb23Component_BetaChannel_Build) then
            begin
              // **REF7**
              InternalBuildNumber := Win11_Feb23Component_BetaChannel_Build;
              InternalWin1011Version := win10plusUnknown;
              case InternalRevisionNumber of
                730, 741, 746, 870, 875, 885, 891, 1020, 1028, 1037, 1095,
                1180, 1245, 1250, 1255, 1325 .. MaxInt:
                  InternalExtraUpdateInfo := Format(
                    'February 2023 Component Update Beta v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'February 2023 Component Update [Unknown Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win11_May23Component_BetaChannel_Build) then
            begin
              // **REF8**
              InternalBuildNumber := Win11_May23Component_BetaChannel_Build;
              InternalWin1011Version := win10plusUnknown;
              case InternalRevisionNumber of
                1391, 1465, 1470, 1537, 1546, 1610, 1616, 1680, 1690, 1755 ..
                MaxInt:
                  InternalExtraUpdateInfo := Format(
                    'May 2023 Component Update Beta v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'May 2023 Component Update [Unknown Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win11_23H2_FutureComponent_Beta_Build) then
            begin
              // **REF9**
              InternalBuildNumber := Win11_23H2_FutureComponent_Beta_Build;
              InternalWin1011Version := win10plusUnknown;
              case InternalRevisionNumber of
                2419, 2483, 2486, 2552, 2700, 2771, 2776, 2841, 2850, 2915,
                2921, 3061, 3066, 3130, 3139, 3140, 3209, 3212, 3276, 3286,
                3350, 3420, 3430, 3495, 3500, 3566, 3570, 3575, 3640, 3646,
                3720, 3785, 3790, 3858, 3930, 3936, 4000, 4005, 4010, 4076,
                4082, 4145, 4225, 4291, 4300, 4367, 4371, 4435, 4440, 4445,
                4510, 4515, 4580, 4655, 4660, 4800, 4805, 4870, 4880, 4945,
                4950, 5015, 5025, 5090, 5097, 5160, 5170, 5235, 5240, 5305
                .. MaxInt:
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update Beta v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update [Unknown Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win11_24H2_FutureComponent_Rel_Build) then
            begin
              // **REF12**
              InternalBuildNumber := Win11_24H2_FutureComponent_Rel_Build;
              InternalWin1011Version := win10plusUnknown;
              case InternalRevisionNumber of
                 461, 470, 670, 751, 770, 961, 1252, 1330, 1340, 1350, 1542,
                 1843, 1912, 1930, 2122, 2130, 2200, 2213, 2222, 2415, 2510,
                 2702, 2705, 2992, 3000:
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update Dev Channel v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                 3073, 3281, 3291, 3360, 3380, 3576:
                  // released with "ge_release" version string
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update Dev & Beta Channels v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                 3585, 3653, 3671, 3863, 3872, 3941, 3950, 3964, 4151, 4161,
                 4230, 4250, 4441, 4452, 4520, 4733, 4741, 5722, 5733, 5742,
                 5751, 5761, 5770, 5790, 6682, 6690, 6760, 6772, 6780, 6972,
                 6982:
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update Beta Channels v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update [Unknown Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win11_24H2_FutureComponent_PreRel_Build) then
            begin
              // **REF13**
              InternalBuildNumber := Win11_24H2_FutureComponent_PreRel_Build;
              InternalWin1011Version := win10plusUnknown;
              case InternalRevisionNumber of
                5510, 5516, 5518, 5551, 5562, 5570, 5581, 5600, 5603, 5622,
                5641, 5651, 5661:
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update Dev Channel v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update [Unknown Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            else if IsBuildNumber(Win11_25H2_FutureComponent_Rel_Build) then
            begin
              // **REF14**
              InternalBuildNumber := Win11_25H2_FutureComponent_Rel_Build;
              InternalWin1011Version := win10plusUnknown;
              case InternalRevisionNumber of
                7051, 7052, 7070, 7262, 7271:
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update Dev & Beta Channels v10.0.%d.%d',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
                else
                  InternalExtraUpdateInfo := Format(
                    'Future Component Update [Unknown Beta v10.0.%d.%d]',
                    [InternalBuildNumber, InternalRevisionNumber]
                  );
              end;
            end
            // End with some much less likely cases
            // NOTE: All the following tests MUST come after the last call to
            //       FindBuildNameAndExtraFrom() for non-server OSs because some
            //       build numbers are common to both sets of tests and the
            //       following rely on FindBuildNameAndExtraFrom() to have
            //       filtered out releases.
            else if FindWin10PreviewBuildNameAndExtraFrom(
              Win10_20H2_Preview_Builds, '20H2',
              InternalBuildNumber, InternalExtraUpdateInfo
            ) then
            begin
              InternalWin1011Version := win10v20H2;
            end
            else if FindWin10PreviewBuildNameAndExtraFrom(
              Win10_2004_Preview_Builds, '2004',
              InternalBuildNumber, InternalExtraUpdateInfo
            ) then
            begin
              InternalWin1011Version := win10v2004;
            end
            else if IsBuildNumber(Win10_1903_Build) then
            begin
              // Build 18362 was used for version 1903 and preview and some
              // version 1909 previews, as follows:
              //   1903 preview - revs 0, 30, 53, 86, 113
              //   1903 release - revs 116..1256
              //   1909 preview - revs 10000, 10005, 10006, 10012, 10014, 10015,
              //                       10019, 10022, 10024
              InternalBuildNumber := Win10_1903_Build;
              if IsInRange(InternalRevisionNumber, 116, 1256) then
              begin
                InternalWin1011Version := win10v1903;
                InternalExtraUpdateInfo := 'Version 1903';
              end
              else if IsInRange(InternalRevisionNumber, 0, 113) then
              begin
                InternalWin1011Version := win10v1903;
                InternalExtraUpdateInfo := Format(
                  'Version 1903 Preview Build %d.%d',
                  [InternalBuildNumber, InternalRevisionNumber]
                )
              end
              else if IsInRange(InternalRevisionNumber, 10000, 10024) then
              begin
                InternalWin1011Version := win10v1909;
                InternalExtraUpdateInfo := Format(
                  'Version 1909 Preview Build %d.%d',
                  [InternalBuildNumber, InternalRevisionNumber]
                );
              end;
            end
            else if FindWin10PreviewBuildNameAndExtraFrom(
              Win10_1903_Preview_Builds, '1903',
              InternalBuildNumber, InternalExtraUpdateInfo
            ) then
            begin
              InternalWin1011Version := win10v1903;
            end
            else if FindWin10PreviewBuildNameAndExtraFrom(
              Win10_1809_Preview_Builds, '1809',
              InternalBuildNumber, InternalExtraUpdateInfo
            ) then
            begin
              InternalWin1011Version := win10v1809;
            end
            else if FindWin10PreviewBuildNameAndExtraFrom(
              Win10_1803_Preview_Builds, '1803',
              InternalBuildNumber, InternalExtraUpdateInfo
            ) then
            begin
              InternalWin1011Version := win10v1803;
            end
            else if FindWin10PreviewBuildNameAndExtraFrom(
              Win10_1709_Preview_Builds, '1709',
              InternalBuildNumber, InternalExtraUpdateInfo
            ) then
            begin
              InternalWin1011Version := win10v1709;
            end
            else if FindWin10PreviewBuildNameAndExtraFrom(
              Win10_1703_Preview_Builds, '1703',
              InternalBuildNumber, InternalExtraUpdateInfo
            ) then
            begin
              InternalWin1011Version := win10v1703;
            end
            else if FindWin10PreviewBuildNameAndExtraFrom(
              Win10_1607_Preview_Builds, '1607',
              InternalBuildNumber, InternalExtraUpdateInfo
            ) then
            begin
              InternalWin1011Version := win10v1607;
            end
          end
          else // Win32ProductType in [VER_NT_DOMAIN_CONTROLLER, VER_NT_SERVER]
          begin
            // Check for the easy-to-handle Win Server v10. builds, i.e. the
            // ones where Extra Update Info is just plain text.
            if FindBuildNameAndExtraFrom(
              WinServerSimpleBuildMap,
              InternalBuildNumber,
              InternalExtraUpdateInfo,
              VersionEx // unused
            ) then
            begin
              // Nothing to do: required internal variables set in function call
            end
            else if FindBuildNumberFrom(
              Win2019_IP_Builds, InternalBuildNumber
            ) then
            begin
              // Windows 2019 Insider preview builds require build number in
              // Extra Update Info.
              InternalExtraUpdateInfo := Format(
                'Insider Preview Build %d', [InternalBuildNumber]
              );
            end
          end;
        end;
      end;
    end;

    // ** If InternalBuildNumber is 0 when we get here then we failed to get it
    //    We no longer look in registry as of SVN commit r2001 (Git commit
    //    d44aea3e6e0ed7bd317398252fcf862051b159f7 in ddablib/sysinfo on
    //    GitHub), because this can get spoofed. E.g. when running on Windows 10
    //    TH2 registry call is returning build number of 7600 even though
    //    regedit reveals it to be 10586 !
    //    So we must now consider a build number of 0 as indicating an unknown
    //    build number.
    //    But note that some users report that their registry is returning
    //    correct value. I really hate Windows!!!
    // ** Seems like more registry spoofing (see above).

  end
  else
  begin
    // Get internal OS version information from SysUtils.Win32XXX routines,
    // which in turn gets it from GetVersion or GetVersionEx API call in
    // SysUtils.
    InternalPlatform := Win32Platform;
    InternalMajorVersion := Win32MajorVersion;
    InternalMinorVersion := Win32MinorVersion;
    InternalBuildNumber := Win32BuildNumber;
    InternalCSDVersion := Win32CSDVersion;
    InternalRevisionNumber := GetOSRevisionNumber(
      InternalPlatform = VER_PLATFORM_WIN32_NT
    );
    // Try to get extended information
    {$IFDEF UNICODE}
    GetVersionEx := LoadKernelFunc('GetVersionExW');
    {$ELSE}
    GetVersionEx := LoadKernelFunc('GetVersionExA');
    {$ENDIF}
    FillChar(OSVI, SizeOf(OSVI), 0);
    OSVI.dwOSVersionInfoSize := SizeOf(TOSVersionInfoEx);
    Win32HaveExInfo := GetVersionEx(OSVI);
    if Win32HaveExInfo then
    begin
      // We have extended info: store details in global vars
      Win32ServicePackMajor := OSVI.wServicePackMajor;
      Win32ServicePackMinor := OSVI.wServicePackMinor;
      Win32SuiteMask := OSVI.wSuiteMask;
      Win32ProductType := OSVI.wProductType;
    end;
  end;

  Win32PlatformEx := InternalPlatform;
  Win32MajorVersionEx := InternalMajorVersion;
  Win32MinorVersionEx := InternalMinorVersion;
  Win32BuildNumberEx := InternalBuildNumber;
  Win32CSDVersionEx := InternalCSDVersion;

  // Try to get product info (API introduced with Windows Vista)
  GetProductInfo := LoadKernelFunc('GetProductInfo');
  Win32HaveProductInfo := Assigned(GetProductInfo);
  if Win32HaveProductInfo then
  begin
    if not GetProductInfo(
      InternalMajorVersion, InternalMinorVersion,
      Win32ServicePackMajor, Win32ServicePackMinor,
      Win32ProductInfo
    ) then
      Win32ProductInfo := PRODUCT_UNDEFINED;
  end
  else
    Win32ProductInfo := PRODUCT_UNDEFINED;

  // Set GetSystemInfoFn to GetNativeSystemInfo() API if available, otherwise
  // use GetSystemInfo().
  GetSystemInfoFn := LoadKernelFunc('GetNativeSystemInfo');
  if not Assigned(GetSystemInfoFn) then
    GetSystemInfoFn := GetSystemInfo;
  GetSystemInfoFn(SI);
  // Get processor architecture
  InternalProcessorArchitecture := SI.wProcessorArchitecture;
  // Store revision number
  Win32RevisionNumber := InternalRevisionNumber;
end;

{ TPJOSInfo }

class function TPJOSInfo.BuildBranch: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE, CurrentVersionRegKeys[IsWinNT], 'BuildBranch'
  );
end;

class function TPJOSInfo.BuildNumber: Integer;
begin
  Result := InternalBuildNumber;
end;

class function TPJOSInfo.CanSpoof: Boolean;
begin
  Result := UseGetVersionAPI;
end;

class function TPJOSInfo.CheckSuite(const Suite: Integer): Boolean;
begin
  Result := Win32SuiteMask and Suite <> 0;
end;

class function TPJOSInfo.DecodedDigitalProductID: string;
begin
  if IsReallyWindows8OrGreater then
    Result := DecodedDigitalProductIDWin8AndUp
  else
    Result := DecodedDigitalProductIDWin7AndDown;
end;

class function TPJOSInfo.DecodedDigitalProductIDWin7AndDown: string;
  {
    This method based on C++ code by Richard MacCutchan, posted by enhzflep on
    CodeProject as Solution 4 at https://tinyurl.com/3n7fbt3h
  }
var
  KeyData: TBytes;    // copy of digital product ID
  KeyBlock: TBytes;   // block of significant key data extracted from KeyData
  I, J: Integer;      // loop indices
  KeyCharIndex: Byte; // index into key character array
  Value: Cardinal;    // temp value used when decoding
const
  // Length & indices of first/last significant bytes of key (contiguous block)
  KeyBlockLength = 16;
  KeyBlockStartIndex = 52;
  KeyBlockEndIndex = KeyBlockStartIndex + KeyBlockLength - 1;
  // Valid product key characters
  ValidKeyChars: array[0..23] of Char = (
    'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'M', 'P', 'Q', 'R',
    'T', 'V', 'W', 'X', 'Y', '2', '3', '4', '6', '7', '8', '9'
  );
  ValidKeyCharCount = Cardinal(Length(ValidKeyChars));
  // Length of decoded product key: stored in Result
  DecodedStringLength = 29;
begin
  // Record and check digital product ID
  KeyData := DigitalProductID;
  // Bail out if we have insufficient key data
  Result := '';
  if Length(KeyData) <= KeyBlockEndIndex then
    Exit;

  // Length of decoded product key: stored in Result
  SetLength(Result, DecodedStringLength);
  FillChar(Result[1], Length(Result), 0);

  // Copy block of bytes to be decoded into an array
  SetLength(KeyBlock, KeyBlockLength);
  for I := KeyBlockStartIndex to KeyBlockEndIndex do
    KeyBlock[I - KeyBlockStartIndex] := KeyData[I];

  // Calculate each character of decoded string and place in Result
  // Since Result is a string, string index I is 1-based
  // Symbols are decoded from last to first
  for I := DecodedStringLength downto 1 do
  begin
    if I mod 6 = 0 then
      // Every 6th character is a seperator
      Result[I] := '-'
    else
    begin
      // Decode the current symbol
      KeyCharIndex := 0;
      for J := Pred(Length(KeyBlock)) downto 0 do
      begin
        Value := (KeyCharIndex shl 8) or KeyBlock[J];
        KeyBlock[J] := Byte(Value div ValidKeyCharCount);
        KeyCharIndex := Value mod ValidKeyCharCount;
      end;
      Result[I] := ValidKeyChars[KeyCharIndex];
    end;
  end;
end;

class function TPJOSInfo.DecodedDigitalProductIDWin8AndUp: string;
  {
    This method based on C# code from WinProdKeyFinder
    Copyright (c) 2020 Pavel Hruska
    MIT license
    https://github.com/mrpeardotnet/WinProdKeyFinder
  }
var
  KeyData: TBytes;    // copy of digital product ID
  IsWin8: Byte;       // bit set if Windows 8
  Cut: Integer;       // point at which key is cut to insert 'N' character
  I, J, K: Integer;   // loop control
  Value: Cardinal;  // temp value used in decoding
const
  // start and end indices of siginificant data in KeyData
  KeyOffset = 52;
  EndKeyIndex = 66;
  // Valid product key characters
  ValidKeyChars: array[0..23] of Char = (
    'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'M', 'P', 'Q', 'R',
    'T', 'V', 'W', 'X', 'Y', '2', '3', '4', '6', '7', '8', '9'
  );
  ValidKeyCharCount = Cardinal(Length(ValidKeyChars));
begin
  Result := '';
  // Record and check digital product ID
  KeyData := DigitalProductID;
  // Bail out if we have insufficient key data
  if Length(KeyData) <= EndKeyIndex then
    Exit;

  // Initialise
  IsWin8 := Byte((KeyData[EndKeyIndex] div 6) and 1);
  KeyData[EndKeyIndex] := Byte(
    (KeyData[EndKeyIndex] and $f7) or (IsWin8 and 2) * 4
  );

  // Do decoding
  for I := ValidKeyCharCount downto 0 do
  begin
    Value := 0;
    for J := 14 downto 0 do
    begin
      Value := KeyData[J + KeyOffset] + 256 * Value;
      KeyData[J + KeyOffset] := Byte(Value div ValidKeyCharCount);
      Value := Value mod ValidKeyCharCount;
      Cut := Value;
    end;
    Result := ValidKeyChars[Value] + Result;
  end;

  // Insert 'N' at cut position
  Result := Copy(Result, 2, Cut) + 'N' + Copy(Result, Cut + 2, MaxInt);

  // Insert separator every 6th character
  K := 6;
  while (K < Length(Result)) do
  begin
    Insert('-', Result, K);
    Inc(K, 6);
  end;
end;

class function TPJOSInfo.Description: string;

  // Adds a non-empty string to end of result, optionally preceded by space.
  procedure AppendToResult(const Str: string; const WantSpace: Boolean = True);
  begin
    if Str <> '' then
    begin
      if WantSpace then
        Result := Result + ' ';
      Result := Result + Str;
    end;
  end;

begin
  // Start with product name
  Result := ProductName;
  case Platform of
    ospWinNT:
    begin
      // We have an NT OS
      // append any product type
      if Product = osWinNT then
      begin
        // For NT3/4 append version number after product
        AppendToResult(Format('%d.%d', [MajorVersion, MinorVersion]));
        AppendToResult(Edition);
        AppendToResult(ServicePackEx);  // does nothing if no service pack
        AppendToResult(Format('(Build %d)', [BuildNumber]));
      end
      else
      begin
        // Windows 2000 and later: don't include version number
        AppendToResult(Edition);
        if (ServicePackEx <> '') then
          AppendToResult(', ' + ServicePackEx, False);
        if InternalRevisionNumber > 0 then
          AppendToResult(
            Format(', Build %d.%d', [BuildNumber, InternalRevisionNumber]),
            False
          )
        else
          AppendToResult(Format(', Build %d', [BuildNumber]), False);
      end;
    end;
    ospWin9x:
      // We have a Win 95 line OS: append service pack
      AppendToResult(ServicePack);
  end;
end;

class function TPJOSInfo.DigitalProductID: TBytes;
begin
  Result := GetRegistryBytes(
    HKEY_LOCAL_MACHINE, CurrentVersionRegKeys[IsWinNT], 'DigitalProductId'
  );
end;

class function TPJOSInfo.Edition: string;
begin
  // This method is based on sample C++ code from MSDN
  Result := '';
  case Product of
    osWinVista, osWinSvr2008,
    osWin7, osWinSvr2008R2,
    osWin8, osWinSvr2012,
    osWin8Point1, osWinSvr2012R2,
    osWin10, osWin11, osWin10Svr, osWinSvr2019, osWinSvr2022, osWinServer,
    osWinSvr2025, osWinSvrLater:
    begin
      // For v6.0 and later we ignore the suite mask and use the new
      // PRODUCT_ flags from the GetProductInfo() function to determine the
      // edition
      // 1st try to find edition name from lookup table
      Result := EditionFromProductInfo;
      if Result = '' then
        // no matching entry in lookup: get from registry
        Result := EditionIDFromReg;
      // append 64-bit if 64 bit system
      if InternalProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64 then
        Result := Result + ' (64-bit)';
      // can detect 32-bit if required by checking if
      // InternalProcessorArchitecture = PROCESSOR_ARCHITECTURE_INTEL
    end;
    osWinSvr2003, osWinSvr2003R2:
    begin
      // We check different processor architectures and act accordingly
      // This code closely based on sample code by Microsoft that is no longer
      // available
      if InternalProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64 then
      begin
        if CheckSuite(VER_SUITE_DATACENTER) then
          Result := 'Datacenter Edition for Itanium-based Systems'
        else if CheckSuite(VER_SUITE_ENTERPRISE) then
          Result := 'Enterprise Edition for Itanium-based Systems';
      end
      else if InternalProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64 then
      begin
        if CheckSuite(VER_SUITE_DATACENTER) then
          Result := 'Datacenter x64 Edition'
        else if CheckSuite(VER_SUITE_ENTERPRISE) then
          Result := 'Enterprise x64 Edition'
        else
          Result := 'Standard x64 Edition';
      end
      else
      begin
        if CheckSuite(VER_SUITE_WH_SERVER) then
          Result := 'Home Server'
        else if CheckSuite(VER_SUITE_COMPUTE_SERVER) then
          Result := 'Compute Cluster Edition'
        else if CheckSuite(VER_SUITE_DATACENTER) then
          Result := 'Datacenter Edition'
        else if CheckSuite(VER_SUITE_BLADE) then
          Result := 'Web Edition'
        else if CheckSuite(VER_SUITE_STORAGE_SERVER) then
          Result := 'Storage Server'
        // According to MSDN we can't rely on VER_SUITE_SMALLBUSINESS since it
        // is not removed when upgrading to standard or enterprises editions.
        // When installing Small Business edition both VER_SUITE_SMALLBUSINESS
        // and VER_SUITE_SMALLBUSINESS_RESTRICTED are set. When installing
        // standard edition VER_SUITE_SMALLBUSINESS_RESTRICTED gets unset while
        // VER_SUITE_SMALLBUSINESS remains. So, we first check for the
        // Enterprise edition and exclude Small Business if we find that.
        // Since there is no flag for Standard Edition we check for both
        // VER_SUITE_SMALLBUSINESS and VER_SUITE_SMALLBUSINESS_RESTRICTED and
        // assume Small Business if we find both, otherwise we assume Standard
        // edition.
        else if CheckSuite(VER_SUITE_ENTERPRISE) then
          Result := 'Enterprise Edition'
        else if CheckSuite(VER_SUITE_SMALLBUSINESS) and
          CheckSuite(VER_SUITE_SMALLBUSINESS_RESTRICTED) then
          Result := 'Small Business Edition'
        else
          Result := 'Standard Edition';
      end;
    end;
    osWinXP:
    begin
      if GetSystemMetrics(SM_STARTER) <> 0 then
        Result := 'Starter Edition'
      else if (InternalMajorVersion = 5) and (InternalMinorVersion = 2) and
        not IsServer and  // XP Pro 64 has version 5.2 not 5.1!
        (InternalProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) then
        Result := 'Professional x64 Edition'
      else if CheckSuite(VER_SUITE_PERSONAL) then
        Result := 'Home Edition'
      else
        Result := 'Professional';
    end;
    osWin2K:
    begin
      if IsServer then
      begin
        if CheckSuite(VER_SUITE_DATACENTER) then
          Result := 'Datacenter Server'
        else if CheckSuite(VER_SUITE_ENTERPRISE) then
          Result := 'Advanced Server'
        else
          Result := 'Server';
      end
      else
        Result := 'Professional';
    end;
    osWinNT:
    begin
      if Win32HaveExInfo then
      begin
        // This is NT SP6 or later: got info from OS
        if IsServer then
        begin
          if CheckSuite(VER_SUITE_ENTERPRISE) then
            Result := 'Enterprise Edition'
          else
            Result := 'Server';
        end
        else
          Result := 'Workstation'
      end
      else
        // NT before SP6: we read required info from registry
        Result := NTEditionFromReg;
    end;
  end;
end;

class function TPJOSInfo.EditionFromProductInfo: string;
var
  Idx: Integer; // loops through entries in cProductMap[]
begin
  Result := '';
  for Idx := Low(cProductMap) to High(cProductMap) do
  begin
    if cProductMap[Idx].Id = Win32ProductInfo then
    begin
      Result := cProductMap[Idx].Name;
      Exit;
    end;
  end;
end;

class function TPJOSInfo.EditionIDFromReg: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE, CurrentVersionRegKeys[IsWinNT], 'EditionID'
  );
end;

class function TPJOSInfo.HasPenExtensions: Boolean;
begin
  Result := GetSystemMetrics(SM_PENWINDOWS) <> 0;
end;

class function TPJOSInfo.InstallationDate: TDateTime;
var
  DateStr: string;
  UnixDate: LongWord;
const
  UnixStartDate: TDateTime = 25569.0; // 1970/01/01
begin
  DateStr := GetRegistryString(
    HKEY_LOCAL_MACHINE, CurrentVersionRegKeys[IsWinNT], 'InstallDate'
  );
  Result := 0.0;
  if DateStr = '' then
    Exit;
  UnixDate := StrToIntDef(DateStr, 0);
  if UnixDate = 0 then
    Exit;
  Result := (UnixDate / 86400) + UnixStartDate
end;

class function TPJOSInfo.IsMediaCenter: Boolean;
begin
  Result := GetSystemMetrics(SM_MEDIACENTER) <> 0;
end;

class function TPJOSInfo.IsNT4SP6a: Boolean;
var
  Reg: TRegistry; // registry access object
begin
  if (Product = osWinNT)
    and (InternalMajorVersion = 4)
    and (CompareText(InternalCSDVersion, 'Service Pack 6') = 0) then
  begin
    // System is reporting NT4 SP6
    // we have SP 6a if particular registry key exists
    Reg := RegCreate;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Result := Reg.KeyExists(
        'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Hotfix\Q246009'
      );
    finally
      Reg.Free;
    end;
  end
  else
    // System not reporting NT4 SP6, so not SP6a!
    Result := False;
end;

class function TPJOSInfo.IsReallyWindows2000OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN2K), LoByte(_WIN32_WINNT_WIN2K), 0
  );
end;

class function TPJOSInfo.IsReallyWindows2000SP1OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN2K), LoByte(_WIN32_WINNT_WIN2K), 1
  );
end;

class function TPJOSInfo.IsReallyWindows2000SP2OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN2K), LoByte(_WIN32_WINNT_WIN2K), 2
  );
end;

class function TPJOSInfo.IsReallyWindows2000SP3OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN2K), LoByte(_WIN32_WINNT_WIN2K), 3
  );
end;

class function TPJOSInfo.IsReallyWindows2000SP4OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN2K), LoByte(_WIN32_WINNT_WIN2K), 4
  );
end;

class function TPJOSInfo.IsReallyWindows7OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN7), LoByte(_WIN32_WINNT_WIN7), 0
  );
end;

class function TPJOSInfo.IsReallyWindows7SP1OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN7), LoByte(_WIN32_WINNT_WIN7), 1
  );
end;

class function TPJOSInfo.IsReallyWindows8OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN8), LoByte(_WIN32_WINNT_WIN8), 0
  );
end;

class function TPJOSInfo.IsReallyWindows8Point1OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WINBLUE), LoByte(_WIN32_WINNT_WINBLUE), 0
  );
end;

class function TPJOSInfo.IsReallyWindows10OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WIN10), LoByte(_WIN32_WINNT_WIN10), 0
  );
end;

class function TPJOSInfo.IsReallyWindowsVersionOrGreater(MajorVersion,
  MinorVersion, ServicePackMajor: Word): Boolean;
begin
  if (MajorVersion >= HiByte(_WIN32_WINNT_WIN2K))
    and Assigned(VerSetConditionMask) and Assigned(VerifyVersionInfo) then
    Result := TestWindowsVersion(
      MajorVersion, MinorVersion, ServicePackMajor, 0, VER_GREATER_EQUAL
    )
  else
    Result := False;
end;

class function TPJOSInfo.IsReallyWindowsVistaOrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_VISTA), LoByte(_WIN32_WINNT_VISTA), 0
  );
end;

class function TPJOSInfo.IsReallyWindowsVistaSP1OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_VISTA), LoByte(_WIN32_WINNT_VISTA), 1
  );
end;

class function TPJOSInfo.IsReallyWindowsVistaSP2OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_VISTA), LoByte(_WIN32_WINNT_VISTA), 2
  );
end;

class function TPJOSInfo.IsReallyWindowsXPOrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WINXP), LoByte(_WIN32_WINNT_WINXP), 0
  );
end;

class function TPJOSInfo.IsReallyWindowsXPSP1OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WINXP), LoByte(_WIN32_WINNT_WINXP), 1
  );
end;

class function TPJOSInfo.IsReallyWindowsXPSP2OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WINXP), LoByte(_WIN32_WINNT_WINXP), 2
  );
end;

class function TPJOSInfo.IsReallyWindowsXPSP3OrGreater: Boolean;
begin
  Result := IsReallyWindowsVersionOrGreater(
    HiByte(_WIN32_WINNT_WINXP), LoByte(_WIN32_WINNT_WINXP), 3
  );
end;

class function TPJOSInfo.IsRemoteSession: Boolean;
begin
  Result := GetSystemMetrics(SM_REMOTESESSION) <> 0;
end;

class function TPJOSInfo.IsServer: Boolean;
begin
  if InternalPlatform <> VER_PLATFORM_WIN32_NT then
    // Not WinNT platform => can't be a server
    Result := False
  else if Win32HaveExInfo then
    // Check product type from extended OS info
    Result := (Win32ProductType = VER_NT_DOMAIN_CONTROLLER)
      or (Win32ProductType = VER_NT_SERVER)
  else
    // Check product type stored in registry
    Result := CompareText(ProductTypeFromReg, 'WINNT') <> 0;;
end;

class function TPJOSInfo.IsTabletPC: Boolean;
begin
  Result := GetSystemMetrics(SM_TABLETPC) <> 0;
end;

class function TPJOSInfo.IsWin32s: Boolean;
begin
  Result := Platform = ospWin32s;
end;

class function TPJOSInfo.IsWin9x: Boolean;
begin
  Result := Platform = ospWin9x;
end;

class function TPJOSInfo.IsWindows10PlusVersionOrLater(
  const AVersion: TPJWin10PlusVersion): Boolean;
begin
  Assert(not (AVersion in [win10plusNA, win10plusUnknown]));
  Result := IsReallyWindows10OrGreater and (Windows10PlusVersion >= AVersion);
end;

class function TPJOSInfo.IsWindows10VersionOrLater(
  const AVersion: TPJWin10PlusVersion): Boolean;
begin
  if not (AVersion in Win10_Versions) then
    raise EPJSysInfo.Create('Invalid Windows 10 version: can''t compare');
  Result := IsWindows10PlusVersionOrLater(AVersion);
end;

class function TPJOSInfo.IsWindows11VersionOrLater(
  const AVersion: TPJWin10PlusVersion): Boolean;
begin
  if not (AVersion in Win11_Versions) then
    raise EPJSysInfo.Create('Invalid Windows 11 version: can''t compare');
  Result := IsWindows10PlusVersionOrLater(AVersion);
end;

class function TPJOSInfo.IsWindowsServer: Boolean;
var
  OSVI: TOSVersionInfoEx;
  ConditionMask: UInt64;
begin
  if Assigned(VerSetConditionMask) and Assigned(VerifyVersionInfo) then
  begin
    FillChar(OSVI, SizeOf(OSVI), 0);
    OSVI.dwOSVersionInfoSize := SizeOf(OSVI);
    OSVI.wProductType := VER_NT_WORKSTATION;
    ConditionMask := VerSetConditionMask(0, VER_PRODUCT_TYPE, VER_EQUAL);
    Result := not VerifyVersionInfo(@OSVI, VER_PRODUCT_TYPE, ConditionMask);
  end
  else
    Result := IsServer;
end;

class function TPJOSInfo.IsWinNT: Boolean;
begin
  Result := Platform = ospWinNT;
end;

class function TPJOSInfo.IsWow64: Boolean;
type
  TIsWow64Process = function( // Type of IsWow64Process API fn
    Handle: THandle;
    var Res: BOOL
  ): BOOL; stdcall;
var
  IsWow64Result: BOOL;              // result from IsWow64Process
  IsWow64Process: TIsWow64Process;  // IsWow64Process fn reference
begin
  // Try to load required function from kernel32
  IsWow64Process := LoadKernelFunc('IsWow64Process');
  if Assigned(IsWow64Process) then
  begin
    // Function is implemented: call it
    if not IsWow64Process(GetCurrentProcess, IsWow64Result) then
      raise Exception.Create(sBadProcHandle);
    // Return result of function
    Result := IsWow64Result;
  end
  else
    // Function not implemented: can't be running on Wow64
    Result := False;
end;

class function TPJOSInfo.MajorVersion: Integer;
begin
  Result := InternalMajorVersion;
end;

class function TPJOSInfo.MinorVersion: Integer;
begin
  Result := InternalMinorVersion;
end;

class function TPJOSInfo.NTEditionFromReg: string;
var
  EditionCode: string;  // OS product edition code stored in registry
begin
  EditionCode := ProductTypeFromReg;
  if CompareText(EditionCode, 'WINNT') = 0 then
    Result := 'WorkStation'
  else if CompareText(EditionCode, 'LANMANNT') = 0 then
    Result := 'Server'
  else if CompareText(EditionCode, 'SERVERNT') = 0 then
    Result := 'Advanced Server';
  Result := Result + Format(
    ' %d.%d', [InternalMajorVersion, InternalMinorVersion]
  );
end;

class function TPJOSInfo.Platform: TPJOSPlatform;
begin
  case InternalPlatform of
    VER_PLATFORM_WIN32_NT: Result := ospWinNT;
    VER_PLATFORM_WIN32_WINDOWS: Result := ospWin9x;
    VER_PLATFORM_WIN32s: Result := ospWin32s;
    else raise EPJSysInfo.Create(sUnknownPlatform);
  end;
end;

class function TPJOSInfo.Product: TPJOSProduct;
begin
  Result := osUnknown;
  case Platform of
    ospWin9x:
    begin
      // Win 9x platform: only major version is 4
      Result := osUnknownWin9x;
      case InternalMajorVersion of
        4:
        begin
          case InternalMinorVersion of
            0: Result := osWin95;
            10: Result := osWin98;
            90: Result := osWinMe;
          end;
        end;
      end;
    end;
    ospWinNT:
    begin
      // NT platform OS
      Result := osUnknownWinNT;
      case InternalMajorVersion of
        3, 4:
        begin
          // NT 3 or 4
          case InternalMinorVersion of
            0: Result := osWinNT;
          end;
        end;
        5:
        begin
          // Windows 2000 or XP
          case InternalMinorVersion of
            0:
              Result := osWin2K;
            1:
              Result := osWinXP;
            2:
            begin
              if GetSystemMetrics(SM_SERVERR2) <> 0 then
                Result := osWinSvr2003R2
              else
              begin
                if not IsServer and
                  (InternalProcessorArchitecture
                    = PROCESSOR_ARCHITECTURE_AMD64) then
                  Result := osWinXP // XP Pro X64
                else
                  Result := osWinSvr2003
              end
            end;
          end;
        end;
        6:
        begin
          case InternalMinorVersion of
            0:
              if not IsServer then
                Result := osWinVista
              else
                Result := osWinSvr2008;
            1:
              if not IsServer then
                Result := osWin7
              else
                Result := osWinSvr2008R2;
            2:
              if not IsServer then
                Result := osWin8
              else
                Result := osWinSvr2012;
            3:
              // NOTE: Version 6.3 may only be reported by Windows if the
              // application is "manifested" for Windows 8.1. See
              // https://tinyurl.com/2s384ha4. Getting the OS via
              // VerifyVersionInfo instead of GetVersion or GetVersionEx should
              // work round this for Windows 8.1 (i.e. version 6.3).
              if not IsServer then
                Result := osWin8Point1
              else
                Result := osWinSvr2012R2;
            4:
              if IsServer then
                // Version 6.4 was used for Windows 2016 server tech preview 1.
                // This version *may* only be detected by Windows if the
                // application is "manifested" for the correct Windows version.
                // See https://bit.ly/MJSO8Q.
                Result := osWin10Svr
                // Version 6.4 was also used for some early Windows 10 preview
                // builds, but they have all expired so detection has been
                // removed.
                // See https://tinyurl.com/3c8e3hsc
            else
              // Higher minor version: must be an unknown later OS
              Result := osWinLater
          end;
        end;
        10:
        begin
          // NOTE: Version 10 and later may only be reported by Windows if the
          // application is "manifested" for the correct Windows version. See
          // https://bit.ly/MJSO8Q. Previously, getting the OS from
          // VerifyVersionInfo instead of GetVersion or GetVersionEx worked
          // round this, but MS deprecated this in Windows 10, reverting
          // VerifyVersionInfo to work like GetVersion. WHY????!!!!
          case InternalMinorVersion of
            0:
              if not IsServer then
              begin
                if TestBuildNumber(VER_LESS, Win11_First_Build) then
                  Result := osWin10
                else
                  // ** As of 2021-10-05 Win 11 is reporting version 10.0!
                  Result := osWin11;
              end
              else
              begin
                if TestBuildNumber(
                  VER_LESS_EQUAL, Win2016_Last_Build
                ) then
                  Result := osWin10Svr
                else if TestBuildNumber(
                  VER_LESS_EQUAL, Win2019_Last_Build
                ) then
                  Result := osWinSvr2019
                else if TestBuildNumber(
                  VER_LESS_EQUAL, WinServer_Last_Build
                ) then
                  Result := osWinServer
                else if TestBuildNumber(
                  VER_EQUAL, Win2022_Build
                ) then
                  Result := osWinSvr2022
                else if TestBuildNumber(
                  VER_EQUAL, Win2025_Build
                ) then
                  Result := osWinSvr2025
                else
                  Result := osWinSvrLater
              end;
          end;
        end;
        else
          // Higher major version: must be an unknown later OS
          Result := osWinLater;
      end;
    end;
    ospWin32s:
      // Windows 32s: probably won't ever get this
      Result := osUnknownWin32s;
  end;
end;

class function TPJOSInfo.ProductID: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE, CurrentVersionRegKeys[IsWinNT], 'ProductID'
  );
end;

class function TPJOSInfo.ProductName: string;
begin
  case Product of
    osUnknown, osUnknownWinNT, osUnknownWin9x, osUnknownWin32s: Result := '';
    osWinNT: Result := 'Windows NT';
    osWin2K: Result := 'Windows 2000';
    osWinXP: Result := 'Windows XP';
    osWinVista: Result := 'Windows Vista';
    osWinSvr2008: Result := 'Windows Server 2008';
    osWin95: Result := 'Windows 95';
    osWin98: Result := 'Windows 98';
    osWinMe: Result := 'Windows Me';
    osWinSvr2003: Result := 'Windows Server 2003';
    osWinSvr2003R2: Result := 'Windows Server 2003 R2';
    osWinLater: Result := Format(
      'Windows Version %d.%d', [InternalMajorVersion, InternalMinorVersion]
    );
    osWin7: Result := 'Windows 7';
    osWinSvr2008R2: Result := 'Windows Server 2008 R2';
    osWin8: Result := 'Windows 8';
    osWinSvr2012: Result := 'Windows Server 2012';
    osWin8Point1: Result := 'Windows 8.1';
    osWinSvr2012R2: Result := 'Windows Server 2012 R2';
    osWin10: Result := 'Windows 10';
    osWin10Svr: Result := 'Windows Server 2016';
    osWinSvr2019: Result := 'Windows Server 2019';
    osWin11: Result := 'Windows 11';
    osWinSvr2022: Result := 'Windows Server 2022';
    osWinServer: Result := 'Windows Server';
    osWinSvr2025: Result := 'Windows Server 2025';
    osWinSvrLater: Result := Format(
      'Windows Server Version %d.%d.%d.%d',
      [
        InternalMajorVersion, InternalMinorVersion,
        InternalBuildNumber, InternalRevisionNumber
      ]
    );
    else
      raise EPJSysInfo.Create(sUnknownProduct);
  end;
end;

class function TPJOSInfo.ProductTypeFromReg: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\ProductOptions',
    'ProductType'
  );
end;

class function TPJOSInfo.RegisteredOrganisation: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE, CurrentVersionRegKeys[IsWinNT], 'RegisteredOrganization'
  );
end;

class function TPJOSInfo.RegisteredOwner: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE, CurrentVersionRegKeys[IsWinNT], 'RegisteredOwner'
  );
end;

class function TPJOSInfo.RevisionNumber: Integer;
begin
  Result := InternalRevisionNumber;
end;

class function TPJOSInfo.ServicePack: string;
begin
  // Assume no service pack
  Result := '';
  case Platform of
    ospWin9x:
      // On the Windows 9x platform we decode the service pack info
      if InternalCSDVersion <> '' then
      begin
        case Product of
          osWin95:
            {$IFDEF UNICODE}
            if CharInSet(InternalCSDVersion[1], ['B', 'b', 'C', 'c']) then
            {$ELSE}
            if InternalCSDVersion[1] in ['B', 'b', 'C', 'c'] then
            {$ENDIF}
              Result := 'OSR2';
          osWin98:
            {$IFDEF UNICODE}
            if CharInSet(InternalCSDVersion[1], ['A', 'a']) then
            {$ELSE}
            if InternalCSDVersion[1] in ['A', 'a'] then
            {$ENDIF}
              Result := 'SE';
        end;
      end;
    ospWinNT:
      // On Windows NT we return service pack string, unless NT4 SP6 when we
      // need to check whether actually SP6 or SP6a
      if IsNT4SP6a then
        Result := 'Service Pack 6a' // do not localize
      else
        Result := InternalCSDVersion;
  end;
end;

class function TPJOSInfo.ServicePackEx: string;
begin
  Result := ServicePack;
  if Result = '' then
    Result := InternalExtraUpdateInfo
  else
    Result := Result + ', ' + InternalExtraUpdateInfo;
end;

class function TPJOSInfo.ServicePackMajor: Integer;
begin
  Result := Win32ServicePackMajor;
end;

class function TPJOSInfo.ServicePackMinor: Integer;
begin
  Result := Win32ServicePackMinor;
end;

class function TPJOSInfo.Windows10PlusVersion: TPJWin10PlusVersion;
begin
  Result := InternalWin1011Version;
end;

class function TPJOSInfo.Windows10PlusVersionName: string;
const
  cVersions: array[TPJWin10PlusVersion] of string = (
    // Not windows 10+
    '',
    // Windows 10+ with unknown version string
    'Unknown',
    // Windows 10
    '1507', '1511', '1607', '1703', '1709',
    '1803', '1809', '1903', '1909', '2004',
    '20H2', '21H1', '21H2', '22H2',
    // Windows 11
    '21H2', '22H2', '23H2', '24H2'
  );
begin
  Result := cVersions[Windows10PlusVersion];
end;

{ TPJComputerInfo }

class function TPJComputerInfo.BiosVendor: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE,
    'HARDWARE\DESCRIPTION\System\Bios\',
    'BIOSVendor'
  );
end;

class function TPJComputerInfo.BootMode: TPJBootMode;
begin
  case GetSystemMetrics(SM_CLEANBOOT) of
    0: Result := bmNormal;
    1: Result := bmSafeMode;
    2: Result := bmSafeModeNetwork;
    else Result := bmUnknown;
  end;
end;

class function TPJComputerInfo.ComputerName: string;
var
  PComputerName:  // buffer for name returned from API
    array[0..MAX_COMPUTERNAME_LENGTH] of Char;
  Size: DWORD;    // size of name buffer
begin
  Size := MAX_COMPUTERNAME_LENGTH;
  if GetComputerName(PComputerName, Size) then
    Result := PComputerName
  else
    Result := '';
end;

class function TPJComputerInfo.Is64Bit: Boolean;
begin
  Result := Processor in [paX64, paIA64];
end;

class function TPJComputerInfo.IsAdmin: Boolean;
const
  // SID related constants
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;
var
  AccessToken: THandle;           // process access token
  TokenGroupsInfo: PTokenGroups;  // token groups
  InfoBufferSize: DWORD;          // token info buffer size
  AdmininstratorsSID: PSID;       // administrators SID
  I: Integer;                     // loops thru token groups
  Success: BOOL;                  // API function success results
begin
  if not TPJOSInfo.IsWinNT then
  begin
    // Admin mode is a foreign concept to Windows 9x - everyone is an admin
    Result := True;
    Exit;
  end;
  Result := False;
  Success := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, AccessToken);
  if not Success then
  begin
    if GetLastError = ERROR_NO_TOKEN then
      Success := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, AccessToken);
  end;
  if Success then
  begin
    GetMem(TokenGroupsInfo, 1024);
    Success := GetTokenInformation(
      AccessToken, TokenGroups, TokenGroupsInfo, 1024, InfoBufferSize
    );
    CloseHandle(AccessToken);
    if Success then
    begin
      AllocateAndInitializeSid(
        SECURITY_NT_AUTHORITY, 2, SECURITY_BUILTIN_DOMAIN_RID,
        DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, AdmininstratorsSID
      );
      {$IFOPT R+}
        {$DEFINE RANGECHECKSWEREON}
        {$R-}
      {$ELSE}
        {$UNDEF RANGECHECKSWEREON}
      {$ENDIF}
      for I := 0 to TokenGroupsInfo.GroupCount - 1 do
        if EqualSid(AdmininstratorsSID, TokenGroupsInfo.Groups[I].Sid) then
        begin
          Result := True;
          Break;
        end;
      {$IFDEF RANGECHECKSWEREON}
        {$R+}
      {$ENDIF}
      FreeSid(AdmininstratorsSID);
    end;
    if Assigned(TokenGroupsInfo) then
      FreeMem(TokenGroupsInfo);
  end;
end;

class function TPJComputerInfo.IsNetworkPresent: Boolean;
begin
  Result := GetSystemMetrics(SM_NETWORK) and 1 = 1;
end;

class function TPJComputerInfo.IsUACActive: Boolean;
var
  Reg: TRegistry;   // registry access object
begin
  Result := False;
  if not TPJOSInfo.IsWinNT or (TPJOSInfo.MajorVersion < 6) then
    // UAC only available on Vista or later
    Exit;
  Reg := RegCreate;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if RegOpenKeyReadOnly(
      Reg, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    ) then
      Result := Reg.ValueExists('EnableLUA') and Reg.ReadBool('EnableLUA');
  finally
    Reg.Free;
  end;
end;

class function TPJComputerInfo.MACAddress: string;
type
  // Based on former MSDN knowledge base article Q118623.
  // According to MSDN this method should fail on Windows 6.0 (Vista) and later.
  // It has been known to fail on Vista, but works on Vista Home Premium SP1!
  // It would seem that the call will succeed if there's an active network with
  // Netbios over TCP enabled.
  // Again according to Microsoft, the function is unreliable on Windows 95, 98
  // and Me.

  // This type is defined in MSDN sample code, but tests have found this is
  // not needed (on XP Pro) and Adapter can be of type TAdapterStatus. This
  // method uses the type in case other OSs require it
  TAStat = packed record
    Adapt: TAdapterStatus;
    NameBuff: array [0..29] of TNameBuffer;
  end;
var
  Adapter: TAStat;          // info about a network adapter
  AdapterList: TLanaEnum;   // numbers for current LAN adapters
  Ncb: TNCB;                // network control block descriptor
  I: Integer;               // loops thru all adapters in list

  // Examines given NetBios API call return value to check if call succeeded.
  function NetBiosSucceeded(const RetCode: AnsiChar): Boolean;
  begin
    Result := UCHAR(RetCode) = NRC_GOODRET;
  end;

begin
  // Assume not adapter
  Result := '';
  // Get list of adapters
  FillChar(Ncb, SizeOf(Ncb), 0);
  Ncb.ncb_command := AnsiChar(NCBENUM);
  Ncb.ncb_buffer := PAnsiChar(@AdapterList);
  Ncb.ncb_length := SizeOf(AdapterList);
  if not NetBiosSucceeded(Netbios(@Ncb)) then
    Exit;
  // Get status of each adapter, exiting when first valid one reached
  // MSDN cautions us not to assume lana[0] is valid
  for I := 0 to Pred(Integer(AdapterList.length)) do
  begin
    // reset the adapter
    FillChar(Ncb, SizeOf(Ncb), 0);
    Ncb.ncb_command := AnsiChar(NCBRESET);
    Ncb.ncb_lana_num := AdapterList.lana[I];
    if not NetBiosSucceeded(Netbios(@Ncb)) then
      Exit;
    // get status of adapter
    FillChar(Ncb, SizeOf(Ncb), 0);
    Ncb.ncb_command := AnsiChar(NCBASTAT);
    Ncb.ncb_lana_num := AdapterList.lana[i];
    Ncb.ncb_callname := '*               ';
    Ncb.ncb_buffer := PAnsiChar(@Adapter);
    Ncb.ncb_length := SizeOf(Adapter);
    if NetBiosSucceeded(Netbios(@Ncb)) then
    begin
      // we have a MAC address: return it
      Result := Format(
        '%.2x-%.2x-%.2x-%.2x-%.2x-%.2x',
        [
          Ord(Adapter.Adapt.adapter_address[0]),
          Ord(Adapter.Adapt.adapter_address[1]),
          Ord(Adapter.Adapt.adapter_address[2]),
          Ord(Adapter.Adapt.adapter_address[3]),
          Ord(Adapter.Adapt.adapter_address[4]),
          Ord(Adapter.Adapt.adapter_address[5])
        ]
      );
      Exit;
    end;
  end;
end;

class function TPJComputerInfo.Processor: TPJProcessorArchitecture;
begin
  case InternalProcessorArchitecture of
    PROCESSOR_ARCHITECTURE_INTEL: Result := paX86;
    PROCESSOR_ARCHITECTURE_AMD64: Result := paX64;
    PROCESSOR_ARCHITECTURE_IA64:  Result := paIA64;
    else Result := paUnknown;
  end;
end;

class function TPJComputerInfo.ProcessorCount: Cardinal;
var
  SI: TSystemInfo;  // contains system information
begin
  GetSystemInfoFn(SI);
  Result := SI.dwNumberOfProcessors;
end;

class function TPJComputerInfo.ProcessorIdentifier: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE,
    'HARDWARE\DESCRIPTION\System\CentralProcessor\0\',
    'Identifier'
  );
end;

class function TPJComputerInfo.ProcessorName: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE,
    'HARDWARE\DESCRIPTION\System\CentralProcessor\0\',
    'ProcessorNameString'
  );
end;

class function TPJComputerInfo.ProcessorSpeedMHz: Cardinal;
begin
  Result := Cardinal(
    GetRegistryInt(
      HKEY_LOCAL_MACHINE,
      'HARDWARE\DESCRIPTION\System\CentralProcessor\0\',
      '~MHz'
    )
  );
end;

class function TPJComputerInfo.SystemManufacturer: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE,
    'HARDWARE\DESCRIPTION\System\Bios\',
    'SystemManufacturer'
  );
end;

class function TPJComputerInfo.SystemProductName: string;
begin
  Result := GetRegistryString(
    HKEY_LOCAL_MACHINE,
    'HARDWARE\DESCRIPTION\System\Bios\',
    'SystemProductName'
  );
end;

class function TPJComputerInfo.UserName: string;
const
  UNLEN = 256;  // max size of user name buffer (per MS SDK docs)
var
  PUserName: array[0..UNLEN] of Char; // buffer for name returned from API
  Size: DWORD;                        // size of name buffer
begin
  Size := UNLEN;
  if GetUserName(PUserName, Size) then
    Result := PUserName
  else
    Result := '';
end;

{ TPJSystemFolders }

class function TPJSystemFolders.CommonFiles: string;
begin
  Result :=  ExcludeTrailingPathDelimiter(
    GetCurrentVersionRegStr('CommonFilesDir')
  );
end;

class function TPJSystemFolders.CommonFilesRedirect: string;
begin
  Result := GetEnvVar('COMMONPROGRAMFILES');
end;

class function TPJSystemFolders.CommonFilesX86: string;
begin
  Result :=  ExcludeTrailingPathDelimiter(
    GetCurrentVersionRegStr('CommonFilesDir (x86)')
  );
end;

class function TPJSystemFolders.ProgramFiles: string;
begin
  Result :=  ExcludeTrailingPathDelimiter(
    GetCurrentVersionRegStr('ProgramFilesDir')
  );
end;

class function TPJSystemFolders.ProgramFilesRedirect: string;
begin
  Result := GetEnvVar('PROGRAMFILES');
end;

class function TPJSystemFolders.ProgramFilesX86: string;
begin
  Result :=  ExcludeTrailingPathDelimiter(
    GetCurrentVersionRegStr('ProgramFilesDir (x86)')
  );
end;

class function TPJSystemFolders.System: string;
var
  PFolder: array[0..MAX_PATH] of Char;  // buffer to hold name returned from API
begin
  if GetSystemDirectory(PFolder, MAX_PATH) <> 0 then
    Result := ExcludeTrailingPathDelimiter(PFolder)
  else
    Result := '';
end;

class function TPJSystemFolders.SystemWow64: string;
type
  // type of GetSystemWow64DirectoryFn API function
  TGetSystemWow64Directory = function(lpBuffer: PChar; uSize: UINT): UINT;
    stdcall;
var
  PFolder: array[0..MAX_PATH] of Char;  // buffer to hold name returned from API
  GetSystemWow64Directory: TGetSystemWow64Directory;  // API function
begin
  Result := '';
  {$IFDEF UNICODE}
  GetSystemWow64Directory := LoadKernelFunc('GetSystemWow64DirectoryW');
  {$ELSE}
  GetSystemWow64Directory := LoadKernelFunc('GetSystemWow64DirectoryA');
  {$ENDIF}
  if not Assigned(GetSystemWow64Directory) then
    Exit;
  if GetSystemWow64Directory(PFolder, MAX_PATH) <> 0 then
    Result := ExcludeTrailingPathDelimiter(PFolder);
end;

class function TPJSystemFolders.Temp: string;
var
  PathBuf: array[0..MAX_PATH] of Char;  // buffer to hold name returned from API
begin
  if GetTempPath(MAX_PATH, PathBuf) <> 0 then
    Result := ExcludeTrailingPathDelimiter(PathBuf)
  else
    Result := '';
end;

class function TPJSystemFolders.Windows: string;
var
  PFolder: array[0..MAX_PATH] of Char;  // buffer to hold name returned from API
begin
  if GetWindowsDirectory(PFolder, MAX_PATH) <> 0 then
    Result := ExcludeTrailingPathDelimiter(PFolder)
  else
    Result := '';
end;

{ TPJBiosInfo }

function TPJBiosInfo.BiosECFirmwareVersion: Word;
var
  StructPtr: PByte;
  PMajor, PMinor: PByte;
begin
  Result := 0;
  StructPtr := FindStruct(0);
  if not Assigned(StructPtr) or (SMBiosSpecVersion < $0204) then
    Exit;
  PMajor := StructPtr + $16;
  PMinor := StructPtr + $17;
  Result := PMajor^ shl 8 + PMinor^;
end;

function TPJBiosInfo.BiosReleaseDate: TDate;
var
  USADateStr: string;
  D, M, Y: Integer;
  DStr, MStr, YStr: string;
  SepPos: Integer;
  Res: TDateTime;
begin
  USADateStr := Trim(BiosReleaseDateInvariant);
  Result := 0.0;
  if USADateStr = '' then
    Exit;
  SepPos := Pos('/', USADateStr);
  if SepPos = 0 then
    Exit;
  MStr := Copy(USADateStr, 1, SepPos - 1);
  USADateStr := Copy(USADateStr, SepPos + 1, $FF);
  SepPos := Pos('/', USADateStr);
  if SepPos = 0 then
    Exit;
  DStr := Copy(USADateStr, 1, SepPos - 1);
  YStr := Copy(USADateStr, SepPos + 1, $FF);
  if Length(YStr) = 2 then
    YStr := '19' + YStr;
  if (Length(MStr) > 2) or (Length(DStr) > 2) or (Length(YStr) <> 4) then
    Exit;
  if not TryStrToInt(DStr, D) or not TryStrToInt(MStr, M)
    or not TryStrToInt(YStr, Y) then
    Exit;
  if TryEncodeDate(Word(Y), Word(M), Word(D), Res) then
    Result := Res;
end;

function TPJBiosInfo.BiosReleaseDateInvariant: string;
begin
  Result := GetString(0, $08, $0200);
end;

function TPJBiosInfo.BiosVendor: string;
begin
  Result := GetString(0, $04, $0200);
end;

function TPJBiosInfo.BiosVersion: Word;
var
  StructPtr: PByte;
  PMajor, PMinor: PByte;
begin
  Result := 0;
  StructPtr := FindStruct(0);
  if not Assigned(StructPtr) or (SMBiosSpecVersion < $0204) then
    Exit;
  PMajor := StructPtr + $14;
  PMinor := StructPtr + $15;
  Result := PMajor^ shl 8 + PMinor^;
end;

function TPJBiosInfo.BiosVersionStr: string;
begin
  Result := GetString(0, $05, $0200);
end;

constructor TPJBiosInfo.Create;
begin
  inherited Create;
  if not LoadData then
    FreeData;
end;

destructor TPJBiosInfo.Destroy;
begin
  FreeData;
  inherited;
end;

function TPJBiosInfo.FindStruct(const StructType: Byte): PByte;
var
  NextStructPtr: PByte;
  StructHeader: PSMBiosStructureHeader;
  I: Cardinal;
begin
  Result := nil;
  if not IsBiosSupported then
    Exit;

  // Scan through table data, looking for system information structure (type 1)
  NextStructPtr := @(fData^.Data[0]);
  for I := 0 to Pred(fData^.Length) do
  begin
    StructHeader := PSMBiosStructureHeader(NextStructPtr);
    if StructHeader^.Kind = StructType then
    begin
      Result := NextStructPtr;
      Exit;
    end;
    Inc(NextStructPtr, StructHeader^.Length);
    while PWord(NextStructPtr)^ <> 0 do
      Inc(NextStructPtr);
    Inc(NextStructPtr, 2);
  end;
end;

procedure TPJBiosInfo.FreeData;
begin
  if Assigned(fData) then
    FreeMem(fData, fDataSize);
  fData := nil;
  fDataSize := 0;
end;

function TPJBiosInfo.GetString(const StructType, Offset: Byte;
  const MinVer: Word): string;
var
  StructPtr: PByte;
  StructHeader: PSMBiosStructureHeader;
  StrIdx: Byte;
  StrPtr: PAnsiChar;
  {$IFDEF UNICODE}
  RawResult: RawByteString;
  {$ELSE}
  RawResult: AnsiString;
  {$ENDIF}
begin
  Result := '';
  if Offset = 0 then
    Exit;
  if SMBiosSpecVersion < MinVer then
    Exit;
  StructPtr := FindStruct(StructType);
  if not Assigned(StructPtr) then
    Exit;
  StructHeader := PSMBiosStructureHeader(StructPtr);
  // Get the 1-based index of the string in system information structure
  StrIdx := (StructPtr + Offset)^;
  // Find start of required string in system info structure
  StrPtr := PAnsiChar(StructHeader);
  Inc(StrPtr, StructHeader^.Length);  // *** assumes SizeOf(StrPtr^) = 1
  // Skip over preceeding strings strings in the structure
  while (StrIdx > 1) and (StrPtr^ <> #0) do
  begin
    Inc(
      StrPtr,
      {$IFDEF STRLENDEPRECATED}
      System.AnsiStrings.StrLen(StrPtr)
      {$ELSE}
      StrLen(StrPtr)
      {$ENDIF}
    );
    Inc(StrPtr);
    Dec(StrIdx);
  end;
  // Build required string from the zero terminated character sequence
  // According to the SMBIOS specification strings are UTF-8 with no BOM
  // On compilers that support Unicode we treat RawResult as a string of UTF-8
  // characters and convert to the resulting UnicodeString, otherwise we simply
  // return the string as an ANSI string & hope for the best!
  RawResult := '';
  while StrPtr^ <> #0 do
  begin
    RawResult := RawResult + StrPtr^;
    Inc(StrPtr);
  end;
  {$IFDEF UNICODE}
  Result := UTF8ToUnicodeString(RawResult);
  {$ELSE}
  Result := RawResult;
  {$ENDIF}
end;

function TPJBiosInfo.IsBiosSupported: Boolean;
begin
  Result := Assigned(fData) and (fDataSize > 0)
    and (SMBiosSpecVersion >= SMBiosMinVersion);
end;

function TPJBiosInfo.LoadData: Boolean;
type
  TGetSystemFirmwareTable = function(FirmwareTableProviderSignature: DWORD;
    FirmwareTableID: DWORD; pFirmwareTableBuffer: PVOID; BufferSize: DWORD):
    UInt; stdcall;
const
  RSMB: DWORD = (Ord('R') shl 24) or (Ord('S') shl 16) or (Ord('M') shl 8)
    or Ord('B');
  // Fixed fields of
  SMBiosFixedFieldSize = SizeOf(fData^) - SizeOf(fData^.Data);
var
  GetSystemFirmwareTable: TGetSystemFirmwareTable;
begin
  Result := False;
  fData := nil;
  fDataSize := 0;
  GetSystemFirmwareTable := LoadKernelFunc('GetSystemFirmwareTable');
  if not Assigned(GetSystemFirmwareTable) then
    Exit;
  fDataSize := GetSystemFirmwareTable(RSMB, 0, nil, 0);
  if fDataSize = 0 then
    Exit;
  fData := AllocMem(fDataSize);
  if GetSystemFirmwareTable(RSMB, 0, fData, fDataSize) = 0 then
    Exit;
  if fData^.Length <> fDataSize - SMBiosFixedFieldSize then
    Exit;
  Result := True;
end;

function TPJBiosInfo.SMBiosSpecVersion: Word;
begin
  if Assigned(fData) and (fDataSize >= SizeOf(fData) - SizeOf(fData^.Data)) then
    Result := fData.MajorVersion shl 8 + fData.MinorVersion
  else
    Result := 0;
end;

function TPJBiosInfo.SystemFamily: string;
begin
  Result := GetString(1, $1A, $0204);
end;

function TPJBiosInfo.SystemManufacturer: string;
begin
  Result := GetString(1, $04, $0200);
end;

function TPJBiosInfo.SystemOEMVersion: string;
begin
  Result := GetString(1, $6, $0200);
end;

function TPJBiosInfo.SystemProductName: string;
begin
  Result := GetString(1, $05, $0200);
end;

function TPJBiosInfo.SystemSerialNumber: string;
begin
  Result := GetString(1, $07, $0200);
end;

function TPJBiosInfo.SystemSKUNumber: string;
begin
  Result := GetString(1, $19, $0204);
end;

function TPJBiosInfo.SystemUuid: TGUID;
var
  ResBytes: TBytes;
begin
  ZeroMemory(@Result, SizeOf(Result));
  if not IsBiosSupported or (SMBiosSpecVersion < UuidSupportMinVersion) then
    Exit;
  ResBytes := SystemUuidRaw;
  if Length(ResBytes) <> SizeOf(TGUID) then
    Exit;
  MoveMemory(@Result, @ResBytes[0], SizeOf(Result));
end;

function TPJBiosInfo.SystemUuidRaw: TBytes;
var
  SysInfoStructPtr: PByte;
  UuidOffset: Cardinal;
  PUuid: PByte;
begin
  SysInfoStructPtr := FindStruct(1);
  if not Assigned(SysInfoStructPtr)
    or (SMBiosSpecVersion < UuidSupportMinVersion) then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  // UUID is at byte offset 8 in system information block
  SetLength(Result, UuidDataSize);
  PUuid := SysInfoStructPtr + $8;
  for UuidOffset := Low(Result) to High(Result) do
  begin
    Result[UuidOffset] := PUuid^;
    Inc(PUuid);
  end;
end;

function TPJBiosInfo.SystemUuidStr(const UseRFC4122ByteOrdering: Boolean):
  string;
var
  Uuid: TBytes;
const
  // Defines fields for displaying the UUID. Fields are 4 byte, 2 byte, 2 byte,
  // 2 byte, 6 byte.
  UuidFmtStr = '%.2X%.2X%.2X%.2X-%.2X%.2X-%.2X%.2X-%.2X%.2X-'
    + '%.2X%.2X%.2X%.2X%.2X%.2X';
begin
  Result := '';
  if not IsBiosSupported or (SMBiosSpecVersion < UuidSupportMinVersion) then
    // UUID not supported: return empty string
    Exit;

  Uuid := SystemUuidRaw;
  if Length(Uuid) <> UuidDataSize then
    // Corrupt UUID returned: return empty string
    Exit;

  if UseRFC4122ByteOrdering then
    // When using the byte ordering specified by RFC4122 all fields are in
    // network byte order.
    Result := Format(
      UuidFmtStr,
      [
        Uuid[0], Uuid[1], Uuid[2], Uuid[3],
        Uuid[4], Uuid[5],
        Uuid[6], Uuid[7],
        Uuid[8], Uuid[9],
        Uuid[10], Uuid[11], Uuid[12], Uuid[13], Uuid[14], Uuid[15]
      ]
    )
  else
    // When not using RFC4122 byte ordering, the byte ordering mandated by
    // documentation for SMBIOS v2.6 and later is used, i.e. the first three
    // fields (4 bytes, 2 bytes, 2 bytes) are in little endian format, while
    // subsequent fields are in network byte order (2 bytes, 6 bytes).
    Result := Format(
      UuidFmtStr,
      [
        Uuid[3], Uuid[2], Uuid[1], Uuid[0],
        Uuid[5], Uuid[4],
        Uuid[7], Uuid[6],
        Uuid[8], Uuid[9],
        Uuid[10], Uuid[11], Uuid[12], Uuid[13], Uuid[14], Uuid[15]
      ]
    );
end;

function TPJBiosInfo.SystemWakeupType: TPJBiosWakeupType;
var
  SysInfoStructPtr: PByte;
  PWakeupType: PByte;
begin
  Result := wutUnknown;
  SysInfoStructPtr := FindStruct(1);
  if not Assigned(SysInfoStructPtr) or (SMBiosSpecVersion < $0201) then
    Exit;
  PWakeupType := SysInfoStructPtr + $18;
  case PWakeupType^ of
    0: Result := wutReserved;
    1: Result := wutOther;
    2: Result := wutUnknown;
    3: Result := wutAPMTimer;
    4: Result := wutModemRing;
    5: Result := wutLANRemote;
    6: Result := wutPowerSwitch;
    7: Result := wutPCIPME;
    8: Result := wutACPowerRestored;
  end;
end;

initialization

// Initialize global variables from extended OS and product info
InitPlatformIdEx;

end.
