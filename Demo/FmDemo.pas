{
 * FmDemo.pas
 *
 * Main form for System Information unit demo program.
 *
 * $Rev$
 * $Date$
 *
 * Any copyright in this file is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/
}


unit FmDemo;

interface

uses
  StdCtrls, Classes, Controls, ComCtrls, Forms,
  PJSysInfo, ExtCtrls;

type
  TDemoForm = class(TForm)
    TabControl1: TTabControl;
    edDisplay: TMemo;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
  private
    procedure DisplayRuling;
    procedure DisplayRuleOff;
    procedure DisplayHeading(const Title: string);
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
  DemoForm: TDemoForm;

implementation

uses
  SysUtils;

{$R *.DFM}

procedure TDemoForm.DisplayHeading(const Title: string);
begin
  if edDisplay.Lines.Count > 0 then
    edDisplay.Lines.Add('');
  edDisplay.Lines.Add(Title);
end;

procedure TDemoForm.DisplayItem(const Name, Value: string);
begin
  edDisplay.Lines.Add(Format('%-24s| %s', [Name, Value]));
end;

procedure TDemoForm.DisplayItem(const Name: string; const Value: Boolean);
const
  cBoolean: array[Boolean] of string = ('False', 'True');
begin
  DisplayItem(Name, cBoolean[Value]);
end;

procedure TDemoForm.DisplayItem(const Name: string; const Value: Integer);
begin
  DisplayItem(Name, IntToStr(Value));
end;

procedure TDemoForm.DisplayItem(const Name: string; const Value: TPJOSPlatform);
const
  cOSPlatform: array[TPJOSPlatform] of string = (
    'ospWinNT', 'ospWin9x', 'ospWin32s'
  );
begin
  DisplayItem(Name, cOSPlatform[Value]);
end;

procedure TDemoForm.DisplayItem(const Name: string; const Value: TPJOSProduct);
const
  cOSProduct: array[TPJOSProduct] of string = (
    'osUnknownWinNT', 'osWinNT', 'osWin2K', 'osWinXP', 'osUnknownWin9x',
    'osWin95', 'osWin98', 'osWinMe', 'osUnknownWin32s', 'osWinSvr2003',
    'osUnknown', 'osWinVista', 'osWinSvr2003R2', 'osWinSvr2008',
    'osWinLater', 'osWin7', 'osWinSvr2008R2', 'osWin8', 'osWinSvr2012'
  );
begin
  DisplayItem(Name, cOSProduct[Value]);
end;

procedure TDemoForm.DisplayRuleOff;
begin
  edDisplay.Lines.Add(StringOfChar('=', 24) + '+' + StringOfChar('=', 55));
end;

procedure TDemoForm.DisplayRuling;
begin
  edDisplay.Lines.Add(StringOfChar('-', 24) + '+' + StringOfChar('-', 55));
end;

procedure TDemoForm.FormCreate(Sender: TObject);
begin
  ShowContent(TabControl1.TabIndex);
end;

procedure TDemoForm.ShowContent(Tab: Integer);
begin
  edDisplay.Clear;
  case Tab of
    0: ShowTPJComputerInfo;
    1: ShowTPJSystemFolders;
    2: ShowTPJOSInfo;
    3: ShowWin32Globals;
  end;
end;

procedure TDemoForm.ShowTPJComputerInfo;
const
  cProcessors: array[TPJProcessorArchitecture] of string = (
    'paUnknown', 'paX64', 'paIA64', 'paX86'
  );
  cBootModes: array[TPJBootMode] of string = (
    'bmUnknown', 'bmNormal', 'bmSafeMode', 'bmSafeModeNetwork'
  );
begin
  DisplayHeading('TPJComputerInfo Static Methods');
  DisplayRuling;
  DisplayItem('Computer Name', TPJComputerInfo.ComputerName);
  DisplayItem('User Name', TPJComputerInfo.UserName);
  DisplayItem('MAC Address', TPJComputerInfo.MACAddress);
  DisplayItem('Processor Count', Integer(TPJComputerInfo.ProcessorCount));
  DisplayItem('Processor Architecture', cProcessors[TPJComputerInfo.Processor]);
  DisplayItem('Is 64 Bit?', TPJComputerInfo.Is64Bit);
  DisplayItem('Is Network Present?', TPJComputerInfo.IsNetworkPresent);
  DisplayItem('Boot Mode', cBootModes[TPJComputerInfo.BootMode]);
  DisplayRuleOff;
end;

procedure TDemoForm.ShowTPJOSInfo;
begin
  DisplayHeading('TPJOSInfo Static Methods');
  DisplayRuling;
  DisplayItem('BuildNumber', TPJOSInfo.BuildNumber);
  DisplayItem('Description', TPJOSInfo.Description);
  DisplayItem('Edition', TPJOSInfo.Edition);
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
  DisplayItem('ServicePackMajor', TPJOSInfo.ServicePackMajor);
  DisplayItem('ServicePackMinor', TPJOSInfo.ServicePackMinor);
  DisplayItem('HasPenExtensions', TPJOSInfo.HasPenExtensions);
  DisplayRuleOff;
end;

procedure TDemoForm.ShowTPJSystemFolders;
begin
  DisplayHeading('TPJSystemFolders Static Methods');
  DisplayRuling;
  DisplayItem('CommonFiles', TPJSystemFolders.CommonFiles);
  DisplayItem('ProgramFiles', TPJSystemFolders.ProgramFiles);
  DisplayItem('System', TPJSystemFolders.System);
  DisplayItem('SystemWow64', TPJSystemFolders.SystemWow64);
  DisplayItem('Temp', TPJSystemFolders.Temp);
  DisplayItem('Windows', TPJSystemFolders.Windows);
  DisplayRuleOff;
end;

procedure TDemoForm.ShowWin32Globals;
begin
  DisplayHeading('SysUtils Win32XXX Variables');
  DisplayRuling;
  DisplayItem('Win32Platform', Win32Platform);
  DisplayItem('Win32MajorVersion', Win32MajorVersion);
  DisplayItem('Win32MinorVersion', Win32MinorVersion);
  DisplayItem('Win32BuildNumber', Win32BuildNumber);
  DisplayItem('Win32CSDVersion', Win32CSDVersion);
  DisplayRuleOff;

  DisplayHeading('PJSysInfo Win32XXX Variables');
  DisplayRuling;
  DisplayItem('Win32HaveExInfo', Win32HaveExInfo);
  DisplayItem('Win32ProductType', Win32ProductType);
  DisplayItem('Win32ServicePackMajor', Win32ServicePackMajor);
  DisplayItem('Win32ServicePackMinor', Win32ServicePackMinor);
  DisplayItem('Win32SuiteMask', Win32SuiteMask);
  DisplayItem('Win32HaveProductInfo', Win32HaveProductInfo);
  DisplayItem('Win32ProductInfo', Integer(Win32ProductInfo));
  DisplayRuleOff;
end;

procedure TDemoForm.TabControl1Change(Sender: TObject);
begin
  ShowContent(TabControl1.TabIndex);
end;

end.

