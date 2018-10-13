{

FreePascal / Lazarus PiDuinoDroid Garage Opener
Project uses a Raspberry Pi 3 with a touch screen

https://backports.debian.org/Instructions/ <---- needed to run latest FPC/Lazarus
https://forum.lazarus.freepascal.org/index.php/topic,38728.15.html <---- when I had issues installing components
https://github.com/JurassicPork/TLazSerial <---- Serial Port component for Lazarus / Linux
http://wiki.freepascal.org/Indy_with_Lazarus <---- INDY components for Lazarus

Designed for my own usage but available to everyone to maybe give ideas.
Steven.Chesser@twc.com

}

{
 TLazSerial - I had to modify it a bit to compile as it didn't like a section about the baud rates available.
}

{
  things to worry about / to-do
  1 - protect serial object better? Not sure if the CS works like I hope it does
  2 - check if arduino communications are lost or not there to begin with
  3 - add configuration screen for port / ID passphrase
  4 - alt-f4 only way to close program
  5 - date/time format is set to US style, cause well I live in the US
  6 - Optimization could be done in a lot of places probably
  7 - Make it HTTPS and add more better security - Didn't want to over complicate this for now
  8 - Doesn't remember state of sounds when restarted
  9 - The communcations between everything is a simple single line text + CRLF design.
        Maybe switch to JSON between Pi / Arduino / FMX Client App down the road?
 10 - Change triangles maybe to match what the FMX does?
 11 - No logging added yet
 12 - debugger output screen would be nice
}

unit frm_MainMenu;

{$mode objfpc}{$H+}

interface

uses
  io, IdContext, Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Buttons, LazSerial, IdHTTPServer,
  IdCustomHTTPServer, Process;


// command response headers

const
  _init = '%init%';
  _dht11error = '%dht11error%';
  _dht11data = '%dht11data%';
  _magsensors = '%magsensor%';
  _build = '%build%';
  _msg = '%msg%';
  _sound = '%sound%';
  _motion = '%motion%';

  // ID / PassPhrase

  _myID = '767D299B-AACD-47F2-955F-F1C28973C289'; // can be anything really

  // Strings
  _Opened = 'Opened';
  _Closed = 'Closed';
  _SoundsOn = 'Sounds On';
  _SoundsOff = 'Sounds Off';

  // Colors
  _GarageButtonIdle = clgreen;
  _GarageButtonPress = clyellow;

  _SoundsButtonOn = clgreen;
  _SoundsButtonOnFont = clwhite;

  _SoundsButtonOff = clyellow;
  _SoundsButtonOffFont = clblack;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    ck_Sounds: TButton;
    http: TIdHTTPServer;
    timer_Idle: TIdleTimer;
    lbl_msg: TLabel;
    lbl_Version: TLabel;
    lbl_Temp: TLabel;
    lbl_Humidity: TLabel;
    lbl_DateTime: TLabel;
    timer_RightDoor: TTimer;
    pnl_Middle: TPanel;
    serial: TLazSerial;
    lbl_LeftDoor: TLabel;
    lbl_leftStatus: TLabel;
    lbl_RightDoor: TLabel;
    lbl_rightStatus: TLabel;
    pnl_Top: TPanel;
    pnl_Bottom: TPanel;
    pnl_left: TPanel;
    pnl_right: TPanel;
    pnl_Temp: TPanel;
    pnl_Humidity: TPanel;
    pnl_DateTime: TPanel;
    sp_leftArrow: TShape;
    sp_rightArrow: TShape;
    timer_LeftDoor: TTimer;
    timer_ScreenCheck: TTimer;
    timer_ComportInit: TTimer;
    procedure BothDoorClick(Sender: TObject);
    procedure ck_SoundsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure httpCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure timer_IdleTimer(Sender: TObject);
    procedure LeftDoorClick(Sender: TObject);
    procedure Timer_leftDoorTimer(Sender: TObject);
    procedure RightDoorClick(Sender: TObject);
    procedure Timer_rightDoorTimer(Sender: TObject);
    procedure Timer_ScreenCheckTimer(Sender: TObject);
    procedure serialRxData(Sender: TObject);
    procedure sp_leftArrowMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);

    procedure sp_rightArrowMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure timer_ComportInitTimer(Sender: TObject);
  private
    isLeftDoorWorking: boolean;
    isRightDoorWorking: boolean;
    isLeftDoorOpen: boolean;
    isRightDoorOpen: boolean;
    isScreenON: boolean;
    hasDHT11error: boolean;
    CS: TRTLCriticalSection;
    procedure processPacket(inputData: string);
  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

function OccurrencesOfChar(const S: string; const C: char): integer;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      inc(result);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  InitCriticalSection(CS);
  isLeftDoorWorking := False;
  isRightDoorWorking := False;
  isLeftDoorOpen := False;
  isRightDoorOpen := False;
  hasDHT11error := False;
  isScreenOn := True;
end;

procedure TfrmMain.httpCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  idx: integer;
  command: string;
  id: string;
  comResponse: string;
begin
  idx := 0;
  command := '';
  id := '';
  comResponse := '';

  for idx := 0 to ARequestInfo.params.Count - 1 do
  begin
    if ARequestInfo.params.Names[idx] = 'command' then
      command := ARequestInfo.params.ValueFromIndex[idx]
    else
    if ARequestInfo.params.Names[idx] = 'id' then
      id := ARequestInfo.params.ValueFromIndex[idx];
  end;

  if (command <> '') and (id = _myID) then
  begin
    try
      EnterCriticalSection(cs);
      try
        serial.writedata(command);
        comResponse := Serial.SynSer.Recvstring(2000);
      finally
        LeaveCriticalSection(cs);
      end;
      aresponseinfo.ResponseNo := 200;
      aresponseinfo.Responsetext := comResponse;
    except
      on e: Exception do
      begin
        aresponseinfo.ResponseNo := 500;
        aresponseinfo.ResponseText := e.message;
      end;
    end;

  end
  else
  begin
    aresponseinfo.ResponseNo := 400;
    aresponseinfo.ResponseText := 'Invalid Service Request by end-user';
  end;
end;



procedure TfrmMain.timer_IdleTimer(Sender: TObject);
var
  Randy: byte;
begin
  // super ugly way but works to get updates of sorts.
  // this is a garage door... so we can wait a momment for something to update
  // if not, can make this a bit more systematic if you please, to check passed time
  // or whatever you want.

  EnterCriticalSection(cs);
  try
    Randy := random(6);
    case Randy of
      0..3: serial.WriteData('4'); // mag sensor update
      4: serial.WriteData('T'); // temp sensors update
      5: serial.WriteData('A'); // audio/sounds mode
    end;
  finally
    LeaveCriticalSection(cs);
  end;
  lbl_DateTime.Caption := datetostr(now) + '    ' + timetostr(now) +
    '     ' + LongDayNames[dayofweek(now)];
  activecontrol := nil;
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  try
    Serial.active := False;
    http.active := False;
    DoneCriticalSection(cs);
  finally
  end;
end;

procedure TfrmMain.BothDoorClick(Sender: TObject);
begin
  LeftDoorClick(Sender);
  sleep(500);
  RightDoorClick(Sender);
end;

procedure TfrmMain.ck_SoundsClick(Sender: TObject);
begin
  // tap stop is disabled for ck_sounds but selection box still
  // wants to appear around it
  // this "fixes" it for now
  ck_sounds.Enabled := False;
  if ck_sounds.tag = 0 then
  begin

    EnterCriticalSection(cs);
    try
      serial.writedata('S');
      ck_sounds.tag := 1;
      ck_sounds.Caption := 'Sounds On';
      ck_sounds.Color := _SoundsButtonON;
      ck_sounds.Font.Color := _SoundsButtonONfont;
    finally
      LeaveCriticalSection(cs);
    end;

  end
  else // enable sounds
  begin
    EnterCriticalSection(cs);
    try
      serial.writedata('M'); // disable sounds
      ck_sounds.tag := 0;
      ck_sounds.Caption := _SoundsOff;
      ck_sounds.color := _SoundsButtonOff;
      ck_sounds.Font.Color := _SoundsButtonOffFont;
    finally
      LeaveCriticalSection(cs);
    end;
  end;
  ck_sounds.Enabled := True;
  mouse.CursorPos := point(Width div 2, Height div 2);
end;



procedure TfrmMain.LeftDoorClick(Sender: TObject);
begin
  if isLeftDoorWorking then
    exit;
  sp_leftArrow.Brush.Color := _GarageButtonPress;
  isLeftDoorWorking := True;
  timer_LeftDoor.Enabled := True;
  EnterCriticalSection(cs);
  try
    serial.writedata('1');
  finally
    LeaveCriticalSection(cs);
  end;
end;


procedure TfrmMain.Timer_leftDoorTimer(Sender: TObject);
begin
  timer_LeftDoor.Enabled := False;
  isLeftDoorWorking := False;
  sp_leftArrow.Brush.Color := _GarageButtonIdle;
  mouse.CursorPos := point(Width div 2, Height div 2);

end;


procedure TfrmMain.Timer_rightDoorTimer(Sender: TObject);
begin
  timer_RightDoor.Enabled := False;
  isRightDoorWorking := False;
  sp_rightArrow.Brush.Color := _GarageButtonIdle;
  mouse.CursorPos := point(Width div 2, Height div 2);
end;

procedure TfrmMain.Timer_ScreenCheckTimer(Sender: TObject);
var
  p: tprocess;
begin

  if isScreenOn = False then // we already turned then screen off
    exit;

  isScreenON := False;
  p := tprocess.Create(nil);
  p.Executable := 'xset';
  p.Parameters.add('dpms');
  p.parameters.add('force');
  p.parameters.add('off');
  p.Execute;
  p.Free;

end;

procedure TfrmMain.RightDoorClick(Sender: TObject);
begin
  if isRightDoorWorking then
    exit;
  sp_rightArrow.Brush.Color := _GarageButtonPress;
  isRightDoorWorking := True;
  timer_RightDoor.Enabled := True;
  EnterCriticalSection(cs);
  try
    serial.writedata('2');
  finally
    LeaveCriticalSection(cs);
  end;
end;


procedure TfrmMain.serialRxData(Sender: TObject);
var
  dataRead: string;
begin
  EnterCriticalSection(cs);
  try
    if Serial.DataAvailable then
    begin
      DataRead := Serial.SynSer.Recvstring(2000);
      processPacket(dataRead);
    end;
  finally
    LeaveCriticalSection(cs);
  end;
end;

procedure TfrmMain.sp_leftArrowMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  leftdoorclick(Sender);
end;



procedure TfrmMain.sp_rightArrowMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  rightdoorclick(Sender);
end;

procedure TfrmMain.timer_ComportInitTimer(Sender: TObject);
begin
  timer_ComportInit.Enabled := False;
  EnterCriticalSection(cs);
  try
    serial.active := True;
    sleep(500);
    serial.WriteData('R'); // after we enable the comport, send R to force a Reset
  finally
    LeaveCriticalSection(cs);
  end;
  http.active := True;
end;


procedure TfrmMain.processPacket(inputData: string);

// init and msg are similar. idea is to maybe change font between the two?
// or something extra in init?

  procedure init;
  begin
    inputData := Stringreplace(inputData, _init, '', [rfreplaceall]);
    lbl_msg.Caption := inputData;
    ck_sounds.Enabled := True;
  end;

  procedure msg;
  begin
    inputData := Stringreplace(inputData, _msg, '', [rfreplaceall]);
    lbl_msg.Caption := inputData;
  end;

  procedure dht11error;
  begin
    hasDHT11error := True;
    inputData := Stringreplace(inputData, _dht11error, '', [rfreplaceall]);
    lbl_msg.Caption := _dht11error;
  end;

  procedure dht11data;
  var
    dataBlock: TStringList;
  begin

    if hasDHT11error then
      lbl_msg.Caption := 'Waiting...';

    hasDHT11error := False;
    inputData := Stringreplace(inputData, _dht11data, '', [rfreplaceall]);

    if OccurrencesOfChar(inputData, ';') = 2 then
    begin
      dataBlock := TStringList.Create;
      dataBlock.Delimiter := ';';
      dataBlock.StrictDelimiter := True;
      dataBlock.DelimitedText := inputData;
      if dataBlock.Count = 3 then
      begin
        // position 0 = *F , 1 = *C
        lbl_temp.Caption := 'Temp   ' + dataBlock[0] + '*F';
        // position 2 = Humidity %
        lbl_Humidity.Caption := 'Humidity ' + dataBlock[2] + '%';
      end
      else
      begin
        lbl_temp.Caption := 'Temp    ?';
        lbl_Humidity.Caption := 'Humidity   ?';
      end;
      dataBlock.Free;
    end;
  end;


  procedure magsensors;
  var
    dataBlock: TStringList;

  begin
    inputData := Stringreplace(inputData, _magsensors, '', [rfreplaceall]);
    dataBlock := TStringList.Create;
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
          lbl_leftStatus.Caption := _Opened;
          sp_leftArrow.shape := stTriangleDown;
        end;
        False:
        begin
          lbl_leftStatus.Caption := _Closed;
          sp_leftArrow.shape := stTriangle;
        end;
      end;

      case isRightDoorOpen of
        True:
        begin
          lbl_rightStatus.Caption := _Opened;
          sp_rightArrow.shape := stTriangleDown;
        end;
        False:
        begin
          lbl_rightStatus.Caption := _Closed;
          sp_rightArrow.shape := stTriangle;
        end;
      end;
    end;
    dataBlock.Free;
  end;

  procedure build;
  begin
    inputData := Stringreplace(inputData, _build, '', [rfreplaceall]);
    lbl_version.Caption := 'v' + inputData;
  end;

  procedure sound;
  begin
    inputData := Stringreplace(inputData, _sound, '', [rfreplaceall]);
    if inputData = '0' then
    begin
      ck_sounds.Tag := 0;
      ck_sounds.Caption := _SoundsOff;
      ck_sounds.color := _SoundsButtonOff;
      ck_sounds.Font.Color := _SoundsButtonOffFont;
    end
    else
    begin
      ck_sounds.Tag := 1;
      ck_sounds.Caption := _SoundsOn;
      ck_sounds.color := _SoundsButtonOn;
      ck_sounds.Font.Color := _SoundsButtonOnFont;
    end;
  end;

  procedure motion;
  var
    p: tprocess;
  begin
    timer_ScreenCheck.Enabled := False;
    timer_ScreenCheck.Enabled := True;

    if isScreenOn then
      exit; // no need to turn screen on, it already is.. but at least reset the timer.

    isScreenON := True;
    inputData := Stringreplace(inputData, _motion, '', [rfreplaceall]);
    p := tprocess.Create(nil);
    p.Executable := 'xset';
    p.Parameters.add('dpms');
    p.parameters.add('force');
    p.parameters.add('on');
    p.Execute;
    p.Free;
  end;

begin

  inputData := trim(inputData);

  if OccurrencesOfChar(inputData, '%') = 2 then
  begin
    if pos(_init, inputData) > 0 then
      init
    else
    if pos(_dht11error, inputData) > 0 then
      dht11error
    else
    if pos(_dht11data, inputData) > 0 then
      dht11data
    else
    if pos(_magsensors, inputData) > 0 then
      magsensors
    else
    if pos(_build, inputData) > 0 then
      build
    else
    if pos(_msg, inputData) > 0 then
      msg
    else
    if pos(_sound, inputData) > 0 then
      sound;
    if pos(_motion, inputdata) > 0 then
      motion;
  end;

end;

initialization
  randomize;
  with DefaultFormatSettings do
  begin
    DateSeparator := '/';
    shortdateformat := 'mm/dd/yyyy';
    longdateformat := 'mm/dd/yyyy';
    shorttimeformat := 'hh:mm am/pm';
    longtimeformat := 'hh:mm am/pm';
  end;

end.
