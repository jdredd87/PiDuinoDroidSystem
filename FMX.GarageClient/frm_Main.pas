{

 Simple little FMX program to hit up the Pi server side of things.
 It works to a degree but could be alot more efficent and more secure.
 Mostly just to demonstrate a few ideas. Not ment to a billion dollar application idea :)

 steven.chesser@twc.com

}

unit frm_Main;

interface

uses
  System.Dateutils,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Actions,
  System.ioutils,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Edit,
  FMX.TabControl,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.ActnList,
  FMX.Gestures,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP;

const

  // these are the header strings returned from the Pi/Arduino
  _initHeader = '%init%';
  _dht11errorHeader = '%dht11error%';
  _dht11dataHeader = '%dht11data%';
  _magsensorsHeader = '%magsensor%';
  _buildHeader = '%build%';
  _msgHeader = '%msg%';

  // commands to send to Pi Server/Arduino
  _relay1CMD = '1';
  _relay2CMD = '2';
  _magSensorsCMD = '4';
  _buildVersionCMD = 'B';
  _dht11SensorCMD = 'T';
  _resetCMD = 'R';

  // quick TAG numbers

  _idleTag = 0; // basically 0 = do nothing, nadda

  _relay1TAG = 1;
  _relay2TAG = 2;
  _dht11SensorTAG = 3;
  _magSensorsTAG = 4;
  _resetTAG = 5;
  _buildVersionTAG = 6;

  // Strings

  _Closed = 'Closed';
  _Opened = 'Opened';

type

  TServerSettings = Record
    Address: String;
    Port: String;
    PassPhrase: String;
  end;

  TfrmMainUI = class(TForm)
    timer_LeftDoor: TTimer;
    timer_RightDoor: TTimer;
    StyleBook1: TStyleBook;
    http: TIdHTTP;
    timerHTTP: TTimer;
    ScaledLayout1: TScaledLayout;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    btn_Settings: TButton;
    lbl_Error: TLabel;
    lbl_version: TLabel;
    r_Status: TRectangle;
    lbl_Temp: TLabel;
    lbl_Humidity: TLabel;
    r_Top: TRectangle;
    r_LeftDoor: TRectangle;
    r_Left1: TRectangle;
    RoundRect1: TRoundRect;
    RoundRect2: TRoundRect;
    RoundRect3: TRoundRect;
    r_Left3: TRectangle;
    r_Left2: TRectangle;
    r_Left4: TRectangle;
    r_Left: TRectangle;
    lbl_LeftStatus: TLabel;
    r_RightDoor: TRectangle;
    r_Right1: TRectangle;
    RoundRect4: TRoundRect;
    RoundRect5: TRoundRect;
    RoundRect6: TRoundRect;
    r_Right4: TRectangle;
    r_Right2: TRectangle;
    r_Right3: TRectangle;
    r_Right: TRectangle;
    lbl_RightStatus: TLabel;
    TabItem2: TTabItem;
    e_ServerAddress: TEdit;
    lbl_ServerAddress: TLabel;
    e_ServerPort: TEdit;
    Label1: TLabel;
    e_PassPhrase: TEdit;
    Label2: TLabel;
    btn_TestConnection: TButton;
    ActionList1: TActionList;
    NextTabAction1: TNextTabAction;
    PreviousTabAction1: TPreviousTabAction;
    btn_Back: TButton;
    lbl_Settings: TLabel;
    AniIndicator1: TAniIndicator;
    procedure timer_LeftDoorTimer(Sender: TObject);
    procedure timer_RightDoorTimer(Sender: TObject);
    procedure timerHTTPTimer(Sender: TObject);
    procedure r_LeftDoorClick(Sender: TObject);
    procedure r_RightDoorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure r_StatusClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure e_SettingsKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure btn_TestConnectionClick(Sender: TObject);
    procedure btn_SettingsClick(Sender: TObject);
    procedure btn_BackClick(Sender: TObject);
  private
    isLeftDoorOpen: Boolean;
    isRightDoorOpen: Boolean;
    hasDHT11error: Boolean;
    lastIdleTimeTemp: tdatetime;
    lastIdleTempMagSensors: tdatetime;
    showOnce: Boolean;
    _InitGood: Boolean;

    Settings: TServerSettings;

    procedure loadSettings;
    procedure saveSettings;
    procedure populateSettings;
    procedure startUp;
    procedure testConnection;
    procedure processPacket(inputData: string);
    procedure idle(Sender: TObject; var done: Boolean);

  public
    { Public declarations }
  end;

var
  frmMainUI: TfrmMainUI;

implementation

{$R *.fmx}

function OccurrencesOfChar(const ContentString: string; const CharToCount: Char): integer;
var
  C: Char;
begin
  result := 0;
  for C in ContentString do
    if C = CharToCount then
      Inc(result);
end;

// make your own settings
// this is just a cheap text file way of doing so

procedure TfrmMainUI.loadSettings;
var
  sl_Settings: tstringlist;
  fn: string;
begin
  Settings.Address := '192.168.1.1';
  Settings.Port := '8080';
  Settings.PassPhrase := 't@c0s';
  sl_Settings := tstringlist.Create;
  fn := System.ioutils.TPath.Combine(System.ioutils.TPath.GetDocumentsPath, 'settings.txt');
  if fileexists(fn) then
  begin
    try
      sl_Settings.LoadFromFile(fn);

      if sl_Settings.IndexOfName('address') > -1 then
        Settings.Address := sl_Settings.Values['address'];

      if sl_Settings.IndexOfName('port') > -1 then
        Settings.Port := sl_Settings.Values['port'];

      if sl_Settings.IndexOfName('passphrase') > -1 then
        Settings.PassPhrase := sl_Settings.Values['passphrase'];
    except
      raise;
    end;
  end;

  sl_Settings.Free;
end;

procedure TfrmMainUI.startUp;
begin
  populateSettings;
  showOnce := false;
  timerHTTP.Tag := _buildVersionTAG;
  timerHTTP.Enabled := True;
end;

procedure TfrmMainUI.saveSettings;
var
  sl_Settings: tstringlist;
  fn: string;
begin
  sl_Settings := tstringlist.Create;
  fn := System.ioutils.TPath.Combine(System.ioutils.TPath.GetDocumentsPath, 'settings.txt');
  sl_Settings.AddPair('address', Settings.Address);
  sl_Settings.AddPair('port', Settings.Port);
  sl_Settings.AddPair('passphrase', Settings.PassPhrase);
  try
    sl_Settings.SaveToFile(fn);
  except
    raise;
  end;
  sl_Settings.Free;
end;

// Load settings and plop them on the sceen
procedure TfrmMainUI.populateSettings;
begin
  loadSettings;
  e_ServerAddress.Text := Settings.Address;
  e_ServerPort.Text := Settings.Port;
  e_PassPhrase.Text := Settings.PassPhrase;
end;

procedure TfrmMainUI.FormCreate(Sender: TObject);
begin
  _InitGood := false;
  showOnce := True;
  lastIdleTimeTemp := now;
  lastIdleTempMagSensors := now;
  application.onidle := idle;
  TabControl1.TabIndex := 0; // make sure we start on first tab
end;

procedure TfrmMainUI.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkHardwareBack) and (TabControl1.TabIndex > 0) then
  begin
    PreviousTabAction1.Execute; // slide back to 1st tab on back button
    Key := 0;
  end;
end;

procedure TfrmMainUI.btn_BackClick(Sender: TObject);
begin
  PreviousTabAction1.Execute;
end;

procedure TfrmMainUI.btn_SettingsClick(Sender: TObject);
begin
  NextTabAction1.Execute;
end;

procedure TfrmMainUI.testConnection;
begin
  Settings.Address := trim(self.e_ServerAddress.Text);
  Settings.Port := trim(self.e_ServerPort.Text);
  Settings.PassPhrase := trim(self.e_PassPhrase.Text);
  saveSettings;

  _InitGood := false;
  timerHTTP.Tag := _resetTAG;
  timerHTTP.Enabled := True;
  AniIndicator1.Visible := True;
  AniIndicator1.Enabled := True;

  tthread.CreateAnonymousThread(
    procedure
    var
      idx: integer;
    begin

      for idx := 1 to 5 do
      begin
        if _InitGood then
          break;
        sleep(1000);
      end;

      tthread.Synchronize(tthread.CurrentThread,
        procedure
        begin
          AniIndicator1.Visible := false;
          AniIndicator1.Enabled := false;
          if _InitGood then
          begin
            showmessage('Connection Passed');
            PreviousTabAction1.Execute;
            startUp;
          end
          else
            showmessage('Connection Failed');
        end);
    end).Start;
end;

procedure TfrmMainUI.btn_TestConnectionClick(Sender: TObject);
begin
  testConnection
end;

procedure TfrmMainUI.e_SettingsKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkreturn then
  begin
    if Sender = e_ServerAddress then
      e_ServerPort.SetFocus
    else if Sender = e_ServerPort then
      e_PassPhrase.SetFocus
    else if Sender = e_PassPhrase then
      btn_TestConnection.SetFocus;
  end;
end;

procedure TfrmMainUI.FormActivate(Sender: TObject);
begin
  if showOnce then
  begin
    showOnce := false;
    lastIdleTimeTemp := now;
    startUp;
  end;
end;

procedure TfrmMainUI.idle(Sender: TObject; var done: Boolean);
begin

  if System.Dateutils.SecondsBetween(now, lastIdleTimeTemp) >= 10 then
  begin
    if timerHTTP.Enabled = false then
    begin
      lastIdleTimeTemp := now;
      timerHTTP.Tag := _dht11SensorTAG; // update temp every 10 seconds
      timerHTTP.Enabled := True;
      exit;
    end;
  end;

  if System.Dateutils.SecondsBetween(now, lastIdleTempMagSensors) >= 5 then
    if timerHTTP.Enabled = false then
    begin
      lastIdleTempMagSensors := now;
      timerHTTP.Tag := _magSensorsTAG; // check magnet sensor every 5 seconds
      timerHTTP.Enabled := True;
    end;
end;


// Click event on the "doors"

// Door code probably could be combined to do really handle any number of doors
// but this is mostly ment to keep things simple to read and understand then
// trying to make an overly complex and fancy program.
// Click event on each door
// Timer to do animation for Left Door

procedure TfrmMainUI.r_LeftDoorClick(Sender: TObject);
begin
  r_LeftDoor.HitTest := false;
  timerHTTP.Tag := _relay1TAG;
  timerHTTP.Enabled := True;
end;

procedure TfrmMainUI.r_RightDoorClick(Sender: TObject);
begin
  r_RightDoor.HitTest := false;
  timerHTTP.Tag := _relay2TAG;
  timerHTTP.Enabled := True;
end;

procedure TfrmMainUI.r_StatusClick(Sender: TObject);
begin
  // basically just reset the last time
  // so the idle event next time its kicked off
  // will trigger a temperature update
  lastIdleTimeTemp := 0;
end;

procedure TfrmMainUI.timer_LeftDoorTimer(Sender: TObject);
begin

  if timer_LeftDoor.Tag = 0 then // tag 0 = move door up
  begin

    if r_Left1.Visible then
    begin
      r_Left1.Visible := false;
      exit;
    end;

    if r_Left2.Visible then
    begin
      r_Left2.Visible := false;
      exit;
    end;

    if r_Left3.Visible then
    begin
      r_Left3.Visible := false;
      exit;
    end;

    if r_Left4.Visible then
    begin
      r_Left4.Visible := false;
      exit;
    end;

    timer_LeftDoor.Tag := 1;
    timer_LeftDoor.Enabled := false;
    r_LeftDoor.HitTest := True;
  end
  else
  begin // else tag != 1 so, move door down

    if not r_Left4.Visible then
    begin
      r_Left4.Visible := True;
      exit;
    end;

    if not r_Left3.Visible then
    begin
      r_Left3.Visible := True;
      exit;
    end;

    if not r_Left2.Visible then
    begin
      r_Left2.Visible := True;
      exit;
    end;

    if not r_Left1.Visible then
    begin
      r_Left1.Visible := True;
      exit;
    end;

    timer_LeftDoor.Tag := 0;
    timer_LeftDoor.Enabled := false;
    r_LeftDoor.HitTest := True;
  end

end;

// Timer to do animation for Right Door
procedure TfrmMainUI.timer_RightDoorTimer(Sender: TObject);
begin

  if timer_RightDoor.Tag = 0 then // tag 0 = move door up
  begin
    if r_Right1.Visible then
    begin
      r_Right1.Visible := false;
      exit;
    end;

    if r_Right2.Visible then
    begin
      r_Right2.Visible := false;
      exit;
    end;

    if r_Right3.Visible then
    begin
      r_Right3.Visible := false;
      exit;
    end;

    if r_Right4.Visible then
    begin
      r_Right4.Visible := false;
      exit;
    end;

    timer_RightDoor.Tag := 1;
    timer_RightDoor.Enabled := false;
    r_RightDoor.HitTest := True;
  end
  else // else tag != 1 so, move door down
  begin

    if not r_Right4.Visible then
    begin
      r_Right4.Visible := True;
      exit;
    end;

    if not r_Right3.Visible then
    begin
      r_Right3.Visible := True;
      exit;
    end;

    if not r_Right2.Visible then
    begin
      r_Right2.Visible := True;
      exit;
    end;

    if not r_Right1.Visible then
    begin
      r_Right1.Visible := True;
      exit;
    end;

    timer_RightDoor.Tag := 0;
    timer_RightDoor.Enabled := false;
    r_RightDoor.HitTest := True;
  end
end;


// Ugly way of doing this ... will probably revisit this soon
// and switch this up to get away from timerHTTP

// better way would probably been a deal to maybe pool calls and fire em off
// one by one from a list. grab one, kick off thread, do http call, get response
// do work, move to next command in the pool

procedure TfrmMainUI.timerHTTPTimer(Sender: TObject);
begin
  timerHTTP.Enabled := false;

  tthread.CreateAnonymousThread(
    procedure

    var
      errorData: string;
      processData: string;
      Tag: integer;

      procedure sendcommand(cmd: string);
      var
        url: string;
      begin
        try
          url := 'http://' + Settings.Address + ':' + Settings.Port + '/?command=' + cmd + '&id=' + Settings.PassPhrase;

          http.get(url);

          if http.ResponseCode = 200 then
            processData := http.ResponseText
          else
            errorData := http.ResponseText;
        except
          on e: exception do
          begin
            // would probably want to log / parse you errors
            // for now, cause this is just a demo type deal
            // eat it and set error text to the execption
            errorData := e.Message;
          end;
        end;
      end;

    begin
      Tag := timerHTTP.Tag;
      timerHTTP.Tag := _idleTag; // reset back to idle
      errorData := '';
      processData := '';
      try
        http.ReadTimeout := 5000;
        case Tag of
          _relay1TAG:
            sendcommand(_relay1CMD);
          _relay2TAG:
            sendcommand(_relay2CMD);
          _dht11SensorTAG:
            sendcommand(_dht11SensorCMD);
          _magSensorsTAG:
            sendcommand(_magSensorsCMD);
          _buildVersionTAG:
            sendcommand(_buildVersionCMD);
          _resetTAG:
            begin
              _InitGood := false;
              sendcommand(_resetCMD);
            end;
        end;
      finally
        tthread.Synchronize(tthread.CurrentThread,
          procedure
          begin
            if errorData <> '' then
              lbl_Error.Text := ('Error : ' + errorData)
            else if processData <> '' then
            begin
              if lbl_Error.Text <> '' then
                lbl_Error.Text := '';
              processPacket(processData);
            end;
          end);
      end;
    end).Start;
end;

procedure TfrmMainUI.processPacket(inputData: string);

// process each message header / value and do something

  procedure init;
  begin
    inputData := Stringreplace(inputData, _initHeader, '', [rfreplaceall]);
    _InitGood := True;
  end;

  procedure msg;
  begin
    inputData := Stringreplace(inputData, _msgHeader, '', [rfreplaceall]);
  end;

  procedure dht11error;
  begin
    hasDHT11error := True;
    inputData := Stringreplace(inputData, _dht11errorHeader, '', [rfreplaceall]);
  end;

  procedure dht11data;
  var
    dataBlock: tstringlist;
  begin

    hasDHT11error := false;

    inputData := Stringreplace(inputData, _dht11dataHeader, '', [rfreplaceall]);

    if OccurrencesOfChar(inputData, ';') = 2 then
    begin
      dataBlock := tstringlist.Create;
      dataBlock.Delimiter := ';';
      dataBlock.StrictDelimiter := True;
      dataBlock.DelimitedText := inputData;
      if dataBlock.Count = 3 then
      begin
        // position 0 = *F , 1 = *C
        lbl_Temp.Text := 'Temperature   ' + dataBlock[0] + '*F';
        // position 2 = Humidity %
        lbl_Humidity.Text := 'Humidity  ' + dataBlock[2] + '%';
      end
      else
      begin
        lbl_Temp.Text := 'Temperature     ?';
        lbl_Humidity.Text := 'Humidity   ?';
      end;
      dataBlock.Free;
    end;
  end;

  procedure magsensors;
  var
    dataBlock: tstringlist;

  begin
    inputData := Stringreplace(inputData, _magsensorsHeader, '', [rfreplaceall]);
    dataBlock := tstringlist.Create;
    dataBlock.Delimiter := ';';
    dataBlock.StrictDelimiter := True;
    dataBlock.DelimitedText := inputData;
    if dataBlock.Count = 2 then
    begin

      isLeftDoorOpen := dataBlock[0] = '1';
      isRightDoorOpen := dataBlock[1] = '1';

      case isLeftDoorOpen of
        True:
          begin
            lbl_LeftStatus.Text := _Opened;
            timer_LeftDoor.Tag := 0;
            timer_LeftDoor.Enabled := True;
          end;
        false:
          begin
            lbl_LeftStatus.Text := _Closed;
            timer_LeftDoor.Tag := 1;
            timer_LeftDoor.Enabled := True;
          end;
      end;

      case isRightDoorOpen of
        True:
          begin
            lbl_RightStatus.Text := _Opened;
            timer_RightDoor.Tag := 0;
            timer_RightDoor.Enabled := True;
          end;
        false:
          begin
            lbl_RightStatus.Text := _Closed;
            timer_RightDoor.Tag := 1;
            timer_RightDoor.Enabled := True;
          end;
      end;
    end;
    dataBlock.Free;
  end;

  procedure build;
  begin
    inputData := Stringreplace(inputData, _buildHeader, '', [rfreplaceall]);
    lbl_version.Text := 'v' + inputData;
  end;

begin

  // remove this chunk that INDY shows

  inputData := trim(Stringreplace(inputData, 'HTTP/1.1 200', '', [rfignorecase]));

  // cheap way to know a header possibly came in... if there are two % chars

  if OccurrencesOfChar(inputData, '%') = 2 then
  begin
    if pos(_initHeader, inputData) > 0 then
      init
    else if pos(_dht11errorHeader, inputData) > 0 then
      dht11error
    else if pos(_dht11dataHeader, inputData) > 0 then
      dht11data
    else if pos(_magsensorsHeader, inputData) > 0 then
      magsensors
    else if pos(_buildHeader, inputData) > 0 then
      build
    else if pos(_msgHeader, inputData) > 0 then
      msg;

  end;

end;

end.
