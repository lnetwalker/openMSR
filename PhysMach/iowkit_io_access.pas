Unit iowkit_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ die Ports des IO Warriors 40 von Code Mercanaries zur Verf�gung  	}	
{ dabei wird die Delphi Schnittstelle des SDK benutzt 			}

{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}
{ History:								}
{		14.04.2006 first raw hack				}

{ $Id: }

INTERFACE

{ the io_port address has a special meaning: its a two digit number with the first digit }
{ addressing the io warrior device ( eg. /dev/usb/iowarrior1 [ range 0-3 ]) and the second digit meaning }
{ which of the four eight bit ports should be read ( range 0-3 ) }
{ address 13 read the second iowarrior  and returns the value of port 3 }
{ the ranges are not checked ! }

function iow_read_ports(io_port:longint):byte;
function iow_write_ports(io_port:longint;byte_value:byte):byte;
function iow_hwinit(initdata:string;DeviceNumber:byte):boolean;

implementation
uses iowkit;


const	
	war_max	  	= 4;			{ max number of iowarriors which are supported }
	debug     	= false;

type TIowDevice = array [1..war_max] of IOWKIT_HANDLE;
	
var	
	IOWarrior 	: TIowDevice;
	oldval		: array[1..war_max] of Cardinal; 
	i		: byte;
	DeviceIndex	: byte;

function iow_read_ports(io_port:longint):byte;

var
	device  	: byte;
	Value		: DWORD;

begin
	{ extract the device number }
	device:=round(io_port/10)-DeviceIndex;
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	(* read the warrior *)
	IowKitReadImmediate(IOWarrior[device+1], Value);
	if ( debug ) then writeln ('IOW_IO: r  ',device,' ',io_port,':',Value);
	
	{ return the wanted port }
	case io_port of
	   	0   : iow_read_ports:=Value;
	   	1   : iow_read_ports:=Value shr 8;
	   	2   : iow_read_ports:=Value shr 16;
	   	3   : iow_read_ports:=Value shr 24;
	end;
end;
	
function iow_write_ports(io_port:longint;byte_value:byte):byte;	
{ in this dirty hack the port parameter is not fully implemented! }
var
	Report		: IOWKIT40_IO_REPORT;
	ovalue  	: Cardinal;
	dev 		: LongInt;
	
begin
	{ extract the device number and build devicename }
	dev:=round(io_port/10)+1-DeviceIndex;
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	
	(* write the warrior *)
	{ shift the outvalue to the Port }
	if (debug) then
		write ('ovalue0=',byte_value,' ');
	case io_port of
		0	:	begin
					ovalue:=(byte_value       ) or $FFFFFF00;
					oldval[dev]:=oldval[dev] and $FFFFFF00;
				end;	
		1	:	begin
					ovalue:=(byte_value shl  8) or $FFFF00FF;
					oldval[dev]:=oldval[dev] and $FFFF00FF;
				end;	
		2	:	begin
					ovalue:=(byte_value shl 16) or $FF00FFFF;
					oldval[dev]:=oldval[dev] and $FF00FFFF;
				end;	
		3	:	begin
					ovalue:=(byte_value shl 24) or $00FFFFFF;
					oldval[dev]:=oldval[dev] and $00FFFFFF;
				end;	
	end;
	if (debug) then write ('ovalue1=',ovalue,' oldval=',oldval[dev+1],'  ');
	{ the values of the other ports must be brought into ovalue }
	ovalue:=oldval[dev] or ovalue;
	if (debug) then write ('ovalue2=',ovalue,' ');
	{ note the new value written to the warrior for next port access }
	oldval[dev]:=ovalue;
	if (debug) then writeln ('oldval2=',oldval[dev]);
	if (debug) then writeln ('IOW_IO: w  ',dev,' ', io_port,':',ovalue);
	{ write out }
	Report.ReportID:=0;
	Report.Value:=ovalue;
	IowKitWrite(IOWarrior[dev],0,@Report,5);
end;


function iow_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
	x	: byte;
begin
	if (deviceNumber>war_max) then DeviceIndex:=DeviceNumber
	else DeviceIndex:=0;

	if (debug) then writeln ( 'IOW_IO: IO-Warrior initilized' );
	for x:=1 to war_max do 
		oldval[x]:=0;
end;


begin
	IOWarrior[1]:=IowKitOpenDevice;
	for i:=2 to war_max do
		IOWarrior[i]:=IowKitGetDeviceHandle(i);
end.
