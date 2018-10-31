unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils,
  System.Variants, System.Actions, System.ImageList, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.Menus, Vcl.ActnList, Vcl.ImgList,
  Pipes, System.StrUtils, System.UITypes, System.IniFiles,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons,
  dxLayoutContainer, cxTextEdit, cxMaskEdit, cxButtonEdit, cxClasses,
  dxLayoutControl, cxMemo, cxLabel, dxAlertWindow, System.IOUtils, cxProgressBar,
  DKLang, cxDropDownEdit, cxRadioGroup, cxGroupBox, Winapi.ShellAPI;

type
  TMainForm = class(TForm)
    PipeConsole1: TPipeConsole;
    OpenCorrectDlg: TOpenDialog;
    SaveDlg: TSaveDialog;
    alMain: TActionList;
    aPlayCorrectVideo: TAction;
    aRecoveryVideo: TAction;
    ilCommon: TcxImageList;
    lcMainGroup_Root: TdxLayoutGroup;
    lcMain: TdxLayoutControl;
    RecoveryItem: TdxLayoutItem;
    btRecoveryVideo: TcxButton;
    PlayCorrectItem: TdxLayoutItem;
    btPlayCorrectVideo: TcxButton;
    PlayRecoveredItem: TdxLayoutItem;
    btPlayRecoveryVideo: TcxButton;
    LogGroup: TdxLayoutGroup;
    meLog: TcxMemo;
    LogItem: TdxLayoutItem;
    aLoadBrokenVideo: TAction;
    aSaveVideo: TAction;
    Timer: TTimer;
    aPlayRecoveryVideo: TAction;
    ActionGroup: TdxLayoutGroup;
    btSaveVideo: TcxButton;
    SaveItem: TdxLayoutItem;
    LoadBrokenItem: TdxLayoutItem;
    btLoadBrokenVideo: TcxButton;
    aLoadCorrectVideo: TAction;
    lbCopyRight: TcxLabel;
    CopyRightItem: TdxLayoutItem;
    RecoveryGroup: TdxLayoutGroup;
    CommonGroup: TdxLayoutGroup;
    BottomGroup: TdxLayoutGroup;
    cbLang: TComboBox;
    LangItem: TdxLayoutItem;
    OpenBrokenDlg: TOpenDialog;
    DKLang: TDKLanguageController;
    rbStoredSample: TcxRadioButton;
    rbYourSample: TcxRadioButton;
    btLoadCorrectVideo: TcxButton;
    UseGroup: TdxLayoutGroup;
    StoredSampleItem: TdxLayoutItem;
    YourSampleItem: TdxLayoutItem;
    YourSampleGroup: TdxLayoutGroup;
    LoadSampleItem: TdxLayoutItem;
    procedure PipeConsole1Error(Sender: TObject; Stream: TStream);
    procedure PipeConsole1Output(Sender: TObject; Stream: TStream);
    procedure PipeConsole1Stop(Sender: TObject; ExitValue: Cardinal);
    procedure aRecoveryVideoExecute(Sender: TObject);
    procedure aPlayCorrectVideoExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure aLoadBrokenVideoExecute(Sender: TObject);
    procedure aSaveVideoExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure aPlayRecoveryVideoExecute(Sender: TObject);
    procedure aLoadCorrectVideoExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbLangChange(Sender: TObject);
    procedure lbCopyRightClick(Sender: TObject);
    procedure rbStoredSampleClick(Sender: TObject);
    procedure rbYourSampleClick(Sender: TObject);
  private
    { Private declarations }

    FIniFile: TIniFile;

    FSeparateLine: String;
    FCleaningList: TStringList;
    FAppPath: String;
    FLoadCorrectFilename: String;
    FStoredCorrectFilename: String;
    FLoadBrokenFilename: String;
    FCorrectFilename: String;
    FBrokenFilename: String;
    FRecoveredVideoFilename: String;
    FSaveVideoFilename: String;
    function ExecConsoleProgramm(ACommandText: String;
                                 ACorrectExitCode: Cardinal;
                                 out AOutputData, AErrorData: String;
                                 out AProcessExitCode: Cardinal): Boolean;
    procedure SetLoadBrokenFilename(const Value: String);
    procedure SetLoadCorrectFilename(const Value: String);

    procedure InitLanguages;

    procedure LoadIniFile;
    procedure SaveIniFile;
  public
    { Public declarations }
    procedure EnableControls;

    property SeparateLine: String read FSeparateLine;

    property LoadCorrectFilename: String read FLoadCorrectFilename write SetLoadCorrectFilename;
    property LoadBrokenFilename: String read FLoadBrokenFilename write SetLoadBrokenFilename;
  end;

  // Проверить соответствие кодов, тем кодам которые возвращаются вызываемыми программами
  TExitCodes = (ecSuccess              = 0,
                ecSignToolNotInPath    = 1,
                ecAssemblyDirectoryBad = 2,
                ecPFXFilePathBad       = 4,
                ecPasswordMissing      = 8,
                ecSignFailed           = 16,
                ecUnknownError         = 32);

  function GetExitCodes(AExitCode: Cardinal): String;

const
  RECOVERY_PREFIX = 'Recovery_';

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uVideoForm, uProgTools;

function GetExitCodes(AExitCode: Cardinal): String;
begin
  Result := DKLangConstW('DL_ExitCodeNoRegisteredText');

  case TExitCodes(AExitCode) of
  ecSuccess             : Result := DKLangConstW('DL_ExitCodeSuccessText');
  ecSignToolNotInPath   : Result := DKLangConstW('DL_ExitCodeSignToolNotInPathText');
  ecAssemblyDirectoryBad: Result := DKLangConstW('DL_ExitCodeAssemblyDirectoryBadText');
  ecPFXFilePathBad      : Result := DKLangConstW('DL_ExitCodePFXFilePathBadText');
  ecPasswordMissing     : Result := DKLangConstW('DL_ExitCodePasswordMissingText');
  ecSignFailed          : Result := DKLangConstW('DL_ExitCodeSignFailedText');
  ecUnknownError        : Result := DKLangConstW('DL_ExitCodeUnknownErrorText');
  end;
end;

function GetStringFromStream(AStream: TStream; AEncoding: TEncoding): String;
var
  SS: TStringStream;
begin
  SS := TStringStream.Create('', AEncoding); // TEncoding.Default
  try
    AStream.Seek(0, soBeginning);
    SS.CopyFrom(AStream, AStream.Size);
    SS.Seek(0, soBeginning);
    Result := SS.DataString;
  finally
    FreeAndNil(SS);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FCleaningList := TStringList.Create;

  FAppPath := ExtractFilePath(ParamStr(0));

  FIniFile := TIniFile.Create(FAppPath + 'setting.cfg');

  FStoredCorrectFilename := FAppPath + 'hubsan_good.mp4';
  FLoadCorrectFilename := FStoredCorrectFilename;
  FLoadBrokenFilename := '';
  FRecoveredVideoFilename := '';
  FSaveVideoFilename := '';

  FSeparateLine := StringOfChar('=', 65);

  InitLanguages;

  LoadIniFile;

  TimerTimer(nil);
end;

procedure TMainForm.InitLanguages;
var
  i: Integer;
begin
  LangManager.RegisterLangResource(HInstance, 'LNG_RUSSIAN', 1049);

  for i := 0 to LangManager.LanguageCount-1 do
    cbLang.Items.Add(LangManager.LanguageNames[i]);
end;

procedure TMainForm.lbCopyRightClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://github.com/apronin83/hubsan_video_recovery', nil, nil, SW_NORMAL);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i := FCleaningList.Count-1 downto 0 do
    try
      TDirectory.Delete(FCleaningList[i], True);
    except
    end;

  FreeAndNil(FCleaningList);

  FreeAndNil(FIniFile);
end;

procedure TMainForm.aLoadCorrectVideoExecute(Sender: TObject);
begin
  if not OpenCorrectDlg.Execute then Exit;

  LoadCorrectFilename := OpenCorrectDlg.FileName;

  FLoadBrokenFilename := '';
  FRecoveredVideoFilename := '';
end;

procedure TMainForm.aLoadBrokenVideoExecute(Sender: TObject);
begin
  if not OpenBrokenDlg.Execute then Exit;

  LoadBrokenFilename := OpenBrokenDlg.FileName;

  FRecoveredVideoFilename := '';
end;

procedure TMainForm.aPlayCorrectVideoExecute(Sender: TObject);
var
  ErrorMsg: String;
begin
  if not FileExists(LoadCorrectFilename) then
    begin
      ShowMessage(DKLangConstW('DL_VideoFileNotFoundMsg'));
      Exit;
    end;

  if not PlayVideo(LoadCorrectFilename, ErrorMsg) then
    ShowMessage(ErrorMsg);
end;


procedure TMainForm.aRecoveryVideoExecute(Sender: TObject);
var
  ExitCode: Cardinal;
  CorrectTextIndex, RecoverTextIndex: Integer;
  AnalyzeCommandText,
  CorrectCommandText,
  RecoverCommandText,
  OutputData, ErrorData: String;
  ResultDataList: TStringList;
  WorkingDirectory: String;
  TryRecoveredVideoFilename: String;
begin
  try
  meLog.Clear;

  meLog.Lines.Add(SeparateLine);
  meLog.Lines.Add('recover_mp4.exe corrupted_file result.h264 --noaudio --ext' + #13#10 + ParseCommandParameters('recover_mp4.exe corrupted_file result.h264 --noaudio --ext').Text);

  meLog.Lines.Add(SeparateLine);
  meLog.Lines.Add('ffmpeg.exe -r 30.000 -i result.h264 -c:v copy result.mp4' + #13#10 + ParseCommandParameters('ffmpeg.exe -r 30.000 -i result.h264 -c:v copy result.mp4').Text);

  //----------------------------------------------------------------------------

  WorkingDirectory := MakeWorkingFolder(TPath.GetTempPath);

  FCleaningList.Add(WorkingDirectory);

  FCorrectFilename := ExpandFileName(WorkingDirectory + ExtractFileName(FLoadCorrectFilename));
  FBrokenFilename := ExpandFileName(WorkingDirectory + ExtractFileName(FLoadBrokenFilename));

  TFile.Copy(ExpandFileName(FLoadCorrectFilename), FCorrectFilename, True);
  TFile.Copy(ExpandFileName(FLoadBrokenFilename), FBrokenFilename, True);

  // Step 1
  // Analyzing...

  AnalyzeCommandText := 'recover_mp4.exe ' + FCorrectFilename + ' --analyze';

  meLog.Lines.Add(SeparateLine);
  meLog.Lines.Add(DKLangConstW('DL_StartLine'));
  meLog.Lines.Add(AnalyzeCommandText);
  meLog.Lines.Add(DKLangConstW('DL_AnalyzingLine'));
  meLog.Lines.Add(SeparateLine);

  ErrorData := '';
  OutputData := '';

  if not ExecConsoleProgramm(AnalyzeCommandText,
                             0,
                             OutputData,
                             ErrorData,
                             ExitCode) then
    begin
      meLog.Lines.Add(DKLangConstW('DL_ErrorLine'));
      meLog.Lines.Add(ErrorData);
      Exit;
    end
  else
    begin
      meLog.Lines.Add(DKLangConstW('DL_CompleteLine'));
      meLog.Lines.Add(OutputData);
    end;

  //----------------------------------------------------------------------------

  ResultDataList := GetStringList(OutputData);
  try
    CorrectTextIndex := ResultDataList.IndexOf('Now run the following command to start recovering:');

    if CorrectTextIndex = -1 then
      begin
        meLog.Lines.Add(SeparateLine);
        meLog.Lines.Add(DKLangConstW('DL_ErrorLine'));
        meLog.Lines.Add(DKLangConstW('DL_NoCommandCorrectLine'));
        Exit;
      end;

    CorrectCommandText := StringReplace(ResultDataList[CorrectTextIndex+1],
                                        'corrupted_file',
                                        FBrokenFilename,
                                        [rfReplaceAll, rfIgnoreCase]);

    RecoverTextIndex := ResultDataList.IndexOf('Then use ffmpeg to mux the final file:' + ' ');

    if RecoverTextIndex = -1 then
      begin
        meLog.Lines.Add(SeparateLine);
        meLog.Lines.Add(DKLangConstW('DL_ErrorLine'));
        meLog.Lines.Add(DKLangConstW('DL_NoCommandRecoveryLine'));
        Exit;
      end;

    RecoverCommandText := ResultDataList[RecoverTextIndex+1];
  finally
    FreeAndNil(ResultDataList);
  end;

  //----------------------------------------------------------------------------
  // Step 2
  // Correcting...

  ErrorData := '';
  OutputData := '';

  meLog.Lines.Add(SeparateLine);
  meLog.Lines.Add(DKLangConstW('DL_StartLine'));
  meLog.Lines.Add(CorrectCommandText);
  meLog.Lines.Add(DKLangConstW('DL_CorrectingLine'));
  meLog.Lines.Add(SeparateLine);

  if not ExecConsoleProgramm(CorrectCommandText,
                             0,
                             OutputData,
                             ErrorData,
                             ExitCode) then
    begin
      meLog.Lines.Add(DKLangConstW('DL_ErrorLine'));
      meLog.Lines.Add(ErrorData);
      Exit;
    end
  else
    begin
      meLog.Lines.Add(DKLangConstW('DL_CompleteLine'));
      meLog.Lines.Add(OutputData);
    end;

  //----------------------------------------------------------------------------
  // Step 3
  // Recovering...

  ErrorData := '';
  OutputData := '';

  TryRecoveredVideoFilename := WorkingDirectory + 'result' + ExtractFileExt(FBrokenFilename);

  RecoverCommandText := StringReplace(RecoverCommandText,
                                      'result' + ExtractFileExt(FBrokenFilename),
                                      TryRecoveredVideoFilename,
                                      [rfReplaceAll, rfIgnoreCase]);
  meLog.Lines.Add(SeparateLine);
  meLog.Lines.Add(DKLangConstW('DL_StartLine'));
  meLog.Lines.Add(RecoverCommandText);
  meLog.Lines.Add(DKLangConstW('DL_RecoveringLine'));
  meLog.Lines.Add(SeparateLine);

  if not ExecConsoleProgramm(RecoverCommandText,
                             0,
                             OutputData,
                             ErrorData,
                             ExitCode) then
    begin
      meLog.Lines.Add(DKLangConstW('DL_ErrorLine'));
      meLog.Lines.Add(ErrorData);
      Exit;
    end
  else
    begin
      meLog.Lines.Add(DKLangConstW('DL_CompleteLine'));
      meLog.Lines.Add(OutputData);
    end;

  FRecoveredVideoFilename := TryRecoveredVideoFilename;

  finally
  end;
end;

procedure TMainForm.aPlayRecoveryVideoExecute(Sender: TObject);
var
  ErrorMsg: String;
begin
  if not FileExists(FRecoveredVideoFilename) then
    begin
      ShowMessage(DKLangConstW('DL_VideoFileNotFoundMsg'));
      Exit;
    end;

  if not PlayVideo(FRecoveredVideoFilename, ErrorMsg) then
    ShowMessage(ErrorMsg);
end;

procedure TMainForm.aSaveVideoExecute(Sender: TObject);
begin
  if not SaveDlg.Execute then Exit;

  FSaveVideoFilename := ExpandFileName(SaveDlg.FileName);

  meLog.Lines.Add(SeparateLine);
  meLog.Lines.Add(DKLangConstW('DL_StartLine'));
  meLog.Lines.Add(DKLangConstW('DL_CopyToLine') + ' ' + FSaveVideoFilename);
  meLog.Lines.Add(DKLangConstW('DL_CopyLine'));
  meLog.Lines.Add(SeparateLine);

  if FileExists(FSaveVideoFilename) then
    if MessageDlg(DKLangConstW('DL_FileAlreadyExistsMsg'), mtConfirmation, mbYesNo, 0) = mrNo then
      begin
        meLog.Lines.Add(DKLangConstW('DL_CopyAbortLine'));
        Exit;
      end;

  TFile.Copy(FRecoveredVideoFilename, FSaveVideoFilename, True);

  meLog.Lines.Add(DKLangConstW('DL_CompleteLine'));
end;

procedure TMainForm.cbLangChange(Sender: TObject);
var
  idx: Integer;
begin
  idx := cbLang.ItemIndex;

  if idx < 0 then idx := 0;

  LangManager.LanguageID := LangManager.LanguageIDs[idx];

  SaveIniFile;
end;

procedure TMainForm.EnableControls;
begin
end;

function TMainForm.ExecConsoleProgramm(ACommandText: String;
                                       ACorrectExitCode: Cardinal;
                                       out AOutputData, AErrorData: String;
                                       out AProcessExitCode: Cardinal): Boolean;
const
  WaitMinute = 15;
  MillisecondsPerMinute = 60000;
var
  CommandList: TStringList;
  OutputStream, ErrorStream: TMemoryStream;
  ResCode, ProcessId:  Cardinal;
begin
  AOutputData := '';
  AErrorData := '';

  OutputStream := TMemoryStream.Create;
  ErrorStream := TMemoryStream.Create;
  CommandList := ParseCommandParameters(ACommandText);
  try
    CommandList.LineBreak := ' ';

    ResCode := PipeConsole1.Execute(CommandList[0],
                                    CommandList.Text,
                                    OutputStream,
                                    ErrorStream,
                                    AProcessExitCode,
                                    ProcessId,
                                    nil,
                                    WaitMinute * MillisecondsPerMinute);

    Result := (AProcessExitCode = ACorrectExitCode);

    if ErrorStream.Size > 0 then
      AErrorData := GetStringFromStream(ErrorStream, TEncoding.Default);

    AOutputData := GetStringFromStream(OutputStream, TEncoding.Default);

    if ResCode = ERROR_TIMEOUT then
      begin
        PipeConsole1.SendCtrlC;
        AErrorData := DKLangConstW('DL_ExecutionTimeExceededLine');
        AOutputData := '';
        Result := False;
      end;
  finally
    FreeAndNil(CommandList);
    FreeAndNil(ErrorStream);
    FreeAndNil(OutputStream);
  end;
end;

procedure TMainForm.PipeConsole1Error(Sender: TObject; Stream: TStream);
begin
  meLog.Lines.Add(DKLangConstW('DL_ErrorOutLine') + ' ' + GetStringFromStream(Stream, TEncoding.Default));
end;

procedure TMainForm.PipeConsole1Output(Sender: TObject; Stream: TStream);
begin
  meLog.Lines.Add(DKLangConstW('DL_OutputOutLine') + ' ' + GetStringFromStream(Stream, TEncoding.Default));
end;

procedure TMainForm.PipeConsole1Stop(Sender: TObject; ExitValue: Cardinal);
begin
  meLog.Lines.Add(DKLangConstW('DL_ExitCodeOutLine') + ' ' + GetExitCodes(ExitValue));
end;

procedure TMainForm.rbStoredSampleClick(Sender: TObject);
begin
  FLoadCorrectFilename := FStoredCorrectFilename;
  FLoadBrokenFilename := '';
  FRecoveredVideoFilename := '';
end;

procedure TMainForm.rbYourSampleClick(Sender: TObject);
begin
  FLoadCorrectFilename := '';
  FLoadBrokenFilename := '';
  FRecoveredVideoFilename := '';
end;

procedure TMainForm.LoadIniFile;
begin
  cbLang.ItemIndex := FIniFile.ReadInteger('COMMON', 'LANGUAGE_IDX', 0);
  LangManager.LanguageID := LangManager.LanguageIDs[cbLang.ItemIndex];
end;

procedure TMainForm.SaveIniFile;
begin
  try
    FIniFile.WriteInteger('COMMON', 'LANGUAGE_IDX', cbLang.ItemIndex);
  finally
    FIniFile.UpdateFile;
  end;
end;

procedure TMainForm.SetLoadBrokenFilename(const Value: String);
var
  SaveRecoveryFile: String;
  SaveRecoveryExt: String;
begin
  SaveRecoveryFile := RECOVERY_PREFIX + ExtractFileName(Value);
  SaveRecoveryExt  := ExtractFileExt(Value);

  SaveDlg.FileName := SaveRecoveryFile;
  SaveDlg.DefaultExt := '*' + SaveRecoveryExt;
  SaveDlg.Filter := Format('%s|*%s', [UpperCase(Copy(SaveRecoveryExt, 2, Length(SaveRecoveryExt))), SaveRecoveryExt]);

  FLoadBrokenFilename := Value;
end;

procedure TMainForm.SetLoadCorrectFilename(const Value: String);
begin
  FLoadCorrectFilename := Value;
end;

function CheckFilename(AFilename: String): Boolean;
begin
  Result := (AFilename <> '') and FileExists(AFilename);
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  LoadSampleItem.Enabled    := rbYourSample.Checked;
  PlayCorrectItem.Enabled   := rbYourSample.Checked and CheckFilename(FLoadCorrectFilename);
  LoadBrokenItem.Enabled    := CheckFilename(FLoadCorrectFilename);
  RecoveryItem.Enabled      := CheckFilename(FLoadCorrectFilename) and
                               CheckFilename(FLoadBrokenFilename);
  PlayRecoveredItem.Enabled := CheckFilename(FRecoveredVideoFilename);
  SaveItem.Enabled          := CheckFilename(FRecoveredVideoFilename);
end;

end.
