program Hubsan501S_SS_Video_Recovery;

{$R 'LangFiles.res' 'LangFiles.rc'}

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  uMainForm in 'uMainForm.pas' {MainForm},
  WMPLib_TLB in 'WMPLib_TLB.pas',
  uVideoForm in 'uVideoForm.pas' {VideoForm},
  uProgTools in 'uProgTools.pas';

{$R *.res}
{$R *.dkl_const.res}

const
  MutexName = '{D965F355-5A83-4D8E-B1F5-011C00C02B20}';
var
  MutexHandle: THandle;
begin
  // Пробуем открыть Mutex по имени
  MutexHandle := OpenMutex(MUTEX_ALL_ACCESS, False, MutexName);

  if MutexHandle <> 0 then
    begin
      // Копия нашего приложения уже запущена - Mutex уже есть
      ShowMessage('Приложение уже запущено.');
      CloseHandle(MutexHandle);
      Halt;
    end;

  // Создание Mutex
  CreateMutex(nil, False, MutexName);

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
