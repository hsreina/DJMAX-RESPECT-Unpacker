unit uUnityType;

interface

uses uEndianStream, Generics.Collections, uUnityTypeNode, UnityFSStringList,
  System.Classes, uUnityClassId;

type
  TUnityType = class
    private
      var m_classId: Int32;
      var m_scriptId: Int16;
      var m_nodes: TList<TUnityTypeNode>;
      var m_stringList: TUnityFSStringList;
      var m_serializeTypeTrees: Boolean;
      var m_generation: UInt32;
      procedure DumpUnityTypeNode(const unityTypeNode: TUnityTypeNode);
      function GetNodes: TEnumerable<TUnityTypeNode>;
      function GetUnityClassId: TUnityClassId;
    public
      constructor Create(const serializeTypeTrees: Boolean; const generation: UInt32);
      destructor Destroy; override;

      procedure Load(const endianStream: TEndianStream);
      procedure Dump;

      property ClassId: Int32 read m_classId;
      property Nodes: TEnumerable<TUnityTypeNode> read GetNodes;
      property UnityClassId: TUnityClassId read GetUnityClassId;
  end;

implementation

uses uConsole, uGeneric;

constructor TUnityType.Create(const serializeTypeTrees: Boolean; const generation: UInt32);
begin
  inherited Create;
  m_generation := generation;
  m_serializeTypeTrees := serializeTypeTrees;
  m_nodes := TList<TUnityTypeNode>.Create;
  m_stringList := TUnityFSStringList.Create;
end;

destructor TUnityType.Destroy;
begin
  m_stringList.Free;
  m_nodes.Free;
  inherited;
end;

procedure TUnityType.Load(const endianStream: TEndianStream);
var
  un: UInt8;
  nodesCount, stringsSize: UInt32;
  I: Integer;
  typeNode, parentNode: TUnityTypeNode;
  nodesByDepth: TDictionary<UInt8, TUnityTypeNode>;
  typeDependencies: Int32;
begin
  nodesByDepth := TDictionary<UInt8, TUnityTypeNode>.Create;
  endianStream.ReadInt32(m_classId);
  // Console.Log('');
  // Console.Log('Class: %s', [TUnityClassIdHelper.ToString(unityType.uClassId)]);

  if m_generation >= 16 then
  begin
    endianStream.ReadUInt8(un);
  end;

  if m_generation >= 17 then
  begin
    endianStream.ReadInt16(m_scriptId);
  end;

  if m_generation >= 13 then
  begin
    if m_classId = 114 then
    begin
      endianStream.Seek($10, 1);
    end;
    endianStream.Seek($10, 1);
  end;

  if not m_serializeTypeTrees then
  begin
    Console.Log('doesn''t have type tree');
    Exit;
  end;

  // Then read type nodes
  endianStream.ReadUInt32(nodesCount);
  endianStream.ReadUInt32(stringsSize);

  for I := 1 to nodesCount do // Each blocks should be 24 bytes
  begin
    typeNode := TUnityTypeNode.Create(m_stringList, m_generation);
    typeNode.Load(endianStream);

    nodesByDepth.AddOrSetValue(typeNode.Depth, typeNode);

    if typeNode.Depth = 0 then
    begin
      m_nodes.Add(typeNode);
    end;

    if nodesByDepth.TryGetValue(typeNode.Depth - 1, parentNode) then
    begin
      parentNode.AddChild(typeNode);
    end;
  end;

  m_stringList.Read(endianStream, stringsSize);

  if m_generation >= 21 then
  begin
    endianStream.ReadInt32(typeDependencies);
  end;

  nodesByDepth.Free;
end;

procedure TUnityType.Dump;
var
  node: TUnityTypeNode;
  nodeName, tab: AnsiString;
  d: UInt8;
begin
  Console.Log('');
  Console.Log('Class %s', [TUnityClassIdHelper.ToString(TUnityClassId(m_classId))]);
  for node in m_nodes do
  begin
    DumpUnityTypeNode(node);
  end;
end;

procedure TUnityType.DumpUnityTypeNode(const unityTypeNode: TUnityTypeNode);
var
  nodeName, tab: AnsiString;
  d: UInt8;
  childNode: TUnityTypeNode;
begin
  if nil = unityTypeNode then
  begin
    Exit;
  end;
  nodeName := unityTypeNode.Name;
  tab := '';
  for d := 0 to unityTypeNode.depth do
  begin
    tab := tab + '  ';
  end;
  Console.Log(
    tab + '%s: %s (%d) %s',
    [
      nodeName,
      m_stringList.StringAtIndex(unityTypeNode.Type_),
      unityTypeNode.byteSize,
      TGeneric.IfElse(unityTypeNode.isArray, '(array)', '')
    ]
  );
  for childNode in unityTypeNode.Children do
  begin
    DumpUnityTypeNode(childNode);
  end;
end;

function TUnityType.GetNodes;
begin
  Result := m_nodes;
end;

function TUnityType.GetUnityClassId;
begin
  Result := TUnityClassId(m_classId);
end;

end.
