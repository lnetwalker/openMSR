program joystick;

{ this is the unittest for joy_io_access unit 	}
{ (c) by Hartmut Eilers <hartmut@eilers.net		}
{ released under the GNU GPL V2 see www.gnu.org	}
{ for license details							}


uses joy_io_access,crt;

{ test the following functions										}
{ function joy_read_ports(io_port:longint):byte;					}
{ function joy_read_ports(io_port:LongInt; axis : byte):integer;	}
{ function joy_hwinit(initdata:string):boolean;						}

var
	taste	: char;
	ende	: boolean;

begin
	writeln ('Unittest joystick running, stop with any key :) ');
	ende:=false;
	writeln('Hardware_init : ',joy_hwinit('/dev/js0'));	
	while not(ende) do begin
		writeln(' Buttons: ',joy_read_ports(0));
		writeln(' Axis 1 : ',joy_read_ports(0,0));
		writeln(' Axis 2 : ',joy_read_ports(0,1));
		if keypressed then begin
			taste:=readkey;
			ende:=true;
		end;
		delay(750);
	end;
end.