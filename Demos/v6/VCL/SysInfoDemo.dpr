{
 * SysInfoDemo.dpr
 *
 * Project file for System Information Unit demo program.
 *
 * $Rev: 1982 $
 * $Date: 2015-09-09 13:16:03 +0100 (Wed, 09 Sep 2015) $
 *
 * Any copyright in this file is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/
}


program SysInfoDemo;

uses
  Forms,
  FmDemo in 'FmDemo.pas' {DemoForm},
  PJSysInfo in '..\..\PJSysInfo.pas';

{$R 'MainIcon.res'}
{$R 'Manifest.res'}

begin
  Application.Initialize;
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;
end.

