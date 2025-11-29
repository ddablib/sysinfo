{
 * Main form file for System Information Unit FireMonkey demo program.
 *
 * Any copyright in this file is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/
}


unit FmFMXDemo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Rtti, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.TabControl, FMX.Ani, FMX.Layouts, FMX.Memo,
  FMX.ListBox, FMX.TreeView, FMX.Grid, FMX.Grid.Style,
  FMX.Controls.Presentation, FMX.ScrollBox,

  PJSysInfo;

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    TabControl1: TTabControl;
    tiComputerInfo: TTabItem;
    tiSpecialFolders: TTabItem;
    tiOSInfo: TTabItem;
    tiWin32Globals: TTabItem;
    sgComputerInfo: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    sgOSInfo: TStringGrid;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    sgSpecialFolders: TStringGrid;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    sgWin32Globals: TStringGrid;
    StringColumn7: TStringColumn;
    StringColumn8: TStringColumn;
    tiBiosInfo: TTabItem;
    sgBiosInfo: TStringGrid;
    StringColumn9: TStringColumn;
    StringColumn10: TStringColumn;
    procedure TabControl1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgResized(Sender: TObject);
  private
    procedure DisplayItem(const SG: TStringGrid; const Name, Value: string);
      overload;
    procedure DisplayItem(const SG: TStringGrid; const Name: string;
      const Value: Boolean); overload;
    procedure DisplayItem(const SG: TStringGrid; const Name: string;
      const Value: Integer); overload;
    procedure DisplayItem(const SG: TStringGrid; const Name: string;
      const Value: TPJOSPlatform); overload;
    procedure DisplayItem(const SG: TStringGrid; const Name: string;
      const Value: TPJOSProduct); overload;
    procedure DisplayItem(const SG: TStringGrid; const Name: string;
      const Value: TBytes); overload;
    procedure DisplayItem(const SG: TStringGrid; const Name: string;
      const Value: TPJWin10PlusVersion); overload;
    procedure ShowContent(Tab: Integer);
    procedure ShowWin32Globals;
    procedure ShowTPJOSInfo;
    procedure ShowTPJComputerInfo;
    procedure ShowTPJSystemFolders;
    procedure ShowTPJBiosInfo;
  end;

var
  Form1: TForm1;

implementation

uses
  Winapi.Windows,   // for inlining
  System.DateUtils;


{$R *.fmx}

procedure TForm1.DisplayItem(const SG: TStringGrid; const Name: string;
  const Value: Integer);
begin
  DisplayItem(SG, Name, IntToStr(Value));
end;

procedure TForm1.DisplayItem(const SG: TStringGrid; const Name: string;
  const Value: TPJOSPlatform);
const
  cOSPlatform: array[TPJOSPlatform] of string = (
    'ospWinNT', 'ospWin9x', 'ospWin32s'
  );
begin
  DisplayItem(SG, Name, cOSPlatform[Value]);
end;

procedure TForm1.DisplayItem(const SG: TStringGrid; const Name, Value: string);
begin
  SG.RowCount := SG.RowCount + 1;
  SG.Cells[0, Pred(SG.RowCount)] := Name;
  SG.Cells[1, Pred(SG.RowCount)] := Value;
end;

procedure TForm1.DisplayItem(const SG: TStringGrid; const Name: string;
  const Value: Boolean);
const
  cBoolean: array[Boolean] of string = ('False', 'True');
begin
  DisplayItem(SG, Name, cBoolean[Value]);
end;

procedure TForm1.DisplayItem(const SG: TStringGrid; const Name: string;
  const Value: TPJWin10PlusVersion);
const
  cVersions: array[TPJWin10PlusVersion] of string = (
    'win10plusNA', 'win10plusUnknown',
    'win10v1507', 'win10v1511', 'win10v1607', 'win10v1703', 'win10v1709',
    'win10v1803', 'win10v1809', 'win10v1903', 'win10v1909', 'win10v2004',
    'win10v20H2', 'win10v21H1', 'win10v21H2', 'win10v22H2',
    'win11v21H2', 'win11v22H2', 'win11v23H2', 'win11v24H2', 'win11v25H2',
    'win11v26H1'
  );
begin
  DisplayItem(SG, Name, cVersions[Value]);
end;

procedure TForm1.DisplayItem(const SG: TStringGrid; const Name: string;
  const Value: TPJOSProduct);
const
  cOSProduct: array[TPJOSProduct] of string = (
    'osUnknownWinNT', 'osWinNT', 'osWin2K', 'osWinXP', 'osUnknownWin9x',
    'osWin95', 'osWin98', 'osWinMe', 'osUnknownWin32s', 'osWinSvr2003',
    'osUnknown', 'osWinVista', 'osWinSvr2003R2', 'osWinSvr2008',
    'osWinLater', 'osWin7', 'osWinSvr2008R2', 'osWin8', 'osWinSvr2012',
    'osWin8Point1', 'osWinSvr2012R2', 'osWin10', 'osWin10Svr', 'osWinSvr2019',
    'osWin11', 'osWinSvr2022', 'osWinServer', 'osWinSvr2025', 'osWinSvrLater'
  );
begin
  DisplayItem(SG, Name, cOSProduct[Value]);
end;

procedure TForm1.DisplayItem(const SG: TStringGrid; const Name: string;
  const Value: TBytes);
var
  B: Byte;
  S: string;
begin
  S := '';
  for B in Value do
    S := S + IntToHex(B) + ' ';
  S := Trim(S);
  DisplayItem(SG, Name, S);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiComputerInfo;
  ShowContent(TabControl1.TabIndex);
end;

procedure TForm1.sgResized(Sender: TObject);
var
  SG: TStringGrid;
begin
  SG := Sender as TStringGrid;
  SG.Columns[1].Width := SG.Width - SG.Columns[0].Width - 8;
end;

procedure TForm1.ShowContent(Tab: Integer);
begin
  case Tab of
    0: ShowTPJComputerInfo;
    1: ShowTPJBiosInfo;
    2: ShowTPJSystemFolders;
    3: ShowTPJOSInfo;
    4: ShowWin32Globals;
  end;
end;

procedure TForm1.ShowTPJBiosInfo;
const
  cWakeupTypes: array[TPJBIOSWakeupType] of string = (
    'wutReserved', 'wutOther', 'wutUnknown', 'wutAPMTimer', 'wutModemRing',
    'wutLANRemote', 'wutPowerSwitch', 'wutPCIPME', 'wutACPowerRestored'
  );

  function FmtVersionWord(const V: Word): string;
  begin
    if V <> 0 then
      Result := Format('$%.4x (v%d.%d)', [V, V shr 8, V and $FF])
    else
      Result := 'Unknown or error';
  end;

  function FmtDate(const D: TDate): string;
  var
    Fmt: TFormatSettings;
  begin
    // Use locale date format
    if SameDate(0.0, D) then
      Exit('Unknown or error');
    Fmt := TFormatSettings.Create;
    Result := FormatDateTime(Fmt.ShortDateFormat, D);
  end;

var
  BIOS: TPJBIOSInfo;
begin
  sgBiosInfo.RowCount := 0;
  BIOS := TPJBIOSInfo.Create;
  try
    DisplayItem(sgBiosInfo, 'IsBIOSSupported', BIOS.IsBIOSSupported);
    DisplayItem(sgBiosInfo, 'SMBIOSSpecVersion',
      FmtVersionWord(BIOS.SMBIOSSpecVersion));
    DisplayItem(sgBiosInfo, 'BIOSVendor', BIOS.BIOSVendor);
    DisplayItem(sgBiosInfo, 'BIOSVersionStr', BIOS.BIOSVersionStr);
    DisplayItem(sgBiosInfo, 'BIOSVersion', FmtVersionWord(BIOS.BIOSVersion));
    DisplayItem(sgBiosInfo, 'BIOSECFirmwareVersion',
      FmtVersionWord(BIOS.BIOSECFirmwareVersion));
    DisplayItem(sgBiosInfo, 'BIOSReleaseDate [current locale]',
      FmtDate(BIOS.BIOSReleaseDate));
    DisplayItem(sgBiosInfo, 'BIOSReleaseDateInvariant',
      BIOS.BIOSReleaseDateInvariant);
    DisplayItem(sgBiosInfo, 'SystemUUIDRaw', BIOS.SystemUUIDRaw);
    DisplayItem(sgBiosInfo, 'SystemUUID [using GUIDToString]',
      GUIDToString(BIOS.SystemUUID));
    DisplayItem(sgBiosInfo, 'SystemUUIDStr(False)', BIOS.SystemUUIDStr(False));
    DisplayItem(sgBiosInfo, 'SystemUUIDStr(True)', BIOS.SystemUUIDStr(True));
    DisplayItem(sgBiosInfo, 'SystemManufacturer', BIOS.SystemManufacturer);
    DisplayItem(sgBiosInfo, 'SystemProductName', BIOS.SystemProductName);
    DisplayItem(sgBiosInfo, 'SystemFamily', BIOS.SystemFamily);
    DisplayItem(sgBiosInfo, 'SystemOEMVersion', BIOS.SystemOEMVersion);
    DisplayItem(sgBiosInfo, 'SystemSerialNumber', BIOS.SystemSerialNumber);
    DisplayItem(sgBiosInfo, 'SystemSKUNumber', BIOS.SystemSKUNumber);
    DisplayItem(sgBiosInfo, 'SystemWakeupType',
      cWakeupTypes[BIOS.SystemWakeupType]);
  finally
    BIOS.Free;
  end;
end;

procedure TForm1.ShowTPJComputerInfo;
const
  cProcessors: array[TPJProcessorArchitecture] of string = (
    'paUnknown', 'paX64', 'paIA64', 'paX86'
  );
  cBootModes: array[TPJBootMode] of string = (
    'bmUnknown', 'bmNormal', 'bmSafeMode', 'bmSafeModeNetwork'
  );
begin
  sgComputerInfo.RowCount := 0;
  DisplayItem(sgComputerInfo, 'ComputerName',
    TPJComputerInfo.ComputerName);
  DisplayItem(sgComputerInfo, 'UserName',
    TPJComputerInfo.UserName);
  DisplayItem(sgComputerInfo, 'MACAddress',
    TPJComputerInfo.MACAddress);
  DisplayItem(sgComputerInfo, 'ProcessorCount',
    Integer(TPJComputerInfo.ProcessorCount));
  DisplayItem(sgComputerInfo, 'Processor',
    cProcessors[TPJComputerInfo.Processor]);
  DisplayItem(sgComputerInfo, 'ProcessorIdentifier',
    TPJComputerInfo.ProcessorIdentifier);
  DisplayItem(sgComputerInfo, 'ProcessorName', TPJComputerInfo.ProcessorName);
  DisplayItem(sgComputerInfo, 'Processor Speed (MHz)',
    TPJComputerInfo.ProcessorSpeedMHz);
  DisplayItem(sgComputerInfo, 'Is64Bit',
    TPJComputerInfo.Is64Bit);
  DisplayItem(sgComputerInfo, 'IsNetworkPresent?',
    TPJComputerInfo.IsNetworkPresent);
  DisplayItem(sgComputerInfo, 'BootMode', cBootModes[TPJComputerInfo.BootMode]);
  DisplayItem(sgComputerInfo, 'IsAdmin', TPJComputerInfo.IsAdmin);
  DisplayItem(sgComputerInfo, 'IsUACActive', TPJComputerInfo.IsUACActive);
  DisplayItem(sgComputerInfo, 'BiosVendor', TPJComputerInfo.BiosVendor);
  DisplayItem(sgComputerInfo, 'SystemManufacturer',
    TPJComputerInfo.SystemManufacturer);
  DisplayItem(sgComputerInfo, 'SystemProductName',
    TPJComputerInfo.SystemProductName);
end;

procedure TForm1.ShowTPJOSInfo;
begin
  sgOSInfo.RowCount := 0;
  DisplayItem(sgOSInfo, 'BuildNumber', TPJOSInfo.BuildNumber);
  DisplayItem(sgOSInfo, 'RevisionNumber', TPJOSInfo.RevisionNumber);
  DisplayItem(sgOSInfo, 'BuildBranch', TPJOSInfo.BuildBranch);
  DisplayItem(sgOSInfo, 'Description', TPJOSInfo.Description);
  DisplayItem(sgOSInfo, 'Edition', TPJOSInfo.Edition);
  if SameDateTime(TPJOSInfo.InstallationDate, 0.0) then
    DisplayItem(sgOSInfo, 'InstallationDate', 'Unknown')
  else
    DisplayItem(sgOSInfo, 'InstallationDate',
      DateTimeToStr(TPJOSInfo.InstallationDate));
  DisplayItem(sgOSInfo, 'IsServer', TPJOSInfo.IsServer);
  DisplayItem(sgOSInfo, 'IsWin32s', TPJOSInfo.IsWin32s);
  DisplayItem(sgOSInfo, 'IsWin9x', TPJOSInfo.IsWin9x);
  DisplayItem(sgOSInfo, 'IsWinNT', TPJOSInfo.IsWinNT);
  DisplayItem(sgOSInfo, 'IsWow64', TPJOSInfo.IsWow64);
  DisplayItem(sgOSInfo, 'IsMediaCenter', TPJOSInfo.IsMediaCenter);
  DisplayItem(sgOSInfo, 'IsTabletPC', TPJOSInfo.IsTabletPC);
  DisplayItem(sgOSInfo, 'IsRemoteSession', TPJOSInfo.IsRemoteSession);
  DisplayItem(sgOSInfo, 'MajorVersion', TPJOSInfo.MajorVersion);
  DisplayItem(sgOSInfo, 'MinorVersion', TPJOSInfo.MinorVersion);
  DisplayItem(sgOSInfo, 'Platform', TPJOSInfo.Platform);
  DisplayItem(sgOSInfo, 'Product', TPJOSInfo.Product);
  DisplayItem(sgOSInfo, 'ProductName', TPJOSInfo.ProductName);
  DisplayItem(sgOSInfo, 'ServicePack', TPJOSInfo.ServicePack);
  DisplayItem(sgOSInfo, 'ServicePackEx', TPJOSInfo.ServicePackEx);
  DisplayItem(sgOSInfo, 'ServicePackMajor', TPJOSInfo.ServicePackMajor);
  DisplayItem(sgOSInfo, 'ServicePackMinor', TPJOSInfo.ServicePackMinor);
  DisplayItem(sgOSInfo, 'Windows10PlusVersion',
    TPJOSInfo.Windows10PlusVersion);
  DisplayItem(sgOSInfo, 'Windows10PlusVersionName',
    TPJOSInfo.Windows10PlusVersionName);
  DisplayItem(sgOSInfo, 'HasPenExtensions', TPJOSInfo.HasPenExtensions);
  DisplayItem(sgOSInfo, 'ProductID', TPJOSInfo.ProductID);
  DisplayItem(sgOSInfo, 'DigitalProductID', TPJOSInfo.DigitalProductID);
  DisplayItem(sgOSInfo, 'DecodedDigitalProductID',
    TPJOSInfo.DecodedDigitalProductID);
  DisplayItem(sgOSInfo, 'RegisteredOrganisation',
    TPJOSInfo.RegisteredOrganisation);
  DisplayItem(sgOSInfo, 'RegisteredOwner', TPJOSInfo.RegisteredOwner);
  DisplayItem(sgOSInfo, 'CanSpoof', TPJOSInfo.CanSpoof);
  DisplayItem(sgOSInfo, 'IsReallyWindows2000OrGreater',
    TPJOSInfo.IsReallyWindows2000OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows2000SP1OrGreater',
    TPJOSInfo.IsReallyWindows2000SP1OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows2000SP2OrGreater',
    TPJOSInfo.IsReallyWindows2000SP2OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows2000SP3OrGreater',
    TPJOSInfo.IsReallyWindows2000SP3OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows2000SP4OrGreater',
    TPJOSInfo.IsReallyWindows2000SP4OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindowsXPOrGreater',
    TPJOSInfo.IsReallyWindowsXPOrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindowsXPSP1OrGreater',
    TPJOSInfo.IsReallyWindowsXPSP1OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindowsXPSP2OrGreater',
    TPJOSInfo.IsReallyWindowsXPSP2OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindowsXPSP3OrGreater',
    TPJOSInfo.IsReallyWindowsXPSP3OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindowsVistaOrGreater',
    TPJOSInfo.IsReallyWindowsVistaOrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindowsVistaSP1OrGreater',
    TPJOSInfo.IsReallyWindowsVistaSP1OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindowsVistaSP2OrGreater',
    TPJOSInfo.IsReallyWindowsVistaSP2OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows7OrGreater',
    TPJOSInfo.IsReallyWindows7OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows7SP1OrGreater',
    TPJOSInfo.IsReallyWindows7SP1OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows8OrGreater',
    TPJOSInfo.IsReallyWindows8OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows8Point1OrGreater',
    TPJOSInfo.IsReallyWindows8Point1OrGreater);
  DisplayItem(sgOSInfo, 'IsReallyWindows10OrGreater',
    TPJOSInfo.IsReallyWindows8OrGreater);
  DisplayItem(sgOSInfo, 'IsWindows10VersionOrLater(win10v1809)',
    TPJOSInfo.IsWindows10VersionOrLater(win10v1809));
  DisplayItem(sgOSInfo, 'IsWindows10VersionOrLater(win10v22H2)',
    TPJOSInfo.IsWindows10VersionOrLater(win10v22H2));
  DisplayItem(sgOSInfo, 'IsWindows11VersionOrLater(win11v23H2)',
    TPJOSInfo.IsWindows11VersionOrLater(win11v23H2));
  DisplayItem(sgOSInfo, 'IsWindows11VersionOrLater(win11v24H2)',
    TPJOSInfo.IsWindows11VersionOrLater(win11v24H2));
  DisplayItem(sgOSInfo, 'IsWindowsServer', TPJOSInfo.IsWindowsServer);
end;

procedure TForm1.ShowTPJSystemFolders;
begin
  sgSpecialFolders.RowCount := 0;
  DisplayItem(sgSpecialFolders, 'CommonFiles',
    TPJSystemFolders.CommonFiles);
  DisplayItem(sgSpecialFolders, 'CommonFilesX86',
    TPJSystemFolders.CommonFilesX86);
  DisplayItem(sgSpecialFolders, 'CommonFilesRedirect',
    TPJSystemFolders.CommonFilesRedirect);
  DisplayItem(sgSpecialFolders, 'ProgramFiles',
    TPJSystemFolders.ProgramFiles);
  DisplayItem(sgSpecialFolders, 'ProgramFilesX86',
    TPJSystemFolders.ProgramFilesX86);
  DisplayItem(sgSpecialFolders, 'ProgramFilesRedirect',
    TPJSystemFolders.ProgramFilesRedirect);
  DisplayItem(sgSpecialFolders, 'Windows', TPJSystemFolders.Windows);
  DisplayItem(sgSpecialFolders, 'System', TPJSystemFolders.System);
  DisplayItem(sgSpecialFolders, 'SystemWow64', TPJSystemFolders.SystemWow64);
  DisplayItem(sgSpecialFolders, 'Temp', TPJSystemFolders.Temp);
end;

procedure TForm1.ShowWin32Globals;
begin
  sgWin32Globals.RowCount := 0;
  DisplayItem(sgWin32Globals, 'Win32Platform', Win32Platform);
  DisplayItem(sgWin32Globals, 'Win32MajorVersion', Win32MajorVersion);
  DisplayItem(sgWin32Globals, 'Win32MinorVersion', Win32MinorVersion);
  DisplayItem(sgWin32Globals, 'Win32BuildNumber', Win32BuildNumber);
  DisplayItem(sgWin32Globals, 'Win32CSDVersion', Win32CSDVersion);

  DisplayItem(sgWin32Globals, 'Win32PlatformEx', Win32PlatformEx);
  DisplayItem(sgWin32Globals, 'Win32MajorVersionEx', Win32MajorVersionEx);
  DisplayItem(sgWin32Globals, 'Win32MinorVersionEx', Win32MinorVersionEx);
  DisplayItem(sgWin32Globals, 'Win32CSDVersionEx', Win32CSDVersionEx);
  DisplayItem(sgWin32Globals, 'Win32BuildNumberEx', Win32BuildNumberEx);

  DisplayItem(sgWin32Globals, 'Win32RevisionNumber', Win32RevisionNumber);

  DisplayItem(sgWin32Globals, 'Win32HaveExInfo', Win32HaveExInfo);
  DisplayItem(sgWin32Globals, 'Win32ProductType', Win32ProductType);
  DisplayItem(sgWin32Globals, 'Win32ServicePackMajor', Win32ServicePackMajor);
  DisplayItem(sgWin32Globals, 'Win32ServicePackMinor', Win32ServicePackMinor);
  DisplayItem(sgWin32Globals, 'Win32SuiteMask', Win32SuiteMask);
  DisplayItem(sgWin32Globals, 'Win32HaveProductInfo', Win32HaveProductInfo);
  DisplayItem(sgWin32Globals, 'Win32ProductInfo', Integer(Win32ProductInfo));
end;

procedure TForm1.TabControl1Change(Sender: TObject);
begin
  ShowContent(TabControl1.ActiveTab.Index);
end;

end.
