program PIOUnitWrite;

uses pio_io_access,crt;

var
	wert	: byte;
	
begin
        repeat
                readln (wert);
		wert:=write_ports($305,wert);
	until keypressed;
end.		
