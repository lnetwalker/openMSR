program TestCase2;
{$MODE OBJFPC}{$H-}
uses exec_io_access;

{ $Id$ }

{ compile with /usr/bin/fpc -Fu.. -gl TestCase3.pas }


begin
	writeln('TestCase3,  test RunCommand via exec_io_access');
	writeln('(c) by Hartmut Eilers, 2008 - released under the GPL V2 or above');
	writeln;
	exec_hwinit('./digitemp.sh:');
	
	writeln(exec_read_analog(11));
	writeln('bye');
end.

