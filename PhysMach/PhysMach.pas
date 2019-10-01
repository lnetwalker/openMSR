unit PhysMach;

{ (c) 2006 by Hartmut Eilers < hartmut@eilers.net			}
{ distributed  under the terms of the GNU GPL V 2			}
{ see http://www.gnu.org/licenses/gpl.html for details		}

{ This unit builds a physical I/O Machine with the following		}
{ features (see the max values below for the amounts ) :		}
{ Digital In/Outputs, Digital Markers, Timers, Counters		}
{ It is also an abstract layer to access the above mentioned		}
{ Resources. It supports different I/O Hardware ( see List of	}
{ imported units below.and is platform independant currently		}
{ Linux and windows on PC Hardware is supported			}

{ $Id$ }

{ the following defines are used in the code:				}

{$ifdef CPU64}
	{$define SOFTIO}
{$endif}

{$ifdef arm}
	{$define LINUX}
	{$define SOFTIO}
	{$define USB8}
	{$define ARMGENERIC}
	{$undef IOW}
	{$define  Gnublin}
{$endif}

{$ifdef MaxOSX}
	{$undef IOwarrior}
{$endif}

{$ifdef USB92}
	{$define ARM}
	{$define LINUX}
{$endif}

{$ifdef Linuxfree}
	{$define LINUX}
	{$define LPT}
	{$define JOY}
	{$define SOFTIO}
	{$define IOW}
	{$define USB8}
{$endif}

{$ifdef Linux386}
	{$define LINUX}
	{$define LPT}
	{$define JOY}
	{$define PIO}
	{$define FUNK}
	{$define KOLTER}
	{$define BMCM}
	{$define SOFTIO}
	{$define IOW}
	{$define USB8}
{$endif}

{$ifdef Linux64}
	{$define LINUX}
	{$define SOFTIO}
	{$define USB8}
	{$define FUNK}
	{$define JOY}
{$endif}

{$ifdef Gnublin}
	{$define LINUX}
	{$define SOFTIO}
	{$undef IOW}
	{$define USB8}
{$endif}

{$ifdef win32}
	{$define SOFTIO}
	{$define IOW}
	{$define USB8}
{$endif}

{$ifdef SOFTIO}
	{$define RND}
	{$define HTTP}
	{$define EXEC}
	{$define AVR}
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
	marker 							: array[1..marker_max]   of boolean;
	eingang,ausgang			: array[1..io_max]	 of boolean;
	zust								: array[1..io_max]	 of boolean;
	lastakku						: array[1..akku_max]     of boolean;
	zahler							: array[1..cnt_max]	 of boolean;
	timer								: array[1..tim_max]	 of boolean;
	t										: array[1..tim_max]	 of word;
	z										: array[1..cnt_max]	 of word;
	analog_in						: array[1..analog_max]   of integer;

	HWPlatform					: string;

	durchlaufeProSec,
	durchlauf,
	durchlauf100				: word;

	i_address,
	o_address,
	c_address,
	a_address						: array [1..group_max] of LongInt;
	i_devicetype,
	o_devicetype,
	c_devicetype,
	a_devicetype,
	u_devicetype				: array [1..analog_max] of char;
	DeviceList					: DeviceTypeArray;
	CfgLine							: String;
	initstring					: string;


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
function  PhysMachDebug(debug:boolean):boolean;
//procedure PhysMachRegCfg(proc : TProcedure);


implementation

uses
{$ifdef LINUX }
		linux,
{$endif}
{$ifdef USB8}
		usb8_io_access,
{$endif}
{$ifdef Gnublin}
		gnublin_io_access,
{$endif}
{$ifdef BMCM}
		bmcm_io_access,
{$endif}
{$ifdef LPT}
		lp_io_access,
{$endif}
{$ifdef PIO}
		pio_io_access,
{$endif}
{$ifdef JOY}
		joy_io_access,
{$endif}
{$ifdef FUNK}
		funk_io_access,
{$endif}
{$ifdef KOLTER}
		kolterPCI_io_access,
		kolterOpto3_io_access,
		adc12lc_io_access,
{$endif}
{$ifdef DILPC}
		dil_io_access,
{$endif}
{$ifdef IOW}
		iowkit_io_access,
{$endif}
{$ifdef SOFTIO}
		http_io_access,
		rnd_io_access,
		exec_io_access,
		AVRnet_io_access,
{$endif}
{$ifdef ARMGENERIC}
		armgeneric_io_access,
{$endif}
		StringCut, sysutils,CommonHelper;

const
	power			: array [0..7] of byte =(1,2,4,8,16,32,64,128);

var
	x									: word;
	CfgCallbackFunc		: TProcedure;
	DebugMsg					: String;
	debugFlag 				: boolean;


//Private functions
function  PhysMachDebug(debug:boolean):boolean;
begin
	debugFlag:=debug;
	PhysMachDebug:=true;
end;


procedure PhysMachReadDevice(IOGroup:LongInt);
var
	wert,i           	: byte;
	DeviceType		: Char;
	Address			: LongInt;

begin
	DeviceType:=i_devicetype[IOGroup];
	Address:=i_address[IOGroup];
	if debugFlag  then debugLOG('PhysMach',2,'PhysMachReadDevice IOGroup='+IntToStr(IOGroup)+' DeviceType='+DeviceType+' Address='+IntToStr(Address));
	case DeviceType of
		'd'	: wert:=0;
{$ifdef DILPC}
		'D'	: wert:=dil_read_ports(Address);
{$endif}
{$ifdef LPT}
		'L'	: wert:=lp_read_ports(Address);
{$endif}
{$ifdef PIO}
		'P'	: wert:=pio_read_ports(Address);
{$endif}
{$ifdef JOY}
		'J'	: wert:=joy_read_ports(Address);
{$endif}
{$ifdef FUNK}
		'F'	: wert:=funk_read_ports(Address);
{$endif}
{$ifdef KOLTER}
		'K'	: wert:=kolterPCI_read_ports(Address);
		'O'	: wert:=kolterOpto3_read_ports(Address);
		'T'	: wert:=adc12lc_read_ports(Address);
{$endif}
{$ifdef BMCM}
		'B' 	: wert:=bmcm_read_ports(Address);
{$endif}
{$ifdef HTTP}
		'H' 	: wert:=http_read_ports(Address);
{$endif}
{$ifdef RND}
		'R'	: wert:=rnd_read_ports(Address);
{$endif}
{$ifdef IOW}
		'I'	: wert:=iow_read_ports(Address);
{$endif}
{$ifdef EXEC}
		'E'	: wert:=exec_read_ports(Address);
{$endif}
{$ifdef USB8}
		'U'	: wert:=usb8_read_ports(Address);
{$endif}
{$ifdef Gnublin}
		'G'	: wert:=gnublin_read_ports(Address);
{$endif}
{$ifdef ARMGENERIC}
		'A'	: wert:=armgeneric_read_ports(Address);
{$endif}
{$ifdef AVR}
		'N'	: wert:=avrnet_read_ports(Address);
{$endif}
	end;

	if (debugFlag) then
		debugLOG	('PhysMach',2,'PhysMach:PhysMachReadDigital   group '+IntToStr(IOGroup)+' -> '+IntToStr(wert));
	DebugMsg:='';
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
		if ( debugFlag ) then begin
			if ( i=7 ) then DebugMsg:=DebugMsg+'E group '+IntToStr(IOGroup)+'   ';
		  if (eingang[(IOGroup-1)*8+1+i]) then DebugMsg:=DebugMsg+'TRUE '
			else  DebugMsg:=DebugMsg+'FALSE ';
		  if (i=0 ) then debugLOG	('PhysMach',2,DebugMsg);
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
		DebugMsg:='';
		for  k:=7 downto 0 do begin
			Value:=Value+power[k]*ord(ausgang[k+(IOGroup-1)*8+1]);
			if (debugFlag ) then begin
				if ( k=7 ) then DebugMsg:=DebugMsg+'A group '+IntToStr(IOGroup)+'   ';
			  if (ausgang[(IOGroup-1)*8+1+k]) then DebugMsg:=DebugMsg+'TRUE '
				else  DebugMsg:=DebugMsg+'FALSE ';
			  if ( k=0 ) then debugLOG	('PhysMach',2,DebugMsg);
			end
		end;

		if (debugFlag ) then
			debugLOG ('PhysMach',2,'DeviceType='+DeviceType+' IOGroup='+IntToStr(IOGroup)+' value='+IntToStr(Value)+' Address='+IntToStr(Address));

		case DeviceType of
			'd'	: Value:=0;
{$ifdef DILPC}
			'D'	: dil_write_ports(Address,Value);
{$endif}
{$ifdef LPT}
			'L'	: lp_write_ports(Address,Value);
{$endif}
{$ifdef PIO}
			'P'	: pio_write_ports(Address,Value);
{$endif}
{$ifdef JOY}
			'J'	: joy_write_ports(Address,Value);
{$endif}
{$ifdef FUNK}
			'F'	: funk_write_ports(Address,Value);
{$endif}
{$ifdef KOLTER}
			'K'	: kolterPCI_write_ports(Address,Value);
			'O'	: kolterOpto3_write_ports(Address,Value);
			'T'	: adc12lc_write_ports(Address,Value);
{$endif}
{$ifdef BMCM}
			'B' 	: bmcm_write_ports(Address,Value);
{$endif}
{$ifdef HTTP}
			'H' 	: http_write_ports(Address,Value);
{$endif}
{$ifdef RND}
			'R' 	: rnd_write_ports(Address,Value);
{$endif}
{$ifdef IOW}
			'I'	: iow_write_ports(Address,Value);
{$endif}
{$ifdef EXEC}
			'E'	: exec_write_ports(Address,Value);
{$endif}
{$ifdef USB8}
			'U'	: usb8_write_ports(Address,Value);
{$endif}
{$ifdef Gnublin}
			'G'	: gnublin_write_ports(Address,Value);
{$endif}
{$ifdef ARMGENERIC}
			'A'	: armgeneric_write_ports(Address,Value);
{$endif}
{$ifdef AVR}
			'N'	: avrnet_write_ports(Address,Value);
{$endif}
		end;
	end;
end;


procedure PhysMachReadAnalogDevice(IOGroup:LongInt);
begin
	if debugFlag then debugLOG('PhysMach',2,'PhysMachReadAnalogDevice: a_devicetype['+IntToStr(IOGroup)+']='+a_devicetype[IOGroup]);
	if (a_devicetype[IOGroup] <> '-') then
		case a_devicetype[IOGroup] of
			'd'	: analog_in[IOGroup]:=0;
{$ifdef JOY}
			'J' 	: analog_in[IOGroup]:=joy_read_aports(a_address[IOGroup]);
{$endif}
{$ifdef KOLTER}
			'T'	: analog_in[IOGroup]:=adc12lc_read_ports(a_address[IOGroup]);
{$endif}
{$ifdef BMCM}
			'B' 	: analog_in[IOGroup]:=bmcm_read_analog(a_address[IOGroup]);
{$endif}
{$ifdef HTTP}
			'H'	: analog_in[IOGroup]:=http_read_analog(a_address[IOGroup]);
{$endif}
{$ifdef EXEC}
			'E'	: analog_in[IOGroup]:=exec_read_analog(a_address[IOGroup]);
{$endif}
{$ifdef USB8}
			'U'	: analog_in[IOGroup]:=usb8_read_analog(a_address[IOGroup]);
{$endif}
{$ifdef Gnublin}
			'G'	: analog_in[IOGroup]:=gnublin_read_analog(a_address[IOGroup]);
{$endif}
{$ifdef AVR}
			'N'	: analog_in[IOGroup]:=avrnet_read_analog(a_address[IOGroup]);
{$endif}

		end;
	if (debugFlag) then debugLOG('PhysMach',2,'Analog_in['+IntToStr(IOGroup)+']='+IntToStr(analog_in[IOGroup]));
end;



procedure PhysMachWriteAnalogDevice(IOGroup:LongInt);
var dummy : byte;
begin
	if debugFlag then debugLOG('PhysMach',2,'PhysMachWriteAnalogDevice: u_devicetype['+IntToStr(IOGroup)+']='+u_devicetype[IOGroup]);
	if (u_devicetype[IOGroup] <> '-') then
		case u_devicetype[IOGroup] of
{$ifdef BMCM}
			'B'	: bmcm_write_analog(a_address[IOGroup],analog_in[IOGroup]);
{$endif}
{$ifdef EXEC}
			'E'	: exec_write_analog(a_address[IOGroup],analog_in[IOGroup]);
{$endif}
			'H' : http_write_analog(a_address[IOGroup],analog_in[IOGroup]);
			'D'	: dummy:=1;
		end;
	if (debugFlag) then debugLOG('PhysMach',2,'Analog_out['+IntToStr(IOGroup)+']='+IntToStr(analog_in[IOGroup]));
end;



procedure PhysMachReadCounter(IOGroup:LongInt);

var
	c,wert		: Byte;

begin
		if (c_devicetype[IOGroup] <> '-') then begin

			debugLOG('PhysMach',2,'reading Counter type '+c_devicetype[IOGroup]+' Adresse '+IntToStr(c_address[IOGroup]));

			{ ZAEHLEReingaenge lesen  }
			case c_devicetype[IOGroup] of
				'd'	: wert:=0;
{$ifdef DILPC}
				'D'	: wert:=dil_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef LPT}
				'L'	: wert:=lp_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef PIO}
				'P'	: wert:=pio_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef JOY}
				'J'	: wert:=joy_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef KOLTER}
				'K'	: wert:=kolterPCI_read_ports(c_address[IOGroup]);
				'O'	: wert:=kolterOpto3_read_ports(c_address[IOGroup]);
				'T'	: wert:=adc12lc_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef BMCM}
				'B' 	: wert:=bmcm_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef HTTP}
				'H' 	: wert:=http_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef RND}
				'R'	: wert:=rnd_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef IOW}
				'I'	: wert:=iow_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef EXEC}
				'E'	: wert:=exec_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef Gnublin}
				'G'	: wert:=gnublin_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef ARMGENERIC}
				'A'	: wert:=armgeneric_read_ports(c_address[IOGroup]);
{$endif}
{$ifdef AVR}
				'N'	: wert:=avrnet_read_ports(c_address[IOGroup]);
{$endif}
			end;
		end
		else
			wert:=0;

		if debugFlag  then begin
			DebugMsg:='Countervalue='+IntToStr(wert);
			for c:=1 to 8 do
				if zust[c] then DebugMsg:=DebugMsg+' TRUE'
				else DebugMsg:=DebugMsg+' FALSE';
			debugLOG('PhysMach',2,DebugMsg);
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
procedure PhysMachRegCfg(proc : TProcedure);
begin
	if proc <> nil then CfgCallbackFunc:=proc;
end;


procedure PhysMachloadCfg(cfgFilename : string);
var
	f				: text;
	zeile		   		: String255;
	initdevice			: char;
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
		if debugFlag  then
			if ((ConfigTags[1]='DEVICE') or (ConfigTags[1]='PORT')) then
				for i:=1 to 5 do
					if debugFlag then debugLOG('PhysMach',2,ConfigTags[i]);
		if ( ConfigTags[1] = 'DEVICE' ) then begin

			if ( GetNumberOfElements(zeile,Trenner) > 6 ) then begin
				writeln (' Error in config file in the following line ');
				writeln ( zeile );
				halt (1);
			end;

			if ( debugFlag ) then debugLOG ('PhysMach',2,'device detected');
			{ device line looks like }
			{ DEVICE!P!$307:$99 }
			initdevice:=ConfigTags[2,1];
			initstring:=ConfigTags[3];
			{ call the initfunction of that device }
			if (debugFlag) then debugLOG ('PhysMach',2,'device '+initdevice+'   '+initstring);
			case initdevice of
				'd'	: HWPlatform:=HWPlatform+',dummy ';
{$ifdef DILPC}
				'D'	: begin
						dil_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',DIL/NetPC ';
					  end;
{$endif}
{$ifdef LPT}
				'L'	: begin
						lp_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',LP Port ';
					  end;
{$endif}
{$ifdef PIO}
				'P'	: begin
						pio_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',PIO 8255 ';
					  end;
{$endif}
{$ifdef JOY}
				'J'	: begin
						joy_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',Joystick ';
					  end;
{$endif}
{$ifdef KOLTER}
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
{$endif}
{$ifdef FUNK}
				'F'	: begin
						funk_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',Funk ';
					  end;
{$endif}
{$ifdef BMCM}
				'B'	: begin
						bmcm_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',BMCM-USB-Device ';
					  end;
{$endif}
{$ifdef HTTP}
				'H' 	: begin
						http_hwinit(initstring,DeviceNumber);
						if debugFlag then debugLOG('PhysMach',2,'http_hwinit initstring='+initstring+' DeviceNumber='+IntToStr(DeviceNumber));
						HWPlatform:=HWPlatform+',HTTP ';
					  end;
{$endif}
{$ifdef RND}
				'R'	: begin
						rnd_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',Random ';
					  end;
{$endif}
{$ifdef IOW}
				'I'	: begin
						iow_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',IO-Warrior ';
					  end;
{$endif}
{$ifdef EXEC}
				'E'	: begin
						exec_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',ext. APP  ';
					  end;
{$endif}
{$ifdef USB8}
				'U'	: begin
						usb8_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',USB8-IO  ';
					  end;
{$endif}
{$ifdef Gnublin}
				'G'	: begin
						gnublin_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',Gnublin-IO ';
					  end;
{$endif}
{$ifdef ARMGENERIC}
				'A'	: begin
						armgeneric_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',ARM generic GPIO ';
					  end;
{$endif}
{$ifdef AVR}
				'N'	: begin
						avrnet_hwinit(initstring,DeviceNumber);
						HWPlatform:=HWPlatform+',AVRNet IO ';
					  end;
{$endif}

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
			if ( debugFlag ) then debugLOG ('PhysMach',2,'port detected');
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
			    end;

			if debugFlag then debugLOG('PhysMach',2,'PhysMachLoadCfg: dir='+dir+' iogroup='+IntToStr(iogroup)+' addr='+ConfigTags[4]);

			if     ( dir = 'I' ) then begin
				val(ConfigTags[4],i_address[iogroup]);
				i_devicetype[iogroup]:=ConfigTags[5,1];
{$IFDEF ARMGENERIC}
				if ( ConfigTags[5]='A' ) then     // ARMGENERIC Device
				  armgeneric_gpiodir(i_address[iogroup],iogroup,0); //Dir=0 -> In dir
{$ENDIF}
				if (debugFlag) then debugLOG ('PhysMach',2,'Input Group '+IntToStr(iogroup)+'devicetype='+i_devicetype[iogroup]);
			end
			else if( dir = 'O' ) then begin
				val(ConfigTags[4],o_address[iogroup]);
				o_devicetype[iogroup]:=ConfigTags[5,1];
{$IFDEF ARMGENERIC}
				if ( ConfigTags[5]='A' ) then
				  armgeneric_gpiodir(o_address[iogroup],iogroup,1); //Dir=1 -> out dir
{$ENDIF}
				if (debugFlag) then debugLOG ('PhysMach',2,'Output Group '+IntToStr(iogroup)+'devicetype='+o_devicetype[iogroup]);
			end
			else if( dir = 'C' ) then begin
				val(ConfigTags[4],c_address[iogroup]);
				c_devicetype[iogroup]:=ConfigTags[5,1];
				if (debugFlag) then debugLOG ('PhysMach',2,'Counter Group '+IntToStr(iogroup)+'devicetype='+i_devicetype[iogroup]);
			end
			else if( dir = 'A' ) then begin
				val(ConfigTags[4],a_address[iogroup]);
				a_devicetype[iogroup]:=ConfigTags[5,1];
				if debugFlag then debugLOG('PhysMach',2,'Analog InLine='+IntToStr(iogroup)+' Address='+IntToStr(a_address[iogroup]));
			end
			else if( dir = 'U' ) then begin
				val(ConfigTags[4],a_address[iogroup]);
				u_devicetype[iogroup]:=ConfigTags[5,1];
				if debugFlag then debugLOG('PhysMach',2,'Analog OutLine='+IntToStr(iogroup)+' Address='+IntToStr(a_address[iogroup]));
			end;
		end
		else if (ConfigTags[1] = 'ASSIGN') then begin
			if debugFlag then debugLOG('PhysMach',2,' ASSIGN Tag found: '+ConfigTags[2]);
			{ for ARMgeneric and GHoma WLAN Power Plug this is needed to get additional config data }
			{ Syntax: ASSIGN DEVICE ADDRESS BIT GPIO/DATA						}
			case char(ConfigTags[2,1]) of
{$IFDEF ARMGENERIC}
			  'A' : begin
				armgeneric_gpio(StrToInt(ConfigTags[3]),StrToInt(ConfigTags[4]),StrToInt(ConfigTags[5]));
				if debugFlag then debugLOG('PhysMach',2,'Address='+ConfigTags[3]+' Bit='+(ConfigTags[4])+' GPIO='+ConfigTags[5]);
				armgeneric_exportGPIO(StrToInt(ConfigTags[3]),StrToInt(ConfigTags[4]),StrToInt(ConfigTags[5]));
			      end;
{$ENDIF}
			  'W' : begin
				//GHoma WLAN Power Plug
			      end

			  else begin
				writeln (' Error in config file, wrong Device in ASSIGN Statement ');
				writeln ( zeile );
				halt (1);
			  end
			end
		end
		{ if a callback function is registered  call this function }
		else begin
		    if CfgCallbackFunc <> nil then begin
			CfgLine:=zeile;
			CfgCallbackFunc;
		    end;
		end;
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
		if debugFlag then debugLOG('PhysMach',2,'PhysMachInit: x='+IntToStr(y)+' a_devicetype['+IntToStr(y)+']='+a_devicetype[y]+' analog_in['+IntToStr(y)+']='+IntToStr(analog_in[y]));
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
		'd'	: ;   // dummy
{$ifdef DILPC}
		'D'	: begin
				dil_close();
			  end;
{$endif}
{$ifdef LPT}
		'L'	: begin
				lp_close();
			  end;
{$endif}
{$ifdef PIO}
		'P'	: begin
				pio_close();
			  end;
{$endif}
{$ifdef JOY}
		'J'	: begin
				joy_close();
			  end;
{$endif}
{$ifdef KOLTER}
		'K'	: begin
				kolterPCI_close();
			  end;
		'O'	: begin
				kolterOpto3_close();
			  end;
		'T'	: begin
				adc12lc_close();
			  end;
{$endif}
{$ifdef FUNK}
		'F'	: begin
				funk_close();
			  end;
{$endif}
{$ifdef BMCM}
		'B'	: begin
				bmcm_close();
			  end;
{$endif}
{$ifdef HTTP}
		'H' 	: begin
				http_close();
			  end;
{$endif}
{$ifdef RND}
		'R'	: begin
				rnd_close();
			  end;
{$endif}
{$ifdef IOW}
		'I'	: begin
				iow_close();
			  end;
{$endif}
{$ifdef EXEC}
		'E'	: begin
				exec_close();
			  end;
{$endif}
{$ifdef USB8}
		'U'	: begin
				usb8_close();
			  end;
{$endif}
{$ifdef Gnublin}
		'G'	: begin
				gnublin_close(initstring);
			  end;
{$endif}
{$ifdef ARMGENERIC}
		'A'	: begin
				armgeneric_close(initstring);
			  end;
{$endif}
{$ifdef AVR}
		'N'	: begin
				avrnet_close(initstring);
			  end;
{$endif}
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
		if debugFlag then debugLOG('PhysMach',2,'PhysMachReadAnalog i='+IntToStr(i));
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
		if debugFlag then debugLOG('PhysMach',2,'PhysMachReadAnalog i='+IntToStr(i));
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
	if debugFlag then debugLOG('PhysMach',2,' Reading IO-Device: '+DeviceType);
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
			PhysMachReadAnalogDevice(IOGroup);

		// handle counters
		if (c_devicetype[IOGroup] = DeviceType) then
			PhysMachReadCounter(IOGroup);

		inc(IOGroup);
	until (IOGroup > group_max);
end;


begin
	debugFlag:=false;
end.
