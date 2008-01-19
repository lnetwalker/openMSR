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

function dil_read_ports(io_port:longint):byte;
function dil_write_ports(io_port:longint;byte_value:byte):byte;
function dil_hwinit(initdata:string):boolean;

implementation
uses oldlinux;

const	
	CSCIR=$22;	{ chip setup and control index register }
	CSCDR=$23;	{ chip setup and control data register  }
	PAMR=$a5;	{ PIO port A Mode Register }
	PADR=$a9;	{ PIO port A data register }
	PBMR=$a4;	{ PIO port B Mode register }
	PBDR=$a8;	{ PIO port B data register }
	debug=false;	

function dil_read_ports(io_port:longint):byte;
{ IN THIS DIRTY HACK THE PARAMETERS ARE UNUSED DUMMIES }
var	byte_value : byte;
begin
	{ read Data from DIP switch }
	WritePort(CSCIR,PBDR);
	ReadPort(CSCDR,byte_value);
	if (debug) then writeln ('DIL: r ',io_port,' -> ',byte_value);
	dil_read_ports:=byte_value;
end;
	

function dil_write_ports(io_port:longint;byte_value:byte):byte;	
{ in this dirty hack the port parameter is ignored! }
begin
	{ write data to LED }
	WritePort(CSCIR,PADR);
	WritePort(CSCDR,byte_value);
	if (debug) then writeln ('DIL: w ',io_port,' -> ',byte_value);
end;


function dil_hwinit(initdata:string):boolean;
begin
	if (debug) then writeln ('DIL: HWinit ',initdata);
	{ initstring is a dummy !}
	{ set the permission to access the ports }
	IOperm($22,$ff,$ff);
	{ set port a of dil pc to output }
	WritePort(CSCIR,PAMR);
	WritePort(CSCDR,$ff);
	{ set port b of dil pc to input }
	WritePort(CSCIR,PBMR);
	WritePort(CSCDR,$00);
end;


begin

end.
