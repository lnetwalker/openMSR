Unit exec_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf ein externes	}
{ Programm zur Verfügung					}
{ Attention: its just a raw hack - not finished			}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}

INTERFACE

function exec_read_ports(io_port:longint):byte;
function exec_write_ports(io_port:longint;byte_value:byte):byte;
function exec_hwinit(initdata:string):boolean;
function exec_read_analog(io_port:longint):Cardinal;

implementation


function exec_read_ports(io_port:longint):byte;
begin

end;

function exec_write_ports(io_port:longint;byte_value:byte):byte;	
begin

end;

function exec_read_analog(io_port:longint):Cardinal;
begin

end;

function exec_hwinit(initdata:string):boolean;
begin

end;


begin

end.
