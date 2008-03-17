unit PhysMach;

{ (c) 2006 by Hartmut Eilers < hartmut@eilers.net			}
{ distributed  under the terms of the GNU GPL V 2			}
{ see http://www.gnu.org/licenses/gpl.html for details			}

{ This unit builds a physical I/O Machine with the following		}
{ features (see the max values below for the amounts ) :		}
{ Digital In/Outputs, Digital Markers, Timers, Counters			}
{ It is also an abstract layer to access the above mentioned		}
{ Resources. It supports different I/O Hardware ( see List of		}
{ imported units below.and is platform independant currently		}
{ Linux and windows on PC Hardware is supported				}

{ $Id$ }

interface

const
	io_max			= 128;
	group_max		= round(io_max/8);
	marker_max		= 255;
	akku_max		= 16;
	cnt_max			= 16;
	tim_max			= 16;
	analog_max		= 64;
	DeviceTypeMax		= 16;


type
	DeviceTypeArray		= array[1..DeviceTypeMax] of char;

var
	marker 			: array[1..marker_max]   of boolean;
	eingang,ausgang		: array[1..io_max]	 of boolean;
	zust			: array[1..io_max]	 of boolean;
	lastakku		: array[1..akku_max]     of boolean;
	zahler			: array[1..cnt_max]	 of boolean;
	timer			: array[1..tim_max]	 of boolean;
	t			: array[1..tim_max]	 of word;	 
	z			: array[1..cnt_max]	 of word;
	analog_in		: array[1..analog_max]   of Cardinal;

	HWPlatform		: string;

	durchlaufeProSec,
	durchlauf,
	durchlauf100		: word;

	i_address,
	o_address,
	c_address,
	a_address		: array [1..group_max] of LongInt; 
	i_devicetype,
	o_devicetype,
	c_devicetype,
	a_devicetype 		: array [1..group_max] of char;
	DeviceList		: DeviceTypeArray;


procedure PhysMachInit;
procedure PhysMachReadDigital;
procedure PhysMachWriteDigital;
procedure PhysMachCounter;
procedure PhysMachloadCfg(cfgFilename : string);
procedure PhysMachReadAnalog;
procedure PhysMachTimer;
function  PhysMachGetDevices:DeviceTypeArray;
procedure PhysMachIOByDevice(DeviceType:char);

implementation

uses
{$ifdef LINUX }
		linux,
		dil_io_access,lp_io_access,pio_io_access,
		joy_io_access,rnd_io_access,http_io_access,
		bmcm_io_access,
{$endif}
{$ifdef newio }
		iowkit_io_access,
{$else}
		iow_io_access,
{$endif}
		exec_io_access;

const
	debugFlag 		= false;
	debug			= false;
	power			: array [0..7] of byte =(1,2,4,8,16,32,64,128);

var
	x			: word;



//Private functions
procedure PhysMachReadDevice(IOGroup:LongInt);
var
	wert,i           	: byte;
	DeviceType		: Char;
	Address			: LongInt;

begin
	DeviceType:=i_devicetype[IOGroup];
	Address:=i_address[IOGroup];
	if debug then writeln('PhysMachReadDevice IOGroup=',IOGroup,' DeviceType=',DeviceType,' Address=',Address);
	case DeviceType of
{$ifdef LINUX}
		'D'	: wert:=dil_read_ports(Address);
		'L'	: wert:=lp_read_ports(Address);
		'P'	: wert:=pio_read_ports(Address);
		'J'	: wert:=joy_read_ports(Address);
{$endif}
		'R'	: wert:=rnd_read_ports(Address);
		'I'	: wert:=iow_read_ports(Address);
		'H' 	: wert:=http_read_ports(Address);
		'B' 	: wert:=bmcm_read_ports(Address);
		'E'	: wert:=exec_read_ports(Address);
	end;

	if (debugFlag) then 
		writeln	('PhysMach:PhysMachReadDigital   group ',IOGroup,' -> ',wert); 
	for i:=7 downto 0 do begin	
		if wert>=power[i] then begin
			{ the adressing needs some explanation }
			{ if IOGroup is 2 we calculate the base address (3-1)*8+1=17 the base of IOGroup 2 }
			{ than we can add the loop counter to count down from 24 to 17 }
	   		eingang[(IOGroup-1)*8+1+i]:=true;
			wert:=wert-power[i]
		end
		else 
			eingang[(IOGroup-1)*8+1+i]:=false;
		if (debugFlag ) then begin
			if ( i=7 ) then write('E group ',IOGroup,'   ');
		   	write (eingang[(IOGroup-1)*8+1+i],' ');
		   	if (i=0 ) then writeln;
		end
	end;
	
end;



procedure PhysMachWriteDevice(IOGroup:LongInt);
var
	k,Value			: byte;
	DeviceType		: Char;
	Address			: LongInt;

begin
	DeviceType:=o_devicetype[IOGroup];
	if (DeviceType <> '-') then begin
		Address:=o_address[IOGroup];
		Value:=0;
		for  k:=7 downto 0 do begin
			Value:=Value+power[k]*ord(ausgang[k+(IOGroup-1)*8+1]);
			if (debugFlag ) then begin
		 		if ( k=7 ) then write('A group ',IOGroup,'    ');
		 		write (ausgang[k+(IOGroup-1)*8+1],' ');
		 		if (k=0 ) then writeln;
			end;		
		end;


		case DeviceType of
{$ifdef LINUX}
			'D'	: dil_write_ports(Address,Value);
			'L'	: lp_write_ports(Address,Value);
			'P'	: pio_write_ports(Address,Value);
			'J'	: joy_write_ports(Address,Value);
{$endif}
			'R' 	: rnd_write_ports(Address,Value);
			'I'	: iow_write_ports(Address,Value);
			'H' 	: http_write_ports(Address,Value);
			'B' 	: bmcm_write_ports(Address,Value);
			'E'	: exec_write_ports(Address,Value);
		end;
	end;
end;


procedure PhysMachReadAnalogDevice(IOGroup:LongInt);
begin
	if (a_devicetype[IOGroup] <> '-') then
		case a_devicetype[IOGroup] of
{$ifdef LINUX}
			'J' 	: analog_in[IOGroup]:=joy_read_ports(a_address[IOGroup]);
			'B' 	: analog_in[IOGroup]:=bmcm_read_analog(a_address[IOGroup]);
{$endif}
			'H'	: analog_in[IOGroup]:=http_read_ports(a_address[IOGroup]);
			'E'	: analog_in[IOGroup]:=exec_read_analog(a_address[IOGroup]);
		end;
	if (debugFlag) then writeln('Analog_in[',IOGroup,']=',analog_in[IOGroup]);
end;



procedure PhysMachReadCounter(IOGroup:LongInt);

var
	c,wert		: Byte;

begin
		if (c_devicetype[IOGroup] <> '-') then begin 

			if debug then writeln('reading Counter type ',c_devicetype[IOGroup],' Adresse ',c_address[IOGroup]);

			{ ZAEHLEReingaenge lesen  }
			case c_devicetype[IOGroup] of
{$ifdef LINUX}
				'D'	: wert:=dil_read_ports(c_address[IOGroup]);
				'L'	: wert:=lp_read_ports(c_address[IOGroup]);
				'P'	: wert:=pio_read_ports(c_address[IOGroup]);
				'J'	: wert:=joy_read_ports(c_address[IOGroup]);
{$endif}
				'R'	: wert:=rnd_read_ports(c_address[IOGroup]);
				'I'	: wert:=iow_read_ports(c_address[IOGroup]);
				'H' 	: wert:=http_read_ports(c_address[IOGroup]);
				'B' 	: wert:=bmcm_read_ports(c_address[IOGroup]);
				'E'	: wert:=exec_read_ports(c_address[IOGroup]);
			end;
		end
		else
			wert:=0;
		
		if debug then begin
			writeln('Countervalue=',wert);
			for c:=1 to 8 do write(' ',zust[c]);
			writeln;
		end;

		for c:=1 to 8 do begin
			{ zust[n] ist jeweils der vorherige Wert }
			if wert mod 2 = 0 then zust[c+IOGroup-1]:=false 			{ wenn low dann 0 speichern	}
			else	{ zust[] ist high }
				if not(zust[c+IOGroup-1]) then begin 				{ wenn pos. Flanke am Eingang }
					zust[c+IOGroup-1]:=true;		  		{ dann 1 speichern }
					if z[c+IOGroup-1]>0 then dec(z[c+IOGroup-1]);	{ und ISTwert herunterz�en } 
					if z[c+IOGroup-1]=0 then zahler[c+IOGroup-1]:=true;   	{ wenn ISTwert 0 dann ZAHLER 1}
				end;
			wert := wert div 2;
		end;
end;




// exported functions



procedure PhysMachloadCfg(cfgFilename : string);
var
	f				: text;
	zeile		   		: string[180];
	initdevice			: char;
	initstring			: string;
	dir				: shortString;
	iogroup				: integer;
	i,NumOfDevices			: Byte;
	AlreadyInList			: Boolean;
	
begin
	assign (f,cfgFilename);
	{$I-} reset (f); {$I+}
	if ioresult <> 0 then
	begin
		writeln (' Config-File nicht gefunden');
		halt(1);
	end;
	NumOfDevices:=1;
	while not(eof(f)) do begin
		readln (f,zeile);
		if ( copy(zeile,1,6) = 'DEVICE' ) then begin
			if ( debugFlag ) then writeln ('device detected');
			{ device line looks like }
			{ DEVICE!P!$307:$99 }
			initdevice:=zeile[8];
			initstring:=copy(zeile,10,length(zeile));
			{ call the initfunction of that device }
			if (debugFlag) then writeln('device ',initdevice,'   ',initstring);
			case initdevice of
{$ifdef LINUX}
				'D'	: begin
						dil_hwinit(initstring);
						HWPlatform:=HWPlatform+',DIL/NetPC ';
					  end;	
				'L'	: begin
						lp_hwinit(initstring);
						HWPlatform:=HWPlatform+',LP Port ';
					  end;	
				'P'	: begin
						pio_hwinit(initstring);
						HWPlatform:=HWPlatform+',PIO 8255 ';
					  end;	
				'J'	: begin
						joy_hwinit(initstring);
						HWPlatform:=HWPlatform+',Joystick ';
					  end;	
{$endif}
				'I'	: begin
						iow_hwinit(initstring);
						HWPlatform:=HWPlatform+',IO-Warrior 40 ';
					  end;	
				'R'	: begin
						rnd_hwinit(initstring);
						HWPlatform:=HWPlatform+',Random ';
					  end;	
				'H' 	: begin
						http_hwinit(initstring);
						HWPlatform:=HWPlatform+',HTTP ';
					  end;
				'B'	: begin
						bmcm_hwinit(initstring);
						HWPlatform:=HWPlatform+',BMCM-USB-Device ';
					  end;
				'E'	: begin
						exec_hwinit(initstring);
						HWPlatform:=HWPlatform+',ext. APP  ';
					  end;
			end;
	
			AlreadyInList:=false;
			for i:=1 to NumOfDevices do
				if (DeviceList[i]=initdevice) then AlreadyInList:=true;

			if not(AlreadyInList) then begin
				DeviceList[NumOfDevices]:=initdevice;
				inc(NumOfDevices);
			end;

			if (NumOfDevices>DeviceTypeMax) then begin
				writeln('Number of used Devicetypes exceeds limit!');
				halt(1);
			end;
		end
		else if (copy(zeile,1,4) = 'PORT') then begin
			if ( debugFlag ) then writeln ('port detected');
			{port line looks like }
			{PORT!I!  1! $00!I}
			dir:=copy(zeile,6,1);
			val(copy(zeile,8,3),iogroup);
			if     ( dir = 'I' ) then begin
				val(copy(zeile,12,4),i_address[iogroup]);
				i_devicetype[iogroup]:=zeile[17];
				if (debugFlag) then writeln('Input Group ',iogroup,'devicetype=',i_devicetype[iogroup]);
			end	
			else if( dir = 'O' ) then begin
				val(copy(zeile,12,4),o_address[iogroup]);
				o_devicetype[iogroup]:=zeile[17];
			end
			else if( dir = 'C' ) then begin
				val(copy(zeile,12,4),c_address[iogroup]);
				c_devicetype[iogroup]:=zeile[17];
			end
			else if( dir = 'A' ) then begin
				val(copy(zeile,12,4),a_address[iogroup]);
				a_devicetype[iogroup]:=zeile[17];
				if debugFlag then writeln('Analog Line=',iogroup,' Address=',a_address[iogroup]);
			end;
		end;
		{ ignore everything else }		
	end;
	close (F);
end;



procedure PhysMachInit;                    { initialisieren der physical machine }

begin
	if ( io_max / 8 > group_max ) then begin
		writeln ('IO_MAX too big compared to group_max');
		halt(1);
	end;		
	for x:=1 to marker_max do Marker[x]:=false;
	for x:=1 to akku_max do lastakku[x]:=false;
	for x:=1 to  io_max do begin
		ausgang[x]:=false;
		eingang[x]:=false;
		zust[x]:=false;
	end;
	for x:=1 to cnt_max do begin
		zahler[x]:=false;
		z[x]:=0;
	end;	 	 
	for x:=1 to tim_max do begin
		timer[x]:=false;
		t[x]:=0;
	end;
	{ the devicetype - means unconfigured }
	for x:=1 to group_max do begin 
		i_devicetype[x]:='-';
		o_devicetype[x]:='-';
		c_devicetype[x]:='-';
		a_devicetype[x]:='-';
	end;
	for x:=1 to DeviceTypeMax do 
		DeviceList[x]:='-';

	hwPlatform:='';
end;                               { ****ENDE INIT ****}




procedure PhysMachReadDigital;               { liesst eingangswerte ein }

var  
	io_group		: integer;

begin
	{ for every configured input the port must be read }
	io_group:=1;
	repeat
		PhysMachReadDevice(io_group);
		inc(io_group);
	until ( io_group > group_max );
end;


procedure PhysMachWriteDigital;              { gibt Ausg.werte an I/O Hardware aus}
var 
	io_group			: integer;
	
begin
	io_group:=1;
	repeat
		PhysMachWriteDevice(io_group);
		inc(io_group);
	until ( io_group > group_max );
end;					{ **** ENDE SET_OUTPUT **** }


procedure PhysMachCounter;		{ zaehlt timer und counter herunter liesst counter hardware }

var 
	c,wert				: byte;
	x,io_group			: integer;

begin
	PhysMachTimer;
	x:=1;
	repeat
		io_group:=round(int(x/8)+1);
		PhysMachReadCounter(io_group);
		x:=x+8;
	until ( x > cnt_max );
end;                               { **** ENDE COUNT_DOWN ****       }



procedure PhysMachReadAnalog;				{ read analog inputs }
var
	x				: integer;

begin
	x:=0;
	repeat
		PhysMachReadAnalogDevice(x);
		inc(x);
	until ( x > analog_max );
end;


procedure PhysMachTimer;

var	c	:byte;

begin
	inc(durchlauf);				{ timerbasis = 1s }
	inc(durchlauf100);			{ timerbasis = 100 ms }
	
	if (durchlauf>=durchlaufeProSec) then begin { Diese Timer laufen mit Sekundenbasis }
		for c:=1 to 4 do begin
			if t[c] >= 0 then t[c]:=t[c]-1;
        	 	if t[c]=0 then timer[c]:=true
     		end;
		durchlauf:=0;
	end;	
	if (durchlauf100>=round(durchlaufeProSec/10)) then begin { timer auf basis 100 ms }
		for c:=5 to 12 do begin
    	     		if t[c] >= 0 then t[c]:=t[c]-1;
        	 	if t[c]=0 then timer[c]:=true
		end;
		durchlauf100:=0;
	end;
	for c:=13 to 16 do begin				{ as fast as program runs }
		if t[c] >= 0 then t[c]:=t[c]-1;
		if t[c]=0 then timer[c]:=true
	end;

	{ END OF TIMER }
end;



function  PhysMachGetDevices:DeviceTypeArray;
begin
	PhysMachGetDevices:=DeviceList;
end;



procedure PhysMachIOByDevice(DeviceType : char);
var
	IOGroup			: Integer;
	i,wert			: Byte;

begin
	IOGroup:=1;
	repeat
		// handle input type
		if (i_devicetype[IOGroup] = DeviceType) then
			PhysMachReadDevice(IOGroup);

		// handle output type
		if (o_devicetype[IOGroup] = DeviceType ) then
			PhysMachWriteDevice(IOGroup);

		// handle analog inputs
		if (a_devicetype[IOGroup] = DeviceType) then
			PhysMAchReadAnalogDevice(IOGroup);

		// handle counters
		if (c_devicetype[IOGroup] = DeviceType) then
			PhysMachReadCounter(IOGroup);

		inc(IOGroup);
	until (IOGroup > group_max);
end;



begin
end.