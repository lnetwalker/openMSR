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
uses crt,Synaser,SysUtils,StringCut,usb8_io_access;

const 	
	power	: array [0..7] of byte =(1,2,4,8,16,32,64,128);
	NoOfOutputs=4;		// how many outputs are used
	USBPORTBITS: array [0..3] of byte=(1,2,4,8);    	// A=0000 0001; B=0000 0010; C=0000 0100; D=0000 1000
	PARPORTBITS: array [0..3] of byte=(254,253,251,247);	// A=1111 1110; B=1111 1101; C=1111 1011; D=1111 0111
	debug=true;

var	XmitTime	: word;
	OldByteValue	: byte;
	IOFile		: String;
	ser		: TBlockSerial;
	IO		: String;
	SWITCH_OFF	: byte;
	SWITCH_ON	: byte;
	PORTBITS	: array[0..3] of byte;
	
	
{ send using HTronic USB8 }
function send_usb8 ( byte_value:byte ) : byte;
var 
  response	: byte;

begin
	if debug then writeln('DEBUG Funk send to USB8: ',byte_value);
	response:=usb8_write_ports(1,byte_value);	// send signal
	delay(XmitTime);				// wait some time
	response:=usb8_write_ports(1,0);		// send off
	send_usb8:=0;
end;

{ send using parallel port }
function send_par ( io_port:longint;byte_value:byte) : byte;
var 
  F     : file of byte;
  AllBitsSet	: byte;
begin
	AllBitsSet:=255;
	assign(F,IOFile);
	reset(F,Sizeof(byte_value));
	seek(F,io_port);				// set the outputs
	blockwrite(F,byte_value,1);	
	delay(XmitTime);				// wait some time
	seek(F,io_port);				// switch off the IO lines
	blockwrite(F,AllBitsSet,1);
	close(F);
end;

	
function funk_close():boolean;
begin
    if IO='usb' then usb8_close();
    funk_close:=true;
end;


function funk_read_ports(io_port:longint):byte;
begin

end;
	
function funk_write_ports(io_port:longint;byte_value:byte):byte;	
var 	
	i,k,OutVal	: byte;
	
begin
	if OldByteValue <> byte_value then begin	// transmit only, if changes occurred
	  OldByteValue:=byte_value;			// save byte_value for next run

		for k:=1 to 2 do begin			// transmit the signals twice
			for i:=7 downto 0 do begin
				OutVal:=255;						// always start with all high as dummy
				if debug then write ('funk_write_ports: Bit=',i,' Value=');
				if byte_value>= power[i] then begin			// the bit is high
					if debug then writeln('1 ',PORTBITS[i] + SWITCH_ON);
					byte_value:=byte_value-power[i];
					if i<NoOfOutputs then 				// only the lower 4 bits are used, rest is ignored
						OutVal:=PORTBITS[i] + SWITCH_ON;	// set the bit and the on-bit  
				end
				else begin						// the bit is low
					if debug then writeln('0 ',PORTBITS[i] + SWITCH_OFF);
					if i<NoOfOutputs then 				// only the lower 4 bits are used, rest is ignored
					  OutVal:=PORTBITS[i] + SWITCH_OFF;		// set the bit and the off-bit 
				end;	
				if i<NoOfOutputs then begin
				  if debug then writeln('funk_write_ports OutVal=',OutVal);
				  if IO='usb' then
				    send_usb8 ( OutVal )
				  else
				    send_par ( io_port, OutVal );
				end;  
			end;
			byte_value:=OldByteValue;	// restore byte_value, it was destroyed above
		end;
	end;
	funk_write_ports:=byte_value;
end;

function funk_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
    ListCnt		: Byte;
    Liste		: StringArray;	
begin
  Liste:=StringSplit(initdata,':');
  if debug then writeln(initdata,':',Liste[1]);
  ListCnt:=length(Liste);

  if Liste[1]='usb' then begin
    IO:='usb';
    usb8_hwinit(Liste[2],1);
    if debug then writeln;writeln(IO);
    PORTBITS:=USBPORTBITS;
    SWITCH_ON:=16;		// 0001 0000
    SWITCH_OFF:=32;		// 0010 0000
  end
  else if Liste[1]='par' then begin
    IO:='par';
    PORTBITS:=PARPORTBITS;
    SWITCH_ON:=239;		// 1110 1111
    SWITCH_OFF:=223;		// 1101 1111
  end;

  IOFile:=Liste[2];

  if ListCnt<3 then XmitTime:=500
  else val(Liste[3],XmitTime);

  OldByteValue:=0;
end;


begin

end.
