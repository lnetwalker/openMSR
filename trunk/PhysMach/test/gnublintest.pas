program gnublintest;

{ this is the unittest for gnublin_io_access unit 	}
{ (c) by Hartmut Eilers <hartmut@eilers.net>		}
{ released under the GNU GPL V2 see www.gnu.org	}
{ for license details					}


uses gnublin_io_access,crt;

{ test the following functions						}
{ function gnublin_read_ports(io_port:longint):byte;				}
{ function gnublin_read_ports(io_port:LongInt; axis : byte):integer;	}
{ function gnublin_hwinit(initdata:string):boolean;				}

var
	taste	: char;
	ende	: boolean;
	LED	: byte;

begin
	LED := 0;
	clrscr;
	writeln ('Unittest gnublin running, stop with any key :) ');
	ende:=false;
	writeln('Hardware_init : ',gnublin_hwinit('iiii',0));	
	while not(ende) do begin
		gotoxy(1,2);clreol; write(' GPIO  : ',gnublin_read_ports(0));
		gotoxy(1,3);clreol; write(' LED   : ',LED);
		gotoxy(1,4);clreol; write(' GPA 0 : ',gnublin_read_analog(0));
		gotoxy(1,5);clreol; write(' GPA 1 : ',gnublin_read_analog(1));
		if keypressed then begin
			taste:=readkey;
			ende:=true;
		end;
		//delay(150);
		if ( LED = 1 ) then begin
			gnublin_write_ports(0,0);
			LED := 0;
		end
		else begin
			gnublin_write_ports(0,128);
			LED := 1;
		end
	end;
end.