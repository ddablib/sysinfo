{
 * Project file for System Information Unit FireMonkey demo program.
 *
 * $Rev: 1987 $
 * $Date: 2015-09-10 17:20:57 +0100 (Thu, 10 Sep 2015) $
 *
 * Any copyright in this file is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/
}


program FMXDemo;

uses
  FMX.Forms,
  FmFMXDemo in 'FmFMXDemo.pas' {Form1},
  PJSysInfo in '..\..\PJSysInfo.pas';

{$R 'MainIcon.res'}
{$R 'Manifest.res'}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
