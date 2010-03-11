Unit kolterPCI_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf folgende	}
{ Karten zur Verf�gung 						}
{ PCI 1616, Opto PCI, PCI OptoRel				}
{ many thanks to Kolter Electronic for their support		}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}
{ Due to the IO port accesses root priviledges are needed	}
{ use eg sudo to start, try avoiding setuid for security !	}

{ $Id$ }

INTERFACE

function kolterPCI_read_ports(io_port:longint):byte;
function kolterPCI_write_ports(io_port:longint;byte_value:byte):byte;
function kolterPCI_hwinit(initdata:string;DeviceNumber:byte):boolean;

implementation
uses linux
{$ifndef ZAURUS}
,x86
{$endif}
;

const	
      debug             = false;

function kolterPCI_read_ports(io_port:longint):byte;
var	byte_value : byte;

begin
	{$ifndef ZAURUS}
	ReadPort(io_port,byte_value);
	{$endif}
	if (debug) then writeln('Kolter_IO r : ',io_port,'=',byte_value);
	kolterPCI_read_ports:=byte_value;
end;


function kolterPCI_write_ports(io_port:longint;byte_value:byte):byte;	

begin
	if (debug) then  writeln ('Kolter_IO w : ',io_port,'=',byte_value);
	{$ifndef ZAURUS}
	WritePort(io_port,byte_value);
	{$endif}
	kolterPCI_write_ports:=0;
end;


function kolterPCI_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
        controlPort : LongInt;

begin
	if debug then writeln ('KolterPCI Initstring=',initdata);
	val(initdata,controlPort);
	if ( debug ) then
		writeln('Kolter IO Device Port : ',controlPort);
	{$ifndef ZAURUS}
	{ allow full port access for the addressrange controlPort to controlPort + $FF }
	fpIoPL(3);
	{ it seems that fpIOperm only allows config for the Ports up to $03FF
	if ( fpIOperm(controlPort,$FF,$ff) <> 0 ) then begin
		writeln('Problems setting IO Permissions for Kolter PCI IO Card');
		halt(1);
	end;
	}
	{$endif}
	kolterPCI_hwinit:=true;
end;


begin
end.
