{ special memory sharing unit that allows memory to be shared with main
  pwu library }
unit pwumemshare;
{$ifdef fpc} {$mode objfpc}{h+} {$endif}
interface
uses
  strwrap1,
 {$ifdef fpc}
  dynlibs; {$else} windows;
 {$endif}

const
 {$ifdef UNIX}
  PWU_CONFIG_FILE = 'pwu_unix.conf';
 {$endif}
 {$ifdef WIN32}
  PWU_CONFIG_FILE = 'pwu_win.conf';
 {$endif}


// procedure to get memory manager from library
type 
  TGetMemMan = procedure (out MemMan : TMemoryManager); stdcall;
var 
  GetMemMan: TGetMemMan;



var LibHandle: longint;
var LibMemMan : TMemoryManager; // buffer for imported memory manager
var OldMemMan: TMemoryManager; // buffer for old memory manager

implementation

{$i ../../../../version/version.inc} //exact pwu version


{ Throw an error and display it in the web browser telling user exact problem }
procedure ThrowLibError(const ErrMessage: string);
begin
  WriteLn('Content-Type: text/html'); //must have a header since not init yet
  WriteLn;
  Write( 'ERR ' + ErrMessage);
  halt;
end;


var
  LibPath: string;


{$ifndef fpc}
const nilhandle = 0;
{$endif}



initialization
//  writeln('Content-Type: text/html'); //must have a header since not init yet
//  writeln;
//  writeln( 'DEBUG DEBUG ' );

  { config file must contain path to library on the first line, similar to a
    bash script with path on first line: #/path/library.so }
  LibPath:= GetLn1(PWU_CONFIG_FILE);
  if pos('#', LibPath) = 1 then delete(LibPath,1,1)   // delete pound sign 
  else 
  begin

  end;

  { check for VERSION (pwu-1.X.X.X) in PWU.conf on Line1. This stops incorrect 
    old 1.5.x config files or incompatible DLL's, i.e 1.7.x  }
  if (pos(PWU_VERSION, LibPath) = 0) or (LibPath = '') then ThrowLibError('0B');  // LUFDOC: ERROR# 0B: PWU config file incorrect, library path or pwu DLL is missing in path, or path is empty

{----- Load Lib ---------------------------------------------------------------}
  LibHandle:= LoadLibrary(LibPath);   //load lib before CGI program runs

{----- Set up a special shared memory manager ---------------------------------}
  GetMemoryManager(OldMemMan); //store old memory manager

  GetMemMan:= TGetMemMan(GetProcAddress(LibHandle, 'GetSharedMemMan'));
 { Get the shared memory manager which is stored in the library itself }
  GetMemMan(LibMemMan);
                                                                               // FEB 12 memory issue below
 { Set gotten memory manager up before import *any* functions from library. }
  SetMemoryManager(LibMemMan);
                                                                                 // FEB 12 memory issue above

finalization
  if LibHandle <> NilHandle then FreeLibrary(LibHandle);
  SetMemoryManager(OldMemMan); // restore original memory manager

end.

