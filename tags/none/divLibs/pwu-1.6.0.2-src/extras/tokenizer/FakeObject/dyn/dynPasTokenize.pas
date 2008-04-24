{*******************************************************************************

                               PasTokenizer Project

********************************************************************************
 Pascal tokenizer dynamic DLL interface

 Authors: Lars (L505)

 Version: 1.0a
 Site: http://z505.com
*******************************************************************************}
unit dynPasTokenize;


{$ifdef fpc}
 {$mode objfpc} {$h+}
{$endif}

{$define debug} //put this on for error logging

interface

uses
  dynpwu, // memory sharing from cgi dll
  multitype,
  compactutils,
  tokentypes,
 {$ifdef fpc}
   dynlibs {$else}windows
 {$endif};

var 
  H: tlibhandle;

const 
  LIB = 'PasTok_libfpc';
const
  fmOpenRead = 0;
  fmReadWrite = 2;

type 
  PByteArray = ^TByteArray;
  TByteArray = array[0..maxint -1] of byte;
  TEndOfLine = (eolCRLF, eolLF);
  astr = ansistring;

{$i ..\ChrStrmDef.inc}

var
{ constructor }
  NewChrFileStrm1: function (const filename: string): PChrStrm;
  NewChrStrStrm: function (const s: string): PChrStrm;
{ destructor }
  FreeChrStrStrm: procedure (ChrStrm: PChrStrm);
  FreeChrFileStrm: procedure (ChrStrm: PChrStrm);

{$i ..\PasParserDef.inc}

{ constructor/destructor }
var
  NewPasParser: function (aInStm: PChrStrm): PPasParser;
  FreePasParser: procedure (PasParser: PPasParser);


implementation


{$ifdef debug}
var
  t: text;
{$endif}
initialization
{$ifdef debug}
  assign(t, 'debug.log');
  rewrite(t);
{$endif}
  
  H:= loadlibrary(LIB);
  if H = nilhandle then halt;

  pointer(NewChrFileStrm1):= GetProcAddress(H, 'NewChrFileStrm1');
  pointer(NewChrStrStrm):= GetProcAddress(H, 'NewChrStrStrm');
  pointer(FreeChrStrStrm):= GetProcAddress(H,'FreeChrStrStrm');
  pointer(FreeChrFileStrm):= GetProcAddress(H, 'FreeChrFileStrm');
  pointer(NewPasParser):= GetProcAddress(H, 'NewPasParser');
  pointer(FreePasParser):= GetProcAddress(H, 'FreePasParser');
{$ifdef debug}
  if pointer(NewChrFileStrm1) = nil then writeln(t, 'GetProc Err: NewChrFileStrm1');
  if pointer(NewChrStrStrm) = nil then writeln(t, 'GetProc Err: NewChrStrStrm');
  if pointer(FreeChrStrStrm) = nil then writeln(t, 'getproc err freecharstrstrm');
  if pointer(FreeChrFileStrm) = nil then writeln(t, 'getproc err frechrfilestrm');
  if pointer(NewPasParser) = nil then writeln(t, 'getproc err newpasparser'); 
  if pointer(FreePasParser) = nil then writeln(t, 'getproc err freepasparser');  
{$endif}

finalization
  if H <> nilhandle then freelibrary(H);
{$ifdef debug}
  close(t);
{$endif}

end.