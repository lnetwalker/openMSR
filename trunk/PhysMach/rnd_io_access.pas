Unit rnd_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf ein Random	}
{ I/O Device Zur Verfügung										}
{ Attention: its just a raw hack - not finished					}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details				}

INTERFACE

function rnd_read_ports(io_port:longint):byte;
function rnd_write_ports(io_port:longint;byte_value:byte):byte;
function rnd_hwinit(initdata:string;DeviceNumber):boolean;

implementation


function rnd_read_ports(io_port:longint):byte;
var	
	x	: byte;
begin
	x:=round(random()*255)+1;
	//writeln('rnd_read_ports: ',x);
	rnd_read_ports:=x;
end;
	
function rnd_write_ports(io_port:longint;byte_value:byte):byte;	

begin
end;

function rnd_hwinit(initdata:string;DeviceNumber:byte):boolean;
begin
	randomize;
end;


begin

end.
