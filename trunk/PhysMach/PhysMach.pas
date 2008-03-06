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

{ $Id$S }

interface

const
	io_max			= 128;
	group_max		= round(io_max/8);
	marker_max		= 255;
	akku_max		= 16;
	cnt_max			= 16;
	tim_max			= 16;
	analog_max		= 64;

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


procedure PhysMachInit;
procedure PhysMachReadDigital;
procedure PhysMachWriteDigital;
procedure PhysMachCounter;
procedure PhysMachloadCfg(cfgFilename : string);
procedure PhysMachReadAnalog;
procedure PhysMachTimer;

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


procedure PhysMachloadCfg(cfgFilename : string);
var
	f				: text;
	zeile		   		: string[180];
	initdevice			: char;
	initstring			: string;
	dir				: shortString;
	iogroup				: integer;
	
begin
	assign (f,cfgFilename);
	{$I-} reset (f); {$I+}
	if ioresult <> 0 then
	begin
		writeln (' Config-File nicht gefunden');
		halt(1);
	end;
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
	hwPlatform:='';
end;                               { ****ENDE INIT ****}


procedure PhysMachReadDigital;               { liesst eingangswerte ein }

var  
	wert,i           	: byte;
	io_group,x			: integer;

begin
	{ for every configured input the port must be read }
	x:=1;
	repeat
		io_group:=round(int(x/8)+1);
		if (i_devicetype[io_group] <> '-') then 
			case i_devicetype[io_group] of
{$ifdef LINUX}
				'D'	: wert:=dil_read_ports(i_address[io_group]);
				'L'	: wert:=lp_read_ports(i_address[io_group]);
				'P'	: wert:=pio_read_ports(i_address[io_group]);
				'J'	: wert:=joy_read_ports(i_address[io_group]);
{$endif}
				'R'	: wert:=rnd_read_ports(i_address[io_group]);
				'I'	: wert:=iow_read_ports(i_address[io_group]);
				'H' 	: wert:=http_read_ports(i_address[io_group]);
				'B' 	: wert:=bmcm_read_ports(i_address[io_group]);
				'E'	: wert:=exec_read_ports(i_address[io_group]);
			end	
		else
			wert:=0;
		if (debugFlag) then 
			writeln	('PhysMach:PhysMachReadDigital   group ',io_group,' -> ',wert); 
		for i:=7 downto 0 do begin	
			if wert>=power[i] then begin
		   		eingang[x+i]:=true;
				wert:=wert-power[i]
			end
			else 
				eingang[x+i]:=false;
			if (debugFlag ) then begin
				if ( i=7 ) then write('E group ',x,'   ');
			   	write (eingang[x+i],' ');
			   	if (i=0 ) then writeln;
			end 	  
		end;
		x:=x+8
	until ( x > io_max );
end;



procedure PhysMachWriteDigital;              { gibt Ausg.werte an I/O Hardware aus}
var 
	k,wert				: byte;
	io_group,x			: integer;
	
begin
	x:=1;
	repeat
		wert:=0;
		for  k:=7 downto 0 do begin
			wert:=wert+power[k]*ord(ausgang[k+x]);
			if (debugFlag ) then begin
		 		if ( k=7 ) then write('A group ',x,'    ');
		 		write (ausgang[k+x],' ');
		 		if (k=0 ) then writeln;
			end;		
		end;
		io_group:=round(int(x/8)+1);
		if (o_devicetype[io_group] <> '-') then 
			if debug then writeln('writing device ',o_devicetype[io_group],' Addr ',o_address[io_group],' Value ',wert);
			case o_devicetype[io_group] of
{$ifdef LINUX}
				'D'	: dil_write_ports(o_address[io_group],wert);
				'L'	: lp_write_ports(o_address[io_group],wert);
				'P'	: pio_write_ports(o_address[io_group],wert);
				'J'	: joy_write_ports(o_address[io_group],wert);
{$endif}
				'R' 	: rnd_write_ports(o_address[io_group],wert);
				'I'	: iow_write_ports(o_address[io_group],wert);
				'H' 	: http_write_ports(o_address[io_group],wert);
				'B' 	: bmcm_write_ports(o_address[io_group],wert);
				'E'	: exec_write_ports(o_address[io_group],wert);
			end;	
		x:=x+8;
	until ( x > io_max );
end;					{ **** ENDE SET_OUTPUT **** }



procedure PhysMachCounter;		{ zaehlt timer und counter herunter liesst counter hardware }

var 
	c,wert				: byte;
	x,io_group			: integer;

begin
	for c:=1 to tim_max do begin
		if t[c] > 0 then t[c]:=t[c]-1;	{ Zeitzaehler decrementieren  }
		if t[c]=0 then timer[c]:=true	{ zeitzaehler = 0? ja ==> TIMER auf 1}
	end;
	x:=1;
	repeat
		io_group:=round(int(x/8)+1);
		if (c_devicetype[io_group] <> '-') then begin 

			if debug then writeln('reading Counter type ',c_devicetype[io_group],' Adresse ',c_address[io_group]);

			{ ZAEHLEReingaenge lesen  }
			case c_devicetype[io_group] of
{$ifdef LINUX}
				'D'	: wert:=dil_read_ports(c_address[io_group]);
				'L'	: wert:=lp_read_ports(c_address[io_group]);
				'P'	: wert:=pio_read_ports(c_address[io_group]);
				'J'	: wert:=joy_read_ports(c_address[io_group]);
{$endif}
				'R' 	: wert:=rnd_read_ports(c_address[io_group]);
				'I'	: wert:=iow_read_ports(c_address[io_group]);
				'H' 	: wert:=http_read_ports(c_address[io_group]);
				'B' 	: wert:=bmcm_read_ports(c_address[io_group]);
				'E'	: wert:=exec_read_ports(c_address[io_group]);
			end
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
			if wert mod 2 = 0 then zust[c+x-1]:=false 			{ wenn low dann 0 speichern	}
			else	{ zust[] ist high }
				if not(zust[c+x-1]) then begin 				{ wenn pos. Flanke am Eingang }
					zust[c+x-1]:=true;		  		{ dann 1 speichern			}
					if z[c+x-1]>0 then z[c+x-1]:=z[c+x-1]-1;	{ und ISTwert herunterz�en } 
					if z[c+x-1]=0 then zahler[c+x-1]:=true;   	{ wenn ISTwert 0 dann ZAHLER 1}
				end;
			wert := wert div 2;
		end;
		x:=x+8;
	until ( x > cnt_max );
	//for c:=1 to cnt_max do  if z[c]=0 then zahler[c]:=true;
end;                               { **** ENDE COUNT_DOWN ****       }



procedure PhysMachReadAnalog;				{ read analog inputs }
var
	x				: integer;

begin
	x:=0;
	repeat
		if (a_devicetype[x] <> '-') then
			case a_devicetype[x] of
{$ifdef LINUX}
				'J' 	: analog_in[x+1]:=joy_read_ports(a_address[x],x);
				'B' 	: analog_in[x]:=bmcm_read_analog(a_address[x]);
{$endif}
				'H'	: analog_in[x+1]:=http_read_ports(a_address[x]);
				'E'	: analog_in[x]:=exec_read_analog(a_address[x]);
			end;
		if (debugFlag) then writeln('Analog_in[',x+1,']=',analog_in[x+1]);
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
	for c:=13 to 16 do begin
		if t[c] >= 0 then t[c]:=t[c]-1;
		if t[c]=0 then timer[c]:=true
	end;

	{ END OF TIMER }
end;


begin
end.
