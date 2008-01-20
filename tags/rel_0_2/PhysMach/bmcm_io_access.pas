Unit bmcm_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ die devices von BMCM zur Verfuegung siehe www.bmcm.de 	}	
{ dabei wird die C Schnittstelle des SDK benutzt 			}
{ die libad c-library muss installiert sein }

{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}
{ History:								}
{		05.06.2007 first raw hack	( startcode is iowarrior )}
{		12.06.2007 init read and write first hacked ( digital values only = usb-pio support)}


INTERFACE

{ public functions to init the hardware and read and write ports }

function bmcm_read_ports(io_port:longint):byte;
function bmcm_write_ports(io_port:longint;byte_value:byte):byte;
function bmcm_hwinit(initstring:string):boolean;

{ the io_port address has a special meaning: its a two digit number with the first digit }
{ addressing the usb PIO device ( eg. /dev/acm... [ range 0-3 ]) and the second digit meaning }
{ which of the three eight bit ports should be accessed ( range 0-2 ) }
{ address 12 read the second usb-PIO  and return the value of port 2 aka port c }
{ the ranges are not checked ! }

implementation
uses libadp;					{ use the c library }


const	
	bmcm_max  	= 4;			{ max number of bmcm devices which are supported }
	debug     	= false;

type 
	PCardinal = ^Cardinal;
	
var	
	devices		: array[1..bmcm_max] of longint;		{ array with the device handles }
	cnt			: byte;									{ the counter for the divces }


function bmcm_read_ports(io_port:longint):byte;

var
	dev  		: byte;
	value		: Cardinal;					{ the value read from device }
	p 			: PCardinal;				{ pointer to that value }

begin
	{ extract the device number as key to device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);

	new (p);			{ generate pointer }
	p:=@value;			{ let it show to value }

	ad_digital_in(devices[dev],io_port,p);   { read the value }

	bmcm_read_ports:=value;
end;
	

function bmcm_write_ports(io_port:longint;byte_value:byte):byte;	

var
	dev 		: byte;
	
begin
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10)+1;
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	
	(* write the data to device *)
	if (debug) then
		write ('Value=',byte_value,' ');
	ad_digital_out(devices[dev],io_port,byte_value);
end;


function bmcm_hwinit(initstring:string):boolean;
var
	x,i			: byte;
	initdata 	: array[1..5] of string;
	direction	: LongInt;
	DeviceName	: String;
	pDeviceName	: PChar;


begin
	{ example init string }
	{ usb-pio:/dev/acm01:$00000000:$ffffffff,$ffff0000}
	{ we have 5 datafields delimited by : }
	{ for easy handling this string is divided in array values }
	for i:=1 to 5 do begin
		initdata[i]:=copy(initstring,1,pos(':',initstring));
		initstring:=copy(initstring,pos(':',initstring)+1, length(initstring));
	end;
	{ open the device, devices[cnt] is the device handle }
	DeviceName:=initdata[1]+':'+initdata[2];
	new(pDeviceName);
	pDeviceName:=@DeviceName;
	devices[cnt]:=ad_open(pDeviceName);
	{ setting line direction for port i $f means read, $0 means write for the bit }
	for i:=1 to 3 do begin
		val(initdata[i],direction);
		ad_set_line_direction(devices[cnt],i,direction);
	end;
	{ increment next device counter }
	inc(cnt);
end;


begin
	{ reset the device counter to ensure that device handles are stored correctly }
	cnt:=0;
end.