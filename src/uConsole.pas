unit uConsole;

interface

type
  Console = class
    public
      class procedure Log(const format: string); overload;
      class procedure Log(const format: string; const args: array of const); overload;
  end;

implementation

uses
  System.SysUtils;

class procedure Console.Log(const format: string);
begin
  WriteLn(format);
end;

class procedure Console.Log(const format: string; const args: array of const);
begin
  WriteLn(String.Format(format, args));
end;

end.
