program io_unit_test;

uses iow_io_access,crt;

var
	counter : Cardinal;
	dummy   : char;
	wert	: byte;
	
begin	
	counter:=0;
	repeat
		wert:=read_ports($300);
		writeln('*',wert,'*');
	until keypressed;
end.		
