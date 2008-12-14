Unit lp_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf den LPT Port zur Verf�gung 	}
{ Attention: its just a raw hack - not finished					}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}

INTERFACE

function lp_read_ports(io_port:longint):byte;
function lp_write_ports(io_port:longint;byte_value:byte):byte;
function lp_hwinit(initdata:string;DeviceNumber:byte):boolean;

implementation

const IOFile='/dev/port';

function lp_read_ports(io_port:longint):byte;
var byte_value : byte;
    F     : file;
begin
	assign(F,IOFile);
	reset(F,Sizeof(byte_value));
	seek(F,io_port);
	blockread(F,byte_value,1);
	close(F);
	{ invert the MSB  }
	if byte_value >= 128 then 
		byte_value:=byte_value - 128
	else 	
		byte_value:=byte_value + 128;		
	lp_read_ports:=byte_value;
end;
	
function lp_write_ports(io_port:longint;byte_value:byte):byte;	
var F     : file of byte;
begin
	assign(F,IOFile);
	reset(F,Sizeof(byte_value));
	seek(F,io_port);
	blockwrite(F,byte_value,1);
	close(F);
	lp_write_ports:=byte_value;
end;

function lp_hwinit(initdata:string;DeviceNumber:byte):boolean;
begin

end;


begin

end.
