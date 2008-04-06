//{$Id$}

{$MODE OBJFPC}{$H+}
unit webserver;

{ (c) 2006 by Hartmut Eilers < hartmut@eilers.net				}
{ distributed  under the terms of the GNU GPL V 2				}
{ see http://www.gnu.org/licenses/gpl.html for details				}
{ derived from the original work of pswebserver (c) by 				}
{ Vladimir Sibirov								}

{ simple embeddable HTTP server for FPC Pascal for Linux and			}
{ Windows, using non-blocking socket I/O to easy fit and			}
{ integrate in different programs 						}
{ tested on Win 32  W2K Advanced Server and Debian Linux 			}
{ can serve static HTML Pages and Images and special dynamic			}
{ content provided by the embedding program					}
{ see example program pwserver.pas for information about usage			}

{ History: 									}
{ 15.03.2006 startet with Vladimirs Code 					}
{ 17.03.2006 running non Block http server on linux 				}
{ 20.03.2006 startet porting to win32 using winsock 				}
{ 24.03.2006 WINSOCK code works including read of request 			}
{ 27.03.2006 WINSOCK code works 						}
{ 02.04.2006 serving of simple text pages work 					}
{ 03.04.2006 cleaned code, tested with firefox and konqueror -> ok 		}
{   	     wget doesn't receive anything :( 					}
{ 17.10.2006 started the unit webserver from pswebserver code			}
{		     currently only GET requests are supported			}
{ 12.11.2006 added registration of special URLs through callback		}
{ 18.11.2006 added sending of variable data to the embedding process		}

interface


procedure start_server(address:string;port:word;BlockMode: Boolean;doc_root,logfile:string);
procedure SetupSpecialURL(URL:string;proc : tprocedure);
procedure SetupVariableHandler(proc: tprocedure);
procedure SendPage(myPage : AnsiString);
procedure serve_request;
function GetURL:string;
function GetParams:string;
procedure stop_server();


implementation

{$ifdef LINUX}
	uses sockets, crt,inetaux, BaseUnix, Unix;
{$else}
	uses winsock,crt,inetaux;
{$endif}

{$ifdef WIN32}
	type
		TFDSet = Winsock.TFDSet; 
{$endif}
	
const 
	LocalAddress = '127.0.0.1';
	debug = true;
	MaxUrl = 25;
	
var

	// Listening socket
	{$ifdef LINUX }
		sock,csock	: longint;
	{$else}
		sock		: TSocket;
		ConnSock	: TSocket;
	{$endif}

	// Maximal queue length
	max_connections	: integer;

	binData			: byte;

	// Server and Client address
	{$ifdef LINUX}
		srv_addr	: TInetSockAddr;
		cli_addr	: TInetSockAddr;
		// Conncected socket i/o
		sin, sout,			// Descriptors for listening port
		ccsin,ccsout	: text;		// Descriptors for client communication dynamic ports
		Addr_len	: LongInt;
	{$else}
		srv_addr	: TSockAddr;
		cli_addr	: TSockAddr;	
		GInitData	: TWSADATA;
		addr_len 	: u_int;
		NON_BLOCK	: LongInt;
		FDRead		: TFDSet;
		Result		: integer;
		TimeVal 	: TTimeVal;
		FCharBuf	: array [1..32768] of char;
		RecBufSize	: integer;
		sendString	: AnsiString;
	{$endif}

	// Buffers
	buff			: String;
	post			: array [1..65535] of string;

	// Counter
	BufCnt			: Integer;

	// DOCUMENT ROOT
	DocRoot			: string;

	{ the requested URL, the File to serve and the send data}
	params,URL		: string;
	SpecialURL		: array[1..MaxUrl] of String;
	UrlPointer		: byte;

	G			: file of byte;

	header,page,
	CType			: AnsiString;

	PageSize		: LongInt;

	TRespSize,
	status			: string;

	// Request size
	reqSize,reqCnt		: word;

	// LOG-File
	LOG			: text;

	ServingRoutine		: array[1..MaxUrl] of tprocedure;
	VariableHandler		: tprocedure;

	// this variable is just used to convert numerics to string
	blubber			: string;


procedure writeLOG(MSG: string);
begin
	writeln(LOG,MSG);
	flush(LOG);
end;


procedure SetupSpecialURL(URL:string;proc : tprocedure);
begin
	if proc <> nil then ServingRoutine[UrlPointer]:=proc;
	if URL <> '' then SpecialURL[UrlPointer]:=URL;
	inc(UrlPointer);
	writeLOG('registered special URL'+URL);
end;
	

procedure SetupVariableHandler(proc : tprocedure);
begin
	if proc <> nil then VariableHandler:=proc;
	writeLOG('registered Variable Handler');
end;


procedure start_server(address:string;port:word;BlockMode: Boolean;doc_root,logfile:string);

begin
	// open logfile
	assign(LOG,logfile);
	rewrite(LOG);

	{ Initialization}
	writeLOG('PWS Pascal Web Server - starting server...');
	if (port=0) then port:=10080;
	if (address='') then address:=LocalAddress;
	str(port,blubber);
	writeLOG('using port='+blubber+' address='+address);
	DocRoot:=doc_root;
	BufCnt:=1;
	reqCnt:=0;
	max_connections := 5;
	{$ifdef LINUX}
		srv_addr.family := AF_INET;
		srv_addr.port := htons(port);	 
		srv_addr.addr := StrToAddr(address);
	{$else}
		srv_addr.sin_family := AF_INET;
		srv_addr.sin_port := htons(port);
		srv_addr.sin_addr.S_addr := StrToAddr(Address);
        { Inititialize WINSOCK }
		if WSAStartup($101, GInitData) <> 0 then writeLOG('Error init Winsock');
	{$endif}
	
	{ Create socket }
	sock := fpsocket(PF_INET, SOCK_STREAM, 0);

	if not(BlockMode) then begin
		{ set socket to non blocking mode }
		{$ifdef LINUX}
			FpFcntl(sock,F_SetFd,MSG_DONTWAIT);
		{$else}
			NON_BLOCK:=1;
			Result:=ioctlsocket(sock,FIONBIO,@NON_BLOCK);
			if ( Result=SOCKET_ERROR ) then writeLOG('setting NON_BLOCK failed :(');
		{$endif}
	end;

	// Binding the server
	writeLOG('Binding port..');
	{$ifdef LINUX}
		if not bind(sock, srv_addr, sizeof(srv_addr)) then begin
			writeLOG('!! Error in bind().');
			halt;
		end;
	{$else}
		if (bind(sock, srv_addr, SizeOf(srv_addr)) <> 0) then  begin
			writeLOG('!! Error in bind');
			halt;
		end;
	{$endif}
	
	// Listening on port
	writeLOG('listen..');
	{$ifdef LINUX}
		fplisten(sock, max_connections);
	{$else}
		if (listen(sock, max_connections) = SOCKET_ERROR) then writeLOG('listen() failed with error '+ WSAGetLastError());
	{$endif}
end;


procedure SendPage(myPage : AnsiString);
var
	i 		: byte;

begin
	PageSize:=length(myPage);
	if status='' then status:='200 ok';

	{ generate the header }
	header:='HTTP/1.1 '+status+chr(10);
	header:=header+'Connection: close'+chr(10);
	header:=header+'MIME-Version: 1.0'+chr(10);
	header:=header+'Server: bonita'+chr(10);
	{ currently the mimetype of an object is always text/html }
	header:=header+CType;
	header:=header+'Content-length: ';
	{ the Content-length is the size of the served object }
	{ without the size of the header } 
	str(PageSize,TRespSize);
	header:=header+TRespSize;
	header:=header+chr(10);
	str(PageSize,blubber);
	writeLOG('DocSize: '+blubber);
	writeLOG('Header: '+header);
	writeLOG('/Header');

	// Sending response
	writeLOG('serving data...');
	{$ifdef LINUX}
		str(BufCnt,blubber);
		writeLOG('BufCnt='+blubber);
		{ if I send the header and the page together }
		{ firefox has a problem and displays nothing }
		i:=0;
		repeat
			inc(i);
		until (copy(post[i],1,10)='User-Agent');
		if (copy(post[i],13,7)='Mozilla') then begin
			writeln(ccsout,header);
			writeln(ccsout,myPage);
		end
		else
			writeln(ccsout,header+myPage);

		writeln(ccsout);

		// Flushing output
		flush(ccsout);

	{$else}
		{ note chr(10) is newline }
		{ build the string that should be send }
		sendString:=header+myPage;
		{ copy string to send into the send buffer }
		for i:=1 to length(sendString) do FCharBuf[i]:=sendString[i];
		writeLOG('respSize: '+length(sendString));
		Result:=send(ConnSock,@FCharBuf[1],length(sendString),0);
		if ( Result=SOCKET_ERROR ) then writeLOG('send Data failed :(');
		Shutdown(ConnSock, 2);
	{$endif}
	writeLOG('finished request..., connection closed');
	BufCnt:=1;
end;

procedure process_request;
var Paramstart,i	: word;

begin
	reqSize:=0;
	writeLOG('reading request data');
	repeat
		{ actually we should switch to blocking mode here, }
		{ because it is possible that some amount of time  }
		{ is between the connect and the request           }
		{$ifdef LINUX}
			readln(ccsin, buff);
			str(BufCnt,blubber);
			writeLOG('Req['+blubber+']='+buff);
			post[BufCnt] := buff;
			reqSize:=reqSize+length(post[BufCnt]);
			inc(BufCnt);
		{$else}
			RecBufSize:=recv(ConnSock,@FCharBuf[1],SizeOf(FCharBuf),0);
			if (RecBufSize=SOCKET_ERROR) then writeLOG('socket error during read '+WSAGetLastError);
			buff:=copy(FCharBuf,1,RecBufSize);
			BufCnt:=1;
			{ Request zerlegen und in array post zeile fuer Zeile speichern }
			repeat
				post[BufCnt]:=copy(buff,1,pos(chr(10),buff)-1);
				writeLOG('Req['+BufCnt+']='+post[BufCnt]);
				buff:=copy(buff,pos(chr(10),buff)+1,length(buff));
				inc(BufCnt);
			until length(buff)<1;
			reqSize:=RecBufSize;
		{$endif}	
	until length(buff)<1;

	inc(reqCnt);
	str(reqCnt,blubber);
	writeLOG('# of Requests : '+blubber);
	str(reqSize,blubber);
	writeLOG('requestSize: '+blubber);

	{ processing the request }

	{ post[1] is the request URI, extract the wanted URL }
	{ after first slash (/) in the string the URL starts and longs until next blank }
	{ e.g. "GET /path/to/a/non/existing/file.htm HTTP/1.1" }
	{ request type is ignored it's always GET assumed }
	URL:=copy(post[1],pos('/',post[1]),length(post[1]));
	URL:=copy(URL,1,pos(' ',URL)-1);
	Paramstart:=pos('?',URL);

	if ( Paramstart <> 0 ) then begin
		// this URL has parameters
		params:=copy(URL,Paramstart,length(URL));
		URL:=copy(URL,1,Paramstart-1);
		if VariableHandler<>nil then VariableHandler;
	end;

	// set Content Type
	if (pos('jpg',URL)<>0) then
		CType:='Content-Type: image/jpeg'+chr(10)
	else
		CType:='Content-Type: text/html'+chr(10);

	i:=0;
	repeat
		inc(i);
		if (URL=SpecialURL[i]) then begin
			status:='200 OK';
			str(i,blubber);
			writeLOG('special URL['+blubber+'] detected: '+URL);
			if ServingRoutine[i] <> nil then ServingRoutine[i];
		end;
	until (i=MaxUrl) or (URL=SpecialURL[i]);
	if not(URL=SpecialURL[i]) then begin
		URL:=DocRoot+URL;			// add current dir as Document root
		writeLOG('requested URL='+URL);

		{ now open the file, read and serve it }
		{$i-}
		assign(G,URL);
		reset (G);
		{$i+}
		page:='';
		if (IoResult=0) then begin { the file exists }
			status:='200 OK';
			while not eof(G) do begin  { read the file }
				read(G,BinData);
				page:=page+chr(BinData);
			end;
		end
		else begin  { file not found }
			page:='<html><body>Error: 404 Document not found</body></html>';
			status:='404 Not Found';
			writeLOG('Error 404 doc '+URL+' not found');
		end;

		SendPage(page);
	end;


end;


procedure serve_request;
{ this procedure must be called frequently to serve any outstanding requests }
begin
	// Main loop accepting client connections
	// Opening socket descriptors
	// Reading whole request -> accept on socket, then read requested data

	writeLOG('accept connection');
	{$ifdef LINUX}
	{$else}
	{$endif}



	{$ifdef LINUX}
		Sock2Text(sock,sin,sout);
		reset(sin);
		rewrite(sout);

		if debug then WriteLOG('Reading requests...');
		if (SelectText(sin,10000)>0) then begin
			Addr_len:=SizeOf(cli_addr);
			csock:=accept(sock, cli_addr,Addr_len);
			Sock2Text(csock,ccsin,ccsout);
			reset(ccsin);
			rewrite(ccsout);
			process_request;
			close(ccsin);
			close(ccsout);
			CloseSocket(csock);
		end;
		if debug then WriteLOG('Reading requests...done');

		// Closing connected socket descriptors
		if debug then WriteLOG('trying to close socket descriptors');
		close(sin);
		close(sout);
		if debug then WriteLOG('closeing socket descriptors done');
	{$else}
		fd_zero(FDRead);
		fd_set(sock,FDRead);
		{ a timeout must be set with timeout=nil it blocks }
		TimeVal.tv_sec:=0;
		TimeVal.tv_usec:=0;
		Result:=Select(0, @FDRead, nil, nil, @TimeVal);
		if Result = SOCKET_ERROR then writeLOG('ERROR='+WSAGetLastError);
		if (Result > 0) then begin
			addr_len:=SizeOf(cli_addr);
			ConnSock:=accept(sock, @cli_addr,@addr_len);
			if ( ConnSock=INVALID_SOCKET) then
				writeLOG('accept failed');
			process_request;
		end;
	{$endif}
end;

function GetURL:string;
begin
	GetURL:=URL;
end;


function GetParams:string;
begin
	GetParams:=params;
end;


procedure stop_server;
begin
	// Closing listening socket
	fpshutdown(sock, 2);
	// Shutting down
	writeLOG('shuting down pwserver...');
end;

begin
	UrlPointer:=1;
end.
