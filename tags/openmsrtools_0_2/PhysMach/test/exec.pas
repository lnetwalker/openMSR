program exec;
{$MODE OBJFPC}{$H+}
uses Unix;

Var	S : string;
	f : text;
	i : integer;

function RunCommand(var j: integer; Command: string):String;
var
file1: text;
s,t: string;

begin
  j:=0;
  popen(file1,Command,'r');
  t:='';
  while not eof(file1) do begin
  ReadLn(File1,s);
  t:=t+s+Chr(10);
  inc(j);
  end;
  pclose(file1);
  RunCommand := t;
end;

begin
	popen(f,'./digitemp.sh','r');
	while not eof (f) do begin
		readln (f,S);
		Writeln ('>',S);
	end;
	pclose(f);
	//s:=RunCommand(i,'ifconfig');
	//writeln(i,s);
end.
