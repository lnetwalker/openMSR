unit telnetserver;

{ this unit implements a telnet compatible server 	}
{ the interpreter who works on the telnet session 	}
{ must be supplied by the calling program		}

{ (c) copyright by Hartmut Eilers 2008, released 	}
{ under the GNU GPL V2 or later see http://www.gnu.org	}

{ Based on Sebastian Koppehel's example at		}
{ http://www.bastisoft.de/pascal/pasinet.html		}
{ with modifications  by Richard Pasco			}
{ http://www.richpasco.org/mailform.html		}

{ 18.03.2008	Project start				}

interface

Procedure TelnetSetupInterpreter(proc : tprocedure);
procedure TelnetInit(logfile:String);
procedure TelnetServeRequest(WelcomeMSG : String);
Procedure TelnetWriteAnswer(Line : String);
function  TelnetGetData:String;


implementation

uses sockets,BaseUnix;

const
	ListenPort 		: Word = $AFFE;			// decimal 45054
	MaxConn 		= 1;
	Size_InetSockAddr	: longint = sizeof(TInetSockAddr);

var
	lSock, uSock 		: LongInt;
	sAddr 			: TInetSockAddr;
	Line 			: String;
	sin, sout 		: Text;
	LOG			: Text;
	InterpreterProc		: tprocedure;
	ShutdownProc		: Boolean;
	oa,na 			: PSigActionRec;
	NumStr			: String;



function AddrToStr(addr : LongInt) : String;
var
	r, s 	: String;
	i 	: LongInt;
begin
	r := '';
	for i := 0 to 3 do begin
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


procedure writeLOG(MSG: string);
begin
	writeln(LOG,MSG);
	flush(LOG);
end;


procedure Error(level: word; msg: string; number: word);
var
	NumStr,LevelStr		: String;
begin
	str(number,NumStr);
	str(level,LevelStr);
	writeLOG('Error occured: Level='+LevelStr+' Number='+NumStr+' Msg='+msg);
	Writeln(msg,number);
	halt(level);
end;


Procedure DoSig(sig : Longint);cdecl;

begin
	str(sig,NumStr);
	writeLOG('Receiving signal: '+NumStr);
	Line:='close';
	ShutdownProc:=true;
end;


Procedure TelnetSetupInterpreter(proc : tprocedure);
begin
	if proc <> nil then InterpreterProc:=proc;
	writeLOG('registered Telnet Interpreter');
end;


procedure TelnetInit(logfile:String);
begin
	// open logfile
	assign(LOG,logfile);
	rewrite(LOG);

	lSock := Socket(af_inet, sock_stream, 0);
	if lSock = -1 then Error(1,'Socket error: ',socketerror);
	
	with sAddr do begin
		Family := af_inet;
		Port := htons(ListenPort);
		Addr := 0;
	end;
	
	if not Bind(lSock, sAddr, sizeof(sAddr)) then Error(1,'Bind error: ',socketerror);
	if not Listen(lSock, MaxConn) then Error(1,'Listen error: ',socketerror);

end;


procedure TelnetServeRequest(WelcomeMSG : String);


begin
	shutdownProc:=false;
	repeat
		writeLOG('Waiting for connections...');
		uSock := Accept(lSock, sAddr, Size_InetSockAddr);
		if uSock = -1 then Error(1,'Accept error: ',socketerror);
		writeLOG('Accepted connection from ' + AddrToStr(sAddr.Addr));

		Sock2Text(uSock, sin, sout);
	
		Reset(sin);
		Rewrite(sout);
		Write(sout, WelcomeMSG);
		while not eof(sin) do begin
			Readln(sin, Line);
			writeLOG('Heard: '+line);
			if Line = 'close' then break;
			if InterpreterProc <> nil then InterpreterProc;
		end;
	
		Close(sin);
		Close(sout);
		Shutdown(uSock, 2);
		writeLOG('Connection closed.');
	until ShutdownProc;
end;


Procedure TelnetWriteAnswer(Line : String);
begin
	Write(sout, Line);
end;


function TelnetGetData:String;
begin
	TelnetGetData:=Line;
end;


begin
	InterpreterProc:=nil;
	// setup signal handler for quit
	new(na);
	new(oa);
	na^.sa_Handler:=SigActionHandler(@DoSig);
	fillchar(na^.Sa_Mask,sizeof(na^.sa_mask),#0);
	na^.Sa_Flags:=0;
	{$ifdef Linux}               // Linux specific
		na^.Sa_Restorer:=Nil;
	{$endif}
	IF FPSigAction(SIGTERM,na,oa) <> 0 then begin;
		str(fpgeterrno,NumStr);
		writeLOG('Error: '+NumStr);
		halt(1);
	end;
end.
