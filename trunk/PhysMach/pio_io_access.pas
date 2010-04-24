Unit pio_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ die Ports einer 8255 PIO zur Verf�gung  				}	
{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}
{ History:								}
{		12.09.2005 first raw hack				}

INTERFACE


function pio_read_ports(io_port:longint):byte;
function pio_write_ports(io_port:longint;byte_value:byte):byte;
function pio_hwinit(initdata:string;DeviceNumber:byte):boolean;


implementation
uses linux
{$ifndef ZAURUS}
,x86
{$endif}
;

const	
      debug             = false;

function pio_read_ports(io_port:longint):byte;

var	byte_value : byte;

begin
	{$ifndef ZAURUS}
	ReadPort(io_port,byte_value);
	if (debug) then writeln('PIO_IO r : ',byte_value);
	pio_read_ports:=byte_value;
	{$endif}
end;
	
function pio_write_ports(io_port:longint;byte_value:byte):byte;	
begin
    if (debug) then  writeln ('PIO_IO w : ',byte_value);
	{$ifndef ZAURUS}
	WritePort(io_port,byte_value);
	{$endif}
	pio_write_ports:=0;
end;


function pio_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
        controlPort : LongInt;
        configByte  : byte;
        delim       : byte;

begin
	{ the configport and configword are given in one string as }
	{ parameter; address and data must be delimited by : }
	{ eg hwinit('$307:$99'); }
	delim:=pos(':',initdata);
	val(copy(initdata,1,delim-1),controlPort);
	val(copy(initdata,delim+1,length(initdata)-delim),configByte);
	if ( debug ) then
		writeln('Port : ',controlPort,' ',configByte);
	{$ifndef ZAURUS}
	{ allow full port access for the I/O addressrange  }
	{ ioperm call is not sufficient because ist supports only the range to 3ff }
	{ Thats not enough for some cards e.g. the Kolter ISA 48 ttl I/O }
	fpIoPL(3);
	{fpIOperm(controlPort,$FF,$ff);}
	WritePort(controlPort,configByte);
	{$endif}
	pio_hwinit:=true;
end;


begin
end.
