program runsps;
{$M 16000,0,0}                   { 16000 Bytes STACK , kein HEAP }

{ porting to linux startet at 27.05.99 				}
{ don't blame me for "bad" code						}
{ some of the code inside is from my earliest steps }
{ in pascal and some of my least steps after years	}
{ where I coded not	 one simple line in pascal :) 	}
{ If you have improvements please contact me at 	}
{ hartmut@eilers.net								}
{ all code is copyright by Hartmut Eilers			}
{ the code is distributed under the GNU 			}
{ general public license							}
{ history 											}
{	27.05.1999    	start of Linux Port				}
{ 	03.10.2000	  	start of Version 1.7.1			}
{	11.10.2000	  	installed fpc 1.0 				}
{	11.10.2000	  	start analog processing 		}
{					EQ,LT,GT						}
{	10.09.2005	  	restructure code to support 	}
{					different hardware 				}
{	12.10.2005		started code to read 			}
{					configuaration file				}
{					set TAB STops to 4 started to 	}
{					beauitify code					}
{                                                   }
{   25.10.2005      run_sps is fully configurable,	}
{					hardware may be mixed			}
{	12.04.2006		added driver for joystick 		}
{					analog processing works ! 		}

{ virtual machine version 1.1						}
{ physical machine version 1.3						}


{$define newio}
{ undef newio if you need a binary running without 	}
{ iowarrior library e.g. DIL/Net PC					}
{ for windows only newio works						} 
uses 	dos,crt,
{$ifdef LINUX }
		oldlinux,dil_io_access,lp_io_access,pio_io_access,joy_io_access,
{$endif}
{$ifdef newio }
		iowkit_io_access;
{$else}
		iow_io_access;
{$endif}



{$i ./sps.h}
{$i ./run_awl.h }
{$i ./awl_interpreter.pas}

const 
{$ifdef LINUX}
	Platform = ' Linux ';
{$else}
	Platform = ' Windows ';
{$endif}	
    ProgNamVer  =' RUN_SPS  for'+Platform+version+' '+datum+' ';
    Copyright   ='      (c)  1989 - 2006 by Hartmut Eilers ';
	group_max   = round(io_max/8);     

var	i					: integer;
	i_address,
	o_address,
	c_address,
	a_address			: array [1..group_max] of LongInt; 
	i_devicetype,
	o_devicetype,
	c_devicetype,
	a_devicetype 		: array [1..group_max] of char;
	HWPlatform			: string;

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


procedure sps_laden;

var	f              		:text;
	zeile		   		:string[48];
	i,code  	   		:integer;   { code is currently a dummy, may be used for error detection }
	name		   		:string;

procedure get_file_name;           { namen des awl-files einlesen   }

begin
	write (' Filename : ');
	readln (name);
	if pos('.',name)=0 then name:=name+'.sps';
end;                               { **** ENDE GET_FILE_NAME **** }



begin
	i:=0;
	if paramcount=0 then get_file_name  { keine Aufrufparameter }
	else begin
		name:=paramstr(1);
		if pos('.',name)=0 then name:=name+'.sps';
	end;
	assign (f,name);
	{$I-} reset (f); {$I+}
	if ioresult <> 0 then
	begin
		sound(220);delay(200);nosound;
		writeln (' SPS-File nicht gefunden');
		halt(1);
	end;
	writeln(' Lade Programm ',name);
	while not(eof(f)) do
	begin
		inc(i);
		readln (f,zeile);
		val (copy(zeile,1,3),znr[i],code);
		operation[i] := copy(zeile,5,3);
		operand[i] := zeile[9];
		val (copy(zeile,11,5),par[i],code);
		comment[i] := copy (zeile,17,22);
	end;
	for i := 1 to anweismax do begin
		anweisung[i]:=anweis[i];
		if (length(anweis[i]) < 3) then begin
			repeat
				anweisung[i]:=concat(anweisung[i],' ');
		 	until (length(anweisung[i]) = 3);
		end;
	end;

	close (F);
	doserror:=0;
end;                               {**** ENDE SPS_LADEN **** }



procedure init;                    { initialisieren aller Variablen }

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




procedure run_awl;
{interrupt; }



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


begin                              		{ hp run_awl                      }
    get_input;                      	{ INPUTS lesen                    }
	get_analog;							{ analoge inputs lesen			  }
    interpret;                      	{ einen AWLdurchlauf abarbeiten   }
    set_output;                     	{ OUTPUTS ausgeben                }
    count_down;                     	{ TIMER / ZAHLER aktualisieren    }
    toggle_internal_clock(marker[62],marker[63],marker[64]);{ interne TAKTE M62-M64 toggeln   }
    if (debug) then begin
    	delay (1000);
    	writeln ('###########################################################################');
    end;
end;                               { **** ENDE RUN_AWL ****          }


begin                              { SPS_SIMULATION           }
    { signal handling is needed here, also the program should go in background 	}
    { and at least there should be something done with the load			}
    { set a very nice priority }

{$ifdef LINUX}
    nice(20);
{$endif}
    init;
	load_cfg;
    write(ProgNamVer);
	writeln(HWPlatform);
    writeln(copyright);
    sps_laden;
    if (debug) then begin
	 	for i:=1 to awl_max do writeln (i:3,operation[i]:5, operand[i]:4,par[i]:4,comment[i]:22);
		writeln (' Configured input ports :');
		for i:=1 to group_max do writeln(i:3,i_address[i]:6,i_devicetype[i]:6);
		writeln (' Configured output ports :');
		for i:=1 to group_max do writeln(i:3,o_address[i]:6,o_devicetype[i]:6);
		writeln (' Configured counter ports :');
		for i:=1 to group_max do writeln(i:3,c_address[i]:6,c_devicetype[i]:6);
	end;	
    writeln('AWL gestartet');
    repeat
		run_awl
    until keypressed;	     	
end.                               { **** SPS_SIMULATION **** }
