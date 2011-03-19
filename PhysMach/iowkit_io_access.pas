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

{ $Id$ }

INTERFACE

{ the io_port address has a special meaning: its a two digit number with the first digit }
{ addressing the io warrior device ( eg. /dev/usb/iowarrior1 [ range 1-8 ]) and the second digit meaning }
{ which of the four eight bit ports should be read ( range 0-3 ) }
{ address 13 read the first iowarrior  and returns the value of port 3 }
{ the ranges are not checked ! }

function iow_read_ports(io_port:longint):byte;
function iow_write_ports(io_port:longint;byte_value:byte):byte;
function iow_hwinit(initdata:string;DeviceNumber:byte):boolean;
function iow_close():boolean;

implementation
uses iowkit;


const	
	war_max	  	= 8;			{ max number of iowarriors which are supported }
	debug     	= false;
	IOWnone		= 0;
	// these are the USB product id
	IOW24		= 5377;
	IOW40		= 5376;
	IOW56		= 5379;


type TIowDevice = array [1..war_max] of IOWKIT_HANDLE;
	
var	
	IOWarrior 	: TIowDevice;
	oldval		: array[1..war_max] of Cardinal; 
	OldInValue	: array[1..war_max] of Cardinal;
	IOWType		: array[1..war_max] of byte;
	i		: byte;
	initialized	: boolean;


function iow_close():boolean;
	
begin
    IowKitCloseDevice();
    iow_close:=true;
end;


function iow_read_ports(io_port:longint):byte;

var
	Report40	: IOWKIT40_IO_REPORT;
	Report24	: IOWKIT24_IO_REPORT;
	device  	: byte;
	Value		: Cardinal;
	Result		: LongWord;

begin
	if debug then writeln('iow_read_ports io_port=',io_port);
	{ extract the device number }
	device:=round(io_port/16);
	{ extract the port }
	io_port:=io_port-(device*16);
	// access the hardware port wide ( 8 Bit ) which means 4 accesses to read all inputs
	if ( debug ) then write(IOWKIT_REPORT_SIZE,' IOW_IO: r  ',device,' ',io_port,':');
	(* read the warrior *)
	if (IOWType[device] = 40) then begin
	    if (debug) then writeln('reading IOW40');
	    Report40.Value:=0;
	    Result:=IowKitReadNonBlocking(IOWarrior[device],IOW_PIPE_IO_PINS,@Report40,IOWKIT_REPORT_SIZE);
	    //IowKitReadImmediate(IOWarrior[device], Value);
	    if (Result>0) then begin
		Value:=Report40.Value;
		OldInValue[device]:=Value;
	    end
	    else Value:=OldInValue[device];	
	end;

	if (IOWType[device] = 24) then begin
	    if (debug) then writeln('reading IOW24');
	    Report24.Value:=0;
	    Result:=IowKitReadNonBlocking(IOWarrior[device],IOW_PIPE_IO_PINS,@Report24,IOWKIT_REPORT_SIZE);
	    //IowKitReadImmediate(IOWarrior[device], Value);
	    if (Result>0) then begin
		Value:=Report24.Value;
		OldInValue[device]:=Value;
	    end
	    else Value:=OldInValue[device];	
	end;

	if ( debug ) then writeln (Value);
	{ return the wanted port }
	case io_port of
		0   : iow_read_ports:=Value;
		1   : iow_read_ports:=Value shr 8;
		2   : iow_read_ports:=Value shr 16;
		3   : iow_read_ports:=Value shr 24;
	end;
	if ( debug ) then writeln ('read ',iow_read_ports,' from port ',io_port);
end;


	
function iow_write_ports(io_port:longint;byte_value:byte):byte;	
{ in this dirty hack the port parameter is not fully implemented! }
var
	Report40	: IOWKIT40_IO_REPORT;
	Report24	: IOWKIT24_IO_REPORT;
	ovalue  	: Cardinal;
	dev 		: LongInt;
	selPort		: LongInt;
	
begin
	selPort:=io_port;
	{ extract the device number and build devicename }
	dev:=round(io_port/16);
	{ extract the port }
	io_port:=io_port-(dev*16);
	if ( debug ) then
	    writeln ('ioport=',selPort,' Dev=',dev,' port=',io_port);
	(* write the warrior *)
	{ shift the outvalue to the Port }
	if (debug) then
		write ('io_port=',io_port,' ovalue0=',byte_value,' ');
	case io_port of
		0	:	begin
					ovalue:=(byte_value       );
					oldval[dev]:=oldval[dev] and $FFFFFF00;
				end;	
		1	:	begin
					ovalue:=(byte_value shl  8);
					oldval[dev]:=oldval[dev] and $FFFF00FF;
				end;	
		2	:	begin
					ovalue:=(byte_value shl 16);
					oldval[dev]:=oldval[dev] and $FF00FFFF;
				end;	
		3	:	begin
					ovalue:=(byte_value shl 24);
					oldval[dev]:=oldval[dev] and $00FFFFFF;
				end;	
	end;
	if (debug) then write ('ovalue1=',ovalue,' oldval=',oldval[dev],'  ');
	{ the values of the other ports must be brought into ovalue }
	ovalue:=oldval[dev] or ovalue;
	if (debug) then write ('ovalue2=',ovalue,' ');
	{ note the new value written to the warrior for next port access }
	oldval[dev]:=ovalue;
	if (debug) then writeln ('oldval2=',oldval[dev]);
	if (debug) then writeln ('IOW_IO: w  ',dev,' ', io_port,':',ovalue);
	// access the hardware in 8 Bit which means 4 calls
	{ write out }
	if (IOWType[dev] = 40) then begin
	    Report40.ReportID:=0;
	    Report40.Value:=ovalue;
	    IowKitWrite(IOWarrior[dev],IOW_PIPE_IO_PINS,@Report40,IOWKIT_REPORT_SIZE);
	    iow_write_ports:=byte_value;
	end;
	if (IOWType[dev] = 24) then begin
	    Report24.ReportID:=0;
	    Report24.Value:=ovalue;
	    IowKitWrite(IOWarrior[dev],IOW_PIPE_IO_PINS,@Report24,IOWKIT_REPORT_SIZE);
	    iow_write_ports:=byte_value;
	end;
end;



function iow_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
	x	: byte;
begin
	if not(initialized) then begin
	    IowKitSetLegacyOpenMode(IOW_OPEN_SIMPLE);
	    IOWarrior[1]:=IowKitOpenDevice;
	    if Assigned(IOWarrior[1]) then 
		for i:=2 to war_max do
			IOWarrior[i]:=IowKitGetDeviceHandle(i)
	    else begin
		writeln('Error opening IO Warrior devices in Init');
		halt;
	    end;

	    if (debug) then writeln ( 'IOW_IO: IO-Warrior initilized' );
	    for x:=1 to war_max do begin
		case (IowKitGetProductId(IOWarrior[x])) of
		    IOWnone	: IOWType[x]:=0;
		    IOW40	: IOWType[x]:=40;
		    IOW24	: IOWType[x]:=24;
		    IOW56	: IOWType[x]:=56;
		end;
		oldval[x]:=$FFFFFFFF;
		OldInValue[x]:=0;
	    end;
	    initialized:=true;
	end;
end;


begin
    initialized:=false;
end.
