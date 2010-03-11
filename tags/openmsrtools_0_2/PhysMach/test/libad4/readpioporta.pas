program readpioporta;

uses libadp;

type 
	PCardinal = ^Cardinal;

const 
	DIO1=1;

var 
	pio : longint;
	i : byte;
	value : Cardinal;
	p : PCardinal;

begin
	{ open the pio }
	pio:=ad_open('usb-pio');

	if ( pio=-1 ) then
		writeln('usb-pio open failed')
	else
		writeln('usb-pio ok');

	{ set port A to input }
	ad_set_line_direction(pio,DIO1,$ffffffff);

	new (p);
	p:=@value;
	{ read 10 values from port }
	for i:=1 to 1000 do begin
		ad_digital_in(pio,DIO1,p); 
		writeln (value);
	end;

	{ close the port }
	pio:=ad_close(pio);
	writeln(' close result : ',pio);
end.
