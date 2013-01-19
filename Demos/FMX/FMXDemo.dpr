{
 * Project file for System Information Unit FireMonkey demo program.
 *
 * $Rev$
 * $Date$
 *
 * Any copyright in this file is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/
}


program FMXDemo;

uses
  FMX.Forms,
  FmFMXDemo in 'FmFMXDemo.pas' {Form1},
  PJSysInfo in '..\..\PJSysInfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
