Unit dil_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf		} 
{ die Ports des DIL/Net PC zur Verfügung 			}	
{ eigentlich war das die Unit zum Zugriff auf den Printer	}
{ port der 1.7.0 Version. Um einen schnellen Test zu machen	}
{ habe ich die allernötigsten Änderungen zum Zugriff auf die	}
{ ports eines DIL/NetPC gemacht!!!				}
{ Attention: its just a raw hack - not finished			}
{ If you have improvements please contact me at 		}
{ hartmut@eilers.net						}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}

INTERFACE

function read_ports(io_port:longint):byte;
function write_ports(io_port:longint;byte_value:byte):byte;


implementation
uses linux,ports;

const	CSCIR=$22;	{ chip setup and control index register }
	CSCDR=$23;	{ chip setup and control data register  }
	PAMR=$a5;	{ PIO port A Mode Register }
	PADR=$a9;	{ PIO port A data register }
	PBMR=$a4;	{ PIO port B Mode register }
	PBDR=$a8;	{ PIO port B data register }
	
var	error: boolean;



function read_ports(io_port:longint):byte;
{ IN THIS DIRTY HACK THE PARAMETERS ARE UNUSED DUMMIES }
begin
	{ read Data from DIP switch }
	port[CSCIR]:=PBDR;
	read_ports:=port[CSCDR];
end;
	
function write_ports(io_port:longint;byte_value:byte):byte;	
{ in this dirty hack the port parameter is ignored! }
begin
	{ write data to LED }
	port[CSCIR]:=PADR;
	port[CSCDR]:=byte_value;
	write_ports:=byte_value;
end;



begin
	{ set the permission to access the ports }
	error:=IOperm($22,$aa,$ff);
	{ set port a of dil pc to output }
	port[CSCIR]:=PAMR;
	port[CSCDR]:=$ff;
	{ set port b of dil pc to input }
	port[CSCIR]:=PBMR;
	port[CSCDR]:=$00;
end.
