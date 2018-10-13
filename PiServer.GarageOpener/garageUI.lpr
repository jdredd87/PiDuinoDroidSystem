program garageUI;

{$mode objfpc}{$H+}

uses
  {$DEFINE UseCThreads}
   {$IFDEF UNIX}{$IFDEF UseCThreads}
   cthreads,
   {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, frm_MainMenu, LazSerialPort, indylaz
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='PiDuinoDroid Garage Server';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

