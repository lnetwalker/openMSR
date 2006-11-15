//{$Id$}

{$H+}{$MODE OBJFPC}
unit webserver;

{ (c) 2006 by Hartmut Eilers < hartmut@eilers.net					}
{ distributed  under the terms of the GNU GPL V 2					}
{ see http://www.gnu.org/licenses/gpl.html for details				}
{ derived from the original work of pswebserver (c) by 				}
{ Vladimir Sibirov													}

{ simple embeddable HTTP server for FPC Pascal for Linux and		}
{ Windows, using non-blocking socket I/O to easy fit and			}
{ integrate in different programs 									}
{ tested on Win 32  W2K Advanced Server and Debian Linux 			}
{ can serve static HTML Pages and Images and special dynamic		}
{ content provided by the embedding program							}
{ see example program pwserver.pas for information about usage		}

{ History: 															}
{ 15.03.2006 startet with Vladimirs Code 							}
{ 17.03.2006 running non Block http server on linux 				}
{ 20.03.2006 startet porting to win32 using winsock 				}
{ 24.03.2006 WINSOCK code works including read of request 			}
{ 27.03.2006 WINSOCK code works 									}
{ 02.04.2006 serving of simple text pages work 						}
{ 03.04.2006 cleaned code, tested with firefox and konqueror -> ok 	}
{   	     wget doesn't receive anything :( 						}
{ 17.10.2006 started the unit webserver from pswebserver code		}
{		     currently only GET requests are supported				}
{ 12.11.2006 added registration of special URLs through callback	}

interface

procedure start_server(address:string;port:word;doc_root,logfile:string);
procedure SetupSpecialURL(URL:string;proc : tprocedure);
procedure SendPage(myPage : AnsiString);
procedure serve_request;
procedure stop_server();


implementation

{$ifdef LINUX}
	uses sockets, crt, inetaux, oldlinux;
{$else}
	uses winsock,crt,inetaux;
{$endif}

{$ifdef WIN32}
	type
		TFDSet = Winsock.TFDSet; 
{$endif}
	
const 
	LocalAddress = '127.0.0.1';
	
var

	// Listening socket
	{$ifdef LINUX }
		sock		: longint;
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
		sin, sout	: text;
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

	{ the requested URL, the File to serve and the response }
	URL,SpecialURL	: String;
	G				: file of byte;

	header,page,
	CType			: AnsiString;

	PageSize		: LongInt;

	TRespSize,
	status			: string;

	// Request size
	reqSize,reqCnt	: word;

	// LOG-File
	LOG				: text;

	ServingRoutine 	: tprocedure;

procedure SetupSpecialURL(URL:string;proc : tprocedure);
begin
	if proc <> nil then ServingRoutine:=proc;
	if URL <> '' then SpecialURL:=URL;
end;
	
procedure start_server(address:string;port:word;doc_root,logfile:string);

begin
	// open logfile
	assign(LOG,logfile);
	rewrite(LOG);

	{ Initialization}
	writeln(LOG,'PWS Pascal Web Server - starting server...');
	if (port=0) then port:=10080;
	if (address='') then address:=LocalAddress;
	writeln(LOG,'using port=',port,' address=',address);
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
		if WSAStartup($101, GInitData) <> 0 then writeln (LOG,'Error init Winsock');
	{$endif}
	
	{ Create socket }
	sock := socket(PF_INET, SOCK_STREAM, 0);

	{ set socket to non blocking mode }
	{$ifdef LINUX}
		fcntl(sock,F_SetFd,Open_NonBlock);
	{$else}
		NON_BLOCK:=1;
		Result:=ioctlsocket(sock,FIONBIO,@NON_BLOCK);
		if ( Result=SOCKET_ERROR ) then writeln(LOG,'setting NON_BLOCK failed :(');
	{$endif}
	
	// Binding the server
	writeln(LOG,'Binding port..');
	{$ifdef LINUX}
		if not bind(sock, srv_addr, sizeof(srv_addr)) then begin
			writeln(LOG,'!! Error in bind().');
			halt;
		end;
	{$else}
		if (bind(sock, srv_addr, SizeOf(srv_addr)) <> 0) then  begin
			writeln(LOG,'!! Error in bind');
			halt;
		end;
	{$endif}
	
	// Listening on port
	writeln(LOG,'listen..');
	{$ifdef LINUX}
		listen(sock, max_connections);
	{$else}
		if (listen(sock, max_connections) = SOCKET_ERROR) then writeln(LOG,'listen() failed with error ', WSAGetLastError());
	{$endif}
end;


procedure SendPage(myPage : AnsiString);
begin
	PageSize:=length(myPage);

	{ generate the header }
	header:='HTTP/1.0 '+status+chr(10);
	header:=header+'Connection: close'+chr(10);
	header:=header+'MIME-Version: 1.0'+chr(10);
	header:=header+'Server: PWS/alpha'+chr(10);
	{ currently the mimetype of an object is always text/html }
	header:=header+CType;
	header:=header+'Content-length: ';
	{ the Content-length is the size of the served object }
	{ without the size of the header } 
	str(PageSize,TRespSize);
	header:=header+TRespSize;
	header:=header+chr(10);
	writeln(LOG,'DocSize: ',PageSize);
	writeln(LOG,'Header: ',header);
	writeln(LOG,'/Header');

	// Sending response
	writeln(LOG,'serving data...');
	{$ifdef LINUX}
		writeln(LOG,'BufCnt=',BufCnt);
		{ if I send the header and the page together }
		{ firefox has a problem and display nothing }
		writeln(sout,header);
		writeln(sout,myPage);
		writeln(sout);

		// Flushing output
		flush(sout);

		// Closing connected socket
		close(sin);
		close(sout);
	{$else}
		{ note chr(10) is newline }
		{ build the string that should be send }
		sendString:=header+myPage;
		{ copy string to send into the send buffer }
		for i:=1 to length(sendString) do FCharBuf[i]:=sendString[i];
		writeln(LOG,'respSize: ',length(sendString));
		Result:=send(ConnSock,@FCharBuf[1],length(sendString),0);
		if ( Result=SOCKET_ERROR ) then writeln(LOG,'send Data failed :(');
		Shutdown(ConnSock, 2);
	{$endif}
	writeln(LOG,'finished request..., connection closed');
	BufCnt:=1;
end;

procedure process_request;
begin
	writeln(LOG,'reading request....');
	// Reading whole request -> accept on socket, then read requested data

	writeln(LOG,'accept connection');
	{$ifdef LINUX}
		if not accept(sock, cli_addr, sin, sout) then writeln(LOG,'!! Connection error in accept().');
	{$else}
		addr_len:=SizeOf(cli_addr);
		ConnSock:=accept(sock, @cli_addr,@addr_len);
		if ( ConnSock=INVALID_SOCKET) then
			writeln(LOG,'accept failed');
	{$endif}

	reqSize:=0;
	writeln(LOG,'reading request data');
	repeat
		{ actually we should switch to blocking mode here, }
		{ because it is possible that some amount of time  }
		{ is between the connect and the request           }
		{$ifdef LINUX}
			readln(sin, buff);
			writeln (LOG,'Req[',BufCnt,']=',buff);
			post[BufCnt] := buff;
			reqSize:=reqSize+length(post[BufCnt]);
			inc(BufCnt);
		{$else}
			RecBufSize:=recv(ConnSock,@FCharBuf[1],SizeOf(FCharBuf),0);
			if (RecBufSize=SOCKET_ERROR) then writeln (LOG,'socket error during read ',WSAGetLastError);
			buff:=copy(FCharBuf,1,RecBufSize);
			BufCnt:=1;
			{ Request zerlegen und in array post zeile fuer Zeile speichern }
			repeat
				post[BufCnt]:=copy(buff,1,pos(chr(10),buff)-1);
				writeln(LOG,'Req[',BufCnt,']=',post[BufCnt]);
				buff:=copy(buff,pos(chr(10),buff)+1,length(buff));
				inc(BufCnt);
			until length(buff)<1;
			reqSize:=RecBufSize;
		{$endif}	
	until length(buff)<1;

	inc(reqCnt);
	writeln(LOG,'# of Requests : ',reqCnt);
	writeln(LOG,'requestSize: ',reqSize);

	{ processing the request }

	{ post[1] is the request URI, extract the wanted URL }
	{ after first slash (/) in the string the URL starts and longs until next blank }
	{ e.g. "GET /path/to/a/non/existing/file.htm HTTP/1.1" }
	{ request type is ignored it's always GET assumed }
	URL:=copy(post[1],pos('/',post[1]),length(post[1]));
	URL:=copy(URL,1,pos(' ',URL)-1);

	// set Content Type
	if (pos('jpg',URL)<>0) then
		CType:='Content-Type: image/jpeg'+chr(10)
	else
		CType:='Content-Type: text/html'+chr(10);

	if (URL=SpecialURL) then begin
		if ServingRoutine <> nil then ServingRoutine
	end

	else begin
		URL:=DocRoot+URL;			// add current dir as Document root
		writeln(LOG,'requested URL=',URL);

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
			writeln(LOG,'Error 404 doc ',URL,' not found');
		end;

		SendPage(page);
	end;


end;


procedure serve_request;
{ this procedure must be called frequently to serve any outstanding requests }
begin
	// Main loop accepting client connections
	// Opening socket descriptors
	{$ifdef LINUX}
		Sock2Text(sock,sin,sout);
		reset(sin);
		rewrite(sout);
	{$else}
	
	{$endif}


	{$ifdef LINUX}
		if (SelectText(sin,10000)>0) then process_request;
	{$else}
		fd_zero(FDRead);
		fd_set(sock,FDRead);
		{ a timeout must be set with timeout=nil it blocks }
		TimeVal.tv_sec:=0;
		TimeVal.tv_usec:=0;
		Result:=Select(0, @FDRead, nil, nil, @TimeVal);
		if Result = SOCKET_ERROR then writeln(LOG,'ERROR=',WSAGetLastError);
		if (Result > 0) then process_request;
	{$endif}
end;


procedure stop_server;
begin
	// Closing listening socket
	shutdown(sock, 2);
	// Shutting down
	writeln(LOG,'shuting down pwserver...');
end;

end.
