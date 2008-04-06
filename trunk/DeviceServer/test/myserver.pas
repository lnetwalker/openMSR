program myserver;

{
  by Richard Pasco

  Based on Sebastian Koppehel's example at
  http://www.bastisoft.de/pascal/pasinet.html

  Start myserver.exe running in a console (command prompt)
  window.

  Connect to it from another console window via
  "telnet localhost 45054".
  It answers with "Welcome, stranger!"

  Thereafter it should echo to the local console a copy of
  each line it receives from the client, and also return the
  length of that line to the client.

  Except it doesn't work that way for me.  It displays garbage
  to the local console window and returns the length of that
  garbage to the client.

  If you can please help, contact me:
  http://www.richpasco.org/mailform.html
}

uses
  sockets;

const
  ListenPort : Word = $AFFE;
  MaxConn = 1;

function AddrToStr(addr : LongInt) : String;
  var
    r, s : String;
    i : LongInt;
  begin
    r := '';
    for i := 0 to 3 do
    begin
      Str(addr shr (i * 8) and $FF, s);
      r := r + s;
      if i < 3 then r := r + '.';
    end;
    AddrToStr := r;
  end;

function htons(i : Integer) : Integer;
  begin
    htons := lo(i) shl 8 or hi(i);
  end;

procedure Error(level: word; msg: string; number: word);
  begin
    Writeln(msg,number);
    halt(level);
  end;

var
  lSock, uSock : LongInt;
  sAddr : TInetSockAddr;
  Line : String;
  sin, sout : Text;
const
  Size_InetSockAddr: longint = sizeof(TInetSockAddr);

begin
  lSock := Socket(af_inet, sock_stream, 0);
  if lSock = -1 then Error(1,'Socket error: ',socketerror);

  with sAddr do begin
    Family := af_inet;
    Port := htons(ListenPort);
    Addr := 0;
  end;

  if not Bind(lSock, sAddr, sizeof(sAddr)) then Error(1,'Bind error: ',socketerror);
  if not Listen(lSock, MaxConn) then Error(1,'Listen error: ',socketerror);

  repeat
    WriteLn('Waiting for connections...');
    uSock := Accept(lSock, sAddr, Size_InetSockAddr);
    if uSock = -1 then Error(1,'Accept error: ',socketerror);
    WriteLn('Accepted connection from ' + AddrToStr(sAddr.Addr));

    Sock2Text(uSock, sin, sout);

    Reset(sin);
    Rewrite(sout);
    Writeln(sout, 'Welcome, stranger!');
    while not eof(sin) do begin
      Readln(sin, Line);
      WriteLn('Heard: '+line);
      if Line = 'close' then break;
      Writeln(sout, Line,' ',Length(Line));
    end;

    Close(sin);
    Close(sout);
    Shutdown(uSock, 2);
    WriteLn('Connection closed.');
  until False;
end.
