unit uAudioClip;

interface

uses uUnityClass, uEndianStream, uStreamedResource;

type
  TAudioClip = class (TUnityClass)
    private
      var m_Name: AnsiString;
      var m_LoadType: Int32;
      var m_Channels: Int32;
      var m_Frequency: Int32;
      var m_BitsPerSample: Int32;
      var m_Length: Single;
      var m_IsTrackerFormat: Boolean;
      var m_SubsoundIndex: Int32;
      var m_PreloadAudioData: Boolean;
      var m_LoadInBackground: Boolean;
      var m_Legacy3D: Boolean;
      var m_Resource: TStreamedResource;
      var m_CompressionFormat: Int32;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Load(const stream: TEndianStream); override;
      property Name: AnsiString read m_Name;
      property Resource: TStreamedResource read m_Resource;
      property Channels: Int32 read m_Channels;
      property Frequency: Int32 read m_Frequency;
      property BitsPerSample: Int32 read m_BitsPerSample;
  end;

implementation

uses uConsole;

constructor TAudioClip.Create;
begin
  inherited;
  m_Resource := TStreamedResource.Create;
end;

destructor TAudioClip.Destroy;
begin
  m_Resource.Free;
  inherited;
end;

procedure TAudioClip.Load(const stream: TEndianStream);
begin
  stream.ReadStr(m_Name);
  stream.Align;
  stream.ReadInt32(m_LoadType);
  stream.ReadInt32(m_Channels);
  stream.ReadInt32(m_Frequency);
  stream.ReadInt32(m_BitsPerSample);
  stream.ReadFloat(m_Length);
  stream.ReadBoolean(m_IsTrackerFormat);
  stream.Align;
  stream.ReadInt32(m_SubsoundIndex);
  stream.ReadBoolean(m_PreloadAudioData);
  stream.ReadBoolean(m_LoadInBackground);
  stream.ReadBoolean(m_Legacy3D);
  stream.Align;
  m_Resource.Load(stream);
  stream.ReadInt32(m_CompressionFormat);
end;

end.
