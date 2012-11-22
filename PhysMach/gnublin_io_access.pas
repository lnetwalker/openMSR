Unit gnublin_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ die im GNUBLIN Board eingebaute Hardware				}
{ zur Verfügung							}

{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}

{ $Id: gnublin_io_access.pas 756 2011-03-19 20:21:24Z hartmut $ }

{ Belegung der GPIOs:
  GPIO3...........LED1
  GPIO11..........X4-2
  GPIO13..........
  GPIO14..........X4-3
  GPIO15..........X4-4 }

{ Belegung der Analogen Eingänge
ADC10B_GPA0........J5-1
ADC10B_GPA1........J5-2 (auch auf X4-1)
ADC10B_GPA3........J5-3 }

{ Belegung PWM Ausgang
 PWM_DATA des LPC3131 ist auf J5-4 h }

INTERFACE

{ public functions to init the hardware and read and write ports }

function gnublin_read_ports(io_port:longint):byte;
function gnublin_read_analog(io_port:longint):longint;
function gnublin_write_ports(io_port:longint;byte_value:byte):byte;
function gnublin_hwinit(initstring:string;DeviceNumber:byte):boolean;
function gnublin_close():boolean;

IMPLEMENTATION
uses 
  Classes;

const
	debug      = false;
	
var
	dummy	: byte;

function gnublin_close():boolean;
begin
    gnublin_close:=true;
end;


function gnublin_read_ports(io_port:longint):byte;
begin
	// not supported by device
	gnublin_read_ports:=0;
end;

function gnublin_read_analog(io_port:longint):longint;
	// currently the io_port must be between 1 and 8 !
var
	MSB,LSB,chk 		: byte;
	number			: string;

begin
	str(io_port,number);
	if ( LSB + MSB <> chk ) then writeln ( 'Checksum Error');
	gnublin_read_analog:=MSB * 256 + LSB;
end;

function gnublin_write_ports(io_port:longint;byte_value:byte):byte;
begin
	// it could be possible to use a port as output port, currently not used
	gnublin_write_ports:=0;
end;

function gnublin_hwinit(initstring:string;DeviceNumber:byte):boolean;

begin
end;

begin

end.