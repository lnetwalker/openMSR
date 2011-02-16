Unit rnd_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf ein Random	}
{ I/O Device Zur Verfügung										}
{ Attention: its just a raw hack - not finished					}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details				}

INTERFACE

function rnd_read_ports(io_port:longint):byte;
function rnd_write_ports(io_port:longint;byte_value:byte):byte;
function rnd_hwinit(initdata:string;DeviceNumber:byte):boolean;

implementation
uses crt;

var delay_time	: word;

function rnd_read_ports(io_port:longint):byte;
var	
	x	: byte;
begin
	x:=round(random()*255)+1;
	//writeln('rnd_read_ports: ',x);
	delay(delay_time);
	rnd_read_ports:=x;
end;
	
function rnd_write_ports(io_port:longint;byte_value:byte):byte;	

begin
end;

function rnd_hwinit(initdata:string;DeviceNumber:byte):boolean;
var code	: word;
begin
	if initdata[1]='d' then 
		val(copy(initdata,3,length(initdata)),delay_time,code)
	else
		delay_time:=0;
	randomize;
end;


begin

end.
