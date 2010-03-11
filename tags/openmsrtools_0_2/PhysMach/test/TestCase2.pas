program TestCase2;

uses CommonHelper;

{ $Id$ }

{ compile with /usr/bin/fpc -Fu.. -Fu../../gtk+/qgtk2.pas-0.9/ -Fu../../divLibs/pwu-1.6.0.2-src/main/ -gl TestCase2.pas }


var
	cmd	: String;
	i	: LongInt;


begin
	writeln('TestCase2,  test RunCommand via CommonHelper');
	writeln('(c) by Hartmut Eilers, 2008 - released under the GPL V2 or above');
	writeln;

	cmd:='digitemp.sh';
	for i:=1 to 1000 do begin
		writeln('counter=',i,' Value=',RunCommand(cmd));
	end;

	writeln('bye');
end.

