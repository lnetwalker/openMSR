program iowtest;

uses crt,iowkit_io_access;

var	i: byte;
	v: byte;
begin
	iow_hwinit('',0);
	for i:=10 to 13 do
		iow_write_ports(i,$FF);
	repeat
		v:=iow_read_ports(10);
		write('Port 10=',v);
		iow_write_ports(13,v);
		v:=iow_read_ports(11);
		writeln(' Port 11=',v);
		iow_write_ports(12,v);
		writeln('------------------------------');
		delay(10);
	until keypressed;
end.