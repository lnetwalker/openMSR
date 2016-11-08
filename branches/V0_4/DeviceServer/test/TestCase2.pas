program TestCase2;
{$MODE OBJFPC}{$H-}
uses crt,http_io_access;

{ $Id$ }

{ compile with /usr/bin/fpc -Fu.. -Fu../../PhysMach -Fu../../divLibs/pwu-1.6.0.2-src/main/ -gl TestCase2.pas	}
{ start TestCase2 	}


var
	pause		: LongInt;
	i,k,result	: Byte;
	TmpStr		: String;

begin
	writeln('TestCase2, stress test DeviceServer with http requests');
	writeln('(c) by Hartmut Eilers, 2008 - released under the GPL V2 or above');
	writeln;

	pause:=0;
	TmpStr:='http://localhost:10080/digital/read.html?';
	http_hwinit(TmpStr);
	k:=1000;

	repeat
		for i:=1 to k do begin
			write('Pause :',pause,' Request: ',i); 
			result:=http_read_ports(1);
			writeln(' Result: ',result);
			delay(pause);
		end;
		dec(pause,100);
		inc(k,20);
	until pause<0;;

	writeln('bye');
end.

