program TestCase2;

uses CommonHelper;

{ $Id$ }

{ compile with /usr/bin/fpc -Fu.. -Fu../../gtk+/qgtk2.pas-0.9/ -Fu../../divLibs/pwu-1.6.0.2-src/main/ -gl TestCase2.pas }


var
	cmd	: String;


begin
	writeln('TestCase2,  test RunCommand via CommonHelper');
	writeln('(c) by Hartmut Eilers, 2008 - released under the GPL V2 or above');
	writeln;
	cmd:='digitemp.sh';
	writeln(RunCommand(cmd));
	writeln('bye');
end.

