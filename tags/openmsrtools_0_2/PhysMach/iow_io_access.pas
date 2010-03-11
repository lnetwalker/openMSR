Unit iow_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ die Ports des IO Warriors 40 von Code Mercanaries zur Verf�gung  	}	
{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}
{ History:								}
{		10.09.2005 first raw hack				}
{ 		22.09.2005 able to read selected ports			}

{$define ZAURUS}
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
uses linux;

const	
(* These values are from the SDK Sample program iow40_wr_if0.c *)
(*  IOW_WRITE=1074053121 *)
(*  IOW_READ =1074053122 *)
(* This must be improved, it's bad style to use the constants *)

	IOW_WRITE = 1074053121;
	IOW_READ  = 1074053122;
	war_max	  = 4;						{ max number of iowarriors which are supported }
	
	debug     = false;
	devicefile= '/dev/usb/iowarrior';
	
var	
	f       : LongInt;
	pvalue  : ^Cardinal;
	oldval	: array[1..war_max] of Cardinal; 


function iow_read_ports(io_port:longint):byte;

var
	ivalue  : Cardinal;
	devicenr,
	device  : string;
begin
	{ extract the device number and build devicename }
	str(round(io_port/10),devicenr);
	device:=devicefile+devicenr;
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	
	(* read the warrior *)
	{$ifndef ZAURUS}
	f:=fdOpen(device,Open_RdOnly);
	ioctl (f,IOW_READ,pvalue);
	fdclose(f);
	{$endif}
	ivalue:=pvalue^;
	
	if ( debug ) then writeln ('IOW_IO: r  ',device,' ',io_port,':',ivalue);
	
	{ return the wanted port }
	case io_port of
	    0	: iow_read_ports:=ivalue;
	    1   : iow_read_ports:=ivalue shr 8;
	    2   : iow_read_ports:=ivalue shr 16;
	    3   : iow_read_ports:=ivalue shr 24;
	end;    
end;
	
function iow_write_ports(io_port:longint;byte_value:byte):byte;	
{ in this dirty hack the port parameter is not fully implemented! }
var
	ovalue  : Cardinal;
	devicenr,
	device	: string;
	dev 	: LongInt;
	
begin
	{ extract the device number and build devicename }
	dev:=round(io_port/10);
	str(dev,devicenr);
	device:=devicefile+devicenr;
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	
	(* write the warrior *)
	{ shift the outvalue to the Port }
	if (debug) then
		write ('ovalue0=',byte_value,' ');
	case io_port of
		0	:	begin
					ovalue:=(byte_value       ) or $FFFFFF00;
					oldval[dev+1]:=oldval[dev+1] and $FFFFFF00;
				end;	
		1	:	begin
					ovalue:=(byte_value shl  8) or $FFFF00FF;
					oldval[dev+1]:=oldval[dev+1] and $FFFF00FF;
				end;	
		2	:	begin
					ovalue:=(byte_value shl 16) or $FF00FFFF;
					oldval[dev+1]:=oldval[dev+1] and $FF00FFFF;
				end;	
		3	:	begin
					ovalue:=(byte_value shl 24) or $00FFFFFF;
					oldval[dev+1]:=oldval[dev+1] and $00FFFFFF;
				end;	
	end;
	if (debug) then write ('ovalue1=',ovalue,' oldval=',oldval[dev+1],'  ');
	{ the values of the other ports must be brought into ovalue }
	ovalue:=oldval[dev+1] or ovalue;
	if (debug) then write ('ovalue2=',ovalue,' ');
	{ note the new value written to the warrior for next port access }
	oldval[dev+1]:=ovalue;
	if (debug) then writeln ('oldval2=',oldval[dev+1]);
	if (debug) then writeln ('IOW_IO: w  ',device,' ',dev,' ', io_port,':',ovalue);
	{ write out }
	pvalue^:=ovalue;
	{$ifndef ZAURUS}
	f:=fdOpen(device,Open_WrOnly);
	ioctl (f,IOW_WRITE,pvalue);
	fdclose(f);
	{$endif}
end;


function iow_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
	x	: byte;
begin
	if (debug) then writeln ( 'IOW_IO: IO-Warrior initilized' );
	for x:=1 to war_max do 
		oldval[x]:=0;
end;


begin
 	new (pvalue);
end.
