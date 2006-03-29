Unit joy_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ den Joystick zur Verfügung                                    	}	
{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}
{ History:								}
{		13.09.2005 first raw hack				}

INTERFACE

function joy_read_ports(io_port:longint):byte;
function joy_write_ports(io_port:longint;byte_value:byte):byte;
function joy_hwinit(initdata:string):boolean;


implementation
uses oldlinux;

const	
	debug     = false;
	

function joy_read_ports(io_port:longint):byte;
{ IN THIS DIRTY HACK THE PARAMETERS ARE UNUSED DUMMIES }
begin
end;
	
function joy_write_ports(io_port:longint;byte_value:byte):byte;	
{ in this dirty hack the port parameter is ignored! }
	
begin
end;

function joy_hwinit(initdata:string):boolean;
begin

end;


begin
end.
