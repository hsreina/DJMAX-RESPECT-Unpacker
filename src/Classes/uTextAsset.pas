unit uTextAsset;

interface

uses uUnityClass, System.Classes, uEndianStream;

type
  TTextAsset = class (TUnityClass)
    private
      var m_Name: AnsiString;
      var m_Script: AnsiString;
      var m_PathName: AnsiString;
    public
      procedure Load(const stream: TEndianStream); override;
      property Script: AnsiString read m_Script;
  end;

implementation

uses uConsole;

procedure TTextAsset.Load(const stream: TEndianStream);
var
  size: UInt32;
begin
  stream.ReadStr(m_Name);
  stream.Align;
  stream.ReadStr(m_Script);
  stream.Align;
  stream.ReadStr(m_PathName);
end;

end.
