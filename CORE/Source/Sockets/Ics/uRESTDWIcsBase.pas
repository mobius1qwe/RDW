unit uRESTDWIcsBase;

{$I ..\..\Includes\uRESTDWPlataform.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
  de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
  Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
  de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

  Membros do Grupo :

  XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
  A. Brito                   - Admin - Administrador do desenvolvimento.
  Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
  Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
  Fl�vio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}

// TODO 0
// Portar TODAS as classes;
// Portado TRESTServicePoolerBase;

// TODO 1
// Inserir outras propriedades do SSL no Pooler (SetHttpServerSSL);

// TODO 2
// Passar par�metros do diret�rio, p�gina e url padr�o (SetParamsHttpConnection);

// TODO 3
// Portar AnonymousThread pra Thread (compatibilidade com Delphi antigo);

interface

Uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  System.SyncObjs,
  VCL.ExtCtrls,
  uRESTDWComponentEvents,
  uRESTDWBasicTypes,
  uRESTDWJSONObject,
  uRESTDWBasic,
  uRESTDWBasicDB,
  uRESTDWParams,
  uRESTDWBasicClass,
  uRESTDWComponentBase,
  uRESTDWConsts,
  uRESTDWEncodeClass,
  uRESTDWDataUtils,
  uRESTDWTools,
  OverbyteIcsWinSock,
  OverbyteIcsWSocket,
  OverbyteIcsWndControl,
  OverbyteIcsHttpAppServer,
  OverbyteIcsUtils,
  OverbyteIcsFormDataDecoder,
  OverbyteIcsMimeUtils,
  OverbyteIcsSSLEAY,
  OverbyteIcsHttpSrv,
  OverbyteIcsWSocketS,
  OverbyteIcsSslX509Utils;

Type

  TPoolerHttpConnection = class(THttpAppSrvConnection)
  protected
    vRawData: AnsiString;
    vRawDataLen: Integer;
    vNeedClose: boolean;
  public
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
  end;

  TOnException = Procedure(Sender: TPoolerHttpConnection; Error: String) Of Object;
  TOnServerStarted = Procedure(Sender: TObject) Of Object;
  TOnServerStopped = Procedure(Sender: TObject) Of Object;
  TOnClientConnect = Procedure(Sender: TPoolerHttpConnection; Error: Word) Of Object;
  TOnClientDisconnect = Procedure(Sender: TPoolerHttpConnection; Error: Word) Of Object;
  TOnDocumentReady = Procedure(Sender: TPoolerHttpConnection; Var Flags: THttpGetFlag)
    Of Object;
  TOnAnswered = Procedure(Sender: TPoolerHttpConnection) Of Object;
  TOnTimeout = Procedure(Sender: TPoolerHttpConnection; Reason: TTimeoutReason) of Object;
  TOnBlackListBlock = Procedure(IP, Port: string) Of Object;
  TOnBruteForceBlock = Procedure(IP, Port: string) Of Object;
  TOnServerStatusCheckBlock = Procedure(IP, Port: string) Of Object;

  TIcsSelfAssignedCert = class(TPersistent)
  private
    vAutoGenerateOnStart: boolean;
    vCountry: string;
    vState: string;
    vLocality: string;
    vOrganization: string;
    vOrgUnit: string;
    vExpireDays: Integer;
    vEmail: string;
    vCommonName: string;
    vPrivKeyType: TSslPrivKeyType;
    vCertDigest: TEvpDigest;
    vCert: TSslCertTools;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CreateCertificate;
    function CertificateString: string;
    function PrivateKeyString: string;
  published
    property AutoGenerateOnStart: boolean read vAutoGenerateOnStart
      write vAutoGenerateOnStart default false;
    property Country: String read vCountry write vCountry;
    property State: String read vState write vState;
    property Locality: String read vLocality write vLocality;
    property Organization: String read vOrganization write vOrganization;
    property OrganizationUnit: String read vOrgUnit write vOrgUnit;
    property Email: String read vEmail write vEmail;
    property ExpireDays: Integer read vExpireDays write vExpireDays default 365;
    property CommonName: String read vCommonName write vCommonName;
    property PrivateKeyType: TSslPrivKeyType read vPrivKeyType write vPrivKeyType
      default PrivKeyRsa4096;
    property CertificateDigestType: TEvpDigest read vCertDigest write vCertDigest
      default Digest_sha512;
  end;

  TIcsBruteForceProtection = class(TPersistent)
  private
    vBruteForceCS: TCriticalSection;
    vBruteForceSampleMin: Integer;
    vBruteForceTry: Integer;
    vBruteForceExpirationMin: Integer;
    vBruteForceList: TStringList;
    vBruteForceProtectionStatus: boolean;
    vBruteForceTimer: TTimer;
    function GetBruteForceIndex(IP: String): Integer;
  public
    Constructor Create;
    Destructor Destroy; override;
    procedure ClearBruteForceList;
    procedure StartBruteForce;
    procedure StopBruteForce;
    procedure SampleBruteForce(Sender: TObject);
    procedure BruteForceAttempt(IP: String);
    function BruteForceAllow(IP: String): boolean;
  published
    property BruteForceProtectionStatus: boolean read vBruteForceProtectionStatus
      write vBruteForceProtectionStatus default true;
    property BruteForceSampleMin: Integer read vBruteForceSampleMin
      write vBruteForceSampleMin default 1;
    // Sampling time in minutes to clear blocked IP
    property BruteForceTry: Integer read vBruteForceTry write vBruteForceTry default 3;
    // Attempt times before block
    property BruteForceExpirationMin: Integer read vBruteForceExpirationMin
      write vBruteForceExpirationMin default 30; // Blocked IP expiration time in minutes
  end;

  TRESTDWIcsServicePooler = Class(TRESTServicePoolerBase)
  Private
    // Events
    vOnException: TOnException;
    vOnServerStarted: TOnServerStarted;
    vOnServerStopped: TOnServerStopped;
    vOnClientConnect: TOnClientConnect;
    vOnClientDisconnect: TOnClientDisconnect;
    vOnDocumentReady: TOnDocumentReady;
    vOnAnswered: TOnAnswered;
    vOnTimeout: TOnTimeout;
    vOnBlackListBlock: TOnBlackListBlock;
    vOnBruteForceBlock: TOnBruteForceBlock;
    vOnServerStatusCheckBlock: TOnServerStatusCheckBlock;

    // HTTP Server
    HttpAppSrv: TSslHttpAppSrv;

    // SSL Params
    vSSLRootCertFile, vSSLPrivateKeyFile, vSSLPrivateKeyPassword, vSSLCertFile: String;
    vSSLVerMethodMin, vSSLVerMethodMax: TSslVerMethod;
    vSSLVerifyMode: TSslVerifyPeerModes;
    vSSLVerifyDepth: Integer;
    vSSLVerifyPeer: boolean;
    vSSLCacheModes: TSslSessCacheModes;
    vSSLTimeoutSec: Cardinal;
    vSSLUse: boolean;
    vSSLCliCertMethod: TSslCliCertMethod;
    vIcsSelfAssignedCert: TIcsSelfAssignedCert;

    // HTTP Params
    vMaxClients: Integer;
    vServiceTimeout: Integer;
    vBuffSizeBytes: Integer;
    vBandWidthLimitBytes: Cardinal;
    vBandWidthSampleSec: Cardinal;
    vListenBacklog: Integer;

    // Security
    vBruteForceProtection: TIcsBruteForceProtection;
    vIpBlackList: TStrings;
    vServerStatusCheck: boolean;

    // Misc
    procedure DisconnectClient(Client: TPoolerHttpConnection; Server: TSslHttpAppSrv);

  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; override;

    // Document procedures
    Procedure onDocumentReadyServer(Sender: TObject; Var Flag: THttpGetFlag);
    procedure onPostedDataServer(Sender: TObject; ErrCode: Word);
    procedure ProcessDocument(Sender: TObject; BodyStream: TStream; Flag: THttpGetFlag);
    procedure onExceptionServer(Sender: TObject; E: ESocketException);
    procedure onServerStartedServer(Sender: TObject);
    procedure onServerStoppedServer(Sender: TObject);
    procedure onAnsweredServer(Sender: TObject);
    procedure CustomAnswerStream(Pooler: TPoolerHttpConnection; Flag: THttpGetFlag;
      StatusCode: Integer; ContentType, Header: String);

    // Prepare procedures
    procedure SetHttpServerSSL;
    procedure SetHttpServerParams;
    procedure SetSocketServerParams;
    procedure SetHttpConnectionParams(Remote: TPoolerHttpConnection);

    // Misc Procedures
    Function ClientCount: Integer;
    Procedure SetActive(Value: boolean); Override;
    Procedure EchoPooler(ServerMethodsClass: TComponent; AContext: TComponent;
      Var Pooler, MyIP: String; AccessTag: String; Var InvalidTag: boolean); Override;
    procedure onClientTimeout(Sender: TObject; Reason: TTimeoutReason);
    procedure onClientConnectServer(Sender: TObject; Client: TObject; Error: Word);
    procedure onClientDisconnectServer(Sender: TObject; Client: TObject; Error: Word);

  Published
    // Events
    Property onException: TOnException Read vOnException Write vOnException;
    Property onServerStarted: TOnServerStarted Read vOnServerStarted
      Write vOnServerStarted;
    Property onServerStopped: TOnServerStopped Read vOnServerStopped
      Write vOnServerStopped;
    Property onClientConnect: TOnClientConnect Read vOnClientConnect
      Write vOnClientConnect;
    Property onClientDisconnect: TOnClientDisconnect Read vOnClientDisconnect
      Write vOnClientDisconnect;
    Property onDocumentReady: TOnDocumentReady Read vOnDocumentReady
      Write vOnDocumentReady;
    Property onAnswered: TOnAnswered Read vOnAnswered Write vOnAnswered;
    Property onTimeout: TOnTimeout read vOnTimeout Write vOnTimeout;
    Property onBlackListBlock: TOnBlackListBlock Read vOnBlackListBlock
      Write vOnBlackListBlock;
    Property onBruteForceBlock: TOnBruteForceBlock Read vOnBruteForceBlock
      Write vOnBruteForceBlock;
    Property onServerStatusCheckBlock: TOnServerStatusCheckBlock
      Read vOnServerStatusCheckBlock write vOnServerStatusCheckBlock;

    // SSL Params
    Property SSLRootCertFile: String Read vSSLRootCertFile Write vSSLRootCertFile;
    Property SSLPrivateKeyFile: String Read vSSLPrivateKeyFile Write vSSLPrivateKeyFile;
    Property SSLPrivateKeyPassword: String Read vSSLPrivateKeyPassword
      Write vSSLPrivateKeyPassword;
    Property SSLCertFile: String Read vSSLCertFile Write vSSLCertFile;
    Property SSLVersionMin: TSslVerMethod Read vSSLVerMethodMin Write vSSLVerMethodMin
      default sslVerTLS1_2;
    Property SSLVersionMax: TSslVerMethod Read vSSLVerMethodMax Write vSSLVerMethodMax
      default sslVerMax;
    Property SSLVerifyMode: TSslVerifyPeerModes Read vSSLVerifyMode Write vSSLVerifyMode;
    Property SSLVerifyDepth: Integer Read vSSLVerifyDepth Write vSSLVerifyDepth default 9;
    Property SSLVerifyPeer: boolean Read vSSLVerifyPeer Write vSSLVerifyPeer
      default false;
    Property SSLCacheModes: TSslSessCacheModes Read vSSLCacheModes Write vSSLCacheModes;
    Property SSLTimeoutSec: Cardinal Read vSSLTimeoutSec Write vSSLTimeoutSec default 60;
    property SelfAssignedCert: TIcsSelfAssignedCert read vIcsSelfAssignedCert
      write vIcsSelfAssignedCert;

    // SSL TimeOut in Seconds
    Property SSLUse: boolean Read vSSLUse Write vSSLUse default false;
    Property SSLCliCertMethod: TSslCliCertMethod Read vSSLCliCertMethod
      Write vSSLCliCertMethod;

    // HTTP Params
    Property MaxClients: Integer Read vMaxClients Write vMaxClients default 0;
    Property RequestTimeout: Integer Read vServiceTimeout Write vServiceTimeout
      default 60000; // Connection TimeOut in Milliseconds
    Property BuffSizeBytes: Integer Read vBuffSizeBytes Write vBuffSizeBytes
      default 262144; // 256kb Default
    Property BandWidthLimitBytes: Cardinal Read vBandWidthLimitBytes
      Write vBandWidthLimitBytes default 0;
    Property BandWidthSamplingSec: Cardinal Read vBandWidthSampleSec
      Write vBandWidthSampleSec default 1;
    Property ListenBacklog: Integer Read vListenBacklog Write vListenBacklog default 50;

    // Secutiry
    procedure SetvIpBlackList(Lines: TStrings);
    Property IpBlackList: TStrings Read vIpBlackList Write SetvIpBlackList;
    Property BruteForceProtection: TIcsBruteForceProtection read vBruteForceProtection
      write vBruteForceProtection;
    Property ServerStatusCheck: boolean read vServerStatusCheck write vServerStatusCheck
      default true;
  End;

const
  cIcsHTTPServerNotFound = 'No HTTP server found';
  cIcsHTTPConnectionClosed = 'Closed HTTP connection';
  cIcsCorruptedPackage = 'Corrupted package: RequestContentLength <> Stream.Size';

Implementation

Uses uRESTDWJSONInterface, VCL.Dialogs, OverbyteIcsWSockBuf, VCL.Forms;

Procedure TRESTDWIcsServicePooler.SetHttpServerSSL;
var
  x: Integer;
begin
  if Assigned(HttpAppSrv) then
  begin
    if vSSLUse then
    begin
      HttpAppSrv.SSLContext := TSslContext.Create(HttpAppSrv);

      HttpAppSrv.SslEnable := true;

      for x := 0 to HttpAppSrv.MultiListenSockets.Count - 1 do
        HttpAppSrv.MultiListenSockets[x].SslEnable := true;

      HttpAppSrv.SSLContext.SslSessionTimeout := vSSLTimeoutSec;
      HttpAppSrv.SSLContext.SslSessionCacheModes := vSSLCacheModes;
      HttpAppSrv.SSLContext.SSLVerifyPeer := vSSLVerifyPeer;
      HttpAppSrv.SSLContext.SSLVerifyDepth := vSSLVerifyDepth;
      HttpAppSrv.SSLContext.SslVerifyPeerModes := vSSLVerifyMode;
      HttpAppSrv.SSLContext.SslMinVersion := vSSLVerMethodMin;
      HttpAppSrv.SSLContext.SslMaxVersion := vSSLVerMethodMax;

      if vIcsSelfAssignedCert.vAutoGenerateOnStart then
      begin
        vIcsSelfAssignedCert.CreateCertificate;

        HttpAppSrv.SSLContext.SslPrivKeyLines.Text :=
          vIcsSelfAssignedCert.PrivateKeyString;
        HttpAppSrv.SSLContext.SslCertLines.Text := vIcsSelfAssignedCert.CertificateString;
      end
      else
      begin
        HttpAppSrv.SSLContext.SSLCertFile := vSSLCertFile;
        HttpAppSrv.SSLContext.SslPrivKeyFile := vSSLPrivateKeyFile;
        HttpAppSrv.SSLContext.SslPassPhrase := vSSLPrivateKeyPassword;
        HttpAppSrv.RootCA := vSSLRootCertFile;
      end;

      // TODO 1
      HttpAppSrv.SSLContext.SslCliSecurity := TSslCliSecurity.sslCliSecIgnore;
      HttpAppSrv.SSLContext.SslSecLevel := TSslSecLevel.sslSecLevelAny;
    end
    else
    begin
      HttpAppSrv.SslEnable := false;

      for x := 0 to HttpAppSrv.MultiListenSockets.Count - 1 do
        HttpAppSrv.MultiListenSockets[x].SslEnable := false;

      HttpAppSrv.SSLContext := nil;
    end;
  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
end;

procedure TRESTDWIcsServicePooler.SetSocketServerParams;
begin
  HttpAppSrv.WSocketServer.BufSize := vBuffSizeBytes;
  HttpAppSrv.WSocketServer.SocketRcvBufSize := vBuffSizeBytes;
  HttpAppSrv.WSocketServer.SocketSndBufSize := vBuffSizeBytes;
end;

Procedure TRESTDWIcsServicePooler.SetHttpServerParams;
var
  x: Integer;
  vKeepAliveTimeSec: Integer;
begin
  if Assigned(HttpAppSrv) then
  begin
    HttpAppSrv.ClientClass := TPoolerHttpConnection;

    HttpAppSrv.MaxClients := vMaxClients;
    HttpAppSrv.MaxRequestsKeepAlive := vMaxClients;

    if ((vServiceTimeout > 0) and (vServiceTimeout < 1000)) then
      vKeepAliveTimeSec := 1
    else if vServiceTimeout <= 0 then
      vKeepAliveTimeSec := 0
    else
      vKeepAliveTimeSec := trunc(vServiceTimeout / 1000);

    HttpAppSrv.KeepAliveTimeSec := vKeepAliveTimeSec;
    HttpAppSrv.KeepAliveTimeXferSec := vKeepAliveTimeSec;

    HttpAppSrv.SessionTimeout := vServiceTimeout;

    HttpAppSrv.MaxBlkSize := vBuffSizeBytes;

    HttpAppSrv.BandwidthLimit := vBandWidthLimitBytes;

    if vBandWidthSampleSec < 1 then
      HttpAppSrv.BandwidthSampling := 1000
    else
      HttpAppSrv.BandwidthSampling := vBandWidthSampleSec * 1000;

    HttpAppSrv.onClientConnect := onClientConnectServer;
    HttpAppSrv.onClientDisconnect := onClientDisconnectServer;
    HttpAppSrv.onServerStarted := onServerStartedServer;
    HttpAppSrv.onServerStopped := onServerStoppedServer;

    if AuthenticationOptions.AuthorizationOption <> rdwAONone then
    begin

      case AuthenticationOptions.AuthorizationOption of
        rdwAOBasic:
          HttpAppSrv.AuthTypes := [atBasic];
        rdwAOBearer, rdwAOToken, rdwOAuth:
          HttpAppSrv.AuthTypes := [atDigest];
      end;

    end
    else
      HttpAppSrv.AuthTypes := [atNone];

    if ((ServerIPVersionConfig.ServerIpVersion = sivBoth) or
      (ServerIPVersionConfig.ServerIpVersion = sivIPv4)) then
    begin

      HttpAppSrv.Port := IntToStr(ServicePort);
      HttpAppSrv.ListenBacklog := vListenBacklog;
      HttpAppSrv.SocketFamily := sfAnyIPv4;
      HttpAppSrv.Addr := ServerIPVersionConfig.IPv4Address;

      HttpAppSrv.MultiListenSockets.Clear;

      if (ServerIPVersionConfig.ServerIpVersion = sivBoth) then
      begin
        with HttpAppSrv.MultiListenSockets.Add do
        begin

          Port := IntToStr(ServicePort);
          ListenBacklog := vListenBacklog;
          SocketFamily := sfAnyIPv6;
          Addr := ServerIPVersionConfig.IPv6Address;

        end;
      end;
    end
    else if (ServerIPVersionConfig.ServerIpVersion = sivIPv6) then
    begin

      HttpAppSrv.Port := IntToStr(ServicePort);
      HttpAppSrv.ListenBacklog := vListenBacklog;
      HttpAppSrv.SocketFamily := sfAnyIPv6;
      HttpAppSrv.Addr := ServerIPVersionConfig.IPv6Address;

      HttpAppSrv.MultiListenSockets.Clear;

    end;

  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
end;

procedure TRESTDWIcsServicePooler.onExceptionServer(Sender: TObject; E: ESocketException);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Sender as TPoolerHttpConnection;

  if Assigned(vOnException) then
    vOnException(Remote, E.Message);
end;

procedure TRESTDWIcsServicePooler.onServerStartedServer(Sender: TObject);
begin
  if Assigned(vOnServerStarted) then
    vOnServerStarted(Sender);
end;

procedure TRESTDWIcsServicePooler.onServerStoppedServer(Sender: TObject);
begin
  if Assigned(vOnServerStopped) then
    vOnServerStopped(Sender);
end;

procedure TRESTDWIcsServicePooler.SetvIpBlackList(Lines: TStrings);
begin
  vIpBlackList.Assign(Lines);
end;

procedure TRESTDWIcsServicePooler.onClientTimeout(Sender: TObject;
  Reason: TTimeoutReason);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Sender as TPoolerHttpConnection;

  try
    if Assigned(vOnTimeout) then
      vOnTimeout(Remote, Reason);
  finally
    DisconnectClient(Remote, HttpAppSrv);
  end;
end;

procedure TRESTDWIcsServicePooler.SetHttpConnectionParams(Remote: TPoolerHttpConnection);
begin
  Remote.TimeoutIdle := vServiceTimeout;
  Remote.TimeoutConnect := vServiceTimeout;
  Remote.TimeoutSampling := 5000;
  Remote.TimeoutKeepThreadAlive := false;

  Remote.LineMode := true;
  Remote.LineLimit := MaxInt;
  Remote.LineEnd := sLineBreak;

  Remote.vRawData := '';
  Remote.vRawDataLen := 0;
  Remote.vNeedClose := false;

  Remote.onTimeout := onClientTimeout;
  Remote.OnGetDocument := onDocumentReadyServer;
  Remote.OnPostDocument := onDocumentReadyServer;
  Remote.OnPutDocument := onDocumentReadyServer;
  Remote.OnDeleteDocument := onDocumentReadyServer;
  Remote.OnPatchDocument := onDocumentReadyServer;
  Remote.OnOptionsDocument := onDocumentReadyServer;
  Remote.OnPostedData := onPostedDataServer;
  Remote.onException := onExceptionServer;
  Remote.OnAfterAnswer := onAnsweredServer;
end;

function TRESTDWIcsServicePooler.ClientCount: Integer;
begin
  try
    if Assigned(HttpAppSrv) then
      Result := HttpAppSrv.ClientCount;
  except
    Result := -1;
  end;
end;

Constructor TRESTDWIcsServicePooler.Create(AOwner: TComponent);
Begin
  Inherited Create(AOwner);

  HttpAppSrv := TSslHttpAppSrv.Create(nil);

  If Assigned(HttpAppSrv.SSLContext) Then
    FreeAndNil(HttpAppSrv.SSLContext);

  // TODO 2
  HttpAppSrv.DocDir := '';
  HttpAppSrv.TemplateDir := '';
  HttpAppSrv.DefaultDoc := '';

  vSSLVerMethodMin := sslVerTLS1_2;
  vSSLVerMethodMax := sslVerMax;
  vSSLVerifyDepth := 9;
  vSSLVerifyPeer := false;
  vSSLTimeoutSec := 60; // SSL TimeOut in Seconds
  vSSLUse := false;
  vIcsSelfAssignedCert := TIcsSelfAssignedCert.Create;

  vMaxClients := 0;
  vServiceTimeout := 60000; // TimeOut in Milliseconds
  vBuffSizeBytes := 262144; // 256kb Default
  vBandWidthLimitBytes := 0;
  vBandWidthSampleSec := 1;
  vListenBacklog := 50;

  vIpBlackList := TStringList.Create;
  vIpBlackList.Clear;
  vServerStatusCheck := true;

  vBruteForceProtection := TIcsBruteForceProtection.Create;
End;

procedure TRESTDWIcsServicePooler.onAnsweredServer(Sender: TObject);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Sender as TPoolerHttpConnection;

  try
    if Assigned(vOnAnswered) then
      vOnAnswered(Remote);
  finally
    // Force client disconnection after answer
    // Avoid ghost connections and timeouts
    DisconnectClient(Remote, HttpAppSrv);
  end;
end;

procedure TRESTDWIcsServicePooler.onClientConnectServer(Sender: TObject; Client: TObject;
  Error: Word);
var
  Remote: TPoolerHttpConnection;
  i: Integer;
begin
  Remote := Client as TPoolerHttpConnection;

  // Check for Brute Force exploit
  if not(vBruteForceProtection.BruteForceAllow(Remote.PeerAddr)) then
  begin
    try
      if Assigned(vOnClientConnect) then
        vOnClientConnect(Remote, Remote.LastError);

      if Assigned(vOnBruteForceBlock) then
        vOnBruteForceBlock(Remote.PeerAddr, Remote.PeerPort);
    finally
      DisconnectClient(Remote, HttpAppSrv);
    end;

    exit;
  end;

  // Blocking the black list IPs
  if vIpBlackList.Count > 0 then
  begin
    if vIpBlackList.IndexOf(Remote.PeerAddr) <> -1 then
    begin
      try
        if Assigned(vOnClientConnect) then
          vOnClientConnect(Remote, Remote.LastError);

        if Assigned(vOnBlackListBlock) then
          vOnBlackListBlock(Remote.PeerAddr, Remote.PeerPort);
      finally
        DisconnectClient(Remote, HttpAppSrv);
      end;

      exit;
    end;
  end;

  try
    if Assigned(vOnClientConnect) then
      vOnClientConnect(Remote, Error);
  finally
    SetHttpConnectionParams(Remote);
  end;
end;

procedure TRESTDWIcsServicePooler.onClientDisconnectServer(Sender: TObject;
  Client: TObject; Error: Word);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Client as TPoolerHttpConnection;

  if Assigned(vOnClientDisconnect) then
    vOnClientDisconnect(Remote, Error);
end;

Destructor TRESTDWIcsServicePooler.Destroy;
Begin
  Try
    If Active Then
    Begin
      If HttpAppSrv.ListenAllOK Then
        HttpAppSrv.Stop;
    End;
  Except
    //
  End;

  If Assigned(HttpAppSrv) Then
  begin
    If Assigned(HttpAppSrv.SSLContext) Then
      FreeAndNil(HttpAppSrv.SSLContext);

    FreeAndNil(HttpAppSrv);
  end;

  if Assigned(vBruteForceProtection) then
    FreeAndNil(vBruteForceProtection);

  if Assigned(vIcsSelfAssignedCert) then
    FreeAndNil(vIcsSelfAssignedCert);

  if Assigned(vIpBlackList) then
    FreeAndNil(vIpBlackList);

  Inherited Destroy;
End;

Procedure TRESTDWIcsServicePooler.EchoPooler(ServerMethodsClass, AContext: TComponent;
  Var Pooler, MyIP: String; AccessTag: String; Var InvalidTag: boolean);
Var
  Remote: THttpAppSrvConnection;
  i: Integer;
Begin
  Inherited;

  InvalidTag := false;

  MyIP := '';

  If ServerMethodsClass <> Nil Then
  Begin

    For i := 0 To ServerMethodsClass.ComponentCount - 1 Do
    Begin

      If (ServerMethodsClass.Components[i].ClassType = TRESTDWPoolerDB) Or
        (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) Then
      Begin

        If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName,
          ServerMethodsClass.Components[i].Name]) Then
        Begin

          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin

            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <>
              AccessTag Then
            Begin
              InvalidTag := true;

              exit;
            End;

          End;

          If AContext <> Nil Then
          Begin
            Remote := THttpAppSrvConnection(AContext);

            MyIP := Remote.PeerAddr;
          End;

          Break;

        End;

      End;

    End;

  End;

  If MyIP = '' Then
    Raise Exception.Create(cInvalidPoolerName);
End;

procedure TRESTDWIcsServicePooler.onPostedDataServer(Sender: TObject; ErrCode: Word);
var
  Remote: TPoolerHttpConnection;
  Len: Integer;
  lCount: Integer;
  RawDataTemp: AnsiString;
  Stream: TStream;
begin
  try
    Remote := Sender as TPoolerHttpConnection;

    repeat
    begin
      SetLength(RawDataTemp, Remote.BufSize);

      lCount := Remote.Receive(@RawDataTemp[1], Remote.BufSize);

      if lCount > 0 then
      begin
        SetLength(RawDataTemp, lCount);
        Remote.vRawData := Remote.vRawData + RawDataTemp;
        Remote.vRawDataLen := Remote.vRawDataLen + lCount;
      end
      else
        lCount := 0;

      SetLength(RawDataTemp, 0);
    end
    until lCount <= 0;

    if Remote.RequestContentLength = Remote.vRawDataLen then
    begin
      Remote.PostedDataReceived;

      try
        Stream := nil;

        Stream := TStringStream.Create(Remote.vRawData);

        Stream.Position := 0;

        ProcessDocument(Sender, Stream, hgWillSendMySelf);
      finally
        if Assigned(Stream) then
          FreeAndNil(Stream);
      end;
    end;
  except
    on E: Exception do
    begin
      try
        if Assigned(vOnException) then
          vOnException(Remote, 'onPostedDataServer - ' + E.Message);
      finally
        DisconnectClient(Remote, HttpAppSrv);
      end;
    end;
  end;
end;

procedure TRESTDWIcsServicePooler.ProcessDocument(Sender: TObject; BodyStream: TStream;
  Flag: THttpGetFlag);
var
  Remote: TPoolerHttpConnection;
  lBodyStream: TStream;
begin
  try
    lBodyStream := nil;

    lBodyStream := TMemoryStream.Create;

    Remote := Sender as TPoolerHttpConnection;

    if BodyStream = nil then
    begin
      lBodyStream.Size := 0;

      lBodyStream.Position := 0;
    end
    else
    begin
      lBodyStream.CopyFrom(BodyStream, BodyStream.Size);

      lBodyStream.Position := 0;
    end;

    if (Remote.RequestContentLength <> lBodyStream.Size) then
      raise Exception.Create(cIcsCorruptedPackage);

    TThread.CreateAnonymousThread(
      procedure
      Var
        vCharSet, vToken, vErrorMessage, vAuthRealm, vContentType,
          vResponseString: String;
        StatusCode: Integer;
        ResultStream: TStream;
        vResponseHeader: TStringList;
        vParams: TStringList;
        vCORSHeader: TStringList;
        vRedirect: TRedirect;

        Procedure DestroyComponents;
        Begin
          If Assigned(vResponseHeader) Then
            FreeAndNil(vResponseHeader);

          If Assigned(vParams) Then
            FreeAndNil(vParams);

          if Assigned(lBodyStream) then
            FreeAndNil(lBodyStream);

          if Assigned(ResultStream) then
            FreeAndNil(ResultStream);

          If Assigned(vCORSHeader) Then
            FreeAndNil(vCORSHeader);
        End;

        Procedure Redirect(Url: String);
        Begin
          Remote.WebRedirectURL := Url;
        End;

        Procedure SetReplyCORS;
        Var
          i: Integer;
        Begin
          If CORS Then
          Begin
            If CORS_CustomHeaders.Count > 0 Then
            Begin

              For i := 0 To CORS_CustomHeaders.Count - 1 Do
                vResponseHeader.AddPair(CORS_CustomHeaders.Names[i],
                  CORS_CustomHeaders.ValueFromIndex[i]);
            End
            Else
              vResponseHeader.AddPair('Access-Control-Allow-Origin', '*');

            If Assigned(vCORSHeader) Then
            Begin
              If vCORSHeader.Count > 0 Then
              Begin
                For i := 0 To vCORSHeader.Count - 1 Do
                  vResponseHeader.AddPair(vCORSHeader.Names[i],
                    vCORSHeader.ValueFromIndex[i]);
              End;
            End;

          End;
        End;

      begin
        try
          try
            vCORSHeader := nil;
            vResponseHeader := nil;
            vParams := nil;
            ResultStream := nil;

            vCORSHeader := TStringList.Create;
            vResponseHeader := TStringList.Create;
            vParams := TStringList.Create;

            vResponseString := '';
            @vRedirect := @Redirect;
            vToken := Remote.AuthDigestUri;
            vAuthRealm := Remote.AuthRealm;
            vContentType := Remote.RequestContentType;
            vParams.Text := Remote.Params;

            // Do not process the document if HTTP conection needs to be closed
            // but for some reason it was not closed
            if (Remote.vNeedClose = true) then
              raise Exception.Create(cIcsHTTPConnectionClosed);

            // Server status check protection
            if ((vServerStatusCheck = false) and ((String.IsNullOrEmpty(Remote.Path)) or
              (Remote.Path = '/'))) then
            begin
              try
                if Assigned(vOnServerStatusCheckBlock) then
                  vOnServerStatusCheckBlock(Remote.PeerAddr, Remote.PeerPort);
              finally
                DisconnectClient(Remote, HttpAppSrv);
              end;

              exit;
            end;

            CommandExec(TComponent(Remote), RemoveBackslashCommands(Remote.Path),
              Remote.Method + ' ' + Remote.Path, vContentType, Remote.PeerAddr,
              Remote.RequestUserAgent, Remote.AuthUserName, Remote.AuthPassword, vToken,
              Remote.RequestHeader, StrToInt(Remote.PeerPort), Remote.RequestHeader,
              vParams, Remote.Params, lBodyStream, vAuthRealm, vCharSet, vErrorMessage,
              StatusCode, vResponseHeader, vResponseString, ResultStream, vCORSHeader,
              vRedirect);

            SetReplyCORS;

            Remote.AuthRealm := vAuthRealm;

            If (vResponseString <> '') Or (vErrorMessage <> '') Then
            Begin
              If Assigned(ResultStream) Then
                FreeAndNil(ResultStream);

              If (vResponseString <> '') Then
                ResultStream := TStringStream.Create(vResponseString)
              Else
                ResultStream := TStringStream.Create(vErrorMessage);
            End;

            If Assigned(ResultStream) Then
            Begin
              ResultStream.Position := 0;

              Remote.DocStream := TStringStream.Create;
              Remote.DocStream.CopyFrom(ResultStream, ResultStream.Size);
              Remote.DocStream.Position := 0;

              CustomAnswerStream(Remote, Flag, StatusCode, vContentType,
                vResponseHeader.Text);
            End;

          except
            on E: Exception do
            begin
              try
                if Assigned(vOnException) then
                  vOnException(Remote, 'ProcessDocument Thread - ' + E.Message);
              finally
                DisconnectClient(Remote, HttpAppSrv);
              end;
            end;
          end;
        finally
          DestroyComponents;
        end;

      end).Start;
  except
    on E: Exception do
    begin
      if Assigned(lBodyStream) then
        FreeAndNil(lBodyStream);

      try
        if Assigned(vOnException) then
          vOnException(Remote, 'ProcessDocument - ' + E.Message);
      finally
        DisconnectClient(Remote, HttpAppSrv);
      end;
    end;
  end;
end;

Procedure TRESTDWIcsServicePooler.DisconnectClient(Client: TPoolerHttpConnection;
Server: TSslHttpAppSrv);
begin
  try
    // Try disconnecting gracefully
    Client.vNeedClose := true;

    if Server.IsClient(Client) then
      Client.Shutdown(2);

  except
    on E: Exception do
    begin

      try
        if Assigned(vOnException) then
          vOnException(Client, 'DisconnectClient - ' + E.Message);
      finally
        // Forced disconnection
        if Server.IsClient(Client) then
          Server.WSocketServer.Disconnect(Client);

        Client.vNeedClose := true;
      end;
    end;
  end;
end;

Procedure TRESTDWIcsServicePooler.CustomAnswerStream(Pooler: TPoolerHttpConnection;
Flag: THttpGetFlag; StatusCode: Integer; ContentType: String; Header: String);
begin
  case StatusCode of
    401:
      begin
        vBruteForceProtection.BruteForceAttempt(Pooler.PeerAddr);

        if vBruteForceProtection.BruteForceAllow(Pooler.PeerAddr) then
        begin
          if self.AuthenticationOptions.OptionParams.AuthDialog then
            Pooler.Answer401
          else
            Pooler.Answer403;
        end
        else
          Pooler.Answer403;
      end;
    403:
      Pooler.Answer403;
    404:
      Pooler.Answer404;
  else
    Pooler.AnswerStream(Flag, IntToStr(StatusCode), ContentType, Header);
  end;
end;

Procedure TRESTDWIcsServicePooler.onDocumentReadyServer(Sender: TObject;
Var Flag: THttpGetFlag);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Sender as TPoolerHttpConnection;

  try
    if Assigned(vOnDocumentReady) then
      vOnDocumentReady(Remote, Flag);
  finally
    try
      if not(Remote.RequestMethod in [THttpMethod.httpMethodGet,
        THttpMethod.httpMethodDelete, THttpMethod.httpMethodOptions]) then
        Flag := hgAcceptData
      else
      begin
        Flag := hgWillSendMySelf;

        ProcessDocument(Sender, nil, Flag);
      end;
    except
      on E: Exception do
      begin
        try
          if Assigned(vOnException) then
            vOnException(Remote, 'onDocumentReadyServer - ' + E.Message);
        finally
          DisconnectClient(Remote, HttpAppSrv);
        end;
      end;
    end;
  end;
End;

Procedure TRESTDWIcsServicePooler.SetActive(Value: boolean);
var
  x: Integer;
Begin
  If (Value) Then
  Begin
    Try
      if not(Assigned(ServerMethodClass)) and (self.GetDataRouteCount = 0) then
        raise Exception.Create(cServerMethodClassNotAssigned);

      If Not HttpAppSrv.ListenAllOK Then
      Begin

        SetHttpServerParams;

        SetHttpServerSSL;

        HttpAppSrv.Start;

        SetSocketServerParams;

        vBruteForceProtection.StartBruteForce;
      End;
    Except
      On E: Exception do
      Begin
        Raise Exception.Create(E.Message);
      End;
    End;
  End
  Else If Not(Value) Then
  Begin
    Try
      If HttpAppSrv.ListenAllOK Then
        HttpAppSrv.Stop;

      HttpAppSrv.MultiListenSockets.Clear;

      vBruteForceProtection.StopBruteForce;
    Except
    End;
  End;
  Inherited SetActive(Value);
End;

{ TMyHttpConnection }

constructor TPoolerHttpConnection.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  vNeedClose := false;

  SetLength(vRawData, 0);

  vRawDataLen := 0;
end;

destructor TPoolerHttpConnection.Destroy;
begin
  vNeedClose := true;

  if Length(vRawData) > 0 then
    SetLength(vRawData, 0);

  vRawDataLen := 0;

  inherited Destroy;
end;

{ TIcsBruteForceProtection }

function TIcsBruteForceProtection.BruteForceAllow(IP: String): boolean;
var
  aux: TStringList;

begin
  vBruteForceCS.Acquire;

  try
    try
      aux := nil;

      if vBruteForceProtectionStatus then
      begin
        aux := TStringList.Create;
        aux.Delimiter := ';';
        aux.StrictDelimiter := true;
        aux.Clear;

        if GetBruteForceIndex(IP) > -1 then
        begin
          aux.DelimitedText := vBruteForceList.ValueFromIndex[GetBruteForceIndex(IP)];

          if ((aux[0].ToInteger > vBruteForceTry) and
            (IncMinute(aux[1].ToDouble, vBruteForceExpirationMin) > now)) then
            Result := false
          else
          begin
            if (IncMinute(aux[1].ToDouble, vBruteForceExpirationMin) < now) then
              vBruteForceList.Delete(GetBruteForceIndex(IP));

            Result := true;
          end;
        end
        else
          Result := true;
      end
      else
        Result := true;
    except
      Result := false;
    end;
  finally
    if Assigned(aux) then
      FreeAndNil(aux);

    vBruteForceCS.Release;
  end;
end;

function TIcsBruteForceProtection.GetBruteForceIndex(IP: String): Integer;
begin
  Result := vBruteForceList.IndexOfName(IP);
end;

procedure TIcsBruteForceProtection.SampleBruteForce(Sender: TObject);
var
  x: Integer;
  aux: TStringList;
begin
  vBruteForceCS.Acquire;

  try
    aux := nil;

    aux := TStringList.Create;

    for x := 0 to vBruteForceList.Count - 1 do
    begin

      aux.Delimiter := ';';
      aux.StrictDelimiter := true;
      aux.Clear;

      aux.DelimitedText := vBruteForceList[x];

      if (IncMinute(aux[1].ToDouble, vBruteForceExpirationMin) < now) then
        vBruteForceList.Delete(x);
    end;
  finally
    if Assigned(aux) then
      FreeAndNil(aux);

    vBruteForceCS.Release;
  end;
end;

procedure TIcsBruteForceProtection.StartBruteForce;
begin
  if Assigned(vBruteForceTimer) then
  begin
    vBruteForceTimer.Enabled := false;

    FreeAndNil(vBruteForceTimer);
  end;

  if vBruteForceProtectionStatus then
  begin
    vBruteForceTimer := TTimer.Create(nil);

    vBruteForceTimer.Enabled := false;

    vBruteForceTimer.Interval := vBruteForceSampleMin * 60 * 1000;

    vBruteForceTimer.OnTimer := SampleBruteForce;

    vBruteForceTimer.Enabled := true;
  end;
end;

procedure TIcsBruteForceProtection.StopBruteForce;
begin
  if Assigned(vBruteForceTimer) then
  begin
    vBruteForceTimer.Enabled := false;

    FreeAndNil(vBruteForceTimer);
  end;

  ClearBruteForceList;
end;

procedure TIcsBruteForceProtection.BruteForceAttempt(IP: String);
var
  aux: TStringList;

begin
  vBruteForceCS.Acquire;

  try
    try
      aux := nil;

      if vBruteForceProtectionStatus then
      begin
        aux := TStringList.Create;
        aux.Delimiter := ';';
        aux.StrictDelimiter := true;
        aux.Clear;

        if GetBruteForceIndex(IP) > -1 then
        begin
          aux.DelimitedText := vBruteForceList.ValueFromIndex[GetBruteForceIndex(IP)];

          aux[0] := (aux[0].ToInteger + 1).ToString;

          aux[1] := FloatToStr(now);

          vBruteForceList.ValueFromIndex[GetBruteForceIndex(IP)] := aux.DelimitedText;
        end
        else
        begin
          vBruteForceList.AddPair(IP, '1;' + FloatToStr(now));
        end;
      end;
    except
      //
    end;
  finally
    if Assigned(aux) then
      FreeAndNil(aux);

    vBruteForceCS.Release;
  end;
end;

procedure TIcsBruteForceProtection.ClearBruteForceList;
begin
  vBruteForceCS.Acquire;

  try
    if Assigned(vBruteForceList) then
    begin
      vBruteForceList.Clear;

      vBruteForceList.NameValueSeparator := '=';
    end;
  finally
    vBruteForceCS.Release;
  end;
end;

constructor TIcsBruteForceProtection.Create;
begin
  vBruteForceCS := TCriticalSection.Create;

  vBruteForceSampleMin := 1;
  vBruteForceTry := 3;
  vBruteForceExpirationMin := 30;
  vBruteForceProtectionStatus := true;

  vBruteForceList := TStringList.Create;
  vBruteForceList.Clear;
  vBruteForceList.NameValueSeparator := '=';
end;

destructor TIcsBruteForceProtection.Destroy;
begin
  StopBruteForce;

  if Assigned(vBruteForceList) then
    FreeAndNil(vBruteForceList);

  if Assigned(vBruteForceCS) then
    FreeAndNil(vBruteForceCS);

  Inherited Destroy;
end;

{ TIcsSelfAssignedCert }

function TIcsSelfAssignedCert.CertificateString: string;
begin
  Result := vCert.SaveCertToText;
end;

constructor TIcsSelfAssignedCert.Create;
begin
  if Assigned(vCert) then
    FreeAndNil(vCert);

  vCert := TSslCertTools.Create(nil);

  vAutoGenerateOnStart := false;
  vPrivKeyType := TSslPrivKeyType.PrivKeyRsa4096;
  vCertDigest := TEvpDigest.Digest_sha512;
  vExpireDays := 365;
end;

procedure TIcsSelfAssignedCert.CreateCertificate;
begin
  vCert.DoClearCerts;
  vCert.DoClearCA;
  vCert.ClearAll;

  vCert.Country := vCountry;
  vCert.State := vState;
  vCert.Locality := vLocality;
  vCert.Organization := vOrganization;
  vCert.OrgUnit := vOrgUnit;
  vCert.Email := vEmail;
  vCert.CommonName := vCommonName;
  vCert.PrivKeyType := vPrivKeyType;
  vCert.CertDigest := vCertDigest;
  vCert.ExpireDays := vExpireDays;

  vCert.DoKeyPair;
  vCert.DoSelfSignCert;
end;

destructor TIcsSelfAssignedCert.Destroy;
begin
  if Assigned(vCert) then
    FreeAndNil(vCert);

  Inherited Destroy;
end;

function TIcsSelfAssignedCert.PrivateKeyString: string;
begin
  Result := vCert.SavePKeyToText;
end;

End.
