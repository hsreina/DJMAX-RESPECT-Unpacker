unit uUnityClass;

interface

uses
  System.Classes, uEndianStream;

type
  TUnityClass = class abstract
    public
      procedure Load(const stream: TEndianStream); virtual;
  end;

implementation

uses uConsole;

procedure TUnityClass.Load(const stream: TEndianStream);
begin
  Console.Log('Not implemented');
end;

end.
