{ dynamic pastokenizer library main source file

  License: NRCOL (public domain)
  Author Lars (L505)
  Site: http://z505.com }

library PasTok_libfpc; {$ifdef fpc} {$mode objfpc} {$h+} {$endif}

{$define pwu} //define this if using a web PWU (cgi) program

uses
 {$ifdef pwu} 
  dynpwu, // forces memory to be shared with PWU dll 
 {$else}   
  memshare1, //  note: if not using a PWU DLL, use a general unit called memshare1.pas which I will have on my website or SVN some time
 {$endif} 
  PasTokenize,
  ChrStream;

exports
  NewChrFileStrm1,
  NewChrStrStrm,
  FreeChrStrStrm,
  FreeChrFileStrm,
  GetChar,
  PutBackChar;

exports
  GetToken,
  NewPasParser,
  FreePasParser;

begin

end.
