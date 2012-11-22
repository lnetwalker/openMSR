Unit usb8_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ die HTronic USB8 IO					}
{ zur Verfügung								}

{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}

{ $Id: usb8_io_access.pas 756 2011-03-19 20:21:24Z hartmut $ }

INTERFACE

{ public functions to init the hardware and read and write ports }

function usb8_read_ports(io_port:longint):byte;
function usb8_read_analog(io_port:longint):longint;
function usb8_write_ports(io_port:longint;byte_value:byte):byte;
function usb8_hwinit(initstring:string;DeviceNumber:byte):boolean;
function usb8_close():boolean;

IMPLEMENTATION
uses 
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,SysUtils,Synaser
;

const
	debug      = false;
	
var
	ser: TBlockSerial;
	dummy: byte;

function usb8_close():boolean;
begin
    ser.free;
    usb8_close:=true;
end;


function usb8_read_ports(io_port:longint):byte;
begin
	// not supported by device
	usb8_read_ports:=0;
end;

function usb8_read_analog(io_port:longint):longint;
	// currently the io_port must be between 1 and 8 !
var
	MSB,LSB,chk 		: byte;
	number			: string;

begin
	str(io_port,number);
	ser.SendString('c0'+number);
	MSB:=ser.RecvByte(10000);
	LSB:=ser.RecvByte(10000);
	chk:=ser.RecvByte(10000);
	if ( LSB + MSB <> chk ) then writeln ( 'Checksum Error');
	usb8_read_analog:=MSB * 256 + LSB;
end;

function usb8_write_ports(io_port:longint;byte_value:byte):byte;
begin
	// it could be possible to use a port as output port, currently not used
	usb8_write_ports:=0;
end;

function usb8_hwinit(initstring:string;DeviceNumber:byte):boolean;

begin
	ser:=TBlockSerial.Create;
	ser.Connect(initstring); //ComPort
	Sleep(1000);
	ser.config(115000, 8, 'N', SB1, False, False);
	Write('Device: ' + ser.Device + '   Status: ' + ser.LastErrorDesc +' '+
	Inttostr(ser.LastError));
	Sleep(1000);
end;

begin

end.
