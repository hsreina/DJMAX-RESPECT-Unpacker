unit uUnityClassMap;

interface

uses
  System.Classes, uUnityClass, uUnityType, uUnityTypeNode;

type
  TUnityClassMapper = class
    private
      procedure MapLevel0(const cls: TUnityClass; const stream: TStream; const unityType: TUnityType);
    public
      function Map(const stream: TStream; const unityType: TUnityType): TUnityClass;
  end;

implementation

uses uUnityClassFactory, uConsole;

function TUnityClassMapper.Map(const stream: TStream; const unityType: TUnityType): TUnityClass;
var
  node: TUnityTypeNode;
begin
  unityType.Dump;

  Result := TUnityClassFactory.Create(unityType.UnityClassId);
  if nil = Result then
  begin
    Console.Log('Failed to create class');
    Exit;
  end;

  for node in unityType.Nodes do
  begin
    MapLevel0(Result, stream, unityType);
  end;
end;

procedure TUnityClassMapper.MapLevel0(const cls: TUnityClass; const stream: TStream; const unityType: TUnityType);
begin

end;

end.
