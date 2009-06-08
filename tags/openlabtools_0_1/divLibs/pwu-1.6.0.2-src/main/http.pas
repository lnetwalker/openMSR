{*******************************************************************************

                           PSP/PWU HTTP Connections
                           
********************************************************************************

 HTTP get/post for connecting to external websites

 Authors/Credits: Trustmaster (Vladimir Sibirov), L505 (Lars)
 Copyright (c) 2003-2006 by PSP dev team. See Artistic License for legal info.
   
 Notes:

  Dec-12-2006 [L505]
   -fixed httpget, bug was in the copy routine, + 1 added

********************************************************************************}

unit http; 
{$IFDEF FPC}{$MODE OBJFPC}{$H+}
  {$IFDEF EXTRA_SECURE}{$R+}{$Q+}{$CHECKPOINTER ON}{$ENDIF}
{$ENDIF}


interface


{============================= PUBLIC TYPES ===================================}

var debugproc: procedure(s: string); // user assigns this for debugging

type HTTPConnection = pointer;
    // Complete HTTP connection handle


{===================== PUBLIC PROCEDURES AND FUNCTIONS ========================}


procedure HttpClose(cp: HTTPConnection);
function HttpConnect1(const address, agent: string): HTTPConnection;
function HttpConnect(const address: string): HTTPConnection;
function HttpCopy(const source, dest: string): boolean;
function HttpEof(cp: HTTPConnection): boolean;
function HttpGet1(const url, agent: string): string;
function HttpGet(const url:string;UserAgent:string): string;
function HttpGetHeader(cp: HTTPConnection; const name: string): string;
function HttpRead(cp: HTTPConnection): char;
function HttpReadLn(cp: HTTPConnection): string;
function HttpSendRequest(cp: HTTPConnection; const method, uri: string): boolean;
function HttpResponseInfo(cp: HTTPConnection; var final_url, message: string): word;
procedure HttpSetHeader(cp: HTTPConnection; const name, value: string);
procedure HttpSetPostData(cp: HTTPConnection; const data: string);
procedure HttpPutHeader(cp: HTTPConnection; const header: string);



{============================= IMPLEMENTAION ==================================}


implementation
uses 
  hostname, 
 {$ifdef win32}
  sockets_patched, // patched sockets unit because of win32 I/O bug in fpc rtl
 {$else}
  sockets,
 {$endif}   
  substrings;

{============================= PRIVATE FUNCTIONS ==============================}

function int2str(i: integer): string;
begin
  system.str(i, result);
end;

function word2str(w: word): string;
begin
  system.str(w, result);
end;

procedure debugln(s: string);
begin            
  if debugproc <> nil then
    debugproc(s);
end;

{============================= PRIVATE TYPES ==================================}

type
    THTTPHeader = record
    // Header representation
        name, value: string;
    end;

    THTTPHeaders = array of THTTPHeader;

    THTTPConnection = record
    // Complete HTTP connection record
        sock: longint; // Connected socket
        sin, sout: text; // I/O streams
        request, response: THTTPHeaders; // Request/Response headers
        code, uri: string; // Response code + message; final resolved uri (for redirect purpose)
        post: string; // Post data string
    end;

    PHTTPConnection = ^THTTPConnection;
    // Pointer to THTTPConnection


{========================= PROCEDURES AND FUNCTIONS ===========================}
                                                   

// Closes HTTP connection
procedure HttpClose(cp: HTTPConnection);
var 
  conn: PHTTPConnection;
begin
  conn := PHTTPConnection(cp);
  close(conn^.sin);
  close(conn^.sout);
  CloseSocket(conn^.sock);
  dispose(conn);
end;

// delete http:// at beginning of string -L505
procedure TrimHttpStr(var s: string);
begin        
  if length(s) < 1 then exit; 
  s:= substrireplace(s, 'http://', '');
end;

// check https:// can't do SSL regularily -L505
function FindHttps(var s: string): boolean;
begin        
  result:= false;
  if length(s) < 1 then exit; 
  if pos('https://', s) = 1 then
    result:= true;
end;

// add trailing url slash -L505
procedure AddTrailSlash(var s: string);
begin
  if length(s) < 1 then exit; 
  if pos('/', s) = 0 then
  begin
    s:= s + '/';
  end;
end;

// prepare http address: trim http:// and add trailing slash if needed -L505
procedure PrepHttpAddress(var s: string);
begin
  TrimHttpStr(s);
  AddTrailSlash(s);
end;

// Connects to HTTP server specified by hostname:port or hostname
function HttpConnect1(const address, agent: string): HTTPConnection;
var 
  conn: PHTTPConnection;
  addr: TInetSockAddr;
  server: string;
  p: longint;
  port: word;
  tmpaddress: string;
begin
    // Init
    result := nil;
    new(conn);
    tmpaddress:= address;
    // get rid of http:// and
    // localhost or site.com --> must be converted to localhost/ or site.com/ 
    TrimHttpStr(tmpaddress);     
    // Supporting allowed address syntax
    p := pos(':', tmpaddress);
    if p > 0 then
    begin
//      debugln('debug: ":" found');
      // Splitting by :
      server := copy(tmpaddress, 1, p - 1);
      val(copy(tmpaddress, p + 1, length(tmpaddress) - p), port);
      addr := InetResolve(server, port);
    end else
    begin
//      debugln('debug: inetresolve: ' + tmpaddress);
      addr := InetResolve(tmpaddress, 80);
    end; 
    // Checking address validity
    if addr.addr <= 0 then
    begin
      dispose(conn);
      exit(nil);
    end;
    // Performing connection
    conn^.sock := socket(AF_INET, SOCK_STREAM, 0);
    if not connect(conn^.sock, addr, conn^.sin, conn^.sout) then
    begin
      dispose(conn);
      exit(nil);
    end;
    // Descriptors init
    reset(conn^.sin);
    rewrite(conn^.sout);

    // Setting some default request headers
    SetLength(conn^.request, length(conn^.request) + 1);
    conn^.request[length(conn^.request) - 1].name := 'Accept';
    conn^.request[length(conn^.request) - 1].value := 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5';
    SetLength(conn^.request, length(conn^.request) + 1);
    conn^.request[length(conn^.request) - 1].name := 'Accept-Charset';
    conn^.request[length(conn^.request) - 1].value := 'windows-1252, iso-8859-1;q=0.6, *;q=0.1';
    SetLength(conn^.request, length(conn^.request) + 1);
    conn^.request[length(conn^.request) - 1].name := 'Connection';
    conn^.request[length(conn^.request) - 1].value := 'close';
    SetLength(conn^.request, length(conn^.request) + 1);
    conn^.request[length(conn^.request) - 1].name := 'Host';
    conn^.request[length(conn^.request) - 1].value := server;
    SetLength(conn^.request, length(conn^.request) + 1);
    conn^.request[length(conn^.request) - 1].name := 'User-Agent';
    conn^.request[length(conn^.request) - 1].value := agent;
    // Result linking
    result := HTTPConnection(conn);
end;

{ connect with default user agent }
function HttpConnect(const address: string): HTTPConnection;
begin
  result:= HttpConnect1(address, 'PWU HTTP Module');
end;

{ Copy remote file to local one
  Source must be full HTTP URL (may even contain get params), example:
  www.server.com/path/script.php?cid=256&name=example
  Get prams must be URLEncoded
  Dest is local file name accessible for writing}
function HttpCopy(const source, dest: string): boolean;
var
  fh: text;
  data: string;
begin
  result := false;
  data := HttpGet(source,'');
  if data = '' then exit(false);
  assign(fh, dest);         
  rewrite(fh);
  write(fh, data);
  close(fh);
  result := true;
end;


// Checks if Response document is at enf of file
function HttpEof(cp: HTTPConnection): boolean;
var conn: PHTTPConnection;
begin
  conn := PHTTPConnection(cp);
  result := eof(conn^.sin);
end;

{ Returns a string containing the file represented by URL
  URL must be full HTTP URL (may even contain get params), example:
  www.server.com/path/script.php?cid=256&name=example
  Get prams must be URLEncoded 
  
  ERROR CODES: in string format
  '-4 err' : tried to get HTTPS, not supported, only HTTP
  '-3 err' : (port <> 200) and (port <> 301) and (port <> 302) and (port <> 303) 
  '-2 err' : connect error
  '-1 err' : address from inet resolve not valid    
    
               
  }
function HttpGet1(const url, agent: string): string;
var                                            
  tmpurl, host, uri, temp, loc: string;
  port: word;
  addr: TInetSockAddr;
  sock, p: longint;
  c: string;
  sin, sout: text;                                    
  redir: boolean;
  nv: StrArray;
  readsize, // grabbing data bigger than 2GB will have issues, could use int64 but web files are not this big
  tmpbuflen: integer; 
const
  BUF_GROWBY = 512;  
  BUF_INITSIZE = 8192;
begin
    // Init
    result := '';

    tmpurl:= url;
    if FindHttps(tmpurl) then         
    begin 
      result:= '-4 err'; 
      exit; 
    end;      
    // get rid of http:// and
    // localhost or site.com --> must be converted to localhost/ or site.com/ 
    PrepHttpAddress(tmpurl);     
    // Parsing url
    host := copy(tmpurl, 1, pos('/', tmpurl) - 1);                     
    uri := copy(tmpurl, pos('/', tmpurl), length(tmpurl) - pos('/', tmpurl) + 1); // L505: must add 1
    if uri = '' then uri := '/';
    p := pos(':', host);

    if p > 0 then
    begin
      // Splitting by :
      val(copy(host, p + 1, length(host) - p), port);
      host:= copy(host, 1, p - 1);
      addr:= InetResolve(host, port);
    end else
    begin
      debugln('Debug: inetresolve begin: ' +  host);
      addr:= InetResolve(host, 80);
      debugln('Debug: inetresolve end: ' + word2str(addr.addr));      
    end;  
    // Checking address validity
    if addr.addr <= 0 then begin result:= '-1 err'; exit; end;
    // Connecing
    sock := socket(AF_INET, SOCK_STREAM, 0);
    if not connect(sock, addr, sin, sout) then 
    begin 
      result:= '-2 err'; 
      exit; 
    end;
    // Descriptors init
    reset(sin);
    rewrite(sout);
    // Sending request
    writeln(sout, 'GET ' + uri + ' HTTP/1.1');
    debugln('debug: uri: ' + uri);
    writeln(sout, 'Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5');
    writeln(sout, 'Connection: close');
    writeln(sout, 'Host: ' + host);
    debugln('debug: host: ' + host);    
    writeln(sout, 'User-Agent: ' + agent);
    writeln(sout);
    flush(sout);
    // First line
{    readln(sin, temp);
	writeln('buffer=',temp);
    val(copy(temp, 10, 3), port);
	writeln('http port=',port);
    if (port <> 200) and (port <> 301) and (port <> 302) and (port <> 303) then 
    begin
      result:= '-3 err: ' + temp;
      debugln('debug: port: ' + int2str(port));
      debugln('debug: uri: ' + uri);      
      close(sin);
      close(sout);
      CloseSocket(sock);      
      exit;    
    end;      }
    // Headers
    redir:= false;
{    repeat
      readln(sin, temp);
      debugln('debug: repeat temp: ' + temp);
      if upcase(copy(temp, 1, 8)) = 'LOCATION' then
      begin
        debugln('debug: redir: temp: ' + temp);        
        loc := substrireplace(temp, 'Location: ', '');
        debugln('debug: redir new location: ' + loc);                
        redir := true;
      end;
    until temp = '';}
    if redir then
    begin
      // Redirected
      close(sin);
      close(sout);
      CloseSocket(sock);
      result := HttpGet1(loc, agent);
    end else
    begin
      readsize:= 0;
      uniquestring(result);
      setlength(result, BUF_INITSIZE);  // set initial buffer to optimize 
      // Getting contents
      repeat
        readln(sin, c);
	//write(c);
        {inc(readsize);
        tmpbuflen:= length(result);
        if tmpbuflen < readsize then
          SetLength(result, tmpbuflen + BUF_GROWBY); // grow buffer only if needed
        pchar(result)[readsize-1]:= c;}
	result:=result+c;
      until (length(c)<1);
//      pchar(result)[readsize] := #0;
      //setlength(result, readsize); // now set string to proper total size read
	//writeln('httpget result=',result);

      // Closing connection
      close(sin);
      close(sout);
      CloseSocket(sock);
    end;
end;

{ get url with default user agent }
function HttpGet(const url:string;UserAgent:string): string;                    
begin
  if UserAgent='' then UserAgent:='PWU HTTP Module'
  else UserAgent:=UserAgent+' PWU HTTP Module';
  result:= HttpGet1(url, UserAgent);      
end;
                  
// Returns value of server Response header
function HttpGetHeader(cp: HTTPConnection; const name: string): string;
var
  conn: PHTTPConnection;
  i: longword;
begin
  conn := PHTTPConnection(cp);
  result := '';
  if length(conn^.response) > 0 then
  for i := 0 to length(conn^.response) - 1 do if upcase(conn^.response[i].name) = upcase(name) then
  begin
    result := conn^.response[i].value;
    break;
  end;
end;

// Reads single char from Response document
function HttpRead(cp: HTTPConnection): char;
var conn: PHTTPConnection;
begin
  conn := PHTTPConnection(cp);
  result := #0;
  if not eof(conn^.sin) then read(conn^.sin, result);
end;

// Reads a line from Response document
function HttpReadLn(cp: HTTPConnection): string;
var conn: PHTTPConnection;
begin
  conn := PHTTPConnection(cp);
  result := '';
  if not eof(conn^.sin) then readln(conn^.sin, result);
end;

// Sends HTTP request. Headers and POST data must be set before this call
function HttpSendRequest(cp: HTTPConnection; const method, uri: string): boolean;
var
  conn: PHTTPConnection;
  buff: string;
  nv: StrArray;
  i: longword;
begin
    conn := PHTTPConnection(cp);
    // Sending request
    // First line
    writeln(conn^.sout, upcase(method) + ' ' + uri + ' HTTP/1.1');
    // Then headers follow
    if length(conn^.request) > 0 then
    for i := 0 to length(conn^.request) - 1 do writeln(conn^.sout, conn^.request[i].name + ': ' + conn^.request[i].value);
    // Emtpy line
    writeln(conn^.sout);
    // Sending POST data
    if upcase(method) = 'POST' then writeln(conn^.sout, conn^.post);
    flush(conn^.sout);
    // Reading message                        
    readln(conn^.sin, conn^.code);
    // Reading headers
    repeat
        readln(conn^.sin, buff);
        if buff <> '' then
        begin
                SetLength(conn^.response, length(conn^.response) + 1);
                nv := substrsplit(buff, ':');
                conn^.response[length(conn^.response) - 1].name := strtrim(nv[0]);
                conn^.response[length(conn^.response) - 1].value := strtrim(nv[1]);
        end;
    until (buff = '') or eof(conn^.sin);
    if copy(conn^.code, 10, 3) = '200' then result := true;
    // Now the redirect focus
    if length(conn^.response) > 0 then
    for i := 0 to length(conn^.response) - 1 do if upcase(conn^.response[i].name) = 'LOCATION' then
    begin
            conn^.uri := conn^.response[i].value;
            // Well, in plain HTTP it is supposed that you will reconnect yourself :(
            exit;
    end;
end;

// Fetches response result info (exact document URL, response message and code as result)
function HttpResponseInfo(cp: HTTPConnection; var final_url, message: string): word;
var conn: PHTTPConnection;
begin
    conn := PHTTPConnection(cp);
    final_url := conn^.uri;
    message := conn^.code;
    val(copy(conn^.code, 1, 3), result);
end;

// Sets client Request header
procedure HttpSetHeader(cp: HTTPConnection; const name, value: string);
var conn: PHTTPConnection;
    i: longword;
begin
    conn := PHTTPConnection(cp);
    // Changing value if already set
    if length(conn^.request) > 0 then
    for i := 0 to length(conn^.request) - 1 do if upcase(conn^.request[i].name) = upcase(name) then
        begin
            conn^.request[i].value := value;
            exit;
        end;
    // Or setting new header
    SetLength(conn^.request, length(conn^.request) + 1);
    conn^.request[length(conn^.request) - 1].name := name;
    conn^.request[length(conn^.request) - 1].value := value;
end;

// Sets client Request POST data (for POST method)
// Variables must be URLEncoded
procedure HttpSetPostData(cp: HTTPConnection; const data: string);
var conn: PHTTPConnection;
    len: string;
    i: longword;
begin
    conn := PHTTPConnection(cp);
    conn^.post := data;
    str(length(data), len);
    // Changing value if already set
    if length(conn^.request) > 0 then
    for i := 0 to length(conn^.request) - 1 do if upcase(conn^.request[i].name) = upcase('Content-Length') then
    begin
      conn^.request[i].value := len;
      exit;
    end;
    // Or setting new header
    SetLength(conn^.request, length(conn^.request) + 1);
    conn^.request[length(conn^.request) - 1].name := 'Content-Length';
    conn^.request[length(conn^.request) - 1].value := len;
end;

// Sets client Requst header from 'Name: Value' string
procedure HttpPutHeader(cp: HTTPConnection; const header: string);
var conn: PHTTPConnection;
    i: longword;
    nv: StrArray;
begin
    conn := PHTTPConnection(cp);
    // Splitting into name=value pair
    nv := substrsplit(header, ':');
    if length(nv) <> 2 then exit;
    nv[0] := strtrim(nv[0]);
    nv[1] := strtrim(nv[1]);
    // Changing value if already set
    if length(conn^.request) > 0 then
    for i := 0 to length(conn^.request) - 1 do if upcase(conn^.request[i].name) = upcase(nv[0]) then
    begin
      conn^.request[i].value := nv[1];
      exit;
    end;
    // Or setting new header
    SetLength(conn^.request, length(conn^.request) + 1);
    conn^.request[length(conn^.request) - 1].name := nv[0];
    conn^.request[length(conn^.request) - 1].value := nv[1];
end;




end.












































