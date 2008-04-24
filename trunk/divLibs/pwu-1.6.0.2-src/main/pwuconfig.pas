unit pwuconfig; {$ifdef fpc} {$mode objfpc}{$H+} {$endif}

interface

function GetCfgPath: string;

implementation

uses
 pwuenvvar,
 fileutil,
 {$IFDEF WIN32}windows{$ENDIF}
 {$IFDEF UNIX}baseunix{$ENDIF} ;

const
  { System-wide configuration directory path on *NIX }
  PWU_SYSCONF_PATH = '/etc/';
 { main configuration file name. }
 {$ifdef UNIX} PWU_CFG_FILE = 'pwu_unix.conf'; {$endif}
 {$ifdef WIN32} PWU_CFG_FILE = 'pwu_win.conf'; {$endif}

var
  debugt: text;
procedure debugln(s: string);
begin
 {$IFDEF PWUDEBUG}
  writeln(debugt, s);    
 {$ENDIF}
end;

function GetCfgPath: string;
var
  global_cfg_path1,
  global_cfg_path2,
  sys_cfg_path,
  tmpstr: string;
const
 {$IFDEF WIN32}
  SLASH = '\';
 {$ENDIF}
 {$IFDEF UNIX}
  SLASH = '/';
 {$ENDIF}
  GLOBAL_CFG_DIR = 'pwu' + SLASH + 'conf' + SLASH; 
begin
  debugln('GetCfgPath begin'); 
  result:= '';
 {$IFDEF WIN32}
  sys_cfg_path:= pwuenvvar.GetEnvVar('WINDIR') + '\' + PWU_CFG_FILE;
 {$ENDIF}
 {$IFDEF UNIX}
  sys_cfg_path:= PWU_SYSCONF_PATH + PWU_CFG_FILE;
 {$ENDIF}
  tmpstr:= GetEnvVar('DOCUMENT_ROOT');
  if tmpstr <> '' then 
  begin
    global_cfg_path1:=  tmpstr + SLASH + '..' + SLASH + GLOBAL_CFG_DIR + PWU_CFG_FILE;
    global_cfg_path2:=  tmpstr + SLASH + GLOBAL_CFG_DIR + PWU_CFG_FILE;
  end else
  begin
    global_cfg_path1:= '';
    global_cfg_path2:= '';
  end;
  debugln('search config path 1: ' + global_cfg_path1);
  debugln('search config path 2: ' + global_cfg_path2);
  
  // First search for config file in current directory
  if FileExists_read(PWU_CFG_FILE) then
    result:= PWU_CFG_FILE
  else     // Try global DOCROOT/../pwu/conf (one back, hidden from public)
    if ( global_cfg_path1 <> '' ) and ( FileExists_read(global_cfg_path1) ) then
      result:= global_cfg_path1
    else   
      // Try global DOCROOT/pwu/conf/ location - http://example.com/pwu/conf/
      if ( global_cfg_path2 <> '' ) and ( FileExists_read(global_cfg_path2) ) then
        result:= global_cfg_path2
      else   // Try system-wide
        if FileExists_read(sys_cfg_path) then
          result:= sys_cfg_path;
  debugln('config path used: ' + result);          
  debugln('GetCfgPath end');   
end;


initialization
{$IFDEF PWUDEBUG}
  assign(debugt, 'pwuconfig.debug.log');
  rewrite(debugt)
{$ENDIF}

finalization
{$IFDEF PWUDEBUG}
  close(debugt);
{$ENDIF}
end.

