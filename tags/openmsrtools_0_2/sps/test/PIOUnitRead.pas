program pio_unit_test;

uses  pio_io_access,crt;

var
	wert	: byte;
	
begin	
	repeat
		wert:=read_ports($302);
		writeln('*',wert,'*');
	until keypressed;
end.		
