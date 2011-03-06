program joytest;
{ $Id: }



uses crt,joy_io_access;

const IOPort=$1;

var axis : byte;

begin
	joy_hwinit('/dev/input/js0',1);
	repeat
		write ('Analog In: ');
		for axis:= 0 to 3 do 
		    // read the four analog values
		    write(axis,' : ',joy_read_aports($10 + axis));
		write ('Binary in: ');
		writeln(joy_read_ports($10));
	until keypressed;
end.