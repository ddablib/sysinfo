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
  PJSysInfo, FMX.ListBox, FMX.TreeView, FMX.Grid;

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    TabControl1: TTabControl;
    tiComputerInfo: TTabItem;
    StringGrid1: TStringGrid;
    NameCol: TStringColumn;
    ValueCol: TStringColumn;
    tiSpecialFolders: TTabItem;
    tiOSInfo: TTabItem;
    tiWin32Globals: TTabItem;
    procedure TabControl1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure DisplayItem(const Name, Value: string); overload;
    procedure DisplayItem(const Name: string; const Value: Boolean); overload;
    procedure DisplayItem(const Name: string; const Value: Integer); overload;
    procedure DisplayItem(const Name: string; const Value: TPJOSPlatform);
      overload;
    procedure DisplayItem(const Name: string; const Value: TPJOSProduct);
      overload;
    procedure ShowContent(Tab: Integer);
    procedure ShowWin32Globals;
    procedure ShowTPJOSInfo;
    procedure ShowTPJComputerInfo;
    procedure ShowTPJSystemFolders;
  end;

var
  Form1: TForm1;

implementation

uses
  System.DateUtils;


{$R *.fmx}

procedure TForm1.DisplayItem(const Name: string; const Value: Integer);
begin
  DisplayItem(Name, IntToStr(Value));
end;

procedure TForm1.DisplayItem(const Name: string; const Value: TPJOSPlatform);
const
  cOSPlatform: array[TPJOSPlatform] of string = (
    'ospWinNT', 'ospWin9x', 'ospWin32s'
  );
begin
  DisplayItem(Name, cOSPlatform[Value]);
end;

procedure TForm1.DisplayItem(const Name, Value: string);
begin
  StringGrid1.RowCount := StringGrid1.RowCount + 1;
  StringGrid1.Cells[0, Pred(StringGrid1.RowCount)] := Name;
  StringGrid1.Cells[1, Pred(StringGrid1.RowCount)] := Value;
end;

procedure TForm1.DisplayItem(const Name: string; const Value: Boolean);
const
  cBoolean: array[Boolean] of string = ('False', 'True');
begin
  DisplayItem(Name, cBoolean[Value]);
end;

procedure TForm1.DisplayItem(const Name: string; const Value: TPJOSProduct);
const
  cOSProduct: array[TPJOSProduct] of string = (
    'osUnknownWinNT', 'osWinNT', 'osWin2K', 'osWinXP', 'osUnknownWin9x',
    'osWin95', 'osWin98', 'osWinMe', 'osUnknownWin32s', 'osWinSvr2003',
    'osUnknown', 'osWinVista', 'osWinSvr2003R2', 'osWinSvr2008',
    'osWinLater', 'osWin7', 'osWinSvr2008R2', 'osWin8', 'osWinSvr2012',
    'osWin8Point1', 'osWinSvr2012R2', 'osWin10', 'osWin10Svr', 'osWinSvr2019',
    'osWin11', 'osWinSvr2022', 'osWinServer'
  );
begin
  DisplayItem(Name, cOSProduct[Value]);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiComputerInfo;
  ShowContent(TabControl1.TabIndex);
end;

procedure TForm1.ShowContent(Tab: Integer);
begin
  StringGrid1.RowCount := 0;
  case Tab of
    0: ShowTPJComputerInfo;
    1: ShowTPJSystemFolders;
    2: ShowTPJOSInfo;
    3: ShowWin32Globals;
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
  DisplayItem('ComputerName', TPJComputerInfo.ComputerName);
  DisplayItem('UserName', TPJComputerInfo.UserName);
  DisplayItem('MACAddress', TPJComputerInfo.MACAddress);
  DisplayItem('ProcessorCount', Integer(TPJComputerInfo.ProcessorCount));
  DisplayItem('Processor', cProcessors[TPJComputerInfo.Processor]);
  DisplayItem('ProcessorIdentifier', TPJComputerInfo.ProcessorIdentifier);
  DisplayItem('ProcessorName', TPJComputerInfo.ProcessorName);
  DisplayItem('Processor Speed (MHz)', TPJComputerInfo.ProcessorSpeedMHz);
  DisplayItem('Is64Bit', TPJComputerInfo.Is64Bit);
  DisplayItem('IsNetworkPresent?', TPJComputerInfo.IsNetworkPresent);
  DisplayItem('BootMode', cBootModes[TPJComputerInfo.BootMode]);
  DisplayItem('IsAdmin', TPJComputerInfo.IsAdmin);
  DisplayItem('IsUACActive', TPJComputerInfo.IsUACActive);
  DisplayItem('BiosVendor', TPJComputerInfo.BiosVendor);
  DisplayItem('SystemManufacturer', TPJComputerInfo.SystemManufacturer);
  DisplayItem('SystemProductName', TPJComputerInfo.SystemProductName);
end;

procedure TForm1.ShowTPJOSInfo;
begin
  DisplayItem('BuildNumber', TPJOSInfo.BuildNumber);
  DisplayItem('RevisionNumber', TPJOSInfo.RevisionNumber);
  DisplayItem('Description', TPJOSInfo.Description);
  DisplayItem('Edition', TPJOSInfo.Edition);
  if SameDateTime(TPJOSInfo.InstallationDate, 0.0) then
    DisplayItem('InstallationDate', 'Unknown')
  else
    DisplayItem('InstallationDate', DateTimeToStr(TPJOSInfo.InstallationDate));
  DisplayItem('IsServer', TPJOSInfo.IsServer);
  DisplayItem('IsWin32s', TPJOSInfo.IsWin32s);
  DisplayItem('IsWin9x', TPJOSInfo.IsWin9x);
  DisplayItem('IsWinNT', TPJOSInfo.IsWinNT);
  DisplayItem('IsWow64', TPJOSInfo.IsWow64);
  DisplayItem('IsMediaCenter', TPJOSInfo.IsMediaCenter);
  DisplayItem('IsTabletPC', TPJOSInfo.IsTabletPC);
  DisplayItem('IsRemoteSession', TPJOSInfo.IsRemoteSession);
  DisplayItem('MajorVersion', TPJOSInfo.MajorVersion);
  DisplayItem('MinorVersion', TPJOSInfo.MinorVersion);
  DisplayItem('Platform', TPJOSInfo.Platform);
  DisplayItem('Product', TPJOSInfo.Product);
  DisplayItem('ProductID', TPJOSInfo.ProductID);
  DisplayItem('ProductName', TPJOSInfo.ProductName);
  DisplayItem('ServicePack', TPJOSInfo.ServicePack);
  DisplayItem('ServicePackEx', TPJOSInfo.ServicePackEx);
  DisplayItem('ServicePackMajor', TPJOSInfo.ServicePackMajor);
  DisplayItem('ServicePackMinor', TPJOSInfo.ServicePackMinor);
  DisplayItem('HasPenExtensions', TPJOSInfo.HasPenExtensions);
  DisplayItem('RegisteredOrganisation', TPJOSInfo.RegisteredOrganisation);
  DisplayItem('RegisteredOwner', TPJOSInfo.RegisteredOwner);
  DisplayItem('CanSpoof', TPJOSInfo.CanSpoof);
  DisplayItem('IsReallyWindows2000OrGreater',
    TPJOSInfo.IsReallyWindows2000OrGreater);
  DisplayItem('IsReallyWindows2000SP1OrGreater',
    TPJOSInfo.IsReallyWindows2000SP1OrGreater);
  DisplayItem('IsReallyWindows2000SP2OrGreater',
    TPJOSInfo.IsReallyWindows2000SP2OrGreater);
  DisplayItem('IsReallyWindows2000SP3OrGreater',
    TPJOSInfo.IsReallyWindows2000SP3OrGreater);
  DisplayItem('IsReallyWindows2000SP4OrGreater',
    TPJOSInfo.IsReallyWindows2000SP4OrGreater);
  DisplayItem('IsReallyWindowsXPOrGreater',
    TPJOSInfo.IsReallyWindowsXPOrGreater);
  DisplayItem('IsReallyWindowsXPSP1OrGreater',
    TPJOSInfo.IsReallyWindowsXPSP1OrGreater);
  DisplayItem('IsReallyWindowsXPSP2OrGreater',
    TPJOSInfo.IsReallyWindowsXPSP2OrGreater);
  DisplayItem('IsReallyWindowsXPSP3OrGreater',
    TPJOSInfo.IsReallyWindowsXPSP3OrGreater);
  DisplayItem('IsReallyWindowsVistaOrGreater',
    TPJOSInfo.IsReallyWindowsVistaOrGreater);
  DisplayItem('IsReallyWindowsVistaSP1OrGreater',
    TPJOSInfo.IsReallyWindowsVistaSP1OrGreater);
  DisplayItem('IsReallyWindowsVistaSP2OrGreater',
    TPJOSInfo.IsReallyWindowsVistaSP2OrGreater);
  DisplayItem('IsReallyWindows7OrGreater',
    TPJOSInfo.IsReallyWindows7OrGreater);
  DisplayItem('IsReallyWindows7SP1OrGreater',
    TPJOSInfo.IsReallyWindows7SP1OrGreater);
  DisplayItem('IsReallyWindows8OrGreater',
    TPJOSInfo.IsReallyWindows8OrGreater);
  DisplayItem('IsReallyWindows8Point1OrGreater',
    TPJOSInfo.IsReallyWindows8Point1OrGreater);
  DisplayItem('IsReallyWindows10OrGreater',
    TPJOSInfo.IsReallyWindows8OrGreater);
  DisplayItem('IsWindowsServer', TPJOSInfo.IsWindowsServer);
end;

procedure TForm1.ShowTPJSystemFolders;
begin
  DisplayItem('CommonFiles', TPJSystemFolders.CommonFiles);
  DisplayItem('CommonFilesX86', TPJSystemFolders.CommonFilesX86);
  DisplayItem('CommonFilesRedirect', TPJSystemFolders.CommonFilesRedirect);
  DisplayItem('ProgramFiles', TPJSystemFolders.ProgramFiles);
  DisplayItem('ProgramFilesX86', TPJSystemFolders.ProgramFilesX86);
  DisplayItem('ProgramFilesRedirect', TPJSystemFolders.ProgramFilesRedirect);
  DisplayItem('Windows', TPJSystemFolders.Windows);
  DisplayItem('System', TPJSystemFolders.System);
  DisplayItem('SystemWow64', TPJSystemFolders.SystemWow64);
  DisplayItem('Temp', TPJSystemFolders.Temp);
end;

procedure TForm1.ShowWin32Globals;
begin
  DisplayItem('Win32Platform', Win32Platform);
  DisplayItem('Win32MajorVersion', Win32MajorVersion);
  DisplayItem('Win32MinorVersion', Win32MinorVersion);
  DisplayItem('Win32BuildNumber', Win32BuildNumber);
  DisplayItem('Win32CSDVersion', Win32CSDVersion);

  DisplayItem('Win32PlatformEx', Win32PlatformEx);
  DisplayItem('Win32MajorVersionEx', Win32MajorVersionEx);
  DisplayItem('Win32MinorVersionEx', Win32MinorVersionEx);
  DisplayItem('Win32CSDVersionEx', Win32CSDVersionEx);
  DisplayItem('Win32BuildNumberEx', Win32BuildNumberEx);

  DisplayItem('Win32RevisionNumber', Win32RevisionNumber);

  DisplayItem('Win32HaveExInfo', Win32HaveExInfo);
  DisplayItem('Win32ProductType', Win32ProductType);
  DisplayItem('Win32ServicePackMajor', Win32ServicePackMajor);
  DisplayItem('Win32ServicePackMinor', Win32ServicePackMinor);
  DisplayItem('Win32SuiteMask', Win32SuiteMask);
  DisplayItem('Win32HaveProductInfo', Win32HaveProductInfo);
  DisplayItem('Win32ProductInfo', Integer(Win32ProductInfo));
end;

procedure TForm1.TabControl1Change(Sender: TObject);
begin
  StringGrid1.Parent := TabControl1.ActiveTab;
  ShowContent(TabControl1.ActiveTab.Index);
end;

end.
