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
procedure TelnetInit(LPort: Word;logfile:String);
procedure TelnetServeRequest(WelcomeMSG : String);
Procedure TelnetWriteAnswer(Line : String);
function  TelnetGetData:String;
procedure TelnetShutDown;


implementation

uses crt,sockets,BaseUnix,Unix,inetaux;

const
	MaxConn 		= 1;
	Size_InetSockAddr	: longint = sizeof(TInetSockAddr);

var
	lSock, uSock 		: LongInt;
	sAddr 			: TInetSockAddr;
	Line 			: String;
	sin, sout 		: Text;
	LOG			: Text;
	InterpreterProc		: tprocedure;
	ListenPort 		: Word ;
	ShutDownProc		: Boolean;





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


Procedure TelnetSetupInterpreter(proc : tprocedure);
begin
	if proc <> nil then InterpreterProc:=proc;
	writeLOG('registered Telnet Interpreter');
end;


procedure TelnetInit(LPort: Word;logfile:String);
begin
	ShutDownProc:=false;
	// open logfile
	assign(LOG,logfile);
	rewrite(LOG);

	lSock := Socket(af_inet, sock_stream, 0);
	if lSock = -1 then Error(1,'Socket error: ',socketerror);
	
	if LPort=0 then LPort:=ListenPort;

	with sAddr do begin
		Family := af_inet;
		Port := htons(LPort);
		Addr := 0;
	end;

	if not Bind(lSock, sAddr, sizeof(sAddr)) then Error(1,'Bind error: ',socketerror);
	if not Listen(lSock, MaxConn) then Error(1,'Listen error: ',socketerror);

end;


procedure TelnetServeRequest(WelcomeMSG : String);


begin
	writeLOG('Waiting for connections...');
	uSock := Accept(lSock, sAddr, Size_InetSockAddr);

	if uSock = -1 then Error(1,'Telnet Accept error: ',socketerror);
	// set NonBlocking IO
	{$ifdef LINUX}
		FpFcntl(usock,F_SetFd,MSG_DONTWAIT);
	{$endif}

	writeLOG('Accepted connection from ' + AddrToStr(sAddr.Addr));
	Sock2Text(uSock, sin, sout);
	
	Reset(sin);
	Rewrite(sout);
	Write(sout, WelcomeMSG);
	repeat
		if SelectText(sin,10000)>0 then begin
			Readln(sin, Line);
			writeLOG('Heard: '+line);
			if Line = 'close' then break;
			if InterpreterProc <> nil then InterpreterProc;
		end;
		if ShutDownProc then break;
	until false;

	Close(sin);
	Close(sout);
	Shutdown(uSock, 2);
	writeLOG('Connection closed.');
end;


Procedure TelnetWriteAnswer(Line : String);
begin
	Write(sout, Line);
end;


function TelnetGetData:String;
begin
	TelnetGetData:=Line;
end;


procedure TelnetShutDown;
begin
	ShutDownProc:=true;
	delay(500);
	Shutdown(lsock,2);
	Shutdown(usock,2);
end;


begin
	InterpreterProc:=nil;
	ListenPort:= $AFFE;			// decimal 45054
end.
