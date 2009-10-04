{
 * SysInfoDemo.dpr
 *
 * Project file for System Information Unit demo program.
 *
 * $Rev$
 * $Date$
 *
 * This file is copyright (C) P D Johnson (www.delphidabbler.com), 2003-2009.
 * It may be used without restriction. This code distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.
}


program SysInfoDemo;

uses
  Forms,
  FmDemo in 'FmDemo.pas' {DemoForm},
  PJSysInfo in '..\PJSysInfo.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;
end.

