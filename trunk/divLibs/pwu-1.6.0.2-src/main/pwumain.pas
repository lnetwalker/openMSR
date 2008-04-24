{*******************************************************************************

                                PSP/PWU 1.6.X

********************************************************************************
                                       
--------------------------------------------------------------------------------
 Main Web Unit
--------------------------------------------------------------------------------
  Main functions and procedures for web programs. Developers: SVN logs are 
  important. Notes are not added to the top of this source file any more. Log 
  your changes when you upload to SVN. Comment the source code, regardless.
--------------------------------------------------------------------------------
  Authors/Credits:
--------------------------------------------------------------------------------
  Trustmaster (Vladimir Sibirov), L505 (Lars Olson), TonyH (Anthony Henry)
  This file is copyright to above authors. Legal: see the Artistic License.
********************************************************************************}

// DEFAULT: ON
 {$DEFINE EXTRA_SECURE}
// take this off to save some kilobytes (kb)
// turn it on if you want strong security (check as many overflows as possible)
// DEFAULT: on


// DEFAULT: ON
 {$DEFINE G_ZIP}
{ take this off to save some kilobytes (kb)
  turn it on if you plan to use GZIP in PWU config file }

{
  Comment the above DEFINES out and use the -d compiler
  option if you want. For example:

  -dEXTRA_SECURE compiler argument
  -dG_ZIP compiler argument }


{$IFDEF FPC}{$MODE OBJFPC}{$H+}
  {$IFDEF EXTRA_SECURE}{$R+}{$Q+}{$CHECKPOINTER ON}{$ENDIF}
{$ENDIF}


unit pwumain;

interface

uses
  pwuTypes,
  pwuErrors;
  
  
const
 { main configuration file name. }
 {$ifdef UNIX} PWU_CFG_FILE = 'pwu_unix.conf'; {$endif}
 {$ifdef WIN32} PWU_CFG_FILE = 'pwu_win.conf'; {$endif}

  { Session file name }
  PWU_SESS_PATH = 'pwusess.sds';



  { Supply PWU version }
  {$i ../version/version.inc}

{------------------------------------------------------------------------------}
{--- Main Procedures/Functions ------------------------------------------------}
{------------------------------------------------------------------------------}



 {-- CGI Variable Functions --}
function CountCGIVars: longword;
function GetCgiVar(const name: string): string;
function GetCgiVar_S(const name: string; const SecureLevel: integer): string;
function GetCgiVarAsFloat(const name: string): double;
function GetCgiVarAsInt(const name: string): longint;
function GetCgiVar_SafeHTML(const name: string): string; 
function FetchCgiVarName(index: longword): string;
function FetchCgiVarValue(index: longword): string;
function IsCgiVar(const name: string): boolean;
function GetCgiVar_SF(const name: string; const SecureLevel: integer): string;


 {-- Cookie Functions --}
function CountCookies: longword;
function FetchCookieName(index: longword): string;
function FetchCookieValue(index: longword): string;
function GetCookie(const name: string): string;
function GetCookieAsFloat(const name: string): double;
function GetCookieAsInt(const name: string): longint;
function IsCookie(const name: string): boolean;
function SetCookie(const name, value: string): boolean;
function SetCookieAsFloat(const name: string; value: double): boolean;
function SetCookieAsInt(const name: string; value: longint): boolean;
function SetCookieEx(const name, value, path, domain, expires: string): boolean;
function SetCookieAsFloatEx(const name: string; value: double; const path, domain, expires: string): boolean;
function SetCookieAsIntEx(const name: string; value: longint; const path, domain, expires: string): boolean;
function UnsetCookie(const name: string): boolean;
function UnsetCookieEx(const name, path, domain: string): boolean;


 {-- Config Functions --}
function CountWebConfigVars: longword;
function FetchWebConfigVarName(index: longword): string;
function FetchWebConfigVarValue(index: longword): string;
function GetWebConfigVar(const name: string): string;
function IsWebConfigVar(const name: string): boolean;
function SetWebConfigVar(const name, value: string): boolean;


 {-- Environment Variable Functions --}
//function CountEnvVars: longword;
//function FetchEnvVarName(index: longword): string;
//function FetchEnvVarValue(index: longword): string;

function IsEnvVar(const name: string): boolean;
//function SetEnvVar(const name, value: string): boolean;


 {-- Filtering Functions --}
function FilterHTML(const input: string): string;
function FilterHTML_S(const input: string; const SecureLevel: integer): string;
function TrimBadChars(const input: string): string;
function TrimBadChars_file(const input: string): string;
function TrimBadChars_dir(const input: string): string;
function TrimBadChars_S(const input: string; const SecureLevel: integer): string;


 {-- Header Functions --}
function CountWebheaders: longword;
function FetchWebHeaderName(index: longword): string;
function FetchWebHeaderValue(index: longword): string;
function GetWebHeader(const name: string): string;
function IsWebHeader(const name: string): boolean;
function SetWebHeader(const name, value: string): boolean;
function UnsetWebHeader(const name: string): boolean;
function PutWebHeader(const header: string): boolean;


 {-- Output/Write Out Functions/Procedures --}
procedure WebWrite(const s: string);
procedure WebWriteA(args: array of const);
procedure WebWriteF(const s: string);
procedure WebWriteFF(const s: string);
procedure WebWriteF_Fi(const s: string; const HTMLFilter: boolean);
procedure WebWriteLn(const s: string);
procedure WebWriteLnF(const s: string);
procedure WebWriteLnFF(const s: string);
procedure WebWriteLnF_Fi(const s: string; const HTMLFilter: boolean );
function WebFileOut(const fname: string): errcode;
function WebResourceOut(const fname: string): errcode;
procedure WebBufferOut(Const Buff; BuffLength : LongWord);
function WebTemplateOut(const fname: string; const HTMLFilter: boolean): errcode;
function WebTemplateRaw(const fname: string): errcode;
function WebFormat(const s: string): string;
function WebFormatAndFilter(const s: string): string;
function WebFormat_SF(const s: string;
                      const HTMLFilter: boolean;
                      const FilterSecureLevel,
                            TrimSecureLevel: integer): string;


 {-- RTI Functions --}
function CountRtiVars: longword;
function FetchRtiName(index: longword): string;
function FetchRtiValue(index: longword): string;
function GetRti(const name: string): string;
function GetRtiAsFloat(const name: string): double;
function GetRtiAsInt(const name: string): longint;
function IsRti(const name: string): boolean;


 {-- Session Functions --}
function CountSessVars: longword;
function FetchSessName(index: longword): string;
function FetchSessValue(index: longword): string;
function GetSess(const name: string): string;
function GetSessAsFloat(const name: string): double;
function GetSessAsInt(const name: string): longint;
function IsSess(const name: string): boolean;
function SessDestroy: boolean;
function SetSess(const name, value: string): boolean;
function SetSessAsFloat(const name: string; value: double): boolean;
function SetSessAsInt(const name: string; value: longint): boolean;
function UnsetSess(const name: string): boolean;


 {-- Upload File Functions --}
function FetchUpfileName(index: longword): string;
function GetUpFileName(const name: string): string;
function GetUpFileSize(const name: string): longint;
function GetUpFileType(const name: string): string;
function CountUpFiles: longword;
function IsUpFile(const name: string): boolean;
function SaveUpFile(const name, fname: string): boolean;


 {-- Web Variable Functions/Procedures --}
function CountWebVars: longword;
function FetchWebVarName(index: longword): string;
function FetchWebVarValue(index: longword): string;
function GetWebVar(const name: string): string;
function GetWebVar_S(const name: string; const SecureLevel: integer): string;
function GetWebVarAsFloat(const name: string): double;
function GetWebVarAsInt(const name: string): longint;
procedure SetWebVar(const name, value: string);
procedure SetWebVarAsFloat(const name: string; value: double);
procedure SetWebVarAsInt(const name: string; value: longint);
function IsWebVar(const name: string): byte;
procedure UnsetWebVar(const name: string);


 {-- Utility/Tools Functions --}
function LineEndToBR(const s: string): string;
function RandomStr(len: longint): string;
function XORCrypt(const s: string; key: byte): string;


 {-- Error Functions --}
function ThrowWebError(const ErrMessage: string): boolean;


// END OF PUBLIC FUNCTION/PROCEDURE DECLARATIONS
{------------------------------------------------------------------------------}

{------------------------------------------------------------------------------}
implementation
{------------------------------------------------------------------------------}

uses
 {$IFDEF WIN32}
  windows,
 {$ENDIF}
 {$IFDEF UNIX}
  baseunix,
 {$ENDIF}
  native_out,   // native write function
  pwuenvvar,
  base64enc,
  fileutil,
  sdsMain,      // TODO: change to dynamic sds.pas or sdsInternal.pas.
  substrings,
  sysutils,     // TODO: use CompactSysUtils if possible, to reduce size of DLL/DSO
  urlenc,
  mimetypes,
  fileshare,
  pwuconfig,
 {$IFDEF G_ZIP}           
  objbuff     // output buffer with built in gzip
 {$ENDIF};

var debugt: text; // Debug output

type
  // Associative variable
  TWebVariable = record
    name, value: string;
  end;

  // Variables associative array
  TWebVariables = array of TWebVariable;
  PWebVariables = ^TWebVariables;

type
  // Type of uploaded file
  TWebUpFile = record
    name, filename, data, content_type: string;
    size: longint;
  end;

  // Type to store all uploaded files
  TWebUpFiles = array of TWebUpFile;

  // Pointer to file data
  PWebUpFiles = ^TWebUpFiles;

const
  CGI_CRLF = #13#10; // CGI uses #13#10 no matter what OS


type
  // Line type for Multipart/Form-Data handling functions
  MP_Line = array[1..6] of string;

  // Multipart/Form-Data form type
  MP_Form = array of string;

  // Pointer to MP_Form
  MP_PForm = ^MP_Form;


var
  cgi,  // CGI GET/POST data
  conf, // Configuration data
  cook, // Cookie data
//  env,  // Environment data
  hdr,  // Headers
  rti,  // Run Time Information
  sess, // Session data
  vars: TWebVariables; // PWU assign data
  UpFiles: TWebUpFiles;    // Uploaded files storage
  headers_sent, // Headers sent flag
  session_registered: boolean; // Session registered flag
 {$IFDEF G_ZIP}
  output_buffering, output_compression : boolean; // Output buffering and compression flags
  outbuff : PSmartBuffer;
 {$ENDIF}
  error_reporting, error_halt: boolean; // Error reporting flags


procedure SetRTI(const name, value: string); forward;
function SessUpdate: boolean; forward;


{------------------------------------------------------------------------------}
{--- SYSAPI FUNCTIONS ---------------------------------------------------------}
{------------------------------------------------------------------------------}
(* // no need when using baseunix 
{$IFDEF UNIX}
var
  environ: ppchar; cvar; external;

function getenv(const name: PChar): PChar; cdecl; external 'c' name 'getenv';
function setenv(const name, value: pchar; replace: longint): longint; cdecl; external 'c' name 'setenv';
function unsetenv(const name: pchar): longint; cdecl; external 'c' name 'unsetenv';
{$ENDIF}
*)

{------------------------------------------------------------------------------}


{------------------------------------------------------------------------------}
{--- PRIVATE FUNCTIONS/PROCEDURES ---------------------------------------------}
{------------------------------------------------------------------------------}

{ ERROR LOGGING IF PWUDEBUG DEFINED. NOTE: WITH DYNPWU, USE DEBUG DLL WITH 
  DEBUGLN COMPILED INTO IT }
procedure debugln(s: string);
begin
 {$IFDEF PWUDEBUG}
  writeln(debugt, s);
  flush(debugt);
 {$ENDIF}
end;

{ if a premature error occurs before InitWebHeaders, we need to output a simple 
  header first }
procedure ErrorHeader;
begin
  NativeWrite('Content-Type: text/html' + CGI_CRLF); //initialize a simple header
  NativeWrite(CGI_CRLF);
end;


{ default header definitions on successful startup }
procedure InitWebHeaders;
begin
  debugln('InitWebHeaders begin');
  SetLength(hdr, 2);
  hdr[0].name:= 'X-Powered-By';
  hdr[0].value:= 'PWU/' + PWU_VERSION;
  hdr[1].name:= 'Content-Type';
  hdr[1].value:= 'text/html; charset=' + GetWebConfigVar('header_charset');
 {$IFDEF G_ZIP}
  if output_buffering
    and output_compression
    and substrexists(GetEnvVar('HTTP_ACCEPT_ENCODING'), 'gzip') then
    begin
      SetLength(hdr, 3);
      hdr[2].name:= 'Content-Encoding';
      hdr[2].value:= 'gzip';
    end
  else
    output_compression := false;  
 {$ENDIF}
  debugln('InitWebHeaders end');
end;


// Some default RTI definitions on startup
procedure InitRTI;
begin
  debugln('InitRTI begin');
  SetLength(rti, 2);
  rti[0].name:= 'HEADERS_SENT';
  rti[0].value:= 'FALSE';
  rti[1].name:= 'ERRORS';
  rti[1].value:= '0';
  debugln('InitRTI end');
end;


// Finds the configuration file and parses it into conf[]
function ParseWebConfig: boolean;
var
  cfg_path,
  buff,
  name,
  value: string;
  fh: text;
  i: integer;
  tmplen: integer;
begin
  debugln('ParseWebConfig begin');
  result:= false;
  cfg_path:= GetCfgPath;
  if cfg_path = '' then
  begin 
    debugln('ParseWebConfig exit 1'); 
    exit; // won't go further if config file not found
  end;

  // Opening
  assign(fh, cfg_path);
  reset(fh);

  // Parsing
  while not eof(fh) do
  begin
    readln(fh, buff);
    // Emtpy lines are ignored
    if buff = '' then continue;
    // All comment lines start with # only
    if buff[1] = '#' then continue;
    i:= substrpos(buff, '=');
    name:= copy(buff, 1, i - 1);
    value:= copy(buff, i + 1, length(buff) - i);
    name:= strtrim(name);
    value:= substrstrip(strtrim(value), '"');
    if (name = '') or (value = '') then continue;
    SetLength(conf, length(conf) + 1);
    tmplen:= length(conf) - 1;
    conf[tmplen].name:= name;
    conf[tmplen].value:= value;
  end;
  close(fh);

// Setting program flags

 {$IFDEF G_ZIP}
  if system.lowercase(GetWebConfigVar('output_buffering')) = 'on' then
    output_buffering:= true
  else
    output_buffering:= false;
  if system.lowercase(GetWebConfigVar('output_compression')) = 'on' then
    output_compression:= true 
  else 
    output_compression:= false;
 {$ENDIF}

  if system.lowercase(GetWebConfigVar('error_reporting')) = 'on' then
    error_reporting:= true 
  else 
    error_reporting:= false;
  if system.lowercase(GetWebConfigVar('error_halt')) = 'on' then
    error_halt:= true 
  else 
    error_halt:= false;

  // Done
  result:= true;
  debugln('ParseWebConfig end');
end;


// Sends HTTP headers
function SendWebHeaders: boolean;
var
  i: longword;          
begin
  debugln('SendWebHeaders begin');
  result:= false;
  // Check if sent
  if headers_sent then exit(false);
  // Update session
  SessUpdate;
  // Send
  if length(hdr) > 0 then
  for i:= 0 to length(hdr) - 1 do
    NativeWrite(hdr[i].name + ': ' + hdr[i].value + CGI_CRLF);
  NativeWrite(CGI_CRLF);
  // Update RTI
  headers_sent:= true;
  SetRTI('HEADERS_SENT', 'TRUE');
  // Done
  result:= true;
  debugln('SendWebHeaders end');
end;


{$IFDEF G_ZIP}
// Flushes output buffer
function FlushBuffer: boolean;
begin
  debugln('FlushBuffer begin');
  result:= false;
  // Check if headers are sent
  if not headers_sent then SendWebHeaders;
  // Flushing
  OutBuff^.Flush;
  // Done
  result:= true;
  debugln('ParseWebConfig end');
end;
{$ENDIF}


// Dumps vars into cgi
function PutCGIVars(const data: string): boolean;
var
  i,
  len,
  cnt: longword;
  lex: string;
begin
  debugln('PutCgiVars begin');
  // Init
  result:= false;
  i:= 1;
  cnt:= 0;
  len:= length(data);
  if len = 0 then 
  begin
    result:= true;
    debugln('PutCgiVars Exit 1');
    exit;
  end;
  if data[1] = '\' then inc(i);
  // Parse out
  while (i <= len) do
  begin
    // New item
    SetLength(cgi, cnt + 1);
    // Getting name
    lex:= '';
    while (i <= len) and (data[i] <> '=') do
    begin
      SetLength(lex, length(lex) + 1);
      lex[length(lex)]:= data[i];
      inc(i);
    end;
    cgi[cnt].name:= UrlDecode(lex);
    inc(i);
    // Getting value
    lex:= '';
    while (i <= len) and (data[i] <> '&') do
    begin
      SetLength(lex, length(lex) + 1);
      lex[length(lex)]:= data[i];
      inc(i);
    end;
    cgi[cnt].value:= UrlDecode(lex);
    inc(i);
    // Increasing counter
    inc(cnt);
  end;
  // Done
  result:= true;
  debugln('PutCgiVars end');
end;


// Dumps vars from multipart/form-data into cgi and UpFile
// OLD NOTE: Left as-is in 1.3.3 (it must be totally rewritten otherwise)
procedure MP_FormSplit(var data: PString; const boundary: string; var form: MP_PForm);
// Splits the form into items
var
  separator: string;
  ptr,
  len,
  len2: longint;
begin
  debugln('MP_FormSplit begin');
  separator:= '--' + boundary + #13 + #10;
  len2:= length(separator);
  // Cutting off last boundary
  len:= substrpos(data^, '--' + boundary + '--');
  data^:= copy(data^, 1, len-1);
  // Cutting off first boundary
  delete(data^, 1, len2);
  while len > 0 do
  begin
    len:= length(data^);
    ptr:= substrpos(data^, separator);
    if ptr <> 0 then
    begin
      // Not last item
      SetLength(form^, length(form^) + 1);
      form^[length(form^) - 1]:= copy(data^, 1, ptr - 2);
      // Cutting this item and next boundary
      delete(data^, 1, ptr + len2 - 1);
    end else
    begin
      // Last item
      SetLength(form^, length(form^) + 1);
      form^[length(form^) - 1]:= copy(data^, 1, len-1);
      break;
    end;
  end;
  debugln('MP_FormSplit end');
end;


// Multipart: Extracts current line beginning from ptr and ending with #13#10
function MP_GetLine(data: PString; var ptr: longint): string;
var
  s: string;
begin
  debugln('MP_GetLine begin');
  result:= '';
  if data = nil then 
  begin
    debugln('MP_GetLine exit, data nil');
    exit;
  end;
//  debugln('MP_GetLine data: ' + data^);
  repeat
    s:= copy(data^, ptr, 1);
    if (s <> #13) and (s <> #10) then result:= result + s;
    inc(ptr);
  until (s = #13) or (s = #10);
  inc(ptr);
  debugln('MP_GetLine end');
end;


// Multipart: Splits string by space. Max. result = 6 strings.
function MP_SplitLine(line: string): MP_Line;
var
  cnt, elem, len: integer;
  s: string;
  quoted: boolean;
begin
  debugln('MP_SplitLine begin...');
  result[1]:= '';
  result[2]:= '';
  result[3]:= '';
  result[4]:= '';
  result[5]:= '';
  result[6]:= '';
  elem:= 1;
  len:= length(line);
  quoted:= false;
  cnt:= 1;
//  debugln('MP_SplitLine line param: ' + line + ' Line length: ' + inttostr(len));
  for cnt:= 1 to len do
  begin
    s:= copy(line, cnt, 1);
    if (s='"') then quoted:= not quoted; // on/off - track whether inside quotes or not
    if (s<>' ') and (s<>'=') and (s<>';') and (s<>'"') and (s<>':') then
      result[elem]:= result[elem] + s;
    if ((s=' ') or (s=';') or (s=':') or (s='=')) and quoted then 
      result[elem]:= result[elem] + s;
    if ((s=';') or (s='=') or (s=':')) and (not quoted) then
      inc(elem);
  end;
  debugln('MP_SplitLine end ');
end;


// Multipart: Extracts data boundary from content-type string
function MP_GetBoundary(const content_type: string): string;
var
  len: integer;
begin
  debugln('MP_GetBoundry begin');
  len:= substrpos(Content_Type, '=');
  result:= copy(content_type, len + 1, length(content_type)-len);
  if substrpos(result, '"') = 1 then result:= copy(result, 2, length(result) - 2);
  debugln('MP_GetBoundry end');
end;

// Multipart: put cgi vars
procedure MP_PutCGIVars(data: PString; const content_type: string);
var
  cnt,
  ptr,
  tmp,
  len,
  dpos: longint;
  buff, boundary: string;
  line: MP_Line;
  form: MP_PForm;
  UpIndex: integer; // current index to UpFile array
begin
  debugln('MP_PutCGIVars begin');
  New(form);
  boundary:= MP_GetBoundary(content_type);
  MP_FormSplit(data, boundary, form);
  for cnt:= 0 to (length(form^) - 1) do
  begin
    ptr:= 1;
    len:= length(form^[cnt]);
    dpos:= substrpos(form^[cnt], #13 + #10 + #13 + #10) + 4;
    // Getting first line
    buff:= MP_GetLine(@(form^[cnt]), ptr);
    // Splitting into words
    line:= MP_SplitLine(buff);
    // Is it file or variable?
    if substrpos(buff, 'filename') <> 0 then
    begin
      // It is a file
      SetLength(UpFiles, length(UpFiles) + 1);
      UpIndex:= length(UpFiles) - 1;
      UpFiles[UpIndex].name:= line[4];
      UpFiles[UpIndex].filename:= line[6];
      debugln('Upload file name var: ' +UpFiles[UpIndex].name);
      debugln('Upload filename: ' + UpFiles[UpIndex].filename);
      // Getting content type
      buff:= MP_GetLine(@(form^[cnt]), ptr);
      line:= MP_SplitLine(buff);
      UpFiles[UpIndex].content_type:= line[2];
      // Getting value till the end
      UpFiles[UpIndex].size:= len - dpos;
      
      // *** Make sure we have enough room to use MOVE *** (equivalent to GetMem);
      SetLength(UpFiles[UpIndex].data, UpFiles[UpIndex].size);
      
      // NO LONGER NEEDED *** UpFiles[UpIndex].data:= copy(form^[cnt], dpos, UpFiles[UpIndex].size);
       // ** Tonys Code     
       // *** Move is Much faster then copy especially for large strings. 
      
       If UpFiles[UpIndex].size > 0 then
        Move(form^[cnt][dpos], UpFiles[UpIndex].Data[1], UpFiles[UpIndex].size); 
    end else
    begin
      // It is a variable
      SetLength(cgi, length(cgi) + 1);
      cgi[length(cgi) - 1].name:= line[4];
      // Getting value till the end
      tmp:= len - dpos;
      cgi[length(cgi) - 1].value:= copy(form^[cnt], dpos, tmp);
    end;
  end;
  Dispose(form);
  debugln('MP_PutCGIVars end');
end;


// Dumps vars into cook
function PutCookieVars(const data: string): boolean;
var i, len, cnt: longword;
   lex: string;
begin
  debugln('PutCookieVars begin');
  // Init
  result:= false;
  i:= 1;
  cnt:= 0;
  len:= length(data);
  if data[1] = '\' then inc(i);
  // Parse out
  while (i <= len) do
  begin
    // New item
    SetLength(cook, cnt + 1);
    // Getting name
    lex:= '';
    while (i <= len) and (data[i] <> '=') do
    begin
      SetLength(lex, length(lex) + 1);
      lex[length(lex)]:= data[i];
      inc(i);
    end;
    cook[cnt].name:= UrlDecode(lex);
    inc(i);
    // Getting value
    lex:= '';
    while (i <= len) and (data[i] <> ';') do
    begin
      SetLength(lex, length(lex) + 1);
      lex[length(lex)]:= data[i];
      inc(i);
    end;
    cook[cnt].value:= UrlDecode(lex);
    inc(i);
    // Ignoring spaces
    while (i <= len) and (data[i] = ' ') do
      inc(i);
    // Increasing counter
    inc(cnt);
  end;
  // Done
  result:= true;
  debugln('PutCookieVars end');
end;

// Dumps vars into sess
function PutSessVars(const data: string): boolean;
var
  i,
  len,
  cnt: longword;
  lex: string;
begin
  debugln('PutSessVars begin');
  // Init
  result:= false;
  i:= 1;
  cnt:= 0;
  len:= length(data);
  // Parse out
  while (i <= len) do
  begin
    // New item
    SetLength(sess, cnt + 1);
    // Getting name
    lex:= '';

    while (i <= len) and (data[i] <> '=') do
    begin
      SetLength(lex, length(lex) + 1);
      lex[length(lex)]:= data[i];
      inc(i);
    end;
    sess[cnt].name:= UrlDecode(lex);
    inc(i);
    // Getting value
    lex:= '';

    while (i <= len) and (data[i] <> ';') do
    begin
      SetLength(lex, length(lex) + 1);
      lex[length(lex)]:= data[i];
      inc(i);
    end;

    sess[cnt].value:= UrlDecode(lex);
    inc(i);
    // Increasing counter
    inc(cnt);
  end;
  // Done
  result:= true;
  debugln('PutSessVars end');
end;

// Session garbage collector
function SessGC: boolean;
var
  SessTable,
  sess_lim: string;
  res: SDS_Result;
  sess_time: longword;
  limdate: TDateTime;
  tmpstr: string;
begin
  result:= false;
  // Checking
  SessTable:= GetWebConfigVar('session_path');
  if not FileExists(SessTable) then
  begin
    // Searching in system temp
    tmpstr:= {$IFDEF WIN32}GetEnvVar('WINDIR') + '\'{$ENDIF}{$IFDEF UNIX}'/tmp/'{$ENDIF}+ PWU_SESS_PATH;
    if FileExists(tmpstr) then 
      SessTable:= tmpstr
    else
      exit; // false
  end;
  // Checking lifetime in minutes
  val(GetWebConfigVar('session_life_time'), sess_time);
  if sess_time = 0 then
    exit(true);
  limdate:= now - (sess_time / 1440);
  sess_lim:= FormatDateTime('yyyy-mm-dd hh:nn:ss', limdate);
  // Performing GC
  res:= sdsmain.query(
         'DELETE FROM `' + SessTable + '` WHERE modified < "' + sess_lim + '"'
        );
  if sdsmain.ResultError(res) = '' then result:= true;
  sdsmain.FreeResult(res);
end;

// Gets session data
function SessStart: string;
var
  SessTable: string;
  res: SDS_Result;
  row: SDS_Array;
  key, sid: string;
begin
  debugln('SessStart begin');
  // Init
  result:= '';
  // Checking path
  SessTable:= GetWebConfigVar('session_path');
  if not FileExists_readwrite(SessTable) then
  begin
    // Searching in system temp
    if FileExists_readwrite(
                  {$IFDEF WIN32}GetEnvVar('WINDIR') + '\'{$ENDIF}
                  {$IFDEF UNIX}'/tmp/'{$ENDIF}
                  + PWU_SESS_PATH) then

      SessTable:= {$IFDEF WIN32}GetEnvVar('WINDIR') + '\'{$ENDIF}
                   {$IFDEF UNIX}'/tmp/'{$ENDIF}
                   + PWU_SESS_PATH
    else
    begin
      debugln('SessStart exit, file not found');
      exit('');
    end;
  end;
  // Running garbage collector
  SessGC;
  // Is it registered
  if not IsCookie('PWUSESS') then
  begin
    session_registered:= false;
    SetRTI('SESSION_REGISTERED', 'FALSE');
    exit('');
  end;
  session_registered:= true;
  SetRTI('SESSION_REGISTERED', 'TRUE');
  key:= Base64Decode(GetCookie('PWUSESS'));
  sid:= sdsmain.Escape(copy(key, 13, length(key) - 12));
  key:= sdsmain.Escape(copy(key, 1, 12));
  // Selecting
  res:= sdsmain.Query('SELECT data FROM `' + SessTable + '` WHERE id = ' + sid + ' AND key = "' + key + '"');
  if sdsmain.ResultRows(res) = 1 then
  begin
    row:= sdsmain.FetchRow(res);
    result:= Base64Decode(sdsmain.FetchColumn(row, 0));
    sdsmain.FreeRow(row);
  end
    else
  begin
    result:= '';
    // Unset the cookie, it has timed out
    UnsetCookie('PWUSESS');
  end;
  sdsmain.FreeResult(res);
  debugln('SessStart end');
end;

// Updates session table due to sess or registers a new session
function SessUpdate: boolean;
var
  SessTable, data: string;
  res: SDS_Result;
  id, i: longword;
  key, sid: string;
  registered: boolean;
  tmpstr: string;
begin
  debugln('SessUpdate begin');
  if length(sess) = 0 then exit(true);
  // Init
  result:= false;
  SessTable:= GetWebConfigVar('session_path');
  if not FileExists(SessTable) then
  begin
    // Searching in system temp
    tmpstr:= {$IFDEF WIN32}GetEnvVar('WINDIR') + '\' {$ENDIF}
             {$IFDEF UNIX}'/tmp/'{$ENDIF} + PWU_SESS_PATH;
    if ( FileExists(tmpstr) ) or (SessTable = '') then SessTable:= tmpstr;
  end;
  // Create session table if not exists
  if not FileExists(SessTable) then
  begin
    res:= sdsmain.Query('CREATE TABLE `' + SessTable + '` (id INT, key TEXT, data TEXT, modified DATETIME)');
    if sdsmain.ResultRows(res) < 1 then
      ThrowWebError('Could not create session table, SDS returned: ' + sdsmain.ResultError(res));
    sdsmain.FreeResult(res);
  end;
  // Depending on whether session is registered
  if IsCookie('PWUSESS') then
  begin
    key:= Base64Decode(GetCookie('PWUSESS'));
    sid:= sdsmain.Escape(copy(key, 13, length(key) - 12));
    key:= sdsmain.Escape(copy(key, 1, 12));
    // Selecting
    res:= sdsmain.Query('SELECT COUNT(*) FROM `' + SessTable + '` WHERE id = ' + sid + ' AND key = "' + key + '"');
    if sdsmain.ResultRows(res) = 1 then registered:= true else
    begin
      registered:= false;
      // Unset the cookie
      UnsetCookie('PWUSESS');
    end;
    sdsmain.FreeResult(res);
  end else
    registered:= false;
  // Generate new data string
  data:= '';
  if length(sess) > 0 then
  for i:= 0 to length(sess) - 1 do
    data:= data + UrlEncode(sess[i].name) + '=' + UrlEncode(sess[i].value) + ';';
  // Strip tail ;
  data:= copy(data, 1, length(data) - 1);
  data:= Base64Encode(data);
  if registered then
  begin
    // Updating
    res:= sdsmain.Query('UPDATE `' + SessTable +
                        '` SET data = "' + sdsmain.Escape(data) + '", ' +
                              'modified = NOW WHERE id = ' + sid +
                                              ' AND key = "' + key + '"');
    if sdsmain.ResultRows(res) = 1 then result:= true;
    sdsmain.FreeResult(res);
  end
    else
  begin
    // Check headers
    if headers_sent then
    begin
      ThrowWebError('Can not register new session - headers are already sent');
      exit(false);
    end;
    // Creating new one
    key:= RandomStr(12);
    res:= sdsmain.Query('INSERT INTO `' + SessTable +
                        '` (key, data, modified) ' +
                        'VALUES ("' + key + '", "' +
                                  sdsmain.Escape(data) + '", ' +
                                  'NOW' +')');
    if sdsmain.ResultRows(res) = 1 then
    begin
      id:= sdsmain.LastID(SessTable);
      str(id, sid);
      key:= Base64Encode(key + sid);
      SetCookie('PWUSESS', key);
      SetRTI('SESSION_REGISTERED', 'TRUE');
    end else
      result:= false;
    sdsmain.FreeResult(res);
  end;
  debugln('SessUpdate end');
end;

// Is responsible for getting GET, POST, COOKIE and SESSION data
function GetWebData: boolean;
var
  method,
  ctype,
  data: string;
  upl_max_size,
  cont_len,
  cnt: longword;
begin
  debugln('GetWebData begin');
  result:= false;
  // First getting method data
  method:= GetEnvVar('REQUEST_METHOD');
  if method = 'POST' then
  begin
    // Getting data from stdin
    data:= '';
    val(GetWebConfigVar('upload_max_size'), upl_max_size);
    upl_max_size:= upl_max_size * 1048576;
    val(GetEnvVar('CONTENT_LENGTH'), cont_len);
    if cont_len > upl_max_size then cont_len:= upl_max_size;
    SetLength(data, cont_len);
    for cnt:= 1 to cont_len do read(data[cnt]);
    // Depending on content type
    ctype:= GetEnvVar('CONTENT_TYPE');
    if substrpos(lowercase(ctype), 'application/x-www-form-urlencoded') > 0 then
    begin
      PutCGIVars(data);
    end else
      if substrpos(lowercase(ctype), 'multipart/form-data') > 0 then
      begin
        MP_PutCGIVars(@data, ctype);
      end;
  end else
    if method = 'GET' then
    begin
      data:= GetEnvVar('QUERY_STRING');
      PutCGIVars(data);
    end;

  // Get cookies
  if IsEnvVar('HTTP_COOKIE') then
  begin
    data:= GetEnvVar('HTTP_COOKIE');
    PutCookieVars(data);
  end;

  // Get session
  data:= SessStart;
  if data <> '' then PutSessVars(data);

  // Done
  result:= true;
  debugln('GetWebData end');
end;

// Sets Run Time Information variable
procedure SetRTI(const name, value: string);
var
  i: longword;
begin
  debugln('SetRti begin');
  if length(rti) > 0 then
    for i:= 0 to length(rti) - 1 do if rti[i].name = name then
    begin
      rti[i].value:= value;
      break;
    end;
  SetLength(rti, length(rti) + 1);
  rti[length(rti) - 1].name:= name;
  rti[length(rti) - 1].value:= value;
  debugln('SetRti end');
end;


// END OF PRIVATE FUNCTIONS/PROCEDURES
{------------------------------------------------------------------------------}


{------------------------------------------------------------------------------}
{--- PUBLIC FUNCTIONS/PROCEDURES ----------------------------------------------}
{------------------------------------------------------------------------------}

// Returns number of elements in the cgi var list
function CountCGIVars: longword;
begin
  result:= length(cgi);
end;

// Returns number of configuration variables
function CountWebConfigVars: longword;
begin
  result:= length(conf);
end;

// Returns number of cookie variables
function CountCookies: longword;
begin
  result:= length(cook);
end;

// Returns number of set headers
function CountWebHeaders: longword;
begin
  result:= length(hdr);
end;

// Returns number of Run-Time Information variables
function CountRTIVars: longword;
begin
  result:= length(rti);
end;

// Returns number of session variables
function CountSessVars: longword;
begin
  result:= length(sess);
end;

// Returns number of files uploaded
function CountUpFiles: longword;
begin
  result:= length(UpFiles);
end;

// Returns number of all PWU variables
function CountWebVars: longword;
begin
  result:= length(vars);
end;

{ Replaces special characters with their HTML equivalents
  If you are taking input on a guestook or forum for example, you will want to
  use FilterHTML

  Default security level: 2 }
function FilterHTML(const input: string): string;
begin
  result:= FilterHTML_S(input, 2);
end;


(* Powers the FilterHTML function, here with ability to define security level

  Security level 1:
    Replaces special characters with their HTML equivalents.
    This one does not filter { or } or $ if you are for example working with
    templates, because you need those characters.

  Security level 2:
    Similar to level 1, but more filtering of malicious input variable
    attempts. This filter replaces the special template characters, so if you
    want your templates to come through use FilterHTML_1 *)
function FilterHTML_S(const input: string; const SecureLevel: integer): string;
begin

  if SecureLevel = 1 then
  begin
    result:= substrreplace(input, '&', '&amp;');
    result:= substrreplace(result, '#', '&#35;');
    result:= substrreplace(result, '"', '&quot;');
    result:= substrreplace(result, '''', '&#39;');  //single quote
    result:= substrreplace(result, '<', '&lt;');
    result:= substrreplace(result, '>', '&gt;');
    result:= substrreplace(result, '|', '&#124;');  //pipe
    result:= substrreplace(result, '%', '&#37;');   //percent sign
    result:= substrreplace(result,  #0, '');        //null character
  end;
  
  if SecureLevel = 2 then
  begin
    result:= substrreplace(input, '&', '&amp;');
    result:= substrreplace(result, '#', '&#35;');   //pound sign
    result:= substrreplace(result, '"', '&quot;');  //quote
    result:= substrreplace(result, '''', '&#39;');  //single quote
    result:= substrreplace(result, '<', '&lt;');    //less than
    result:= substrreplace(result, '>', '&gt;');    //greater than
    result:= substrreplace(result, '|', '&#124;');  //pipe
    result:= substrreplace(result, '%', '&#37;');   //percent sign
    result:= substrreplace(result,  #0, '');        //null character
    result:= substrreplace(result, '(', '&#40;');   //open bracket
    result:= substrreplace(result, ')', '&#41;');   //closed bracket
    result:= substrreplace(result, '$', '&#36;');   //dollar sign
    result:= substrreplace(result, '?', '&#63;');   //question mark
//   Note: CSS Styles in a macro var could contain curlies { } so are not filtered    
  end;
  
end;


{ Indexed access to cgi variable }
function FetchCGIVarName(index: longword): string;
begin
  if (index < longword(length(cgi))) and (length(cgi) > 0) then
    result:= cgi[index].name
  else
   result:= '';
end;


{ Indexed access to cgi variable }
function FetchCGIVarValue(index: longword): string;
begin
  if (index < longword(length(cgi))) and (length(cgi) > 0) then
    result:= cgi[index].value
  else
    result:= '';
end;


{ Indexed access to configuration variable }
function FetchWebConfigVarName(index: longword): string;
begin
  if (index < longword(length(conf))) and (length(conf) > 0) then
    result:= conf[index].name
  else
    result:= '';
end;


{ Indexed access to configuration variable }
function FetchWebConfigVarValue(index: longword): string;
begin
  if (index < longword(length(conf))) and (length(conf) > 0) then
    result:= conf[index].value
  else
    result:= '';
end;


{ Indexed access to cookie variable }
function FetchCookieName(index: longword): string;
begin
  if (index < longword(length(cook))) and (length(cook) > 0) then
    result:= cook[index].name
  else
    result:= '';
end;


{ Indexed access to cookie variable }
function FetchCookieValue(index: longword): string;
begin
  if (index < longword(length(cook))) and (length(cook) > 0) then
    result:= cook[index].value
  else
    result:= '';
end;


{ Indexed access to header }
function FetchWebHeaderName(index: longword): string;
begin
  if (index < longword(length(hdr))) and (length(hdr) > 0) then
    result:= hdr[index].name
  else
    result:= '';
end;

{ Indexed access to header }
function FetchWebHeaderValue(index: longword): string;
begin
  if (index < longword(length(hdr))) and (length(hdr) > 0) then
    result:= hdr[index].value
  else
    result:= '';
end;

{ Indexed access to RTI variable }
function FetchRTIName(index: longword): string;
begin
  if (index < longword(length(rti))) and (length(rti) > 0) then
    result:= rti[index].name
  else
    result:= '';
end;

{ Indexed access to RTI variable }
function FetchRTIValue(index: longword): string;
begin
  if (index < longword(length(rti))) and (length(rti) > 0) then
    result:= rti[index].value
  else
    result:= '';
end;

{ Indexed access to cgi variable }
function FetchSessName(index: longword): string;
begin
  if (index < longword(length(sess))) and (length(sess) > 0) then
    result:= sess[index].name
  else
    result:= '';
end;

{ Indexed access to cgi variable }
function FetchSessValue(index: longword): string;
begin
  if (index < longword(length(sess))) and (length(sess) > 0) then
    result:= sess[index].value
  else
    result:= '';
end;

{ Indexed access to uploaded file name }
function FetchUpFileName(index: longword): string;
begin
  if (index < longword(length(UpFiles))) and (length(UpFiles) > 0) then
    result:= UpFiles[index].name
  else
    result:= '';
end;

{ Indexed access to PWU variable }
function FetchWebVarName(index: longword): string;
begin
  if (index < longword(length(vars))) and (length(vars) > 0) then
    result:= vars[index].name
  else
    result:= '';
end;

{ Indexed access to PWU variable }
function FetchWebVarValue(index: longword): string;
begin
  if (index < longword(length(vars))) and (length(vars) > 0) then
    result:= vars[index].value
  else
    result:= '';
end;

{ Formats a string replacing variables as if they were macros.
  i.e. if a string contains $MyVariable it will be replaced
  This function does not filter and replace malicious/html characters, but
  rather trims (discards) them

  Default security level: 2 }
function WebFormat(const s: string): string;
begin
  result:= WebFormat_SF(s, false, 0, 2);
  // Uses the following default security settings:
  //   Filter HTML input: NO, see WebFormatAndfilter
  //   Filter security: level 0, not applicable
  //   Trim security: level 2

end;

{ Same as WebFormat, but filters and replaces HTML characters with safe ones,
  as opposed to trimming and discarding them like WebFormat does.

  Default security level: 2 }
function WebFormatAndFilter(const s: string): string;
begin
  result:= WebFormat_SF(s, true, 2, 0);
  { Uses the following default security settings:

     Filter HTML: yes
     Filter security: level 2
     Trim security: level 0. Not applicable. We are filtering, not trimming }
end;

{ WebFormat_SF offers the ability to specify security levels and filter
  settings, and is also used internally to power the default WebFormat
  and WebFilterFormat functions. Those are the ones you use normally,
  this one is for special circumstances

  The _SF suffix means "with specifiable Security and Filter options"

  If HTMLFilter = false the Filter security is ignored and should be set
  at 0, because there is no filter security setting that applies.

  The trim security is ignored and should set at 0 when
  HTMLFIlter = true,  because we can't trim the special characters
  and then try to replace them after (they would already be trimmed).
  i.e. we have to use one or the other, either replace or trim input.}

function WebFormat_SF(const s: string;
                      const HTMLFilter: boolean;
                      const FilterSecureLevel,
                            TrimSecureLevel: integer): string;
const
  ID_CHARS = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_';
var
  i,
  len: longword;
  lex: string;
begin
  // Init
  i:= 1;
  len:= length(s);
  lex:= '';
  result:= '';
  // Parsing
  while i <= len do
  begin
    // Normal concat until chars of our attention
    while (i <= len) and (s[i] <> '$') and (s[i] <> '{') do
    begin
      SetLength(result, length(result) + 1);
      result[length(result)]:= s[i];
      inc(i);
    end;
    // If encountered an indication char
    if (i <= len) and (s[i] = '$') then
    begin
      // $varname?
      // Checking if escaped
      if ((i - 1) > 0) and (s[i - 1] = '\') then
      begin
        // Escaped, ignoring
        SetLength(result, length(result) + 1);
        result[length(result)]:= s[i];
        inc(i);
      end
        else
      begin
        // Getting var name
        inc(i);
        lex:= '';
        while (i <= len) and (substrpos(ID_CHARS, s[i]) > 0) do
        begin
          SetLength(lex, length(lex) + 1);
          lex[length(lex)]:= s[i];
          inc(i);
        end;
        // Evaluating and adding
        if HTMLFilter = true then
        begin

          if FilterSecureLevel = 0 then
          begin
            lex:= GetWebVar_S(lex, 0) //must use GetWebVar security level 0 here since we are implementing our own security with filterHTML.
          end;

          if FilterSecureLevel = 1 then
          begin
            lex:= FilterHTML_S(GetWebVar_S(lex, 0), 1) //must use GetWebVar security level 0 here since we are implementing our own security with filterHTML.
          end;

          if FilterSecureLevel = 2 then
          begin
            lex:= FilterHTML_S(GetWebVar_S(lex, 0), 2) //must use GetWebVar security level 0 here since we are implementing our own security with filterHTML.
          end;

        end else
        begin

          if TrimSecureLevel = 0 then
          begin
            lex:= GetWebVar_S(lex, 0);
          end;

          if TrimSecureLevel = 1 then
          begin
//            NativeWrite(lex+ ' BEFORE' + CGI_CRLF);  //DEBUG
            lex:= GetWebVar_S(lex, 1);
//            NativeWrite(lex + ' AFTER' + CGI_CRLF ); //DEBUG
          end;

          if TrimSecureLevel = 2 then
          begin
//            NativeWrite(lex + ' BEFORE' + CGI_CRLF);//DEBUG
            lex:= GetWebVar_S(lex, 2);
//            NativeWrite(lex + ' AFTER' + CGI_CRLF ); //DEBUG
          end;

        end;

        result:= result + lex;
      end;
    end else
      if (i <= len) and (s[i] = '{') then
      begin
        // {$varname}?
        // Check if escaped or does match the pattern
        if ((i - 1) > 0) and (s[i - 1] = '\') then
        begin
          // Escaped, ignoring
          SetLength(result, length(result) + 1);
          result[length(result)]:= s[i];
          inc(i);
        end
          else
        if i = len then // at end of line
        begin
          SetLength(result, length(result) + 1);
          result[length(result)]:= s[i];
          inc(i);
        end
          else
        if ((i + 1) < len) and (s[i + 1] <> '$') then
        begin
          // Does not match, ignoring
          SetLength(result, length(result) + 1);
          result[length(result)]:= s[i];
          inc(i);
        end
          else
        begin
          // There MUST be } or you should escape curly braces
          // Getting var name till }
          i:= i + 2;
          lex:= '';
          while (i <= len) and (s[i] <> '}') do
          begin
            SetLength(lex, length(lex) + 1);
            lex[length(lex)]:= s[i];
            inc(i);
          end;
          inc(i);
          // Evaluating and adding
          if HTMLFilter = true then
          begin

            if FilterSecureLevel = 0 then
            begin
              lex:= GetWebVar_S(lex, 0) //must use GetWebVar security level 0 here since we are implementing our own security with filterHTML.
            end;

            if FilterSecureLevel = 1 then
            begin
              lex:= FilterHTML_S(GetWebVar_S(lex, 0), 1) //must use GetWebVar security level 0 here since we are implementing our own security with filterHTML.
            end;

            if FilterSecureLevel = 2 then
            begin
              lex:= FilterHTML_S(GetWebVar_S(lex, 0), 2) //must use GetWebVar security level 0 here since we are implementing our own security with filterHTML.
            end;
          end
            else
          begin

            if TrimSecureLevel = 0 then
            begin
              lex:= GetWebVar_S(lex, 0);
            end;

            if TrimSecureLevel = 1 then
            begin
  //            NativeWrite(lex + ' BEFORE' + CGI_CRLF);//DEBUG
              lex:= GetWebVar_S(lex, 1);
  //            NativeWrite(lex + ' AFTER' + CGI_CRLF ); //DEBUG
            end;

            if TrimSecureLevel = 2 then
            begin
  //            NativeWrite(lex + ' BEFORE' + CGI_CRLF );//DEBUG
              lex:= GetWebVar_S(lex, 2);
  //            NativeWrite(lex + ' AFTER' + CGI_CRLF ); //DEBUG
            end;

          end;

          result:= result + lex;
        end;
      end;
  end;
end;

{ Returns value of CGI (GET/POST) variable. This also means your URL variables.

  Default Security level is 2. Use the _S suffix function if you do not need
  high filtering security, or you wish to implment your own filters }
function GetCGIVar(const name: string): string;
begin
  result:= GetCGIVar_S(name, 2);
end;

{ Same as GetCGIVar, but the _S suffix means you can choose the security level
  User specified security level.

  Security 0: does not automatically trim. use this when you want to implement
              your own filtering, such as when using FilterHTML
  Security 1: trims (deletes) special (malicious) characters
  Security 2: trims even more than level 1 }
function GetCGIVar_S(const name: string; const SecureLevel: integer): string;
var
  i: longword;
begin
  result:= '';
  if length(cgi) = 0 then exit;
  
  for i:= 0 to length(cgi) - 1 do if cgi[i].name = name then
  begin

    //perform a trim with security 2, output the result
    if SecureLevel = 2 then
    begin
      result:= TrimBadChars_S(cgi[i].value, 2);
      exit;
    end;
    
    //perform a trim with security 1, output the result
    if SecureLevel = 1 then
    begin
      result:= TrimBadChars_S(cgi[i].value, 1);
      exit;
    end;
    
    //perform NO trim, output the result
    if SecureLevel = 0 then
    begin
      result:= cgi[i].value;
      exit;
    end;
    
  end;
end;

{ Returns value of CGI (GET/POST) variable as double precision float
  todo: implement security levels? is it needed? }
function GetCgiVarAsFloat(const name: string): double;
var
  i: longword;
begin
  result:= 0.0;
  if length(cgi) = 0 then exit;
  for i:= 0 to length(cgi) - 1 do if cgi[i].name = name then
  begin
    val(cgi[i].value, result);
    break;
  end;
end;

{ Returns value of CGI (GET/POST) variable as integer
  todo: implement security levels? is it needed? }
function GetCgiVarAsInt(const name: string): longint;
var
  i: longword;
begin
  result:= 0;
  if length(cgi) = 0 then exit;
  for i:= 0 to length(cgi) - 1 do if cgi[i].name = name then
  begin
    val(cgi[i].value, result);
    break;
  end;
end;

{ Returns value of configuration variable
  todo: implement security levels? is it needed? }
function GetWebConfigVar(const name: string): string;
var
  i: longword;
begin
  result:= '';
  if length(conf) = 0 then exit;
  for i:= 0 to length(conf) - 1 do if conf[i].name = name then
  begin
    result:= conf[i].value;
    break;
  end;
end;

{ Returns value of a cookie
  todo: implement security levels. it is needed! }
function GetCookie(const name: string): string;
var
  i: longword;
begin
  result:= '';
  if length(cook) = 0 then exit;
  for i:= 0 to length(cook) - 1 do if cook[i].name = name then
  begin
    result:= cook[i].value;
    break;
  end;
end;

{ Returns value of a cookie as double precision float
  todo: implement security levels? is it needed? }
function GetCookieAsFloat(const name: string): double;
var
  i: longword;
begin
  result:= 0.0;
  if length(cook) = 0 then exit;
  for i:= 0 to length(cook) - 1 do if cook[i].name = name then
  begin
    val(cook[i].value, result);
    break;
  end;
end;

{ Returns value of a cookie as integer
  todo: implement security levels? is it needed? }
function GetCookieAsInt(const name: string): longint;
var
  i: longword;
begin
  result:= 0;
  if length(cook) = 0 then exit;
  for i:= 0 to length(cook) - 1 do if cook[i].name = name then
  begin
    val(cook[i].value, result);
    break;
  end;
end;



{ Returns value part of already assigned HTTP header
  todo: implement security levels? is it needed? }
function GetWebHeader(const name: string): string;
var
  i: longword;
begin
   result:= '';
   if length(hdr) = 0 then exit;
   for i:= 0 to length(hdr) - 1 do if upcase(hdr[i].name) = upcase(name) then
    begin
      result:= hdr[i].value;
      break;
    end;
end;


{ Returns value of RTI (Run Time Information) variable
  todo: implement security levels? is it needed? }
function GetRTI(const name: string): string;
var
  i: longword;
begin
  result:= '';
  if length(rti) = 0 then exit;
  for i:= 0 to length(rti) - 1 do if rti[i].name = name then
  begin
     result:= rti[i].value;
     break;
  end;
end;

{ Returns value of RTI variable as double precision float
 todo: implement security levels? is it needed? }
function GetRTIAsFloat(const name: string): double;
var
  i: longword;
begin
  result:= 0.0;
  if length(rti) = 0 then exit;
  for i:= 0 to length(rti) - 1 do if rti[i].name = name then
  begin
     val(rti[i].value, result);
     break;
  end;
end;

{ Returns value of RTI variable as integer
  todo: implement security levels? is it needed? }
function GetRTIAsInt(const name: string): longint;
var
  i: longword;
begin
  result:= 0;
  if length(rti) = 0 then exit;
  for i:= 0 to length(rti) - 1 do if rti[i].name = name then
  begin
    val(rti[i].value, result);
    break;
  end;
end;


{ Returns value of session variable
  todo: implement security levels. it is needed! }
function GetSess(const name: string): string;
var
  i: longword;
begin
  result:= '';
  if length(sess) = 0 then exit;
  for i:= 0 to length(sess) - 1 do if sess[i].name = name then
  begin
    result:= sess[i].value;
    break;
  end;
end;

{ Returns value of session variable as double precision float
  todo: implement security levels? is it needed? }
function GetSessAsFloat(const name: string): double;
var
  i: longword;
begin
   result:= 0.0;
   if length(sess) = 0 then exit;
   for i:= 0 to length(sess) - 1 do if sess[i].name = name then
  begin
    val(sess[i].value, result);
    break;
  end;
end;

{ Returns value of session variable as integer
  todo: implement security levels? is it needed? }
function GetSessAsInt(const name: string): longint;
var
  i: longword;
begin
  result:= 0;
  if length(sess) = 0 then exit;
  for i:= 0 to length(sess) - 1 do if sess[i].name = name then
  begin
    val(sess[i].value, result);
    break;
  end;
end;

{ Returns original name of the uploaded file
  todo: implement security levels? is it needed? }
function GetUpFileName(const name: string): string;
var
  i: longword;
begin
  result:= '';
  if length(UpFiles) = 0 then exit;
  for i:= 0 to length(UpFiles) - 1 do if UpFiles[i].name = name then
  begin
    result:= UpFiles[i].filename;
    break;
  end;
end;

{ Returns size of the uploaded file }
function GetUpFileSize(const name: string): longint;
var
  i: longword;
begin
  result:= 0;
  if length(UpFiles) = 0 then exit;
  for i:= 0 to length(UpFiles) - 1 do if UpFiles[i].name = name then
  begin
    result:= UpFiles[i].size;
    break;
  end;
end;

{ Returns Content-Type of the uploaded file
  todo: implement security levels? is it needed? }
function GetUpFileType(const name: string): string;
var
  i: longword;
begin
  result:= '';
  if length(UpFiles) = 0 then exit;
  for i:= 0 to length(UpFiles) - 1 do if UpFiles[i].name = name then
  begin
    result:= UpFiles[i].content_type;
    break;
  end;
end;

{ Returns value of any PWU variable (cgi, session, cookie, vars)
  Default security level: 2 }
function GetWebVar(const name: string): string;
begin
  result:= GetWebVar_S(name, 2);
end;


// Powers the GetCGIVar_SafeHTML function. Use this function for special
// circumstances, with the ability to specify security level.
//
// Security level 0:
//   Doesn't filter special characters. Use this if you are filtering or
//   trimming yourself, or when you are using FilterHTML
//
// Security level 1:
//   Filters malicious characters from variable into safe html equivilents
//
// Security level 2:
//   Filters even more than security level 1, including { } $
//
function GetCGIVar_SF(const name: string; const SecureLevel: integer): string;
var
  i: longword;
begin
  result:= '';

  // look in cgi vars
  if length(cgi) > 0 then
  for i:= 0 to length(cgi) - 1 do if cgi[i].name = name then
  begin

    if SecureLevel = 0 then
    begin
      result:= cgi[i].value;
      exit;
    end;

    if SecureLevel = 1 then
    begin
      result:= FilterHTML_S(cgi[i].value, 1);
      exit;
    end;

    if SecureLevel = 2 then
    begin
      result:= FilterHTML_S(cgi[i].value, 2);
      exit;
    end;

  end;

end;


function GetCGIVar_SafeHTML(const name: string): string;
begin
  result:= GetCGIVar_SF(name, 2);
end;


(* Powers the GetWebVar function. Use this function for special circumstances,
   with the ability to specify security level.

   Security level 0:
     Doesn't trim special characters. Use this if you are trimming yourself,
     or when you are using FilterHTML

   Security level 1:
     Trims (deletes) malicious characters from variable

   Security level 2:
     Trims even more than security level 1, including { } $ *)

function GetWebVar_S(const name: string; const SecureLevel: integer): string;
var
  i: longword;
begin
  result:= '';
  // First look in vars
  if length(vars) > 0 then
  for i:= 0 to length(vars) - 1 do if vars[i].name = name then
  begin

    if SecureLevel = 0 then
    begin
      result:= vars[i].value;
      exit;
    end;
    
    if SecureLevel = 1 then
    begin
      result:= TrimBadChars_S(vars[i].value, 1);
      exit;
    end;

    if SecureLevel = 2 then
    begin
      result:= TrimBadChars_S(vars[i].value, 2);
      exit;
    end;

  end;

  // Then look in session vars
  if length(sess) > 0 then
  for i:= 0 to length(sess) - 1 do if sess[i].name = name then
  begin

    if SecureLevel = 0 then
    begin
      result:= sess[i].value;
      exit;
    end;
    
    if SecureLevel = 1 then
    begin
      result:= TrimBadChars_S(sess[i].value, 1);
      exit;
    end;
    
    if SecureLevel = 2 then
    begin
      result:= TrimBadChars_S(sess[i].value, 2);
      exit;
    end;

  end;

  // Then look in cookie vars
  if length(cook) > 0 then
  for i:= 0 to length(cook) - 1 do if cook[i].name = name then
  begin

    if SecureLevel = 0 then
    begin
      result:= cook[i].value;
      exit;
    end;

    if SecureLevel = 1 then
    begin
      result:= TrimBadChars_S(cook[i].value, 1);
      exit;
    end;

    if SecureLevel = 2 then
    begin
      result:= TrimBadChars_S(cook[i].value, 2);
      exit;
    end;

  end;

  // Then look in cgi vars
  if length(cgi) > 0 then
  for i:= 0 to length(cgi) - 1 do if cgi[i].name = name then
  begin

    if SecureLevel = 0 then
    begin
      result:= cgi[i].value;
      exit;
    end;

    if SecureLevel = 1 then
    begin
      result:= TrimBadChars_S(cgi[i].value, 1);
      exit;
    end;
    
    if SecureLevel = 2 then
    begin
      result:= TrimBadChars_S(cgi[i].value, 2);
      exit;
    end;

  end;
  
end;

{ Returns value of PWU variable as float (double precision) }
function GetWebVarAsFloat(const name: string): double;
begin
  val(GetWebVar(name), result);
end;

{ Returns value of PWU variable as integer }
function GetWebVarAsInt(const name: string): longint;
begin
  val(GetWebVar(name), result);
end;

{ Tells whether a CGI (GET/POST) variable is assigned }
function IsCGIVar(const name: string): boolean;
var
  i: longword;
begin
  result:= false;
  if length(cgi) = 0 then exit;
  for i:= 0 to length(cgi) - 1 do if cgi[i].name = name then
  begin
    result:= true;
    break;
  end;
end;

{ Tells whether a configuration variable is assigned }
function IsWebConfigVar(const name: string): boolean;
var
  i: longword;
begin
  result:= false;
  if length(conf) = 0 then exit;
  for i:= 0 to length(conf) - 1 do if conf[i].name = name then
  begin
    result:= true;
    break;
  end;
end;

{ Tells whether a cookie is assigned }
function IsCookie(const name: string): boolean;
var
  i: longword;
begin
  result:= false;
  if length(cook) = 0 then exit;
  for i:= 0 to length(cook) - 1 do if cook[i].name = name then
  begin
    result:= true;
    break;
  end;
end;

{ Tells whether a environment variable is assigned }
function IsEnvVar(const name: string): boolean;
var
  tmp : string;
begin
   tmp := GetEnvVar(name);
   result := not (tmp = '')
end;

{ Tells whether a header is assigned }
function IsWebHeader(const name: string): boolean;
var
  i: longword;
begin
  result:= false;
  if length(hdr) = 0 then exit;
  for i:= 0 to length(hdr) - 1 do if upcase(hdr[i].name) = upcase(name) then
  begin
    result:= true;
    break;
  end;
end;

{ Tells whether a RTI variable exists }
function IsRTI(const name: string): boolean;
var
  i: longword;
begin
  result:= false;
  if length(rti) = 0 then exit;
  for i:= 0 to length(rti) - 1 do if rti[i].name = name then
  begin
    result:= true;
    break;
  end;
end;

{ Tells whether a session variable is assigned }
function IsSess(const name: string): boolean;
var 
  i: longword;
begin
  result:= false;
  if length(sess) = 0 then exit;
  for i:= 0 to length(sess) - 1 do if sess[i].name = name then
  begin
    result:= true;
    break;
  end;
end;

{ Tells whether file field is uploaded }
function IsUpFile(const name: string): boolean;
var 
  i: longword;
begin
  result:= false;
  if length(UpFiles) = 0 then exit;
  for i:= 0 to length(UpFiles) - 1 do if UpFiles[i].name = name then
  begin
    result:= true;
    break;
  end;
end;

{ Tells whether a PWU variable exists, abstract for session, cookie, cgi, etc }
function IsWebVar(const name: string): byte;
var 
  i: longword;
begin
  result:= 0;
  // First looking in vars
  if length(vars) > 0 then
  for i:= 0 to length(vars) - 1 do if vars[i].name = name then
  begin
    result:= 1;
    exit;
  end;
  // Then looking in sess
  if length(sess) > 0 then
  for i:= 0 to length(sess) - 1 do if sess[i].name = name then
  begin
    result:= 2;
    exit;
  end;
  // Then looking in cook
  if length(cook) > 0 then
  for i:= 0 to length(cook) - 1 do if cook[i].name = name then
  begin
    result:= 3;
    exit;
  end;
  // Then looking in cgi
  if length(cgi) > 0 then
  for i:= 0 to length(cgi) - 1 do if cgi[i].name = name then
  begin
    result:= 4;
    exit;
  end;
end;

{ Replaces all end-of-line chars with <br /> tags }
function LineEndToBR(const s: string): string;
begin
  result:= s;
  if substrexists(result, #13+#10) then
    result:= substrreplace(result, #13+#10, '<br />');
  if substrexists(result, #10) then
    result:= substrreplace(result, #10, '<br />');
end;

{ Plain text output }
procedure WebWrite(const s: string);
begin
 {$IFDEF G_ZIP}
  if output_buffering then
  begin
    // Append str to buffer
    OutBuff^.AppendStr(s);
  end else
 {$ENDIF}
  begin
    if not headers_sent then SendWebHeaders;
    NativeWrite(s);
  end;
end;

{ Output several arguments at once, multiple types allowed }
procedure WebWriteA(args: array of const);
var i: longint;  
begin  
  if high(Args)<0 then 
    webwrite('')  
  else
  begin
    //  debugln('WebWriteA: total, ' + inttostr(High(Args)+1) +' arguments');  
    for i:=0 to high(Args) do  
    begin  
      case Args[i].vtype of  
        vtinteger    :  
          webwrite(inttostr(args[i].vinteger));  
        vtboolean    :  
          webwrite(booltostr(args[i].vboolean));  
        vtchar       :  
          webwrite(string(args[i].vchar));  
        vtextended   :  
          webwrite(FormatFloat('', args[i].VExtended^));  // i.e float value
        vtString     :  
          webwrite(args[i].VString^);  
        vtPChar      :  
          webwrite(Args[i].VPChar);  
        vtAnsiString :  
          webwrite(AnsiString(Args[I].VAnsiString));
      else  
          debugln ('WebWriteA:’Unknown type in array of const parameter'{ + args[i].vtype});  
      end;  
    end;  
  end;
end;

{ PWU-formatted output $MacroVariables.  As opposed to WebWriteFF, this
  function trims (deletes) malicious characters. It does not replace them with
  html equivilents. F suffix stands for "formatted"
  Default security level: 2, trim }
procedure WebWriteF(const s: string);
begin
  WebWriteF_Fi(s, false{filter OFF});
end;

{ PWU-formatted output $MacroVariables. As opposed to WebWriteF, this function
  fiters and does replace malicious characters with HTML equivilents, rather
  than deleting them.  FF suffix stands for "format and filter".
  Default security level: 2, filter }
procedure WebWriteFF(const s: string);
begin
  WebWriteF_Fi(s, true {filter ON});
end;

{ Powers the WebWriteF and WebWriteFF functions
  With specifiable filter option for malicious input. If FilterTheHTML is true
  then the malicious input and special characters are replaced with HTML
  equivilents. If false, the malious input is trimmed (deleted). If you don't
  want trimming or filtering at all, see WebFormat_SF and use it instead. }
procedure WebWriteF_Fi(const s: string; const HTMLFilter: boolean);
begin
  if HTMLFilter = true then
    WebWrite(WebFormatAndFilter(s))
  else
    WebWrite(WebFormat(s));
end;

{ Plain output with line feed, no html break }
procedure WebWriteLn(const s: string);
begin
  WebWrite(s + CGI_CRLF);
end;


(* formatted writeln, outputs variables like macros. i.e. replaces {$Var}
   with an existing web variable. Trims malicious attempts by deleting special
   characters. F stands for "Formatted". If you don't want trimming, see
   WebWriteLnFF which filters instead. *)
procedure WebWriteLnF(const s: string);
begin
  WebWriteLnF_Fi(s, false);
end;

(* formatted and filtered writeln, outputs variables like macros,
   i.e. replaces {$MyVar} with an existing web variable, plus filters
   malicious attempts by filtering HTML special characters.
   FF stands for "Formatted and Filtered" *)
procedure WebWriteLnFF(const s: string);
begin
  WebWriteLnF_Fi(s, true);
end;


(* powers the WebWriteLnF and WebWriteLnFF functions, and is to be used for
   more control when webwritelnf and webwritelnff are too limiting.
   If FilterTheHTML option is on, then the template is filtered first and
   special characters are is replaced with HTML equivilents
   F stands for "Formatted", while _Fi stands for "Filter input options" *)
procedure WebWriteLnF_Fi(const s: string; const HTMLFilter: boolean );
var
  FormattedStr: string;
begin

  if HTMLFilter = true then
    FormattedStr:= WebFormatAndFilter(s)
  else
    FormattedStr:= WebFormat(s);

 {$IFDEF G_ZIP}
  if output_buffering then
  begin

    // Append str to buffer
    OutBuff^.AppendStr(FormattedStr);
    // Append end of line
    OutBuff^.AppendLineFeed;
  end
    else
 {$ENDIF}
  begin
    if not headers_sent then SendWebHeaders;
    NativeWrite(FormattedStr + CGI_CRLF);
  end;
end;

{ Plain file output - returns error if file not found (see pwuErrors)  }
function WebFileOut(const fname: string): errcode;
var
  fh: text;
  s: string;
begin
  result:= GENERAL_ERR; 
  if not FileExists_read(fname) then
  begin
//    ThrowWebError('File does not exist: ' + fname); // todo: in throwweberror offer logerr.txt style debugging
    result:= FILE_READ_ERR;
    exit;
  end;
  if (not headers_sent) {$IFDEF G_ZIP} and (not output_buffering) {$ENDIF} then
    SendWebHeaders;
                
  assign(fh, fname);
  reset(fh);
  while not eof(fh) do
  begin
    readln(fh, s);
   {$IFDEF G_ZIP}
    if output_buffering then
    begin
      // Append str to buffer
      OutBuff^.AppendStr(S);
      // Append end of line
      OutBuff^.AppendLineFeed;
    end else
   {$ENDIF G_ZIP}
      NativeWrite(s + CGI_CRLF);
  end;
  close(fh);
  result:= ok; 
end;

{ Binary Buffer Output...UNTYPED }
procedure WebBufferOut(Const Buff; BuffLength : LongWord);
Var 
 P : Pointer;
begin
  P := @Buff;
  if (not headers_sent){$IFDEF G_ZIP} and (not output_buffering){$ENDIF} then
    SendWebHeaders;
 {$IFDEF G_ZIP}
 if output_buffering then
    begin
      OutBuff^.AppendBuffer(P, BuffLength);
    end
  else
 {$ENDIF}
    NativeWrite(P, BuffLength);
end;

{ Plain binary file output }
function WebResourceOut(const fname: string): errcode;
CONST
 BUFFSIZE = 16384;

var
      fh: file of char;
    buff: ^char;
     len: longword;

begin
  result:= GENERAL_ERR;
  if not FileExists_read(fname) then
  begin
//    ThrowWebError('File does not exist: ' + fname); // todo: offer errorlog.txt style debugging
    result:= FILE_READ_ERR;    
    exit;
  end;
  GetMem(buff, BUFFSIZE);
  if (not headers_sent) then SetWebHeader('Content-Type', GetMimeType(fname));
  if (not headers_sent){$IFDEF G_ZIP} and (not output_buffering){$ENDIF} then
    SendWebHeaders;
  assign(fh, fname);
  reset(fh);
  while not eof(fh) do
    begin
      blockread(fh, buff^, BUFFSIZE, len);
      {$IFDEF G_ZIP}
      if output_buffering then
        begin
          OutBuff^.AppendBuffer(buff,len);
        end
        else
      {$ENDIF}
         NativeWrite(Buff, len);
     end;  {while}
  close(fh);
  FreeMem(Buff);
  result:= ok;
end;

{ Formatted file output (macro variables such as $Var). If HTMLFilter is
  true, then any malicious characters from the incoming variables, are replaced
  with html equivalents. If false, then malicious characters are trimmed
  (deleted) without being replaced.

  i.e. if an incoming variable $EditInput contains malicious characters, they
  are either trimmed or they are filtered, depending on which FilterOption you
  choose. The actual TEMPLATE itself is not filtered or trimmed of malicious
  input. You are responsible for the template being safe on your server.
  If someone somehow manages to change your template file and inputs malicious
  characters, this is basically impossible to secure down. If you are worried
  about this, don't use templates. Generally, it is not a worry - someone would
  have to first manage to get control of your template file. Template files
  are dynamic text files. Anything dynamic in text file format is less secure,
  just like a PHP script is less secure than a binary executable. PHP scripts
  are MUCH less secure than PSP/PWU templates.
  }
function WebTemplateOut(const fname: string; const HTMLFilter: boolean): errcode;
var
  fh: text;
  s: string;
begin
  result:= GENERAL_ERR;
  if not FileExists_read(fname) then
  begin
//     ThrowWebError('File does not exist: ' + fname); // todo: offer errorlog.txt style debugging
     result:= FILE_READ_ERR;
     exit;
  end;
  if (not headers_sent)
  {$IFDEF G_ZIP} and (not output_buffering){$ENDIF}
  then
    SendWebHeaders;
  assign(fh, fname);
  reset(fh);
  while not eof(fh) do
  begin
    readln(fh, s);
   {$IFDEF G_ZIP}
    if output_buffering then
    begin
      if HTMLFilter = true then
        s:= WebFormatAndFilter(s)
      else                    
        s:= WebFormat(s);

      // Append str to buffer
      OutBuff^.AppendStr(S);
      // Append end of line
      OutBuff^.AppendLineFeed;
    end else
   {$ENDIF G_ZIP}
      if HTMLFilter = true then
        NativeWrite(WebFormatAndFilter(s) + CGI_CRLF)
      else
        NativeWrite(WebFormat(s) + CGI_CRLF);
    
  end;
  close(fh);
  result:= ok;
end;


{ Raw template output. Similar to WebTemplateOut but NO filtering or trimming
  is perfomed on the macro variables.
  
  Insecure, only use when you wish HTML to be output as raw HTML. People can
  inject javascript and other stuff into URL variables if you use RAW template
  output}
function WebTemplateRaw(const fname: string): errcode;
var
  fh: text;
  s: string;
begin
  result:= GENERAL_ERR;
  if not FileExists_read(fname) then
  begin
//     ThrowWebError('File does not exist: ' + fname); // todo: offer errorlog.txt style debugging
     result:= FILE_READ_ERR;
     exit;
  end;
  if (not headers_sent)
  {$IFDEF G_ZIP} and (not output_buffering){$ENDIF}
  then
    SendWebHeaders;
  assign(fh, fname);
  reset(fh);
  while not eof(fh) do
  begin
    readln(fh, s);
   {$IFDEF G_ZIP}
    if output_buffering then
    begin
      s:= WebFormat_SF(s, false, 0, 0); //security is 0, RAW output
      // Append str to buffer
      OutBuff^.AppendStr(S);
      // Append end of line
      OutBuff^.AppendLineFeed;
    end
   {$ENDIF}
      else
        NativeWrite(WebFormat(s) + CGI_CRLF);
  end;
  close(fh);
  result:= OK;  
end;

{ Sets HTTP header like 'Name: Value' }
function PutWebHeader(const header: string): boolean;
var 
  i: longword;
  nv: TStrArray;
begin
  result:= false;
  // Check headers
  if headers_sent then
  begin
    ThrowWebError('Can''t set header - headers already sent');
    exit(false);
  end;
  // Splitting into name=value pair
  nv:= substrsplit(header, ':');
  if length(nv) <> 2 then exit;
  nv[0]:= strtrim(nv[0]);
  nv[1]:= strtrim(nv[1]);
  // Changing value if already set
  if length(hdr) > 0 then
  for i:= 0 to length(hdr) - 1 do if upcase(hdr[i].name) = upcase(nv[0]) then
  begin
    hdr[i].value:= nv[1];
    exit;
  end;
  // Or setting new header
  SetLength(hdr, length(hdr) + 1);
  hdr[length(hdr) - 1].name:= nv[0];
  hdr[length(hdr) - 1].value:= nv[1];
  result:= true;
end;

{ Generates a random string of alphanumeric and '_' characters with specified
  length }
function RandomStr(len: longint): string;
const
  PW_CHARS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_';
var 
  i: longword;
begin
  SetLength(result, len);
  for i:= 1 to len do
  begin
      randomize;
      result[i]:= PW_CHARS[random(62) + 1];
  end;
end;

{ Saves uploaded file to disk }
function SaveUpFile(const name, fname: string): boolean;
var 
  i: longword;
  fh: File of char;
  writeresult : boolean;

begin
  result:= false;
  if length(UpFiles) = 0 then exit;
  writeresult := false;
  {$I-}
  assign(fh, fname);
  rewrite(fh);
  I := 0;
  repeat
    if UpFiles[i].name = name then 
      begin
        If Length(UpFiles[i].Data) > 0 then
           begin
             blockwrite(fh, UpFiles[i].data[1],UpFiles[i].size);
             if ioresult = 0 then writeresult := true;
           end;
      end;
   Inc(I);
  until (I = Length(UpFiles)) or WriteResult;
  close(fh);
  result := writeresult;
  {$I+}
end;

{ Destroys currently registered session }
function SessDestroy: boolean;
var
  SessTable, key, sid: string;
  res: SDS_Result;
begin
  result:= false;
  // Checking
  SessTable:= GetWebConfigVar('session_path');
  if not FileExists(SessTable) then exit(false);
  // Checking if registered
  if not IsCookie('PWUSESS') then exit(false);
  // Extracting key and id
  key:= Base64Decode(GetCookie('PWUSESS'));
  sid:= sdsmain.Escape(copy(key, 13, length(key) - 12));
  key:= sdsmain.Escape(copy(key, 1, 12));
  // Running query
  res:= sdsmain.Query('DELETE FROM `' + SessTable + '` WHERE id = ' + sid + ' AND key = "' + key + '"');
  if sdsmain.ResultRows(res) = 1 then result:= true;
  sdsmain.FreeResult(res);
  // Unset sess
  SetLength(sess, 0);
end;

{ Dynamically sets configuration variable name and value }
function SetWebConfigVar(const name, value: string): boolean;
var 
  i: longword;
begin
  result:= false;
  // Specific behaviour
  if name = 'header_charset' then
  begin
    // Charset can be set before sending headers
    if headers_sent then ThrowWebError('CONFIG ERR: header_charset configured before headers set');
    exit(false);
  end else if name = 'error_reporting' then
  begin
    // Setting internal flag
    if lowercase(value) = 'on' then error_reporting:= true else error_reporting:= false;
  end else if name = 'error_halt' then
  begin
    // Setting internal flag
    if lowercase(value) = 'on' then error_halt:= true else error_halt:= false;
  end
 {$IFDEF G_ZIP}
  else if name = 'output_buffering' then
  begin
    // Setting internal flag and applying checks
    if lowercase(value) = 'on' then
    begin
      if not output_buffering then output_buffering:= true;
    end
    else
    begin
      if output_buffering then FlushBuffer;
      output_buffering:= false;
    end;
  end else if name = 'output_compression' then
  begin
    // Setting internal flag and applying checks
    if lowercase(value) = 'on' then
    begin
      if not output_buffering then
      begin
        ThrowWebError('Config ERR: output_compression can''t be used without output_buffering');
        exit(false);
      end;
      if headers_sent then
      begin
        ThrowWebError('CONFIG ERR: output_compression can''t be enabled before headers sent');
        exit(false);
      end;
      output_compression:= true;
    end else
    begin
      if headers_sent then
      begin
        ThrowWebError('CONFIG ERR: output_compression can''t be disabled before headers sent');
        exit(false);
      end;
      if output_compression then
        UnsetWebHeader('Content-Encoding');
      output_compression:= false;
    end;
  end
 {$ENDIF G_ZIP}
  else
    if (name = 'session_path') or (name = 'session_life_time') then
    begin
      // Vain calls
      ThrowWebError('Config warning: runtime configuration of session_path and session_life_time has no effect');
      exit(false);
    end else if name = 'upload_max_size' then
    begin
      // Vain call
      ThrowWebError('Config warning: runtime configuration of upload_max_size has no effect');
      exit(false);
    end;
  // Changing value if already set
  if length(conf) > 0 then
  for i:= 0 to length(conf) - 1 do if conf[i].name = name then
  begin
    conf[i].value:= value;
    exit;
  end;

  // Setting a new config variable is possible
  SetLength(conf, length(conf) + 1);
  conf[length(conf) - 1].name:= name;
  conf[length(conf) - 1].value:= value;
  result:= true;
end;

{ Sets a cookie }
function SetCookie(const name, value: string): boolean;
var 
  i: longword;
begin
  result:= false;
  // Check headers
  if headers_sent then
  begin
    ThrowWebError('Can''t set cookie: headers already sent');
    exit(false);
  end;
  // Changing value if already set
  if length(cook) > 0 then
  for i:= 0 to length(cook) - 1 do if cook[i].name = name then
  begin
    cook[i].value:= value;
    exit;
  end;
  // Or setting new one
  SetLength(cook, length(cook) + 1);
  cook[length(cook) - 1].name:= name;
  cook[length(cook) - 1].value:= value;
  // Adding the header
  SetLength(hdr, length(hdr) + 1);
  hdr[length(hdr) - 1].name:= 'Set-Cookie';
  hdr[length(hdr) - 1].value:= UrlEncode(name) + '=' + UrlEncode(value) + ';path=/;expires=Mon, 01 Dec 2020 12:00:00 GMT';
  result:= true;
end;

{ Sets a cookie as double precision float }
function SetCookieAsFloat(const name: string; value: double): boolean;
var
  s: string;
begin
  str(value, s);
  result:= SetCookie(name, s);
end;

{ Sets a cookie as integer }
function SetCookieAsInt(const name: string; value: longint): boolean;
var
  s: string;
begin
  str(value, s);
  result:= SetCookie(name, s);
end;

{ Sets an extended cookie }
function SetCookieEx(const name, value, path, domain, expires: string): boolean;
var 
  i: longword;
begin
  result:= false;
  // Check headers
  if headers_sent then
  begin
    ThrowWebError('Can''t set cookie: headers already sent');
    exit(false);
  end;
  // Changing value if already set
  if length(cook) > 0 then
  for i:= 0 to length(cook) - 1 do if cook[i].name = name then
  begin
    cook[i].value:= value;
    exit;
  end;
  // Or setting new one
  SetLength(cook, length(cook) + 1);
  cook[length(cook) - 1].name:= name;
  cook[length(cook) - 1].value:= value;
  // Adding the header
  SetLength(hdr, length(hdr) + 1);
  hdr[length(hdr) - 1].name:= 'Set-Cookie';
  hdr[length(hdr) - 1].value:= UrlEncode(name) + '=' + UrlEncode(value) + ';path=' + path + ';domain=' + domain + ';expires=' + expires;
  result:= true;
end;

{ Sets an extended cookie as double precision float }
function SetCookieAsFloatEx(const name: string; value: double; const path, domain, expires: string): boolean;
var
  s: string;
begin
  str(value, s);
  result:= SetCookieEx(name, s, path, domain, expires);
end;

{ Sets an extended cookie as integer }
function SetCookieAsIntEx(const name: string; value: longint; const path, domain, expires: string): boolean;
var
  s: string;
begin
  str(value, s);
  result:= SetCookieEx(name, s, path, domain, expires);
end;


{ Sets HTTP header }
function SetWebHeader(const name, value: string): boolean;
var 
  i: longword;
begin
  result:= false;
  // Check headers
  if headers_sent then
  begin
    ThrowWebError('Can''t set header: headers already sent');
    exit(false);
  end;
  // Changing value if already set
  if length(hdr) > 0 then
  for i:= 0 to length(hdr) - 1 do
    if upcase(hdr[i].name) = upcase(name) then
    begin
      hdr[i].value:= value;
      exit;
    end;
  // Or setting new one
  SetLength(hdr, length(hdr) + 1);
  hdr[length(hdr) - 1].name:= name;
  hdr[length(hdr) - 1].value:= value;
  result:= true;
end;

{ Sets session variable }
function SetSess(const name, value: string): boolean;
var 
  i: longword;
begin
  result:= false;
  // Check
  if headers_sent then
  begin
    ThrowWebError('Setting session data after headers sent has no effect');
    exit(false);
  end;
  // Changing value if already set
  if length(sess) > 0 then
  for i:= 0 to length(sess) - 1 do
    if sess[i].name = name then
    begin
      sess[i].value:= value;
      exit;
    end;
  // Or, if setting a new one
  SetLength(sess, length(sess) + 1);
  sess[length(sess) - 1].name:= name;
  sess[length(sess) - 1].value:= value;
  result:= true;
end;

{ Sets session variable as double precision float }
function SetSessAsFloat(const name: string; value: double): boolean;
var
  s: string;
begin
  str(value, s);
  result:= SetSess(name, s);
end;

{ Sets session variable as integer }
function SetSessAsInt(const name: string; value: longint): boolean;
var
  s: string;
begin
  str(value, s);
  result:= SetSess(name, s);
end;


(* Assigns PWU variable. i.e. macro variables in templates and formated output
   such as $SomeVar and {$SomeVar} *)
procedure SetWebVar(const name, value: string);
var 
  i: longword;
begin
  // Changing value if already set
  if length(vars) > 0 then
  for i:= 0 to length(vars) - 1 do if vars[i].name = name then
  begin
    vars[i].value:= value;
    exit;
  end;
  // Or setting new one
  SetLength(vars, length(vars) + 1);
  vars[length(vars) - 1].name:= name;
  vars[length(vars) - 1].value:= value;
end;

{ Assigns PWU variable as double precision float }
procedure SetWebVarAsFloat(const name: string; value: double);
var
  s: string;
begin
  str(value, s);
  SetWebVar(name, s);
end;

{ Assigns PWU variable as integer }
procedure SetWebVarAsInt(const name: string; value: longint);
var
  s: string;
begin
  str(value, s);
  SetWebVar(name, s);
end;

{ Throws PWU error if error reporting is on in config file }
function ThrowWebError(const ErrMessage: string): boolean;  
var
  i: longint;
  s: string;
begin
  // Init
  result:= false;
  // Increase ERRORs RTI
  i:= GetRTIAsInt('ERRORS');
  inc(i);
  str(i, s);
  SetRTI('ERRORS', s);
  if not error_reporting then exit(true);
  // Disable content encoding
  if IsWebHeader('Content-Encoding') then
    UnsetWebHeader('Content-Encoding');
  // Send headers
  if not headers_sent then
    SendWebHeaders;
  // Flush the buffer
 {$IFDEF G_ZIP}
  if output_buffering then FlushBuffer;
 {$ENDIF}
  // Adjusting error message
  WebWriteln('<br>ERR: ' + ErrMessage + '<p />'); //error on its own line
  if error_halt then halt(0);
  // Done
  result:= true;
end;

{ Trims (deletes) all bad, unsecure characters from a string.
  i.e. hackers sometimes use pipe characters | or ../../ to try to hack the
  server. Mainly useful for trimming URL variables for malicious attempts.
  Note: see also FilterHTML, which replaces characters with real output such
        as &gt; &quot;

 Default security level: 2 }
function TrimBadChars(const input: string): string;
begin
  result:= TrimBadChars_S(input, 2);
end;

{ Trims (deletes) all bad, unsecure characters from a string that is being used
  for filenames. For example, if you are opening a file, you will want the
  file name in a local directory, only characters like A-Z plus dots and
  brackets, but not things like pipe characters and dollar signs, as a pipe
  could cause a command to be injected if calling Exec() and user input is
  connected to the command some way. Trims slashes because slashes could allow
  one to retrieve files from other directories on the system }
function TrimBadChars_file(const input: string): string;
begin
//    result:= substrreplace(result,'.', '',[rfReplaceAll]);  // Dot is okay
//    result:= substrreplace(result,'~', '',[rfReplaceAll]);  // Squiggly ~ character is okay for filenames
    result:= substrreplace(input,'/',   ' ');     // slashes NOT okay. safe means local directory only!
    result:= substrreplace(result,'\',  ' ');    // slashes NOT okay. safe means local directory only!
    result:= substrreplace(result,'|',  ' ');    // pipe character bad
    result:= substrreplace(result,'#',  ' ');
    result:= substrreplace(result,'@',  ' ');    
    result:= substrreplace(result,'$',  ' ');
    result:= substrreplace(result,'!',  ' ');
    result:= substrreplace(result,'%',  ' ');
    result:= substrreplace(result,'^',  ' ');
    result:= substrreplace(result,'&',  ' ');
    result:= substrreplace(result,'*',  ' ');
    result:= substrreplace(result,'=',  ' ');
    result:= substrreplace(result,'`',  ' ');
    result:= substrreplace(result,'?',  ' ');
    result:= substrreplace(result,'"',  ' ');   // double quote
    result:= substrreplace(result,'''', ' ');  // single quote
    result:= substrreplace(result,'[',  ' ');   // square bracket open
    result:= substrreplace(result,']',  ' ');   // square bracket close
    result:= substrreplace(result,'>',  ' ');   // greater than
    result:= substrreplace(result,'<',  ' ');   // less than
    result:= substrreplace(result,',',  ' ');   // comma
end;

{ Trims (deletes) all bad, unsecure characters from a string that is being used
  for a directory. For example, if you are opening a directory or file and
  directory, you will want only characters like A-Z, plus dots, slashes, and
  brackets, but not things like pipe characters and quotations }
function TrimBadChars_dir(const input: string): string;
begin
//    result:= substrreplace(result,'.', '');  // Dot is okay
//    result:= substrreplace(result,'~', '');  // Squiggly ~ character is okay for filenames
//    result:= substrreplace(result,'/', '',);   //slashes okay
//    result:= substrreplace(result,'\', '');  //slashes okay
    result:= substrreplace(input,  '|', ' ');
    result:= substrreplace(result, '#', ' ');
    result:= substrreplace(result, '@', ' ');
    result:= substrreplace(result, '$', ' ');
    result:= substrreplace(result, '!', ' ');
    result:= substrreplace(result, '%', ' ');
    result:= substrreplace(result, '^', ' ');
    result:= substrreplace(result, '&', ' ');
    result:= substrreplace(result, '*', ' ');
    result:= substrreplace(result, '=', ' ');
    result:= substrreplace(result, '`', ' ');
    result:= substrreplace(result, '?', ' ');
    result:= substrreplace(result, '"', ' ');   // double quote
    result:= substrreplace(result, '''',' ');  // single quote
    result:= substrreplace(result, '[', ' ');   // square bracket open
    result:= substrreplace(result, ']', ' ');   // square bracket close
    result:= substrreplace(result, '>', ' ');   // greater than
    result:= substrreplace(result, '<', ' ');   // less than
    result:= substrreplace(result, ',', ' ');   // comma
end;

{ Powers the TrimBadChars function. Ability to define security level

  Security level 1: Trims bad (malicious) charachers
  Security level 2:  Even more are trimmed than in security level 1 }
function TrimBadChars_S(const input: string; const SecureLevel: integer): string;
begin

  if SecureLevel = 1 then
  begin
    result:= substrreplace(result, #0,  ' ');   //null character
    result:= substrreplace(input,  '/', ' ');   //slashes bad
    result:= substrreplace(result, '\', ' ');
    result:= substrreplace(result, '|', ' ');  //pipe character bad
    result:= substrreplace(result, '?', ' ');
    result:= substrreplace(result, '$', ' ');
    result:= substrreplace(result, '&', ' ');
    result:= substrreplace(result, '<', ' ');
    result:= substrreplace(result, '>', ' ');
    exit;
  end;

  if SecureLevel = 2 then
  begin
    result:= substrreplace(result,  #0, ' ');  // null character
    result:= substrreplace(input, '/',  ' ');  // slashes bad
    result:= substrreplace(result, '\', ' ');
    result:= substrreplace(result, '|', ' ');  // pipe character bad
    result:= substrreplace(result, '?', ' ');
    result:= substrreplace(result, '$', ' ');
    result:= substrreplace(result, '<', ' ');
    result:= substrreplace(result, '>', ' ');
    result:= substrreplace(result, '#', ' ');
    result:= substrreplace(result, '@', ' ');
    result:= substrreplace(result, '!', ' ');
    result:= substrreplace(result, '%', ' ');
    result:= substrreplace(result, '^', ' ');
    result:= substrreplace(result, '&', ' ');
    result:= substrreplace(result, '*', ' ');
    result:= substrreplace(result, '=', ' ');
    result:= substrreplace(result, '~', ' ');
    result:= substrreplace(result, '(', ' ');
    result:= substrreplace(result, ')', ' ');
    result:= substrreplace(result, '[', ' ');
    result:= substrreplace(result, ']', ' ');
    result:= substrreplace(result, '`', ' ');  // backquote
    result:= substrreplace(result, '"', ' ');  // double quote
    result:= substrreplace(result, '''',' ');  // single quote
    exit;
  end;
  
end;

{ Unsets a cookie }
function UnsetCookie(const name: string): boolean;
var
  tmp: TWebVariables;
  i: longword;
begin
  result:= false;
  // Header check
  if headers_sent then
  begin
    ThrowWebError('Can''t unset cookie: headers already sent');
    exit(false);
  end;
  // First removing from the list
  SetLength(tmp, 0);
  if length(cook) > 0 then
  for i:= 0 to length(cook) - 1 do if cook[i].name <> name then
  begin
    SetLength(tmp, length(tmp) + 1);
    tmp[length(tmp) - 1]:= cook[i];
  end;
  // Swap
  cook:= tmp;
  // The setting a removing header
  SetLength(hdr, length(hdr) + 1);
  hdr[length(hdr) - 1].name:= 'Set-Cookie';
  hdr[length(hdr) - 1].value:= UrlEncode(name) + '=;path=/;expires=Fri, 26 Aug 2005 12:00:00 GMT';
  result:= true;
end;

{ Unsets extended cookie }
function UnsetCookieEx(const name, path, domain: string): boolean;
var
  tmp: TWebVariables;
  i: longword;
begin
  result:= false;
  // Header check
  if headers_sent then
  begin
    ThrowWebError('Can''t unset cookie: headers already sent');
    exit(false);
  end;
  // First removing from the list
  SetLength(tmp, 0);
  if length(cook) > 0 then
  for i:= 0 to length(cook) - 1 do if cook[i].name <> name then
  begin
    SetLength(tmp, length(tmp) + 1);
    tmp[length(tmp) - 1]:= cook[i];
  end;
  // Swap
  cook:= tmp;
  // The setting a removing header
  SetLength(hdr, length(hdr) + 1);
  hdr[length(hdr) - 1].name:= 'Set-Cookie';
  hdr[length(hdr) - 1].value:= UrlEncode(name) + '=;path=' + path + ';domain=' + domain + ';expires=Fri, 26 Aug 2005 12:00:00 GMT';
  result:= true;
end;

{ Removes HTTP header from the list }
function UnsetWebHeader(const name: string): boolean;
var
  tmp: TWebVariables;
  i: longword;
begin
  result:= false;
  // Check
  if headers_sent then
  begin
    ThrowWebError('Unsetting header when headers already sent has no effect');
    exit(false);
  end;
  // First removing from the list
  SetLength(tmp, 0);
  if length(hdr) > 0 then
  for i:= 0 to length(hdr) - 1 do if upcase(hdr[i].name) <> upcase(name) then
  begin
    SetLength(tmp, length(tmp) + 1);
    tmp[length(tmp) - 1]:= hdr[i];
  end;
  // Swap
  hdr:= tmp;
  result:= true;
end;

{ Unsets session variable }
function UnsetSess(const name: string): boolean;
var
  tmp: TWebVariables;
  i: longword;
begin
  result:= false;
  // Check
  if headers_sent then
  begin
    ThrowWebError('Unsetting session data after headers already sent has no effect');
    exit(false);
  end;
  // First removing from the list
  SetLength(tmp, 0);
  if length(sess) > 0 then
  for i:= 0 to length(sess) - 1 do if sess[i].name <> name then
  begin
    SetLength(tmp, length(tmp) + 1);
    tmp[length(tmp) - 1]:= sess[i];
  end;
  // Swap
  sess:= tmp;
  result:= true;
end;

{ Removes PWU variable from the list }
procedure UnsetWebVar(const name: string);
var
  tmp: TWebVariables;
  i: longword;
begin
  // Removing from the list
  SetLength(tmp, 0);
  if length(vars) > 0 then
  for i:= 0 to length(vars) - 1 do if vars[i].name <> name then
  begin
    SetLength(tmp, length(tmp) + 1);
    tmp[length(tmp) - 1]:= vars[i];
  end;
  // Swap
  sess:= tmp;
end;

{ Bytewise XOR encryption }
function XORCrypt(const s: string; key: byte): string;
var
  i,
  len: longword;
begin
  result:= '';
  len:= length(s);
  SetLength(result, len);
  for i:= 1 to len do
    result[i]:= chr(ord(s[i]) xor key);
end;


// END OF PUBLIC FUNCTIONS/PROCEDURES
{------------------------------------------------------------------------------}


{------------------------------------------------------------------------------}
{--- INITIALIZATION/FINALIZATION ----------------------------------------------}
{------------------------------------------------------------------------------}

var
  // temporary string
  tmp: string;
    

initialization
 {$IFDEF PWUDEBUG}
  assign(debugt, 'pwumain.debug.log');                                   
  rewrite(debugt);      
  debugln('----DEBUG LOG----');
  flush(debugt);
 {$ENDIF}

  // Init variables
  headers_sent:= false;
  // Init some defaults
  InitRTI;
                                                                                 // debug hostgator - GOOD ABOVE
  // Load up the config, print regular text error if not found                   // problem: on hostgator server it does NOT LIKE pwu-unix.conf and crashes! On local fakelinux, pwu-unix.conf is fine. On hostgator pwu_unix.conf seems to work fine. Something funny with the dash in files that certain servers do not like?
  if not ParseWebConfig then
  begin
    ErrorHeader;
    NativeWrite('ERR 1A see docs'); // can't find config file in global, local, or system path
    halt;
  end;
 {$IFDEF G_ZIP}
  if (output_buffering) and (output_compression) then 
    OutBuff := New(PSmartBuffer, DynamicBuffer(8192));
 {$ENDIF}  
                                                                                 // debug hostgator - BAD ABOVE
  // Initialize the main headers since now there aren't any errors above
  InitWebHeaders;

  // Load all available data
  if not GetWebData then
    ThrowWebError('Failed to receive data from server');


finalization

 {$IFDEF G_ZIP}
  // Set content length if it can be set this way
  if (output_buffering) and (output_compression) and (not headers_sent) and (OutBuff^.Used > 0) then
  begin
    OutBuff^.gzip;
    str(OutBuff^.Used, tmp);
    SetWebHeader('Content-Length', tmp);
  end;
 {$ENDIF}
  // Send headers if not sent already
  if not headers_sent then SendWebHeaders;

 {$IFDEF G_ZIP}
  // Send buffer if not sent already
  // if OutBuff^.Used <> 0 then OutBuff^.Flush;
  if (output_buffering) and (output_compression) then dispose(OutBuff, Destroy);
 {$ENDIF}      

 {$IFDEF PWUDEBUG}
   close(debugt);    
 {$ENDIF}
end.


