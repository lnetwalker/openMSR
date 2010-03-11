program TestCase1;
{$MODE OBJFPC}{$H-}
uses telnetserver;

{ $Id$ }

{ compile with /usr/bin/fpc -Fu.. -gl TestCase1.pas 	}
{ start TestCase1 and do a telnet localhost 45054	}

Procedure interpreter;
var
	Line		: String;
begin
	Line:=TelnetGetData;
	TelnetWriteAnswer(Line+chr(10)+'>');
end;


begin
	writeln('TestCase1,  test telnetserver unit');
	writeln('(c) by Hartmut Eilers, 2008 - released under the GPL V2 or above');
	writeln;
	TelnetInit(45055,'./telnet.log');
	TelnetSetupInterpreter(@interpreter);
	TelnetServeRequest('Telnet TestServer'+chr(10)+'>');

	writeln('bye');
end.

