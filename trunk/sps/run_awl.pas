

{ virtuelle Maschine V 1.1 }

{$i ./run_awl.h}
{$i ./awl_interpreter.pas}

procedure run_awl_menu;

begin
     cursor_off;
     textcolor(Black);textbackground(green);
     my_wwindow (2,screeny-4,screenx,screeny,'[HELP]','',false);
     writeln(' 1-8 -> E1-E8, Shift 1-8 -> E9-E16, ALT 1-8 -> E17-E24 ');
	 write  (' q-i -> Z1-Z8, Shift q-i -> Z9-Z16, a-f-> Analog 1-4 IN');
     textbackground(lightgray);
     my_wwindow (2,2,screenx,screeny-4,'[RUN]','<ESC>',false);
     write('NUMBER   0000000001111111111222222222233333333334444444444');
     writeln('555555555566666');
     write('         1234567890123456789012345678901234567890123456789');
     writeln('012345678901234');
     gotoxy(1,4);writeln('MARKER ');
     gotoxy(1,5);writeln('TIMER  ');
     gotoxy(1,6);writeln('COUNTER');
     gotoxy(1,8);writeln('EINGANG');
     gotoxy(1,9);writeln('AUSGANG');
     gotoxy(1,11);write('NUMBER    :   1     2     3     4   ');
     writeln('  5     6     7     8');
     gotoxy(1,13);writeln('TIMERWERT :');
     gotoxy(1,14);writeln('ZÄHLERWERT:');
     gotoxy(1,15);writeln('ANALOG IN :');
 end;

procedure print_in_out;            { gibt die zustände der ein-/ausgänge  }
                                   { auf bildschirm aus }
var i                : byte;

begin
  gotoxy (10,4);							
  for i:=1 to 64 do write(ord(marker[i]));				
  gotoxy (10,5);							
  for i:=1 to 16 do write(ord(timer[i]));				
  gotoxy (10,6);							
  for i:=1 to 16 do write(ord(zahler[i]));				
  gotoxy (10,8);
  for i:= 1 to 64 do write(ord(eingang[i]));
  gotoxy (10,9);
  for i:= 1 to 64 do write(ord(ausgang[i]));
  gotoxy (13,13);							
  write (t[1]:5,' ',t[2]:5,' ',t[3]:5,' ',t[4]:5,' ');			
  writeln(t[5]:5,' ',t[6]:5,' ',t[7]:5,' ',t[8]:5,' ');		
  gotoxy (13,14);						       
  write (z[1]:5,' ',z[2]:5,' ',z[3]:5,' ',z[4]:5,' ');  	       
  writeln(z[5]:5,' ',z[6]:5,' ',z[7]:5,' ',z[8]:5,' ');
  gotoxy (13,15);
  write(analog_in[1]:5,' ',analog_in[2]:5,' ',analog_in[3]:5,' ',analog_in[4]:5);
 
  writeln('');
    						        	      
  if extern then write('   EXTERNAL SIGNALS')			       
  else write('   INTERNAL SIGNALS');				       
end;                              { **** ENDE PRINT_IN_OUT **** }



function next_event:byte;
var 	
	key		:byte;
	
begin
	{ hier einfach: tasten:=ord(readkey); dann single step !! geil ;) }
     if keypressed then key:=ord(readkey)
     else key:=ord('^');
	 next_event:=key;
end;


procedure chk_inputs(key:byte);               { ließt eingangswerte ein }


begin
     case key of
         33 : eingang[9]:=not(eingang[9]);  { shift und 1-8 fuer E9-E16 }
         34 : eingang[10]:=not(eingang[10]);
        	  
         36 : eingang[12]:=not(eingang[12]);
         37 : eingang[13]:=not(eingang[13]);
         38 : eingang[14]:=not(eingang[14]);
			  
         40 : eingang[16]:=not(eingang[16]);

         47 : eingang[15]:=not(eingang[15]);

         49 : eingang[1]:=not(eingang[1]);  { 1-8 fuer Eingaenge E1-E8}
         50 : eingang[2]:=not(eingang[2]);
         51 : eingang[3]:=not(eingang[3]);
         52 : eingang[4]:=not(eingang[4]);
         53 : eingang[5]:=not(eingang[5]);
         54 : eingang[6]:=not(eingang[6]);
         55 : eingang[7]:=not(eingang[7]);
         56 : eingang[8]:=not(eingang[8]);
		
        167 : eingang[11]:=not(eingang[11]); { shift 3 für E11 }

		177 : eingang[17]:=not(eingang[17]); { alt 1-8 für E17-E24 }
		178 : eingang[18]:=not(eingang[18]);
		179 : eingang[19]:=not(eingang[19]);
		180 : eingang[20]:=not(eingang[20]);
		181 : eingang[21]:=not(eingang[21]);
		182 : eingang[22]:=not(eingang[22]);
		183 : eingang[23]:=not(eingang[23]);
		184 : eingang[24]:=not(eingang[24]);
		
     end;
end;


procedure chk_analoginputs(key:byte);

begin
     case key of
	 97  :begin
	    	inc(analog_in[1]);
			if ( analog_in[1] > 255 ) then analog_in[1]:=0;
	      end;     
     100 :begin
	    	inc(analog_in[3]);
			if ( analog_in[3] > 255 ) then analog_in[3]:=0;
	      end;
	 102:begin
	    	inc(analog_in[4]);
			if ( analog_in[4] > 255 ) then analog_in[4]:=0;
	      end;     
	 115:begin
	    	inc(analog_in[2]);
			if ( analog_in[2] > 255 ) then analog_in[2]:=0;
	      end;     
     end;	      
end;                               {****  ENDE GET_INPUT ****}





procedure chk_counters(key:byte);              { zählt timer und counter herunter }

begin	
     case key of
         69 : dec(z[11]);      { shift und q-i fuer Zaehler Z9-Z16}
         73 : dec(z[16]);
         81 : dec(z[9]);
         82 : dec(z[12]);
         84 : dec(z[13]);
         85 : dec(z[15]);
         87 : dec(z[10]);
         90 : dec(z[14]);

        101 : dec(z[3]);      { q-i fuer Zaehler  Z1-Z8}
        105 : dec(z[8]);
        113 : dec(z[1]);
        114 : dec(z[4]);
        116 : dec(z[5]);
        117 : dec(z[7]);
        119 : dec(z[2]);
        122 : dec(z[6]);
     end;
					
end;                               { **** ENDE COUNT_DOWN **** }


procedure chk_control(key:byte);
begin
     case key of
	 	 27 : esc:=true;
	 end;	 
end;


procedure check_keyboard;

var taste : byte;
begin
	taste:=next_event;		
	if (taste<>ord('^')) then begin
		chk_inputs(taste);
		chk_analoginputs(taste);
		chk_counters(taste);
		chk_control(taste);
	end;
end;


procedure handle_counter;

var 
	c      :byte;
	
begin
     for c:=1 to cnt_max do if z[c]=0 then zahler[c]:=true;
end;



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


procedure init;
var x		:word;
begin
     for x:=1 to marker_max do Marker[x]:=false;
     for x:=1 to analog_max do analog_in[x]:=0;
     for x:=1 to akku_max do lastakku[x]:=false;
     for x:=1 to io_max do begin
         ausgang[x]:=false;
         eingang[x]:=false;
     end;
     for x:=1 to tim_max do begin
         timer[x]:=false;
         t[x]:=65535;
     end;
     for x:=1 to cnt_max do begin     
         zahler[x]:=false;
         zust[x]:=false;
         z[x]:=65535;
     end;	 
     extern:=false;
     esc:=false;
	 runs:=0;
	 TimeRuns:=160;
     maxTimeRuns:=TimeRuns*10;
	 time2:=1;
	 durchlauf:=0;
	 durchlauf100:=0;
	 durchlaufeProSec:=1000;
	 oldUmins:=1;
end;



procedure run_awl;                 { abarbeiten einer AWL }

begin                              {hp run_awl}
     if not(programm) then exit;
	 init;
     run_awl_menu;
     repeat
	 		if (runs<=0) or ( runs > TimeRuns) then begin
				{$ifdef LINUX}
				gettime(std,min,sec,ms,usec);
				{$else}
				gettime(std,min,sec,ms);
				{$endif}
				time1:=(((std*60+min)*60+sec)*1000+ms)*1000+usec;
			end;
			check_keyboard;
			handle_counter;	
			handle_timer;
			interpret;
			print_in_out;
			toggle_internal_clock(marker[62],marker[63],marker[64]);
			if watchdog > awl_max then esc:=true;
			inc(runs);
			if ( runs > TimeRuns ) then begin
				runs:=0;
				{$ifdef LINUX}
				gettime(std,min,sec,ms,usec);
				{$else}
				gettime(std,min,sec,ms);
				{$endif}
				time2:=(((((std*60+min)*60+sec)*1000+ms)*1000+usec)-time1)/1000/TimeRuns;
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
     until esc;

     window (2,2,screenx,screeny);textcolor(black);textbackground(black);clrscr;
     if extern then {port[port_b]:=$00};
     if watchdog > awl_max then begin
        textcolor(black);textbackground(white);
        my_wwindow (10,10,40,15,'[WATCHDOG]','<bel.taste>',true);
        sound(220);delay(200);nosound;
        writeln ('  RUNTIME-ERROR IN AWL');
        writeln ('  Zykluszeit überschritten ');
        write ('  weiter mit <bel. taste> !!!!');
        repeat
        until keypressed;
        readkey;
        window (10,10,40,15);textcolor(black);textbackground(black);clrscr;
     end
end;                               { **** ENDE RUN_AWL ****}
