program FMXGarageApplication;
uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  System.StartUpCopy,
  FMX.Forms,
  frm_Main in 'frm_Main.pas' {frmMainUI};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMainUI, frmMainUI);
  Application.Run;
end.
