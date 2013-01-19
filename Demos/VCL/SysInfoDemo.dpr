{
 * SysInfoDemo.dpr
 *
 * Project file for System Information Unit demo program.
 *
 * $Rev$
 * $Date$
 *
 * Any copyright in this file is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/
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

