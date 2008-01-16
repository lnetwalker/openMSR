program iowkit_test;

{ this is the unittest for iowkit_io_access unit 	}
{ (c) by Hartmut Eilers <hartmut@eilers.net		}
{ released under the GNU GPL V2 see www.gnu.org	}
{ for license details							}


uses iowkit_io_access,crt;

{ test the following functions										}
{ function iow_read_ports(io_port:longint):byte;					}
{ function iow_write_ports(io_port:LongInt):byte;	}
{ function iow_hwinit(initdata:string):boolean;						}

var
	taste	: char;
	ende	: boolean;

begin
	clrscr;
	writeln ('Unittest iowkit_io_access running, stop with any key :) ');
	ende:=false;
	writeln('Hardware_init : ',iow_hwinit(''));	
	while not(ende) do begin
		clreol;gotoxy(1,2); writeln(' Port 0: ',iow_read_ports(0));
		clreol;gotoxy(1,3); writeln(' Port 4: ',iow_write_ports(3,255));
		delay(750);
		clreol;gotoxy(1,4); writeln(' Port 4: ',iow_write_ports(3,0));
		if keypressed then begin
			taste:=readkey;
			ende:=true;
		end;
		delay(750);
	end;
end.