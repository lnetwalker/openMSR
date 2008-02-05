program IOUnitWrite;

uses iow_io_access,crt;

var
	wert	: byte;
	
begin
        repeat
                readln (wert);
		wert:=write_ports($300,wert);
	until keypressed;
end.		
