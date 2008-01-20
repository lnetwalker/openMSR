program openpio;

uses libadp;

var f : longint;

begin
	f:=ad_open('usb-pio');

	if ( f=-1 ) then
		writeln('usb-pio open failed')
	else
		writeln('usb-pio ok');

	f:=ad_close(f);
	writeln(' close result : ',f);
end.
