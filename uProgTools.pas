unit uProgTools;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.IOUtils;

function GetStringList(AString: String): TStringList;
function MakeWorkingFolder(APath: String): String;
function ParseCommandParameters(ACommandText: String): TStringList;

implementation

function GetStringList(AString: String): TStringList;
begin
  Result := TStringList.Create;
  Result.Text := AString;
end;

function MakeWorkingFolder(APath: String): String;
  function GenerateDirectory: String;
  begin
    Result := APath + ChangeFileExt(TPath.GetRandomFileName, '');
  end;
begin
  Result := GenerateDirectory;

  while TDirectory.Exists(Result) do
    Result := GenerateDirectory;

  Result := IncludeTrailingPathDelimiter(Result);

  Result := ExpandFileName(Result);

  TDirectory.CreateDirectory(Result);
end;

function ParseCommandParam(P: PChar; var Param: string): PChar;
var
  i, Len: Integer;
  Start, S: PChar;
begin
  // U-OK
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      Inc(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break;
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Inc(Len);
        Inc(P);
      end;
      if P[0] <> #0 then
        Inc(P);
    end
    else
    begin
      Inc(Len);
      Inc(P);
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
      if P[0] <> #0 then Inc(P);
    end
    else
    begin
      S[i] := P^;
      Inc(P);
      Inc(i);
    end;
  end;

  Result := P;
end;

function ParseCommandParameters(ACommandText: String): TStringList;
var
  Parameters: PWideChar;
  Param: String;
begin
  Parameters := PWideChar(ACommandText);

  Result := TStringList.Create;

  while True do
    begin
      Parameters := ParseCommandParam(Parameters, Param);

      if Param = '' then Break;

      Result.Add(Param);
    end;
end;

end.
