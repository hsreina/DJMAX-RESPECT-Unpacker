unit uUnityTypeNode;

interface

uses uEndianStream, System.Classes, Generics.Collections, UnityFSStringList,
  uUnityT;

type
  TUnityTypeNode = class
    private
      var m_version: UInt16;
      var m_depth: UInt8;
      var m_isArray: Boolean;
      var m_type: UInt32;
      var m_nameStringOffset: UInt32;
      var m_byteSize: UInt32;
      var m_index: UInt32;
      var m_flags: UInt32;
      var m_children: TList<TUnityTypeNode>;
      var m_stringList: TUnityFSStringList;
      var m_refTypeHash: UInt64;
      var m_generation: UInt32;
      function fGetChildren: TEnumerable<TUnityTypeNode>;
      function GetName: AnsiString;
      function GetTypeName: AnsiString;
    public
      constructor Create(const stringList: TUnityFSStringList; const generation: UInt32);
      destructor Destroy; override;
      function GetType: TUnityT;
      procedure Load(const endianStream: TEndianStream);
      procedure AddChild(child: TUnityTypeNode);
      property Version: UInt16 read m_version;
      property Depth: UInt8 read m_depth;
      property IsArray: Boolean read m_isArray;
      property Type_: UInt32 read m_type;
      property NameStringOffset: UInt32 read m_nameStringOffset;
      property ByteSize: UInt32 read m_byteSize;
      property Index_: UInt32 read m_index;
      property Flags: UInt32 read m_flags;
      property Children: TEnumerable<TUnityTypeNode> read fGetChildren;
      property Name: AnsiString read GetName;
      property TypeName: AnsiString read GetTypeName;
  end;

implementation

constructor TUnityTypeNode.Create;
begin
  inherited Create;
  m_generation := generation;
  m_stringList := stringList;
  m_children := TList<TUnityTypeNode>.Create;
end;

destructor TUnityTypeNode.Destroy;
begin
  m_children.Free;
  inherited;
end;

procedure TUnityTypeNode.Load(const endianStream: TEndianStream);
begin
  endianStream.ReadUInt16(m_version);
  endianStream.ReadUInt8(m_depth);
  endianStream.ReadBoolean(m_isArray);
  endianStream.ReadUInt32(m_type);
  endianStream.ReadUInt32(m_nameStringOffset);
  endianStream.ReadUInt32(m_byteSize);
  endianStream.ReadUInt32(m_index);
  endianStream.ReadUInt32(m_flags);
  if m_generation >= 19 then
  begin
    endianStream.ReadUInt64(m_refTypeHash);
  end;
end;

procedure TUnityTypeNode.AddChild(child: TUnityTypeNode);
begin
  m_children.Add(child);
end;

function TUnityTypeNode.fGetChildren;
begin
  Result := m_children;
end;

function TUnityTypeNode.GetName;
begin
  Result := m_stringList.StringAtIndex(m_nameStringOffset);
end;

function TUnityTypeNode.GetTypeName;
begin
  Result := m_stringList.StringAtIndex(m_type);
end;

function TUnityTypeNode.GetType;
begin
  Result := TUnityT(m_type);
end;

end.
