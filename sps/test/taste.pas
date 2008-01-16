program Tasten;

uses crt,linux;

var taste : byte;

begin
	repeat
		taste:=ord(readkey);
		write(taste);
		if (taste=0) then begin
			taste:=ord(readkey);	
			writeln(' ',taste);
		end	
		else writeln;	
	until (taste=13);
end.		
	
