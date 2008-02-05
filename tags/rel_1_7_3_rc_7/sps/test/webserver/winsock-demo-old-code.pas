unit WINSOCK;
{ Winsock.h file for Borland Pascal
  Conversion by Marc B. Manza
             Center for Applied Large-Scale Computing
  Requires Winsock.pas and Winsock.inc
  Send any comments/change requests/etc. to:
  manza@flash.poly.edu
}
{
  Modified by Mike Caughran Cedar Island Software Nov 1994
  Changed references to SOCKET to tSOCKET
  added INADDR_ANY
  added PInteger
}
{Nochmal modifiziert: INC+PAS-Dateien zusammengeführt,
 Strukturen Pascal-like umgebaut (mit "T" und "P") sowie
 unsinnige Komponentenpräfixe entfernt (z.B. sin_addr --> addr).
 Die Strukturen SOCKADDR und SOCKADDR_IN wurden zu einer
 verschachtelten Struktur TSockAddr zusammengeführt.
 Eine handhabbare, statisch linkbare Funktion "OpenSock"
 wurde hinzugefügt.

 Another modification: one File (no .INC file),
 structures modified with "T" and "P" prefixes,
 removed old-c-style record component prefixes (e.g. sin_addr --> addr),
 removed structure SOCKADDR_IN and enhancement of SOCKADDR
 to a record/union TSockAddr with all required components.
 Added static library function "OpenSock()".

 H.Haftmann
}

interface

uses WIN31, WinTypes, WinProcs;


const
 FD_SETSIZE=64;

type
 PFd_Set=^TFd_Set;
 TFd_Set = record
  count: Word;
  fd_array: array[0..FD_SETSIZE-1] of Word;
 end;

 TTimeVal = record
  sec,usec : longint;
 end;

const
 IOCPARM_MASK   =   $007f;
 IOC_VOID       =   $20000000;
 IOC_OUT        =   $40000000;
 IOC_IN         =   $80000000;
 IOC_INOUT      =   (IOC_IN OR IOC_OUT);

 FIONREAD       =$4004667F;
 FIONBIO        =$8004667E;
 FIOASYNC       =$8004667D;

type
 PPChar=^PChar;

 PHostEnt=^THostEnt;
 THostEnt = record
  name : PChar;
  aliases : PPChar;
  addrtype : integer;
  length : integer;
  addr_list : PPChar;
{statt "addr" (bzw. "h_addr") schreibe man "addr_list^"}
{macro addr addr_list^}
 end;

 TNetEnt = record
  name : PChar;
  aliases : PPChar;
  addrtype : Integer;
  net : LongInt;
 end;

 PServEnt=^TServEnt;
 TServEnt=record
  name : PChar;
  aliases : PPChar;
  port : Integer;
  proto : PChar;
 end;

 PProtoEnt=^TProtoEnt;
 TProtoEnt=record
  name : PChar;
  aliases : PPchar;
  proto : Integer;
 end;

const
 IPPROTO_IP     =   0;
 IPPROTO_ICMP   =   1;
 IPPROTO_GGP    =   2;
 IPPROTO_TCP    =   6;
 IPPROTO_PUP    =   12;
 IPPROTO_UDP    =   17;
 IPPROTO_IDP    =   22;
 IPPROTO_ND     =   77;

 IPPROTO_Raw    =   255;
 IPPROTO_Max    =   256;


 IPPORT_Echo    =   7;
 IPPORT_Discard =   9;
 IPPORT_Systat  =   11;
 IPPORT_DayTime =   13;
 IPPORT_NetStat =   15;
 IPPORT_FTP     =   21;
 IPPORT_Telnet  =   23;
 IPPORT_SMTP    =   25;
 IPPORT_TimeServer  =  37;
 IPPORT_NameServer  =  42;
 IPPORT_WhoIs       =  43;
 IPPORT_MTP         =  57;

 IPPORT_TFTP        =  69;
 IPPORT_RJE         =  77;
 IPPORT_Finger      =  79;
 IPPORT_TtyLink     =  87;
 IPPORT_SUPDUP      =  95;

 IPPORT_ExecServer  =  512;
 IPPORT_LoginServer =  513;
 IPPORT_CmdServer   =  514;
 IPPORT_EfsServer   =  520;

 IPPORT_BiffUdp     =  512;
 IPPORT_WhoServer   =  513;
 IPPORT_RouteServer =  520;

 IPPORT_Reserved    =  1024;

 IMPLINK_IP         =  155;
 IMPLINK_LowExper   =  156;
 IMPLINK_HighExper  =  158;

type
 PSockAddr = ^TSockAddr;
 TSockAddr = record
  family : integer;
  case integer of
   0: ( data: array[0..13] of Char );   {Original SOCKADDR}
   1: ( port: Word;                     {Original SOCKADDR_IN}
   case integer of
    0: ( addr: array[0..11] of Char );  {Max. 12 byte IP address}
    1: ( inaddr: LongInt );             {usual 4 byte IP address}
   );
 end;

const
 WSADESCRIPTION_LEN     =   256;
 WSASYS_STATUS_LEN      =   128;

type
 PWsaData=^TWsaData;
 TWsaData=record
  wVersion : word;
  wHighVersion : word;
  szDescription : array[0..WSADESCRIPTION_LEN] of char;
  szSystemStatus : array[0..WSASYS_STATUS_LEN] of char;
  iMaxSockets : integer;
  iMaxUdpDg : integer;
  lpVendorInfo : PChar;
 end;

const
 IP_OPTIONS     =   1;
 INADDR_ANY     =   0;    {msc}
 INADDR_NONE    =  -1;

 INVALID_SOCKET =   $FFFF;
 SOCKET_ERROR   =   -1;

 SOCK_STREAM    =   1;
 SOCK_DGRAM     =   2;
 SOCK_RAW       =   3;
 SOCK_RDM       =   4;
 SOCK_SEQPACKET =   5;

 SO_DEBUG       =   $0001;
 SO_ACCEPTCONN  =   $0002;
 SO_REUSEADDR   =   $0004;
 SO_KEEPALIVE   =   $0008;
 SO_DONTROUTE   =   $0010;
 SO_BROADCAST   =   $0020;
 SO_USELOOPBACK =   $0040;
 SO_LINGER      =   $0080;
 SO_OOBINLINE   =   $0100;

 SO_DONTLINGER  =   $ff7f;

 SO_SNDBUF      =   $1001;
 SO_RCVBUF      =   $1002;
 SO_SNDLOWAT    =   $1003;
 SO_RCVLOWAT    =   $1004;
 SO_SNDTIMEO    =   $1005;
 SO_RCVTIMEO    =   $1006;
 SO_ERROR       =   $1007;
 SO_TYPE        =   $1008;

 AF_UNSPEC      =   0;
 AF_UNIX        =   1;
 AF_INET        =   2;
 AF_IMPLINK     =   3;
 AF_PUP         =   4;
 AF_CHAOS       =   5;
 AF_NS          =   6;
 AF_NBS         =   7;
 AF_ECMA        =   8;
 AF_DATAKIT     =   9;
 AF_CCITT       =   10;
 AF_SNA         =   11;
 AF_DECnet      =   12;
 AF_DLI         =   13;
 AF_LAT         =   14;
 AF_HYLINK      =   15;
 AF_APPLETALK   =   16;

 AF_MAX         =   17;

type
 PSockProto=^TSockProto;
 TSockProto=record
  family,protocol : Word;
 end;

const
 PF_UNSPEC      =   AF_UNSPEC;
 PF_UNIX        =   AF_UNIX;
 PF_INET        =   AF_INET;
 PF_IMPLINK     =   AF_IMPLINK;
 PF_PUP         =   AF_PUP;
 PF_CHAOS       =   AF_CHAOS;
 PF_NS          =   AF_NS;
 PF_NBS         =   AF_NBS;
 PF_ECMA        =   AF_ECMA;
 PF_DATAKIT     =   AF_DATAKIT;
 PF_CCITT       =   AF_CCITT;
 PF_SNA         =   AF_SNA;
 PF_DECnet      =   AF_DECnet;
 PF_DLI         =   AF_DLI;
 PF_LAT         =   AF_LAT;
 PF_HYLINK      =   AF_HYLINK;
 PF_APPLETALK   =   AF_APPLETALK;

 PF_MAX         =   AF_MAX;

type
 PLinger=^TLinger;
 TLinger=record
  onoff : Word;
  linger : Word;
 end;

const
 SOL_SOCKET     =   $ffff;

 SOMAXCONN      =   5;

 MSG_OOB        =   $1;
 MSG_PEEK       =   $2;
 MSG_DONTROUTE  =   $4;

 MSG_MAXIOVLEN  =   16;

 MAXGETHOSTSTRUCT   =  1024;

 FD_READ            =  $01;
 FD_WRITE           =  $02;
 FD_OOB             =  $04;
 FD_ACCEPT          =  $08;
 FD_CONNECT         =  $10;
 FD_CLOSE           =  $20;


 WSABASEERR         =  10000;

 WSAEINTR           =  (WSABASEERR + 4);
 WSAEBADF           =  (WSABASEERR + 9);
 WSAEFAULT          =  (WSABASEERR + 14);
 WSAEINVAL          =  (WSABASEERR + 22);
 WSAEMFILE          =  (WSABASEERR + 24);

 WSAEWOULDBLOCK     =  (WSABASEERR + 35);
 WSAEINPROGRESS     =  (WSABASEERR + 36);
 WSAEALREADY        =  (WSABASEERR + 37);
 WSAENOTSOCK        =  (WSABASEERR + 38);
 WSAEDESTADDRREQ    =  (WSABASEERR + 39);
 WSAEMSGSIZE        =  (WSABASEERR + 40);
 WSAEPROTOTYPE      =  (WSABASEERR + 41);
 WSAENOPROTOOPT     =  (WSABASEERR + 42);
 WSAEPROTONOSUPPORT =  (WSABASEERR + 43);
 WSAESOCKTNOSUPPORT  =  (WSABASEERR + 44);
 WSAEOPNOTSUPP      =  (WSABASEERR + 45);
 WSAEPFNOSUPPORT    =  (WSABASEERR + 46);
 WSAEAFNOSUPPORT    =  (WSABASEERR + 47);
 WSAEADDRINUSE      =  (WSABASEERR + 48);
 WSAEADDRNOTAVAIL   =  (WSABASEERR + 49);
 WSAENETDOWN        =  (WSABASEERR + 50);
 WSAENETUNREACH     =  (WSABASEERR + 51);
 WSAENETRESET       =  (WSABASEERR + 52);
 WSAECONNABORTED    =  (WSABASEERR + 53);
 WSAECONNRESET      =  (WSABASEERR + 54);
 WSAENOBUFS         =  (WSABASEERR + 55);
 WSAEISCONN         =  (WSABASEERR + 56);
 WSAENOTCONN        =  (WSABASEERR + 57);
 WSAESHUTDOWN       =  (WSABASEERR + 58);
 WSAETOOMANYREFS    =  (WSABASEERR + 59);
 WSAETIMEDOUT       =  (WSABASEERR + 60);
 WSAECONNREFUSED    =  (WSABASEERR + 61);
 WSAELOOP           =  (WSABASEERR + 62);
 WSAENAMETOOLONG    =  (WSABASEERR + 63);
 WSAEHOSTDOWN       =  (WSABASEERR + 64);
 WSAEHOSTUNREACH    =  (WSABASEERR + 65);
 WSAENOTEMPTY       =  (WSABASEERR + 66);
 WSAEPROCLIM        =  (WSABASEERR + 67);
 WSAEUSERS          =  (WSABASEERR + 68);
 WSAEDQUOT          =  (WSABASEERR + 69);
 WSAESTALE          =  (WSABASEERR + 70);
 WSAEREMOTE         =  (WSABASEERR + 71);

 WSASYSNOTREADY     =  (WSABASEERR + 91);
 WSAVERNOTSUPPORTED =  (WSABASEERR + 92);
 WSANOTINITIALISED  =  (WSABASEERR + 93);

 WSAHOST_NOT_FOUND  =  (WSABASEERR + 1001);
 HOST_NOT_FOUND     =  WSAHOST_NOT_FOUND;

 WSATRY_AGAIN       =  (WSABASEERR + 1002);
 TRY_AGAIN          =  WSATRY_AGAIN;

 WSANO_RECOVERY     =  (WSABASEERR + 1003);
 NO_RECOVERY        =  WSANO_RECOVERY;

 WSANO_DATA         =  (WSABASEERR + 1004);
 NO_DATA            =  WSANO_DATA;

 WSANO_ADDRESS      =  WSANO_DATA;
 NO_ADDRESS         =  WSANO_ADDRESS;

 EWOULDBLOCK        =  WSAEWOULDBLOCK;
 EINPROGRESS        =  WSAEINPROGRESS;
 EALREADY           =  WSAEALREADY;
 ENOTSOCK           =  WSAENOTSOCK;
 EDESTADDRREQ       =  WSAEDESTADDRREQ;
 EMSGSIZE           =  WSAEMSGSIZE;
 EPROTOTYPE         =  WSAEPROTOTYPE;
 ENOPROTOOPT        =  WSAENOPROTOOPT;
 EPROTONOSUPPORT    =  WSAEPROTONOSUPPORT;
 ESOCKTNOSUPPORT    =  WSAESOCKTNOSUPPORT;
 EOPNOTSUPP         =  WSAEOPNOTSUPP;
 EPFNOSUPPORT       =  WSAEPFNOSUPPORT;
 EAFNOSUPPORT       =  WSAEAFNOSUPPORT;
 EADDRINUSE         =  WSAEADDRINUSE;
 EADDRNOTAVAIL      =  WSAEADDRNOTAVAIL;
 ENETDOWN           =  WSAENETDOWN;
 ENETUNREACH        =  WSAENETUNREACH;
 ENETRESET          =  WSAENETRESET;
 ECONNABORTED       =  WSAECONNABORTED;
 ECONNRESET         =  WSAECONNRESET;
 ENOBUFS            =  WSAENOBUFS;
 EISCONN            =  WSAEISCONN;
 ENOTCONN           =  WSAENOTCONN;
 ESHUTDOWN          =  WSAESHUTDOWN;
 ETOOMANYREFS       =  WSAETOOMANYREFS;
 ETIMEDOUT          =  WSAETIMEDOUT;
 ECONNREFUSED       =  WSAECONNREFUSED;
 ELOOP              =  WSAELOOP;
 ENAMETOOLONG       =  WSAENAMETOOLONG;
 EHOSTDOWN          =  WSAEHOSTDOWN;
 EHOSTUNREACH       =  WSAEHOSTUNREACH;
 ENOTEMPTY          =  WSAENOTEMPTY;
 EPROCLIM           =  WSAEPROCLIM;
 EUSERS             =  WSAEUSERS;
 EDQUOT             =  WSAEDQUOT;
 ESTALE             =  WSAESTALE;
 EREMOTE            =  WSAEREMOTE;

type
 u_short=Word;
 u_int=Word;
 TSocket=Word;

{ Library Functions: BSD equivalents }

function Accept (s:TSocket; const addr:TSockaddr; var addrlen:Integer):TSocket;
function Bind   (s:TSocket; const addr:Tsockaddr; namelen:integer):integer;
function CloseSocket(s:TSocket):integer;
function Connect(s:TSocket; const name:Tsockaddr; namelen:integer):integer;
function IoctlSocket(s:TSocket; cmd:Longint; var argp:LongInt):integer;
function GetPeerName(s:TSocket; const name:Tsockaddr; var namelen:Integer):integer;
function GetSockName(s:TSocket; const name:Tsockaddr; var namelen:Integer):integer;
function GetSockOpt(s:TSocket; level, optname:integer; var optval; var optlen:Integer):integer;
function htonl  (hostlong:LongInt):LongInt;
function htons  (hostshort:Word):Word;
function inet_addr(cp:PChar):LongInt;  { four-byte internet address }
function inet_ntoa(inaddr:LongInt):PChar;
function Listen (s:TSocket; backlog:integer):integer;
function ntohl  (netlong:LongInt):LongInt;
function ntohs  (netshort:Word):Word;
function Recv   (s:TSocket; buf:PChar; len, flags:Integer):integer;
function RecvFrom(s:TSocket; buf:PChar; len, flags:Integer; const from:Tsockaddr; var fromlen:Integer):integer;
function Select (nfds:integer; var readfds, writefds, exceptfds:Tfd_set; const timeout:TTimeVal):Longint;
function Send   (s:TSocket; buf:PChar; len, flags:Integer):integer;
function SendTo (s:TSocket; buf:PChar; len, flags:Integer; const addrto:Tsockaddr; tolen:Integer):integer;
function SetSockOpt(s:TSocket; level, optname:integer; const optval; optlen:integer):integer;
function Shutdown(s:TSocket; how:integer):integer;
function Socket (af, struct, protocol:integer):TSocket;
function GetHostByAddr(addr:PChar; len, struct:integer):PHostEnt;
function GetHostbyName(name:PChar):PHostEnt;
function GetHostName(name:PChar; len:integer):integer;
function GetServByPort(port:integer; proto:PChar):PServEnt;
function GetServByName(name, proto:PChar):PServEnt;
function GetProtoByNumber(proto:integer):PProtoEnt;
function GetProtoByName(name:PChar):PProtoEnt;

{ Library Funtions: WSA extensions }

function WSAStartup (wVersionRequired:word; var lpWSData:TWSADATA):integer;
function WSACleanup:integer;
procedure WSASetLastError (iError:integer);
function WSAGetLastError:integer;
function WSAIsBlocking:BOOL;
function WSAUnhookBlockingHook:integer;
function WSASetBlockingHook (lpBlockFunc:TFarProc):TFarProc;
function WSACancelBlockingCall:integer;
function WSAAsyncGetServByName (HWindow:HWnd; wMsg:Word; name, proto, buf:PChar; buflen:integer):THandle;
function WSAAsyncGetServByPort ( HWindow:HWnd; wMsg, port:Word; proto, buf:PChar; buflen:integer):THandle;
function WSAAsyncGetProtoByName (HWindow:HWnd; wMsg:Word; name, buf:PChar; buflen:integer):THandle;
function WSAAsyncGetProtoByNumber (HWindow:HWnd; wMsg:Word; number:integer; buf:PChar; buflen:integer):THandle;
function WSAAsyncGetHostByName (HWindow:HWnd; wMsg:Word; name, buf:PChar; buflen:integer):THandle;
function WSAAsyncGetHostByAddr (HWindow:HWnd; wMsg:Word; addr:PChar; len, struct:integer;
                                buf:PChar; buflen:integer):THandle;
function WSACancelAsyncRequest (hAsyncTaskHandle:THandle):integer;
function WSAAsyncSelect (s:TSocket; HWindow:HWnd; wMsg:Word; lEvent:longint):integer;

{ Macro functions }

function WSAMakeSyncReply (Buflen, Error:Word):LongInt;
inline($5A/$58);    { POP DX AX : MakeLong()}
function WSAMakeSelectReply (Event, Error:Word):LongInt;
inline($5A/$58);    { POP DX AX : MakeLong()}
function WSAGetAsyncBuflen (Param:LongInt):Word;
inline($58/$5A);    { POP AX DX : LoWord()}
function WSAGetAsyncError (Param:LongInt):Word;
inline($5A/$58);    { POP DX AX : HiWord()}
function WSAGetSelectEvent (Param:LongInt):Word;
inline($58/$5A);    { POP AX DX : LoWord()}
function WSAGetSelectError (Param:LongInt):Word;
inline($5A/$58);    { POP DX AX : HiWord()}

{ Static linkable function }

function OpenSock(Sock:TSocket; Server:PChar; Port:Word):Integer;

implementation

function Accept;            external 'WINSOCK' index 1;
function Bind;              external 'WINSOCK' index 2;
function CloseSocket;       external 'WINSOCK' index 3;
function Connect;           external 'WINSOCK' index 4;
function GetPeerName;       external 'WINSOCK' index 5;
function GetSockName;       external 'WINSOCK' index 6;
function GetSockOpt;        external 'WINSOCK' index 7;
function htonl;             external 'WINSOCK' index 8;
function htons;             external 'WINSOCK' index 9;
function inet_addr;         external 'WINSOCK' index 10;
function inet_ntoa;         external 'WINSOCK' index 11;
function IoctlSocket;       external 'WINSOCK' index 12;
function Listen;            external 'WINSOCK' index 13;
function ntohl;             external 'WINSOCK' index 14;
function ntohs;             external 'WINSOCK' index 15;
function Recv;              external 'WINSOCK' index 16;
function RecvFrom;          external 'WINSOCK' index 17;
function Select;            external 'WINSOCK' index 18;
function Send;              external 'WINSOCK' index 19;
function SendTo;            external 'WINSOCK' index 20;
function SetSockOpt;        external 'WINSOCK' index 21;
function ShutDown;          external 'WINSOCK' index 22;
function Socket;            external 'WINSOCK' index 23;

function GetHostByAddr;     external 'WINSOCK' index 51;
function GetHostByName;     external 'WINSOCK' index 52;
function GetProtoByName;    external 'WINSOCK' index 53;
function GetProtoByNumber;  external 'WINSOCK' index 54;
function GetServByName;     external 'WINSOCK' index 55;
function GetServByPort;     external 'WINSOCK' index 56;
function GetHostName;       external 'WINSOCK' index 57;

function WSAAsyncSelect;        external 'WINSOCK' index 101;
function WSAAsyncGetHostByAddr; external 'WINSOCK' index 102;
function WSAAsyncGetHostByName; external 'WINSOCK' index 103;
function WSAAsyncGetProtoByNumber; external 'WINSOCK' index 104;
function WSAAsyncGetprotoByName; external 'WINSOCK' index 105;
function WSAAsyncGetServByPort; external 'WINSOCK' index 106;
function WSAAsyncGetServByName; external 'WINSOCK' index 107;
function WSACancelAsyncRequest; external 'WINSOCK' index 108;
function WSASetBlockingHook;    external 'WINSOCK' index 109;
function WSAUnhookBlockingHook; external 'WINSOCK' index 110;
function WSAGetLastError;       external 'WINSOCK' index 111;
procedure WSASetLastError;      external 'WINSOCK' index 112;
function WSACancelBlockingCall; external 'WINSOCK' index 113;
function WSAIsBlocking;         external 'WINSOCK' index 114;
function WSAStartup;            external 'WINSOCK' index 115;
function WSACleanup;            external 'WINSOCK' index 116;

function OpenSock(Sock:TSocket; Server:PChar; Port:Word):Integer;
 var
  sa: TSockAddr;
  he: PHostEnt;
 begin
  FillChar(sa,sizeof(sa),0);
  sa.family:=AF_INET;
  sa.port:=htons(port);
  sa.inaddr:=inet_addr(Server);

  if sa.inaddr=INADDR_NONE then begin
   he:=GetHostByName(Server);
   if he=nil then begin
    OpenSock:=-3;       {code for "cannot evaluate/resolve IP address"}
    exit;
   end;
   Move(he^.addr_list^^,sa.addr,he^.length);
  end;

  if Connect(Sock,sa,sizeof(sa))=SOCKET_Error then begin
   OpenSock:=-4;        {code for "cannot open socket connection"}
   exit;
  end;
  OpenSock:=0;          {code for success}
 end;

end.
