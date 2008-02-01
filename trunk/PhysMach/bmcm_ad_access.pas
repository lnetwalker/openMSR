Unit bmcm_ad_access;

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

function cmcm_read_ports(io_port:longint):byte;
function cmcm_read_analog(io_port:longint):integer;
function cmcm_write_ports(io_port:longint;byte_value:byte):byte;
function cmcm_hwinit(initstring:string):boolean;

{ the io_port address has a special meaning: its a two digit number with the first digit }
{ addressing the usb PIO device ( eg. /dev/acm... [ range 0-3 ]) and the second digit meaning }
{ which of the three eight bit ports should be accessed ( range 0-2 ) }
{ address 12 read the second usb-PIO  and return the value of port 2 aka port c }
{ the ranges are not checked ! }

{$undef ZAURUS}			{ Zaurus = Linux on ARM }

implementation
{$ifndef ZAURUS}
uses libadp,strings;					{ use the c library }
{$endif}

const	
	bmcm_max  	= 4;			{ max number of bmcm devices which are supported }
	debug     	= false;

type 
	PCardinal = ^Cardinal;
	
var	
	devices		: array[1..bmcm_max] of longint;		{ array with the device handles }
	cnt		: byte;									{ the counter for the divces }
	p 		: PCardinal;				{ pointer to that value }


function cmcm_read_ports(io_port:longint):byte;

var
	dev  		: byte;
	value		: Cardinal;					{ the value read from device }

begin
	{ extract the device number as key to device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);

	p:=@value;			{ let it show to value }
	
	{$ifndef ZAURUS }
	ad_digital_in(devices[dev],io_port+1,p);   { read the value }
	if debug then writeln('BMCM read device: ',devices[dev],' Port: ',io_port+1,' value=',value);
	{$endif}

	cmcm_read_ports:=value;
end;


function cmcm_read_analog(io_port:longint):integer;

var
	dev  		: byte;
	value		: Cardinal;					{ the value read from device }

begin
	{ extract the device number as key to device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);

	p:=@value;			{ let it show to value }
	
	{$ifndef ZAURUS }
	ad_discrete_in(devices[dev],io_port,0,p);   { read the value }
	if debug then writeln('BMCM read device: ',devices[dev],' Port: ',io_port+1,' value=',value);
	{$endif}

	cmcm_read_analog:=value;
end;


function cmcm_write_ports(io_port:longint;byte_value:byte):byte;	

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

	{$ifndef ZAURUS}
	ad_digital_out(devices[dev],io_port+1,byte_value);
	{$endif}

end;


function cmcm_hwinit(initstring:string):boolean;
var
	x,i		: byte;
	initdata 	: array[1..5] of string;
	direction	: LongInt;
	DeviceName	: String;
	pDeviceName	: PChar;


begin

	{ example init string }
	{ usb-pio:0:$00000000:$ffffffff,$ffff0000}
	{ we have 5 datafields delimited by : }
	{ for easy handling this string is divided in array values }
	for i:=1 to 5 do begin
		initdata[i]:=copy(initstring,1,pos(':',initstring)-1);
		initstring:=copy(initstring,pos(':',initstring)+1, length(initstring));
		if debug then writeln('initstring=',initstring,' initdata[',i,']=',initdata[i]);
	end;
	{ open the device, devices[cnt] is the device handle }
	if length(initdata[2])>0 then 
		DeviceName:=initdata[1]+':'+initdata[2]
	else
		DeviceName:=initdata[1];

	StrPCopy(pDeviceName,DeviceName);

	if debug then writeln('open device: ',DeviceName);

	{$ifndef ZAURUS}
	devices[cnt]:=ad_open(pDeviceName);
	if (devices[cnt]<>0) then begin
		writeln('Fatal error: opening device : ',cnt,' ',DeviceName,' check settings in config file');
		halt;
	end;
	{$endif}

	{ increment next device counter }
	inc(cnt);
end;


begin
	new (p);			{ generate pointer }

	{ reset the device counter to ensure that device handles are stored correctly }
	cnt:=0;
end.
