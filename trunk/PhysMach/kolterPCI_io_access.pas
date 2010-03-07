Unit kolterPCI_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf folgende	}
{ Karten zur Verf�gung 						}
{ PCI 1616, Opto PCI, PCI OptoRel
{ many thanks to Kolter Electronic for their support		}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}

{ $Id$ }

INTERFACE

function kolterPCI_read_ports(io_port:longint):byte;
function kolterPCI_write_ports(io_port:longint;byte_value:byte):byte;
function kolterPCI_hwinit(initdata:string;DeviceNumber:byte):boolean;

implementation


function kolterPCI_read_ports(io_port:longint):byte;

begin
end;


function kolterPCI_write_ports(io_port:longint;byte_value:byte):byte;	

begin
end;


function kolterPCI_hwinit(initdata:string;DeviceNumber:byte):boolean;
begin
end;


begin
end.
