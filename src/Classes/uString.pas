unit uString;

interface

uses uUnityClass, uEndianStream;

type
  TString = class (TUnityClass)
    private
      var m_value: AnsiString;
    public
      procedure Load(const stream: TEndianStream); override;
  end;

implementation

procedure TString.Load(const stream: TEndianStream);
begin
  stream.ReadStr(m_value);
end;

end.
