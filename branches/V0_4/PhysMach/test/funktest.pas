program funktest;
{ $Id: }



uses funk_io_access;

const IOPort=$3bc;

var 	bits,
	a,b,c,d	: byte;
	Knopf	: char;

begin
	funk_hwinit('1000',1);
	a:=0;b:=0;c:=0;d:=0;
	repeat
{
		readln(Knopf);
		case Knopf of
			'a' : 	if (a=0 ) then begin
					a:=1;
					funk_write_ports(IOPort,$ee);
				end else begin
					a:=0;
					funk_write_ports(IOPort,$de);
				end;
			'b' : 	if (b=0 ) then begin
					b:=1;
					funk_write_ports(IOPort,$ed);
				end else begin
					b:=0;
					funk_write_ports(IOPort,$dd);
				end;
			'c' : 	if (c=0 ) then begin
					c:=1;
					funk_write_ports(IOPort,$eb);
				end else begin
					c:=0;
					funk_write_ports(IOPort,$db);
				end;
			'd' : 	if (d=0 ) then begin
					d:=1;
					funk_write_ports(IOPort,$e7);
				end else begin
					d:=0;
					funk_write_ports(IOPort,$d7);
				end;
		end;

	until Knopf='e';
}
		readln(bits);
		funk_write_ports(IOPort,bits);

	until bits=0;
end.