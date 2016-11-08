program writepioporta;

uses libadp;

const 
	DIO1=1;

var 
	pio : longint;
	i : byte;
	value : Cardinal;

begin
	{ open the pio }
	pio:=ad_open('usb-pio');

	if ( pio=-1 ) then
		writeln('usb-pio open failed')
	else
		writeln('usb-pio ok');

	{ set port A to output }
	ad_set_line_direction(pio,DIO1,$00000000);
	
	{ init the random number generator }
	randomize;

	{ write 10 values to port }
	for i:=1 to 10 do begin
		value:=round(random()*255)+1;
		ad_digital_out(pio,DIO1,value); 
		writeln (value);
	end;

	{ close the port }
	pio:=ad_close(pio);
	writeln(' close result : ',pio);
end.
