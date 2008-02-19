{$MODE OBJFPC}{$H+}
uses baseunix,unix;
function RunCommand(var j: integer; Command: string):String;
var
file1: text;
s,t: ansistring;
n,err: longint;

begin
  j:=0;
  n:=popen(file1, Command, 'r');

  if n=-1 then
    begin
      err:=errno;
      writeln(n,' ',err);
    end;
  t:='';
  while not eof(file1) do begin
  Readln(File1,s);
  t:=t+s+Chr(10);
  inc(j);
  end;
  pclose(file1);
  RunCommand := t;
end;

var j : integer;
begin
writeln(runcommand(j,'./digitemp.sh'));
end. 

