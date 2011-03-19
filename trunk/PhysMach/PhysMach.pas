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

{ the following defines are used in the code:				}
{	newio	- use new IO Warrior library				}
{	IOwarrior - include iowarrior library or not			}
{	Linux	- specific Linux ( automatically applied by compiler	}
{	USB92	- specific code to usb9263 from Calao			}

{$ifdef MaxOSX}
	{$undef IOwarrior}
{$endif}


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
	analog_in		: array[1..analog_max]   of integer;

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
	a_devicetype,
	u_devicetype		: array [1..analog_max] of char;
	DeviceList		: DeviceTypeArray;


procedure PhysMachInit;
procedure PhysMachEnd;
procedure PhysMachReadDigital;
procedure PhysMachWriteDigital;
procedure PhysMachCounter;
procedure PhysMachloadCfg(cfgFilename : string);
procedure PhysMachReadAnalog;
procedure PhysMachWriteAnalog;
procedure PhysMachTimer;
function  PhysMachGetDevices:DeviceTypeArray;
procedure PhysMachIOByDevice(DeviceType:char);

implementation

uses
{$ifdef LINUX }
		linux,
		dil_io_access,lp_io_access,pio_io_access,
		joy_io_access,funk_io_access,kolterPCI_io_access,
		kolterOpto3_io_access,adc12lc_io_access,
{$endif}

		
{$ifndef USB92}
		bmcm_io_access,
{$ifdef IOwarrior}
		iowkit_io_access,
{$endif}
{$endif}
		http_io_access,rnd_io_access,exec_io_access,StringCut;

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
		'F'	: wert:=funk_read_ports(Address);
		'K'	: wert:=kolterPCI_read_ports(Address);
		'O'	: wert:=kolterOpto3_read_ports(Address);
		'T'	: wert:=adc12lc_read_ports(Address);
{$endif}
		'H' 	: wert:=http_read_ports(Address);
		'R'	: wert:=rnd_read_ports(Address);
{$ifndef USB92}
{$ifdef IOwarrior}
		'I'	: wert:=iow_read_ports(Address);
{$endif}		
		'B' 	: wert:=bmcm_read_ports(Address);
{$endif}
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
			'F'	: funk_write_ports(Address,Value);
			'K'	: kolterPCI_write_ports(Address,Value);
			'O'	: kolterOpto3_write_ports(Address,Value);
			'T'	: adc12lc_write_ports(Address,Value);
{$endif}
			'H' 	: http_write_ports(Address,Value);
			'R' 	: rnd_write_ports(Address,Value);
{$ifndef USB92}
{$ifdef IOwarrior}
			'I'	: iow_write_ports(Address,Value);
{$endif}
			'B' 	: bmcm_write_ports(Address,Value);
{$endif}
			'E'	: exec_write_ports(Address,Value);
		end;
	end;
end;


procedure PhysMachReadAnalogDevice(IOGroup:LongInt);
begin
	if debugFlag then writeln('PhysMachReadAnalogDevice: a_devicetype[',IOGroup,']=',a_devicetype[IOGroup]);
	if (a_devicetype[IOGroup] <> '-') then
		case a_devicetype[IOGroup] of
{$ifdef LINUX}
			'J' 	: analog_in[IOGroup]:=joy_read_aports(a_address[IOGroup]);
			'T'	: analog_in[IOGroup]:=adc12lc_read_ports(a_address[IOGroup]);
{$ifndef USB92}
			'H'	: analog_in[IOGroup]:=http_read_analog(a_address[IOGroup]);
			'B' 	: analog_in[IOGroup]:=bmcm_read_analog(a_address[IOGroup]);
{$endif}
{$endif}
			'E'	: analog_in[IOGroup]:=exec_read_analog(a_address[IOGroup]);
		end;
	if (debugFlag) then writeln('Analog_in[',IOGroup,']=',analog_in[IOGroup]);
end;



procedure PhysMachWriteAnalogDevice(IOGroup:LongInt);
var dummy : byte;
begin
	if debugFlag then writeln('PhysMachWriteAnalogDevice: a_devicetype[',IOGroup,']=',a_devicetype[IOGroup]);
	if (u_devicetype[IOGroup] <> '-') then
		case u_devicetype[IOGroup] of
			'B' 	: bmcm_write_analog(a_address[IOGroup],analog_in[IOGroup]);
			'E'	: exec_write_analog(a_address[IOGroup],analog_in[IOGroup]);
			'D' 	: dummy:=1; 
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
				'K'	: wert:=kolterPCI_read_ports(c_address[IOGroup]);
				'O'	: wert:=kolterOpto3_read_ports(c_address[IOGroup]);
				'T'	: wert:=adc12lc_read_ports(c_address[IOGroup]);
{$endif}
				'H' 	: wert:=http_read_ports(c_address[IOGroup]);
				'R'	: wert:=rnd_read_ports(c_address[IOGroup]);
{$ifndef USB92}
{$ifdef IOwarrior}
				'I'	: wert:=iow_read_ports(c_address[IOGroup]);
{$endif}
				'B' 	: wert:=bmcm_read_ports(c_address[IOGroup]);
{$endif}
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
	zeile		   		: String255;
	initdevice			: char;
	initstring			: string;
	dir				: shortString;
	iogroup				: integer;
	i,NumOfDevices			: Byte;
	AlreadyInList			: Boolean;
	DeviceNumber			: Byte;
	ConfigTags			: StringArray;
	Trenner				: char;
	
begin
	Trenner:=' ';
	assign (f,cfgFilename);
	{$I-} reset (f); {$I+}
	if ioresult <> 0 then
	begin
		writeln (' Config-File nicht gefunden');
		halt(1);
	end;
	NumOfDevices:=1;
	DeviceNumber:=1;
	while not(eof(f)) do begin
		readln (f,zeile);
		ConfigTags:=StringSplit(zeile,Trenner);
		if debug then 
			if ((ConfigTags[1]='DEVICE') or (ConfigTags[1]='PORT')) then
				for i:=1 to 5 do
					writeln(ConfigTags[i]);
		if ( ConfigTags[1] = 'DEVICE' ) then begin
		
			if ( GetNumberOfElements(zeile,Trenner) > 6 ) then begin
				writeln (' Error in config file in the following line ');
				writeln ( zeile );
				halt (1);
			end;
			
			if ( debugFlag ) then writeln ('device detected');
			{ device line looks like }
			{ DEVICE!P!$307:$99 }
			initdevice:=ConfigTags[2,1];
			initstring:=ConfigTags[3];
			{ call the initfunction of that device }
			if (debugFlag) then writeln('device ',initdevice,'   ',initstring);
			case initdevice of
{$ifdef LINUX}
				'D'	: begin
						dil_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',DIL/NetPC ';
					  end;	
				'L'	: begin
						lp_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',LP Port ';
					  end;	
				'P'	: begin
						pio_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',PIO 8255 ';
					  end;	
				'J'	: begin
						joy_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',Joystick ';
					  end;
				'K'	: begin
						kolterPCI_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+'Kolter PCI I/O ';
					  end;
				'O'	: begin
						kolterOpto3_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+'Kolter Opto3 ISA I/O ';
					  end;
				'T'	: begin
						adc12lc_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+'Kolter ADC12LC ISA analog in ';
					  end;
				'F'	: begin
						funk_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',Funk ';
					  end;
{$endif}
				'H' 	: begin
						http_hwinit(initstring,DeviceNumber);
						if debugFlag then writeln('http_hwinit initstring=',initstring,' DeviceNumber=',DeviceNumber);
						HWPlatform:=HWPlatform+',HTTP ';
					  end;
				'R'	: begin
						rnd_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',Random ';
					  end;	
{$ifndef USB92}
{$ifdef IOwarrior}
				'I'	: begin
						iow_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',IO-Warrior ';
					  end;	
{$endif}
				'B'	: begin
						bmcm_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',BMCM-USB-Device ';
					  end;
{$endif}
				'E'	: begin
						exec_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',ext. APP  ';
					  end;
				else begin
				    writeln('unknown device in config file: ',zeile);
				    halt(1);
				end;
				
			end;
	
			inc(DeviceNumber);
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
		else if (ConfigTags[1] = 'PORT') then begin
			if ( debugFlag ) then writeln ('port detected');
			{port line looks like }
			{PORT!I!  1! $00!I}
			dir:=ConfigTags[2];
			val(ConfigTags[3],iogroup);
			if ( GetNumberOfElements(zeile,Trenner) > 6 ) then begin
				writeln (' Error in config file too much arguments line ');
				writeln ( zeile );
				halt (1);
			end 
			else
			    if ( GetNumberOfElements(zeile,Trenner) < 5 ) then begin
				writeln (' Error in config file too few arguments line ');
				writeln ( zeile );
				halt (1);
			    end;
			    
			if debugFlag then writeln('PhysMachLoadCfg: dir=',dir,' iogroup=',iogroup,' addr=',ConfigTags[4]);
			
			if     ( dir = 'I' ) then begin
				val(ConfigTags[4],i_address[iogroup]);
				i_devicetype[iogroup]:=ConfigTags[5,1];
				if (debugFlag) then writeln('Input Group ',iogroup,'devicetype=',i_devicetype[iogroup]);
			end	
			else if( dir = 'O' ) then begin
				val(ConfigTags[4],o_address[iogroup]);
				o_devicetype[iogroup]:=ConfigTags[5,1];
				if (debugFlag) then writeln('Output Group ',iogroup,'devicetype=',i_devicetype[iogroup]);
			end
			else if( dir = 'C' ) then begin
				val(ConfigTags[4],c_address[iogroup]);
				c_devicetype[iogroup]:=ConfigTags[5,1];
				if (debugFlag) then writeln('Counter Group ',iogroup,'devicetype=',i_devicetype[iogroup]);
			end
			else if( dir = 'A' ) then begin
				val(ConfigTags[4],a_address[iogroup]);
				a_devicetype[iogroup]:=ConfigTags[5,1];
				if debugFlag then writeln('Analog InLine=',iogroup,' Address=',a_address[iogroup]);
			end
			else if( dir = 'U' ) then begin
				val(ConfigTags[4],a_address[iogroup]);
				u_devicetype[iogroup]:=ConfigTags[5,1];
				if debugFlag then writeln('Analog OutLine=',iogroup,' Address=',a_address[iogroup]);
			end;
		end;
		{ ignore everything else }		
	end;
	close (f);
end;



procedure PhysMachInit;                    { initialisieren der physical machine }
var x,y: byte;

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
	end;

	for y:=1 to analog_max do begin
		a_devicetype[y]:='-';
		u_devicetype[y]:='-';
		analog_in[y]:=0;
		if debugFlag then writeln ('PhysMachInit: x=',y,' a_devicetype[',y,']=',a_devicetype[y],' analog_in[',y,']=',analog_in[y]);
	end;

	for x:=1 to DeviceTypeMax do 
		DeviceList[x]:='-';

	hwPlatform:='';
end;                               { ****ENDE INIT ****}

procedure PhysMachEnd;				{ beenden des Programmes, close all devices and clean up }

var	i		: byte;

begin
    for i:=1 to DeviceTypeMax do
	{ loop over all attached devices and call their close/end functions }
			case DeviceList[i] of
{$ifdef LINUX}
				'D'	: begin
						dil_close();
					  end;	
				'L'	: begin
						lp_close();
					  end;	
				'P'	: begin
						pio_close();
					  end;	
				'J'	: begin
						joy_close();
					  end;
				'K'	: begin
						kolterPCI_close();
					  end;
				'O'	: begin
						kolterOpto3_close();
					  end;
				'T'	: begin
						adc12lc_close();
					  end;
				'F'	: begin
						funk_close();
					  end;
{$endif}
				'H' 	: begin
						http_close();
					  end;
				'R'	: begin
						rnd_close();
					  end;	
{$ifndef USB92}
{$ifdef IOwarrior}
				'I'	: begin
						iow_close();
					  end;	
{$endif}
				'B'	: begin
						bmcm_close();
					  end;
{$endif}
				'E'	: begin
						exec_close();
					  end;
			end;

	{ clean up - do everything to leave program clearly }

end;


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
	i				: byte;

begin
	i:=1;
	repeat
		PhysMachReadAnalogDevice(i);
		if debugFlag then writeln('PhysMachReadAnalog i=',i);
		inc(i);
	until ( i > analog_max );
end;


procedure PhysMachWriteAnalog;				{ write analog outputs }
var
	i				: byte;

begin
	i:=1;
	repeat
		PhysMachWriteAnalogDevice(i);
		if debugFlag then writeln('PhysMachReadAnalog i=',i);
		inc(i);
	until ( i > analog_max );
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
	if debugFlag then writeln(' Reading IO-Device: ',DeviceType);
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
