Unit funk_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf die Funksteckdosen über den LPT Port zur Verf�gung 	}
{ Attention: its just a raw hack - not finished					}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}

{ $Id$ }

INTERFACE

function funk_read_ports(io_port:longint):byte;
function funk_write_ports(io_port:longint;byte_value:byte):byte;
function funk_hwinit(initdata:string;DeviceNumber:Byte):boolean;
function funk_close():boolean;

implementation
uses crt;

const 	IOFile='/dev/port';
	power	: array [0..7] of byte =(1,2,4,8,16,32,64,128);
	PORTBITS: array [0..3] of byte =(254,253,251,247);
	// A=1111 1110; B=1111 1101; C=1111 1011; D=1111 0111
	SWITCH_ON=239;		// 1110 1111
	SWITCH_OFF=223;		// 1101 1111
	NoOfOutputs=4;		// how many outputs are used

var	XmitTime	: word;
	OldByteValue	: byte;


function funk_close():boolean;
begin
    funk_close:=true;
end;


function funk_read_ports(io_port:longint):byte;
begin

end;
	
function funk_write_ports(io_port:longint;byte_value:byte):byte;	
var 	F     		: file of byte;
	i,k,OutVal	: byte;
	AllBitsSet	: byte;
	
begin
	AllBitsSet:=255;
	if OldByteValue <> Byte_value then begin	// transmit only, if changes occurred
		OldByteValue:=byte_value;		// save byte_value for next run
		assign(F,IOFile);
		reset(F,Sizeof(OutVal));
		for k:=1 to 2 do begin			// transmit the signals twice
			for i:=7 downto 0 do begin
				OutVal:=AllBitsSet;					// always start with all high as dummy
				if byte_value>= power[i] then begin			// the bit is high
					byte_value:=byte_value-power[i];
					if i<NoOfOutputs then 				// only the lower 4 bits are used, rest is ignored
						OutVal:=PORTBITS[i] and SWITCH_ON;	// set the bit and the on-bit  to low
				end
				else							// the bit is low
					if i<NoOfOutputs then 				// only the lower 4 bits are used, rest is ignored
						OutVal:=PORTBITS[i] and SWITCH_OFF;	// set the bit and the off-bit to low

				if i<NoOfOutputs then begin				// only the lower 4 bits are used, rest is ignored
					seek(F,io_port);				// set the outputs
					blockwrite(F,OutVal,1);	
					delay(XmitTime);				// wait some time
					seek(F,io_port);				// switch off the IO lines
					blockwrite(F,AllBitsSet,1);
				end;
			end;
			byte_value:=OldByteValue;	// restore byte_value, it was destroyed above
		end;
		close(F);
	end;
	funk_write_ports:=byte_value;
end;

function funk_hwinit(initdata:string;DeviceNumber:byte):boolean;
begin
	if length(initdata)=0 then XmitTime:=500
	else begin
		val(initdata,XmitTime);
	end;
	OldByteValue:=0;
end;


begin

end.
