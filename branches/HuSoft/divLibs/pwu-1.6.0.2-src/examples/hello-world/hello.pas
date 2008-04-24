program Hello;

{$mode objfpc}{$H+}

uses
 {$ifdef STATIC}
  pwumain;
 {$else}  
  dynpwu;
 {$endif} 

begin
  WebWriteln(' Hello! ');
end.

