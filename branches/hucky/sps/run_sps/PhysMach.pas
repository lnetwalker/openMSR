unit PhysMach;

interface




implementation
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
	{ the devicetype n/c means unconfigured }
	for x:=1 to group_max do begin 
		i_devicetype[x]:='-';
		o_devicetype[x]:='-';
		c_devicetype[x]:='-';
	end;
	hwPlatform:='';	         
end;                               { ****ENDE INIT ****}


procedure PhysMachReadDigital;               { lieﬂt eingangswerte ein }

var  
	wert,i           	: byte;
	io_group,x			: integer;

begin
	{ for every configured input the port must be read }
	x:=1;
	repeat
		io_group:=round(int(x/8)+1);
		if (i_devicetype[io_group] <> '-') then 
			case o_devicetype[io_group] of
				'D'	: wert:=dil_read_ports(i_address[io_group]);
				'L'	: wert:=lp_read_ports(i_address[io_group]);
				'I'	: wert:=iow_read_ports(i_address[io_group]);
				'P'	: wert:=pio_read_ports(i_address[io_group]);
				'J'	: wert:=joy_read_ports(i_address[io_group]);
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
			if (debug ) then begin
		 		if ( k=7 ) then write('A group ',x,'    ');
		 		write (ausgang[k+x],' ');
		 		if (k=0 ) then writeln;
			end;		
		end;   
		io_group:=round(int(x/8)+1);
		if (o_devicetype[io_group] <> '-') then 
			case o_devicetype[io_group] of
				'D'	: dil_write_ports(o_address[io_group],wert);
				'L'	: lp_write_ports(o_address[io_group],wert);
				'I'	: iow_write_ports(o_address[io_group],wert);
				'P'	: pio_write_ports(o_address[io_group],wert);
				'J'	: joy_write_ports(o_address[io_group],wert);
			end;	
		x:=x+8;
	until ( x > io_max );
end;                               { **** ENDE SET_OUTPUT **** }



procedure PhysMachCounter;                    { z‰hlt timer und counter herunter liesst counter hardware }

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
				'D'	: dil_read_ports(i_address[io_group]);
				'L'	: lp_read_ports(i_address[io_group]);
				'I'	: iow_read_ports(i_address[io_group]);
				'P'	: pio_read_ports(i_address[io_group]);
				'J'	: joy_read_ports(i_address[io_group]);
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
	for c:=1 to cnt_max do begin if z[c]=0 then zahler[c]:=true;
end;                               { **** ENDE COUNT_DOWN ****       }


begin

end.
