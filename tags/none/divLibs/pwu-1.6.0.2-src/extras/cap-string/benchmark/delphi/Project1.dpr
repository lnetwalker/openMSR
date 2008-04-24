program Project1; {$APPTYPE CONSOLE}
uses
  SysUtils, capstr;

function GetTime: string;
begin
  result:= '';
  result:= FormatDateTime('HH:MM:SS', NOW);
end;

const
  MAXCNT = 50000; // lots of concats
  CONCAT1 = 'test123 abcdefgh 123456 test test test test';
  CONCAT2 = ' test';

procedure BigLoopCap;
var
  cs: Tcapstr;
  i: integer;
begin
  writeln('Start time: ', gettime, ' (HH:MM:SS)');
  writeln('Wait...');
  resetbuf(@cs, 81920);// give it a nice chunk size
  for i:= 1 to MAXCNT do
  begin
    addstr(CONCAT1, @cs);
    addstr(CONCAT2, @cs);
  end;
  endupdate(@cs);
  // display a few characters to make compiler know we are using the string
  write(cs.data[cs.strlen - 3]);
  write(cs.data[cs.strlen - 2]);
  write(cs.data[cs.strlen - 1]);
  write(cs.data[cs.strlen]);
  writeln;
  writeln('Finish time: ', gettime);
end;

procedure BigLoopAnsi;
var
  s: ansistring;
  i: integer;
begin
  writeln('Start time: ', gettime, ' (HH:MM:SS)');
  writeln('Wait...');
  s:= '';
  for i:= 1 to MAXCNT do
  begin
    s:= s + CONCAT1 + CONCAT2;
  end;
  // display a few characters to make compiler know we are using the string
  write(s[length(s)- 3]);
  write(s[length(s)- 2]);
  write(s[length(s)- 1]);
  write(s[length(s)]);
  writeln;
  writeln('Finish time: ', gettime);
end;

begin
  writeln('Capstring benchmark 1');
  BigLoopCap;
  writeln;
  writeln('Regular ansistring benchmark 1');
  BigLoopAnsi;
  readln;
end.
