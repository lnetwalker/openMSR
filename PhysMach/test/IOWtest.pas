program IOWtest;
{ $Id: }



uses crt,iowkit_io_access;

var port : byte;

begin
	iow_hwinit('dummy',1);
	randomize;
	repeat
		write ('Binary In: ');
		if paramstr(1) = '24' then begin
		    write(port,' : ',iow_read_ports($10),'     ');
		    writeln;writeln;
		    write ('   Binary OUT: ');
		    writeln(' ',iow_write_ports($11,round(random()*255)+1));
		end;
		if paramstr(1) = '40' then begin
		    for port:= 0 to 1 do 
			// read the first 2 ports
			write(port,' : ',iow_read_ports($10 + port),'     ');
		    // write random values to port 2 and 3
		    writeln;writeln;
		    write ('   Binary OUT: ');
		    write(iow_write_ports($12,round(random()*255)+1));
		    writeln(' ',iow_write_ports($13,round(random()*255)+1));
		end;    
		delay(100);
	until keypressed;
end.