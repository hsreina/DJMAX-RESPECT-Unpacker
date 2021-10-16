unit UnityFSStringList;

interface

uses
  System.Classes, Generics.Collections, uEndianStream;

type

  TUnityFSStringList = class
    private
      var m_internalString: TDictionary<UInt32, AnsiString>;

      var m_memStream: TMemoryStream;
      var m_endianStream: TEndianStream;

      procedure RegisterInternalTypes;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Read(const stream: TStream; const size: UInt32);
      function StringAtIndex(const index: UInt32): AnsiString;
  end;

implementation

uses utils, System.TypInfo, uConsole, System.SysUtils;

constructor TUnityFSStringList.Create;
begin
  inherited;
  m_internalString := TDictionary<UInt32, AnsiString>.Create;
  m_endianStream := nil;
  m_memStream := nil;
  RegisterInternalTypes;
end;

procedure FreeIfNotNil(obj: TObject);
begin
  if not (obj = nil) then
  begin
    obj.Free;
  end;
end;

destructor TUnityFSStringList.Destroy;
begin
  FreeIfNotNil(m_endianStream);
  FreeIfNotNil(m_memStream);
  m_internalString.Free;
  inherited;
end;

procedure TUnityFSStringList.Read(const stream: TStream; const size: UInt32);
var
  str: AnsiString;
  strLength, total: UInt16;
  strLen: Integer;
begin
  if size = 0 then
  begin
    Exit;
  end;
  m_memStream := TMemoryStream.Create;
  m_memStream.CopyFrom(stream, size);
  m_endianStream := TEndianStream.Create(m_memStream, TEndian.Little);
  m_endianStream.Position := 0;
  m_endianStream.ReadZeroTerminatedString(str);
end;

function TUnityFSStringList.StringAtIndex(const index: Cardinal): AnsiString;
var
  isCustomType: Boolean;
  internalId: UInt32;
begin
  isCustomType := (index and $80000000) = 0;
  if isCustomType then
  begin
    m_endianStream.Position := index;
    m_endianStream.ReadZeroTerminatedString(Result);
  end else
  begin
    internalId := Ord(index and $7FFFFFFF);
    if not m_internalString.TryGetValue(internalId, Result) then
    begin
      Result := String.Format('System type %d', [internalId]);
    end;
  end;
end;

procedure TUnityFSStringList.RegisterInternalTypes;
begin
  // Register internal types here
  m_internalString.Add(49, 'Array');
  m_internalString.Add(55, 'Base');
  m_internalString.Add(76, 'bool');
  m_internalString.Add(81, 'char');
  m_internalString.Add(106, 'data');
  m_internalString.Add(155, 'first');
  m_internalString.Add(161, 'float');
  m_internalString.Add(222, 'int');
  m_internalString.Add(241, 'map');
  m_internalString.Add(427, 'm_Name');
  m_internalString.Add(490, 'm_Script');
  m_internalString.Add(543, 'pair');
  m_internalString.Add(633, 'PPtr<Object>');
  m_internalString.Add(778, 'second');
  m_internalString.Add(795, 'size');
  m_internalString.Add(814, 'SInt64');
  m_internalString.Add(840, 'string');
  m_internalString.Add(847, 'TextAsset');
  m_internalString.Add(921, 'UInt64');
  m_internalString.Add(934, 'unsigned int');
  m_internalString.Add(981, 'vector');
end;

end.
