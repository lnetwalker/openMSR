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
{ 29.09.2010 started to add thread support					}
{ 07.02.2011 worked on thread support, added better IO Error checking		}

interface
uses classes;

procedure start_server(address:string;port:word;BlockMode: Boolean;doc_root,logfile:string;ThreadMode : Boolean ;DebugMode : Boolean);
procedure SetupSpecialURL(URL:string;proc : tprocedure);
procedure SetupVariableHandler(proc: tprocedure);
procedure SendPage(WhoAmI:byte;myPage : AnsiString);
procedure serve_request;
function GetURL:string;
function GetParams:string;
procedure stop_server();

const
	BLOCKED=true;
	NONBLOCKED=false;
	Debug_ON=true;
	Debug_OFF=false;
	
implementation

uses 
	CommonHelper,crt, blcksock, synautil, synaip, synacode, synsock,
{$ifdef LINUX}
	BaseUnix,Unix, dos;
{$endif}
{$ifdef Windows}
	windows;
{$endif}

const 
	LocalAddress = '127.0.0.1';
	MaxUrl = 25;
	MaxThreads = 25;
	
var

	// Listening socket
	sock,reply_sock	: TTCPBlockSocket;
	csock			: TSocket;

	// Maximal queue length
	max_connections	: integer;

	binData			: byte;

	Addr_len		: LongInt;

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

	// LOG-Files
	DBG,ERR,ACC		: text;

	ServingRoutine		: array[1..MaxUrl] of tprocedure;
	VariableHandler	: tprocedure;

	// this variable is just used to convert numerics to string
	blubber			: string;

	saveaccess		: Boolean;
	
	// Flag to show wether threads should be used or not
	WithThreads		: Boolean;
	
	ThreadHandle		: array[1..MaxThreads] of TThreadId;
{$ifndef LINUX64}	
	NumOfThreads		: LongInt;
{$endif}
{$ifdef LINUX64}
	NumOfThreads		: Int64;
{$endif}

	DebugOutput		: TRTLCriticalSection;
	ProtectAccessLog	: TRTLCriticalSection;
	ProtectAccess		: TRTLCriticalSection;
	ProtectDataSend	: TRTLCriticalSection;
	ServeSpecialURL	: TRTLCriticalSection;

	debug			: boolean;
	
procedure writeLOG(MSG: string);
begin
	EnterCriticalSection(DebugOutput);
	{$I-}
	writeln(DBG,MSG);
	flush(DBG);
	{$I+}
	if IOResult <>0 then writeln ('error writing debug file');
	LeaveCriticalSection(DebugOutput);
end;


procedure errorLOG(MSG: string);
var
    jahr,mon,tag,wota 	: word;
    std,min,sec,ms	: word;
    TimeString		: string;
{$ifdef Windows}
    st 			: systemtime;
{$endif} 


begin
 {$ifdef linux} // LINUX
	gettime(std,min,sec,ms); 
	getdate(jahr,mon,tag,wota);
 {$else}        // WINDOWS
	getlocaltime( st );
	std:= st.whour;
	min:= st.wminute;
	sec:= st.wsecond;
	ms:= st.wmilliseconds;
	jahr:= st.wyear;
	mon:= st.wmonth;
	tag:= st.wday;

 {$endif} 
	TimeString:='['+IntToStr(tag)+'/'+IntToStr(mon)+'/'+IntToStr(jahr)+':'+IntToStr(std)+':'+IntToStr(min)+':'+IntToStr(sec)+':'+IntToStr(ms)+']';

	writeln(ERR,TimeString+' '+MSG);
	flush(ERR);
end;


procedure accessLOG(MSG: string);
begin
	EnterCriticalSection(ProtectAccessLog);
	if saveaccess then begin
	    {$I-}
	    writeln(ACC,MSG);
	    flush(ACC);
	    {$I+}
	    if IOResult <>0 then writeln ('error writing access log file');
	end;
	LeaveCriticalSection(ProtectAccessLog);
end;


procedure SetupSpecialURL(URL:string;proc : tprocedure);
begin
	if proc <> nil then ServingRoutine[UrlPointer]:=proc;
	if URL <> '' then SpecialURL[UrlPointer]:=URL;
	inc(UrlPointer);
	if debug then writeLOG('registered special URL'+URL);
end;
	

procedure SetupVariableHandler(proc : tprocedure);
begin
	if proc <> nil then VariableHandler:=proc;
	if debug then writeLOG('registered Variable Handler');
end;


procedure start_server(address:string;port:word;BlockMode: Boolean;doc_root,logfile:string;ThreadMode : Boolean; DebugMode : Boolean);
var	port_str	: String;

begin
	// set flags for threadusage
	If ( ThreadMode ) then WithThreads:=true
	else WithThreads:= False;
	
	// check Debug Flag
	if (DebugMode) then debug:=true
	else debug:=false;

	if logfile<>'' then begin
	    // open logfile
	    assign(ACC,logfile);
	    rewrite(ACC);
	    saveaccess:=true;
	end;
	
	{ Initialization}
	if debug then writeLOG('PWS Pascal Web Server - starting server...');
	if (port=0) then port:=10080;
	if (address='') then address:='127.0.0.1';
	str(port,port_str);
	if debug then writeLOG('using port='+port_str+' address='+address);
	DocRoot:=doc_root;
	BufCnt:=1;
	reqCnt:=0;
	max_connections := 5;

	{ Create socket }
	sock:=TTCPBlockSocket.create;
	sock.CreateSocket;
	if sock.LastError<>0 then
	    writeLOG('start_server: Error creating socket');
	//setLinger(true,10);

	if not(BlockMode) then begin
		{ set socket to non blocking mode }
		{$ifdef linux}
		//FpFcntl(sock,F_SetFd,false);
		{$else}
		{$endif}
		writeln (' Nonblocking sockets not supported');
		halt(1);
	end;

	// Binding the server
	if debug then writeLOG('Binding port..');
	sock.bind(address,port_str);
	if sock.LastError<>0 then
	    writeLOG('start_server: Error binding socket');
	// Listening on port
	if debug then writeLOG('listen..');
	sock.listen;
	if sock.LastError<>0 then
	    writeLOG('start_server: Error listen socket');
end;


procedure SendPage(WhoAmI:byte;myPage : AnsiString);
var
	i 		: byte;
	useragent	: String;

begin
	PageSize:=length(myPage);
	//if debug then writeLOG(myPage);
	if status='' then status:='200 ok';

	{ generate the header }
	header:='HTTP/1.1 '+status+CRLF;
	header:=header+'MIME-Version: 1.0'+CRLF;
	header:=header+'Server: bonita'+CRLF;
	if (WithThreads) then 
		header:=header+'Connection: keep-alive'+CRLF
	else
		header:=header+'Connection: close'+CRLF;
	{ currently the mimetype of an object is always text/html }
	header:=header+CType;
	header:=header+'Content-length: ';
	{ the Content-length is the size of the served object }
	{ without the size of the header } 
	str(PageSize,TRespSize);
	header:=header+TRespSize;
	header:=header+CRLF+CRLF;
	str(PageSize,blubber);
	if debug then begin
		writeLOG('SendPage '+IntToStr(WhoAmI)+': DocSize: '+blubber);
		writeLOG('SendPage '+IntToStr(WhoAmI)+': Header: '+header);
		writeLOG('SendPage '+IntToStr(WhoAmI)+': /Header');

		// Sending response
		writeLOG('serving data...');
	end;
	str(BufCnt,blubber);
	if debug then writeLOG('SendPage '+IntToStr(WhoAmI)+': BufCnt='+blubber);
	i:=0;
	repeat
		inc(i);
	until (copy(post[i],1,10)='User-Agent');
	useragent:=copy(post[i],13,7);
	//EnterCriticalSection(ProtectDataSend);
	if debug then writeLOG('SendPage '+IntToStr(WhoAmI)+': ' +useragent + ' -> sending header');
	reply_sock.SendString(header);
	if reply_sock.LastError<>0 then
	    writeLOG('SendPage: Error sending header');
	if debug then writeLOG('SendPage '+IntToStr(WhoAmI)+': ' +useragent + ' -> sending page ');
	reply_sock.SendString(myPage);
	if reply_sock.LastError<>0 then
	    writeLOG('SendPage: Error sending page');
	if debug then writeLOG('SendPage '+IntToStr(WhoAmI)+': page send');
	//LeaveCriticalSection(ProtectDataSend);

	if debug then writeLOG('finished request...');
	BufCnt:=1;
end;


function process_request(WhoAmI:byte):boolean;

var Paramstart,i	: word;
    UserAgent		: string;
    jahr,mon,tag,wota 	: word;
    std,min,sec,ms	: word;
    TimeString,
    ClientIP		: string;
{$ifdef Windows}
    st 			: systemtime;
    n			: word;
{$endif}
    IOError		: Boolean;
    RequestURL		: string;

begin
	IOError:=false;
	reqSize:=0;
	BufCnt:=1;
	if debug then writeLOG('reading request data');
	repeat
		buff:=reply_sock.RecvString(120);
		if reply_sock.LastError<>0 then begin
		    writeLOG('process_request: Error reading request');
		    IOError:=true;
		end;    
		str(BufCnt,blubber);
		if debug then writeLOG('process_request '+IntToStr(WhoAmI)+' : Req['+blubber+']='+buff);
		post[BufCnt] := buff;
		if copy(buff,1,11)='User-Agent:' then UserAgent:=copy(buff,12,length(buff));
		reqSize:=reqSize+length(post[BufCnt]);
		inc(BufCnt);
	until length(buff)<1;

	BufCnt:=BufCnt-2;
	inc(reqCnt);
	str(reqCnt,blubber);
	if debug then writeLOG('process_request '+IntToStr(WhoAmI)+': # of Requests : '+blubber);
	str(reqSize,blubber);
	if debug then writeLOG('process_request '+IntToStr(WhoAmI)+': requestSize: '+blubber);

	{ processing the request }

	{ post[1] is the request URI, extract the wanted URL }
	{ after first slash (/) in the string the URL starts and longs until next blank }
	{ e.g. "GET /path/to/a/non/existing/file.htm HTTP/1.1" }
	{ request type is ignored it's always GET assumed }
	URL:=copy(post[1],pos('/',post[1]),length(post[1]));
	URL:=copy(URL,1,pos(' ',URL)-1);	
	Paramstart:=pos('?',URL);
	RequestURL:=URL;

	if ( Paramstart <> 0 ) then begin
		// this URL has parameters
		params:=copy(URL,Paramstart,length(URL));
		URL:=copy(URL,1,Paramstart-1);
		if VariableHandler<>nil then VariableHandler;
	end;

	// set Content Type
	if (pos('jpg',URL)<>0) then
		CType:='Content-Type: image/jpeg'+CRLF
	else
		if (pos('png',URL)<>0) then
			CType:='Content-Type: image/png'+CRLF
		else
			CType:='Content-Type: text/html'+CRLF;

	i:=0;
	repeat
		inc(i);
		if (URL=SpecialURL[i]) then begin
			//EnterCriticalSection(ServeSpecialURL);
			status:='200 OK';
			str(i,blubber);
			if debug then writeLOG('process_request '+IntToStr(WhoAmI)+': special URL['+blubber+'] detected: '+URL);
			if ServingRoutine[i] <> nil then ServingRoutine[i];
			//LeaveCriticalSection(ServeSpecialURL);
		end;
	until (i=MaxUrl) or (URL=SpecialURL[i]);
	if not(URL=SpecialURL[i]) then begin
		URL:=DocRoot+URL;			// add current dir as Document root
		if debug then writeLOG('process_request '+IntToStr(WhoAmI)+': requested URL='+URL);

		{ now open the file, read and serve it }
		{$ifdef Windows}
		for n:=1 to length(URL) do if (URL[n]='/') then URL[n]:='\';
		{$endif}
		page:='';
		{$i-}
		assign(G,URL);
		reset (G);
		{$i+}
		if (IoResult=0) then begin { the file exists }
			status:='200 OK';
			while not eof(G) do begin  { read the file }
				{$i-}
				read(G,BinData);
				{$i+}
				if ( IOResult <> 0 ) then begin
					page:='<html><body>Error: There was an Error reading the required data</body></html>';
					status:='500 Internal Server Error';
					errorLOG('Error 500:  Error reading '+URL);
					IOError:=true;
					exit;
				end;
				page:=page+chr(BinData);
			end;
			close (G);
		end
		else begin  { file not found }
			page:='<html><body>Error: 404 Document not found</body></html>';
			status:='404 Not Found';
			errorLOG('Error 404 doc '+URL+' not found');
			IOError:=true
		end;

		//EnterCriticalSection(ProtectDataSend);
		if debug then writeLOG('process_request : send page data ->');
		//if debug then writeLOG(page);
		SendPage(WhoAmI,page);
		//LeaveCriticalSection(ProtectDataSend);

	end;
	{ write access log in common logfile format, that looks like:
		78.34.183.237 - - [16/Jun/2009:15:11:09 +0200] "GET /templates/eilers.net/images/mw_menu_cap_r.png HTTP/1.1" 404 8219 "http://www.eilers.net/templates/eilers.net/css/template.css" "Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9.0.10) Gecko/2009042523 Ubuntu/9.04 (jaunty) Firefox/3.0.10"                                                                            
		78.34.183.237 - - [16/Jun/2009:15:11:09 +0200] "GET /templates/eilers.net/images/mw_menu_normal_bg.png HTTP/1.1" 404 8219 "http://www.eilers.net/templates/eilers.net/css/template.css" "Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9.0.10) Gecko/2009042523 Ubuntu/9.04 (jaunty) Firefox/3.0.10"                                                                        
		74.6.22.178 - - [16/Jun/2009:15:14:37 +0200] "GET /robots.txt HTTP/1.0" 200 304 "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"           
		74.6.22.178 - - [16/Jun/2009:15:14:37 +0200] "GET /vrml/ HTTP/1.0" 404 8219 "-" "Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)"           
		77.180.99.188 - - [16/Jun/2009:15:15:34 +0200] "GET / HTTP/1.0" 200 10503 "-" "check_http/v1944 (nagios-plugins 1.4.11)"
		65.55.106.161 - - [16/Jun/2009:16:01:24 +0200] "GET /vrml/ HTTP/1.1" 404 8219 "-" "msnbot/2.0b (+http://search.msn.com/msnbot.htm)"
		77.180.99.188 - - [16/Jun/2009:16:04:05 +0200] "GET / HTTP/1.0" 200 10503 "-" "check_http/v1944 (nagios-plugins 1.4.11)"
		65.55.51.115 - - [16/Jun/2009:16:07:23 +0200] "GET /robots.txt HTTP/1.1" 200 304 "-" "msnbot/2.0b (+http://search.msn.com/msnbot.htm)"
		
		field description
		host rfc931 username date:time request statuscode bytes referrer applinformation
	}
 {$ifdef linux} // LINUX
	gettime(std,min,sec,ms); 
	getdate(jahr,mon,tag,wota);
 {$else}        // WINDOWS
	getlocaltime( st );
	std:= st.whour;
	min:= st.wminute;
	sec:= st.wsecond;
	ms:= st.wmilliseconds;
	jahr:= st.wyear;
	mon:= st.wmonth;
	tag:= st.wday;

 {$endif} 
	TimeString:='['+IntToStr(tag)+'/'+IntToStr(mon)+'/'+IntToStr(jahr)+':'+IntToStr(std)+':'+IntToStr(min)+':'+IntToStr(sec)+':'+IntToStr(ms)+']';
	ClientIP:=reply_sock.GetRemoteSinIP;
	accessLog(ClientIP+' - - '+TimeString+' GET "'+RequestURL+'" '+copy(status,1,3)+' '+IntToStr(length(page))+' '+UserAgent);

	process_request:=IOError;
end;


{ this thread serves a connection until any ioerrors }
{$ifdef linux64} 
function KeepAliveThread(p: pointer):Int64;
{$else}
function KeepAliveThread(p: pointer):LongInt;
{$endif}

var
	endThread		: Boolean;
	
begin
	if debug then writeLOG('KeepAliveThread:started');
	endThread:=false;
	repeat
		if debug then writeLOG('KeepAliveThread'+IntToStr(NumOfThreads)+': process_request');
		EnterCriticalSection(ProtectAccess);
		endThread:=process_request(NumOfThreads);
		LeaveCriticalSection(ProtectAccess);
	until endThread;

	if debug then WriteLOG('KeepAliveThread'+IntToStr(NumOfThreads)+': Closing Client Socket');
	reply_sock.free;
	if reply_sock.LastError<>0 then
	    writeLOG('Keep_Alive_Thread:'+IntToStr(NumOfThreads)+' Error freeing socket');


	// just before end
	dec(NumOfThreads);
	if debug then writeLOG('KeepAliveThread'+IntToStr(NumOfThreads)+':ended');
end;


procedure serve_request;
{ this procedure must be called frequently to serve any outstanding requests }
begin
	// Main loop accepting client connections
	// Opening socket descriptors
	// Reading whole request -> accept on socket, then read requested data

	if debug then writeLOG('serve_request: accept connection');

	if (sock.canread(1000)) then begin
		if debug then writeLOG('serve_request: noticed request');
		csock:=sock.accept;
		if debug then writeLOG('serve_request: request accepted');
		if sock.lastError=0 then begin
			reply_sock:=TTCPBlockSocket.create;
			if debug then writeLOG('serve_request: creating answer socket');
			reply_sock.CreateSocket;
			reply_sock.socket:=csock;
		end;

		if debug then WriteLOG('serve_request: Reading requests...');

		if ( WithThreads ) then begin
			// start a new thread which processes the initial and all 
			// following requests and closes sockets on IO Error reading requests,
			// then end thread
			inc(NumOfThreads);
			if (NumOfThreads <= MaxThreads) then begin
				if debug then writeLOG('serve_request: starting a KeepAliveThread');
				ThreadHandle[NumOfThreads]:=BeginThread(@KeepAliveThread,pointer(NumOfThreads));
			end
			else
				errorLOG('serve_request: Max Number of threads reached - couldn`t serve request');
		end
		else begin
			//EnterCriticalSection(ProtectAccess);
			process_request(0);
			//LeaveCriticalSection(ProtectAccess);
			if debug then WriteLOG('serve_request: free reply socket');
			reply_sock.free;
			if reply_sock.LastError<>0 then
			    writeLOG('server_request: Error freeing socket');

		end
	end;

	if debug then WriteLOG('Reading requests...done');

	if debug then WriteLOG('serve_request done');
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
	sock.free;
	// Shutting down
	if debug then writeLOG('shuting down pwserver...');
end;

begin
	// don't write access log
	saveaccess:=false;

	// switch off debug by default
	debug:=true;
	if (debug) then writeln('Debugging On!');

	// switch off threads
	WithThreads := false;
	NumOfThreads:=0;
	InitCriticalSection(DebugOutput);
	InitCriticalSection(ProtectAccessLog);
	InitCriticalSection(ProtectAccess);
	InitCriticalSection(ProtectDataSend);
	InitCriticalSection(ServeSpecialURL);
	// open logfiles
	//error Log
	assign(ERR,'/tmp/deviceserver_err.log');
	rewrite(ERR);

	// debug Log
	assign(DBG,'/tmp/deviceserver_dbg.log');
	rewrite(DBG);

	UrlPointer:=1;
end.
