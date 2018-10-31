unit uVideoForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.OleCtrls,
  WMPLib_TLB;

type
  TVideoForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FMediaPlayer: TWindowsMediaPlayer;
    FFilename: String;
  public
    procedure Play;
    property Filename: String read FFilename write FFilename;
  end;

  function PlayVideo(AFilename: String; out AErrorMessage: String): Boolean;

implementation

{$R *.dfm}

function PlayVideo(AFilename: String; out AErrorMessage: String): Boolean;
var
  VideoForm: TVideoForm;
begin
  Result := True;

  VideoForm := TVideoForm.Create(nil);
  try
    try
      VideoForm.Caption := ExtractFileName(AFilename);
      VideoForm.Filename := AFilename;

      VideoForm.Play;

      VideoForm.ShowModal;
    except
      on E: Exception do
        begin
          Result := False;
          AErrorMessage := E.Message;
        end;
    end;
  finally
    VideoForm.Release;
  end;
end;

procedure TVideoForm.FormCreate(Sender: TObject);
begin
  FMediaPlayer:= TWindowsMediaPlayer.Create(Self);

  with FMediaPlayer do
    begin

      Width := 214;
      Height := 160;
      Top := 8;
      Left := 8;
      TabOrder := 1;
      Align := alClient;
      Parent := Self;
      Visible:= true
    end;

  // скармливаем адрес видеопотока (или путь к видеофайлу)
  // прошу обратить внимание, что это может быть и не IP,
  // а адрес DDNS, зарегистрированный для сервера трансляции
  //FMediaPlayer.URL:= 'http://www.vesti.ru/video1.asx?vid=onair';

  // растягиваем видео на весь контрол
  FMediaPlayer.ControlInterface.stretchToFit := true;
  //FMediaPlayer.uiMode := 'none';
  //FMediaPlayer.uiMode := 'mini';
  FMediaPlayer.uiMode := 'full';
  FMediaPlayer.enableContextMenu := true;
end;

procedure TVideoForm.FormDestroy(Sender: TObject);
begin
  // приостанавливаем клиента
  FMediaPlayer.controls.stop;

  FreeAndNil(FMediaPlayer);
end;

procedure TVideoForm.Play;
begin
  FMediaPlayer.URL := FFilename;

  FMediaPlayer.settings.set_volume(100);

  FMediaPlayer.controls.play;

  //FMediaPlayer.currentMedia.imageSourceWidth
  //FMediaPlayer.currentMedia.imageSourceWidth

end;

end.
