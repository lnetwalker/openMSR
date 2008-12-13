program funktest;

uses funk_io_access;

const IOPort=$3bc;

var bits : byte;

begin
	funk_hwinit('1000');
	repeat
		readln(bits);
		funk_write_ports(IOPort,bits);
	until bits=0;
end.