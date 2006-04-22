{ This is the physical machine Version 1.3 			}
{ features input outputs analogIn counter and timer }


procedure load_cfg;
var	f					: text;
	zeile		   		: string[48];
	initdevice			: char;
	initstring			: string;
	dir					: shortString;
	iogroup				: integer;
	
begin
	assign (f,'.run_sps.cfg');
	{$I-} reset (f); {$I+}
	if ioresult <> 0 then
	begin
		sound(220);delay(200);nosound;
		writeln (' Config-File nicht gefunden');
		halt(1);
	end;
	while not(eof(f)) do begin
		readln (f,zeile);
		if ( copy(zeile,1,6) = 'DEVICE' ) then begin
			if ( debug ) then writeln ('device detected');
			{ device line looks like }
			{ DEVICE!P!$307:$99 }
			initdevice:=zeile[8];
			initstring:=copy(zeile,10,length(zeile)-9);
			{ call the initfunction of that device }
			if (debug) then writeln('device ',initdevice,'   ',initstring);
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
			end;	
			
		end
		else if (copy(zeile,1,4) = 'PORT') then begin
			if ( debug ) then writeln ('port detected');
			{port line looks like }
			{PORT!I!  1! $00!I}
			dir:=copy(zeile,6,1);
			val(copy(zeile,8,3),iogroup);
			if     ( dir = 'I' ) then begin
				val(copy(zeile,12,4),i_address[iogroup]);
				i_devicetype[iogroup]:=zeile[17];
				if (debug) then writeln('Input Group ',iogroup,'devicetype=',i_devicetype[iogroup]);
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
			end;
			
		end;
		{ ignore everything else }		
	end;
	close (F);
end;


procedure get_input;               { lieﬂt eingangswerte ein }

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
				'I'	: wert:=iow_read_ports(i_address[io_group]);
			end	
		else
			wert:=0;
		if (debug) then 
			writeln	('run_sps:get_input   group ',io_group,' -> ',wert); 
		for i:=7 downto 0 do begin	
			if wert>=power[i] then begin
		   		eingang[x+i]:=true;
				wert:=wert-power[i]
			end
			else 
				eingang[x+i]:=false;
			if (debug ) then begin
				if ( i=7 ) then write('E group ',x,'   ');
			   	write (eingang[x+i],' ');
			   	if (i=0 ) then writeln;
			end 	  
		end;
		x:=x+8
	until ( x > io_max );	 	  
end;

procedure get_analog;				{ read analog inputs }
var
	x					: integer;

begin
	x:=0;
	repeat
		if (a_devicetype[x] <> '-') then
			case a_devicetype[x] of
{$ifdef LINUX}
				'J' : analog_in[x+1]:=joy_read_ports(a_address[x],x);
{$endif}
				'X'	: { this is just a dummy for windows, so there is no empty case statement }
			end;
			if (debug) then writeln('Analog_in[',x+1,']=',analog_in[x+1]);
		inc(x);
	until ( x > analog_max );
end;


procedure set_output;              { gibt Ausg.werte an I/O Hardware aus}
var 
	k,wert				: byte;
	io_group,x			: integer;
	
begin
	x:=1;
	repeat
		wert:=0;
		for  k:=7 downto 0 do begin
			wert:=wert+power[k]*ord(ausgang[k+x]);
			if (debug ) then begin
		 		if ( k=7 ) then write('A group ',x,'    ');
		 		write (ausgang[k+x],' ');
		 		if (k=0 ) then writeln;
			end;		
		end;
		io_group:=round(int(x/8)+1);
		if (o_devicetype[io_group] <> '-') then 
			case o_devicetype[io_group] of
{$ifdef LINUX}
				'D'	: dil_write_ports(o_address[io_group],wert);
				'L'	: lp_write_ports(o_address[io_group],wert);
				'P'	: pio_write_ports(o_address[io_group],wert);
				'J'	: joy_write_ports(o_address[io_group],wert);
{$endif}
				'I'	: iow_write_ports(o_address[io_group],wert);
			end;	
		x:=x+8;
	until ( x > io_max );
end;                               { **** ENDE SET_OUTPUT **** }

procedure count_down;                    { z‰hlt timer und counter herunter liesst counter hardware }

var c,wert              : byte;
	x,io_group			: integer;

begin
	for c:=1 to tim_max do begin
		if t[c] > 0 then t[c]:=t[c]-1;  	 { Zeitz‰hler decrementieren  }
		if t[c]=0 then timer[c]:=true  { zeitz‰hler = 0? ja ==> TIMER auf 1}
	end;
	x:=1;
	repeat
		io_group:=round(int(x/8)+1);
		if (c_devicetype[io_group] <> '-') then 
			{ ZƒHLEReing‰nge lesen  }
			case o_devicetype[io_group] of
{$ifdef LINUX}
				'D'	: dil_read_ports(i_address[io_group]);
				'L'	: lp_read_ports(i_address[io_group]);
				'P'	: pio_read_ports(i_address[io_group]);
				'J'	: joy_read_ports(i_address[io_group]);
{$endif}
				'I'	: iow_read_ports(i_address[io_group]);
			end
		else
			wert:=0;
			
		for c:=1 to 8 do begin
			if wert mod 2 = 0 then zust[c+x-1]:=false { wenn low dann 0 speichern	}
			else
				if not(zust[c+x-1]) then begin  		{ wenn pos. Flanke am Eingang }
					zust[c+x-1]:=true;  				  { dann 1 speichern			}
					if z[c+x-1]>0 then z[c+x-1]:=z[c+x-1]-1;	  {und ISTwert herunterz‰len } 
					if z[c+x-1]=0 then zahler[c+x-1]:=true;   { wenn ISTwert 0 dann ZAHLER 1}
				end;
			wert := wert div 2;
		end;
		x:=x+8;
	until ( x > cnt_max );
	for c:=1 to cnt_max do if z[c]=0 then zahler[c]:=true;
end;                               { **** ENDE COUNT_DOWN ****       }


procedure handle_timer;

var	c	:byte;

begin
	inc(durchlauf);								{ timerbasis = 1s }
	inc(durchlauf100);							{ timerbasis = 100 ms }							
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


function timeNow:Real;
begin
	{$ifdef LINUX}
	gettime(std,min,sec,ms,usec);
	{$else}
	gettime(std,min,sec,ms);
	{$endif}
	timeNow:=(((std*60+min)*60+sec)*1000+ms)*1000+usec;
end;


procedure RPMs;
begin
	inc(runs);
	if ( runs > TimeRuns ) then begin
		runs:=0;
		time2:=timeNow;
		if (time2<=0) then begin
			{TimeRuns:=TimeRuns*2;}
			time2:=1;
		end;	
		durchlaufeProSec:=trunc(1000/time2)	;
		{if (durchlaufeProSec/oldUmins>1.5) then TimeRuns:=TimeRuns*2 }
		{else if (durchlaufeProSec/oldUmins<0.5) then TimeRuns:=trunc(TimeRuns/2); }
		oldUmins:=durchlaufeProSec;
		if ( oldUmins=0 ) then oldUmins:=1; 
		if (timeRuns>maxTimeRuns) then TimeRuns:=maxTimeRuns;
		GotoXY(35,16);clreol;write('Cycletime Tz=',time2:5:2,' ms =',DurchlaufeProSec:5,' CPS ');
	end;	
end;

