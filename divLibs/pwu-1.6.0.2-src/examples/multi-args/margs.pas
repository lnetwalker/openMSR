{ how to send multiple arguments and types into the WebWrite? 
  This demo shows WebWriteA function }
program margs;

{$mode objfpc}{$H+}

uses
 {$ifdef STATIC}
  pwumain;
 {$else}  
  dynpwu;
 {$endif} 

const
  pc: pchar = ' pchar text ';
var
  s: ansistring;
begin
  WebWrite('Simple test <hr>'); 
  WebWrite('<i>Writing multiple types and multiple arguments from one procedure...</i><p>'); 
  s:= ' ansistring ';
  s:= s + 'data ';
  WebWriteA(['ABC ', 123,  pc, 123.456789, s]); // several types at once
  WebWriteA([]); 
  WebWrite('<hr>'); 

end.

