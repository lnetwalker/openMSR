
procedure run_awl;                 { abarbeiten einer AWL }

{$i ./run_awl.h}
{$i ./awl_interpreter.pas}

procedure run_awl_menu;

begin
     cursor_off;
     textcolor(blue);textbackground(green);
     my_wwindow (2,screeny-3,screenx,screeny,'[HELP]','',false);
     write(' 1-8-> Eingänge ;Shift 1-8-> Zähler ; q-r -> analog IN');
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
     gotoxy(30,8);writeln('ANALOG IN');
     gotoxy(1,9);writeln('AUSGANG');
     gotoxy(1,11);write('NUMBER    :   1     2     3     4   ');
     writeln('  5     6     7     8');
     gotoxy(1,13);writeln('TIMERWERT :');
     gotoxy(1,14);writeln('ZÄHLERWERT:');
end;

procedure print_in_out;            { gibt die zustände der ein-/ausgänge  }
                                   { auf bildschirm aus }
var i                : byte;

begin
  gotoxy (10,4);							
  for i:=1 to 64 do write(ord(marker[i]));				
  gotoxy (10,5);							
  for i:=1 to 8 do write(ord(timer[i]));				
  gotoxy (10,6);							
  for i:=1 to 8 do write(ord(zahler[i]));				
  gotoxy (10,8);
  { dont blame me on the following stupid code, its a quick and dirty hack	}
  { to compile that under linux, because :				  	}
  { write(ord(ausgang[1]):1,ord(ausgang[2]):1,ord(ausgang[3]):1);		}
  { cause an: Internal Error 12 of the compiler					}
  for i:= 1 to 8 do write(ord(eingang[i]));
  gotoxy (44,8);
  write(analog_in[1]:4,analog_in[2]:4,analog_in[3]:4,analog_in[4]:4);
  gotoxy (10,9);
  for i:= 1 to 8 do write(ord(ausgang[i]));
  gotoxy (13,13);							
  write (t[1]:5,' ',t[2]:5,' ',t[3]:5,' ',t[4]:5,' ');			
  writeln(t[5]:5,' ',t[6]:5,' ',t[7]:5,' ',t[8]:5,' ');		
  gotoxy (13,14);						       
  write (z[1]:5,' ',z[2]:5,' ',z[3]:5,' ',z[4]:5,' ');  	       
  writeln(z[5]:5,' ',z[6]:5,' ',z[7]:5,' ',z[8]:5,' ');
  writeln('');
    						        	      
  if extern then write('   EXTERNAL SIGNALS')			       
  else write('   INTERNAL SIGNALS');				       
end;                              { **** ENDE PRINT_IN_OUT **** }


procedure get_input;               { ließt eingangswerte ein }

var tasten2           :byte;

procedure read_input;              { I/O Port A lesen        }
var  wert,i          :byte;

begin
     if pio then {wert:=port[port_a]};
     for i:=7 downto 0 do  begin
         if wert>=power[i] then begin
            eingang[i+1]:=true;
            wert:=wert-power[i]
         end
         else eingang[i+1]:=false;
     end;
end;                               { **** ENDE READ__INPUT ****}

begin
     if extern then read_input;
     case tasten of
         33 : dec(z[1]);      { shift und 1-8 fuer Zaehler }
         34 : dec(z[2]);
        
         36 : dec(z[4]);
         37 : dec(z[5]);
         38 : dec(z[6]);

         40 : dec(z[8]);

         47 : dec(z[7]);

        167 : dec(z[3]);
     end;
     case tasten of
         49 : eingang[1]:=not(eingang[1]);  { 1-8 fuer Eingaenge }
         50 : eingang[2]:=not(eingang[2]);
         51 : eingang[3]:=not(eingang[3]);
         52 : eingang[4]:=not(eingang[4]);
         53 : eingang[5]:=not(eingang[5]);
         54 : eingang[6]:=not(eingang[6]);
         55 : eingang[7]:=not(eingang[7]);
         56 : eingang[8]:=not(eingang[8]);
     end;
     case tasten of
	 101:begin
	    	inc(analog_in[3]);
		if ( analog_in[3] > 255 ) then analog_in[3]:=0;
	      end;     
         113 :begin
	    	inc(analog_in[1]);
		if ( analog_in[1] > 255 ) then analog_in[1]:=0;
	      end;
	 114:begin
	    	inc(analog_in[4]);
		if ( analog_in[4] > 255 ) then analog_in[4]:=0;
	      end;     
	 119:begin
	    	inc(analog_in[2]);
		if ( analog_in[2] > 255 ) then analog_in[2]:=0;
	      end;     
     end;	      
     if tasten=0 then begin
        if keypressed then tasten2:=ord(readkey);
        if (tasten2=67) and not(pio_use) then extern:=not(extern);
        if tasten2=68 then grafik:=not(grafik);
        if extern then read_input
        else
           case tasten2 of
                59 : eingang[1]:=not(eingang[1]);
                60 : eingang[2]:=not(eingang[2]);
                61 : eingang[3]:=not(eingang[3]);
                62 : eingang[4]:=not(eingang[4]);
                63 : eingang[5]:=not(eingang[5]);
                64 : eingang[6]:=not(eingang[6]);
                65 : eingang[7]:=not(eingang[7]);
                66 : eingang[8]:=not(eingang[8]);
           end


     end;
end;                               {****  ENDE GET_INPUT ****}


procedure set_output;              { gibt Ausg.werte an I/O Port B}
var       k,wert      : byte;
begin
     if extern then begin
        wert:=0;
        for  k:=0 to 7 do wert:=wert+power[k]*ord(ausgang[k+1]);
        if pio then {port[port_b]:=wert};
     end
end;                               { **** ENDE SET_OUTPUT **** }

procedure count_down;              { zählt timer und counter herunter }

var c,wert              : byte;

begin
     for c:=1 to 8 do begin
         if t[c] >= 0 then t[c]:=t[c]-1;
         if t[c]=0 then timer[c]:=true
     end;
     if extern then begin
        if pio then {wert:=port[port_c]};
        for c:=1 to 8 do begin
            if wert mod 2 = 0 then zust[c]:=false
            else
              if not(zust[c]) then begin
                 zust[c]:=true;
                 if z[c]>=0 then z[c]:=z[c]-1;
              end;
            wert := wert div 2
        end
     end;
     for c:=1 to 8 do if z[c]=0 then zahler[c]:=true;
end;                               { **** ENDE COUNT_DOWN **** }

procedure impuls;                  {zeichnet impulsdiagramm    }

var maxx,maxy,y,z         : word;
    xfakt,yfakt,x         : byte;
    ch                    : string[1];
    meldung               : string[80];


procedure set_hi_low;              {zeichnet linie für hi/ bzw. low }
var x                     : byte;
    z                     : word;
begin
     for x:=1 to 8 do begin
         z:=(x+3) * yfakt-8*ord(eingang[x]);
         if e[x] then begin
            line(y-8,z,y,z);
{            if ein_alt[x]<>eingang[x] then begin}
{               line(y-8,(x+3)*yfakt,y-8,(x+3)*yfakt-8);}
{               setlinestyle(dashedln,0,normwidth);}
{               line(y-8,(x+3)*yfakt,y-8,(maxaus+15)*yfakt);}
{               setlinestyle(solidln,0,normwidth);}
{            end;}
         end;
         z:=(x+15)*yfakt-8*ord(ausgang[x]);
         if a[x] then begin
            line(y-8,z,y,z);
{            if aus_alt[x]<>ausgang[x] then}
{               line(y-8,(x+15)*yfakt,y-8,(x+15)*yfakt-8);}
         end;
         ein_alt[x]:=eingang[x];
         aus_alt[x]:=ausgang[x];
     end;
     set_output;
end;                               { **** ENDE SET_HI_LOW ****}


begin                              { hp impuls }
     save_screen;
{     setgraphmode(graphmode);}
{     grapherror:=graphresult;}
{     if grapherror=0 then begin}
     if true then begin
        setfillstyle(emptyfill,black);
        maxx:=getmaxx;maxy:=getmaxy;
        xfakt:=round(maxx/80);yfakt:=round(maxy/25);
        settextjustify(lefttext,bottomtext);
        rectangle(0,0,maxx,maxy);
        meldung:='SPS-Simulator '+version+' (c) by H. Eilers '+datum;
        outtextxy(round(maxx/2-21*xfakt),1*yfakt,meldung);
        outtextxy(round(maxx*0.75-11*xfakt),2*yfakt,comment[1]);
        rectangle(33,3*yfakt,maxx,12*yfakt);
        rectangle(33,15*yfakt,maxx,24*yfakt);
        repeat
          bar(34,3*yfakt+1,maxx-1,12*yfakt-1);
          bar(2,12*yfakt+1,maxx-1,15*yfakt-1);
          bar(34,15*yfakt+1,maxx-1,24*yfakt-1);
          for x:=1 to 8 do begin
              str(x,ch);
              if e[x] then begin
                 outtextxy(9,(x+3)*yfakt,'E'+ch);
                 z:=(x+3)*yfakt+1;
                 line(33,z,maxx,z);
                 line(33,z+1,maxx,z+1);
              end;
              if a[x] then begin
                 outtextxy(9,(x+15)*yfakt,'A'+ch);
                 z:=(x+15)*yfakt+1;
                 line(33,z,maxx,z);
                 line(33,z+1,maxx,z+1);
              end
          end;
          outtextxy(1,14*yfakt,'Time');
          line (33,14*yfakt-4,maxx,14*yfakt-4);
          y:=33;
          while (y<=maxx) and grafik do begin
              line(y,14*yfakt-8,y,14*yfakt);
              inc(y,8);
              if keypressed then tasten:=ord(readkey);
              get_input;
              interpret;
              bar(12*xfakt,2*yfakt-8,14*xfakt,2*yfakt);
              if extern then
                 outtextxy(round(maxx/4-8*xfakt),2*yfakt,'EXTERNAL SIGNALS')
              else
                 outtextxy(round(maxx/4-8*xfakt),2*yfakt,'INTERNAL SIGNALS');
              toggle_internal_clock(marker[62],marker[63],marker[64]);
              set_hi_low;
              count_down;
          end;
          if extern then {port[port_b]:=$00};
          outtextxy(round(maxx/2-23*xfakt),3*yfakt,
                  '<F 10 tasten fuer zurueck   <P> fuer Hardcopy>');
        until not grafik;
        restorecrtmode
     end
     else begin
        writeln('Grafikfehler: ',grapherrormsg(grapherror));
        repeat
        until keypressed;
     end;
     grafik:=false;
     restore_screen;
     cursor_off;
     if mouseinstalled then mouse_on;
end;                               {**** ENDE IMPULS ****}


procedure check_action;
begin
     if keypressed then tasten:=ord(readkey)
     else tasten:=ord('d');
     if mouseinstalled then begin
          mouse_status (mouseX,mouseY,Leftbutton,Rightbutton);
          if Rightbutton then tasten:=27;
          if Leftbutton then begin
             case MouseY of
                  7 : if not(extern) then
                         case mouseX of
                              11 : dec(z[1]);
                              12 : dec(z[2]);
                              13 : dec(z[3]);
                              14 : dec(z[4]);
                              15 : dec(z[5]);
                              16 : dec(z[6]);
                              17 : dec(z[7]);
                              18 : dec(z[8]);
                         end;
                  9 : if not(extern) then
                         case mouseX of
                              11 : eingang[1]:=not(eingang[1]);
                              12 : eingang[2]:=not(eingang[2]);
                              13 : eingang[3]:=not(eingang[3]);
                              14 : eingang[4]:=not(eingang[4]);
                              15 : eingang[5]:=not(eingang[5]);
                              16 : eingang[6]:=not(eingang[6]);
                              17 : eingang[7]:=not(eingang[7]);
                              18 : eingang[8]:=not(eingang[8]);
                         end;
                 22 : begin
                        {$ifndef Demo}
                        if (mouseX>37) and (mouseX<57) then
                           extern:=not(extern);
                        {$endif}
                        if (mouseX>59) and (mousex<72) then begin
                           grafik:=not(grafik);
                           mouse_off;
                        end;
                      end;
             end;
          end;
     end;
end;

begin                              {hp run_awl}
     if not(programm) then exit;
     save_screen;
{     detectgraph(graphdriver,graphmode);}
{     initgraph(graphdriver,graphmode,'');}
{     grapherror:=graphresult;}
     if grapherror<>0 then begin
        writeln('Grafikfehler: ',grapherrormsg(grapherror));
        halt(grapherror);
     end;
     restorecrtmode;
     restore_screen;
     for x:=1 to 64 do Marker[x]:=false;
     for x:=1 to 4 do analog_in[x]:=0;
     for x:=1 to  8 do begin
         ein_alt[x]:=false;
         aus_alt[x]:=false;
         e[x]:=false;
         a[x]:=false;
         ausgang[x]:=false;
         eingang[x]:=false;
         lastakku[x]:=false;
         zahler[x]:=false;
         timer[x]:=false;
         t[x]:=65535;
         z[x]:=65535;
         zust[x]:=false;
     end;
     extern:=false;
     grafik:=false;
     tasten:=32;
     maxaus:=0;
     for x:=1 to awl_max do begin
         case operand[x] of
            'A'     : begin
                        a[par[x]]:=true;
                        if par[x] > maxaus then maxaus:=par[x];
                      end;
            'E'     : e[par[x]]:=true;
         end
     end;
     run_awl_menu;
     gettime(std,min,sec,ms);
     ms:=0;
     time1:=((std*60+min)*60+sec)*100+ms;
     for x:=1 to 600 do begin
         if keypressed then tasten:=ord('d')          { Dummy wegen Zeiterm}
         else tasten:=ord('d');
         get_input;
         if grafik then impuls;
         interpret;
         set_output;
         print_in_out;
         gotoxy(1,17);write('Checking AWL');
         count_down;
         toggle_internal_clock(marker[62],marker[63],marker[64]);
         if watchdog > awl_max then tasten:=27;
     end;
     gettime(std,min,sec,ms);
     ms:=0;
     time2:=((((std*60+min)*60+sec)*100+ms)-time1)/600;
     GotoXY(1,17);write('Zykluszeit Tz=',time2:5:2,' ms');
     if mouseinstalled then begin
        mouse_area(0,80,0,25);
        mouse_on;
     end;
     repeat
           check_action;
           get_input;
           if grafik then impuls;
           interpret;
           set_output;
           print_in_out;
           count_down;
           toggle_internal_clock(marker[62],marker[63],marker[64]);
           if watchdog > awl_max then tasten:=27;
     until tasten=27;
     if mouseinstalled then mouse_off;
     window (2,2,screenx,screeny);textcolor(black);textbackground(black);clrscr;
     if extern then {port[port_b]:=$00};
     if watchdog > awl_max then begin
        textcolor(black);textbackground(white);
        my_wwindow (10,10,40,15,'[WATCHDOG]','<bel.tasten>',true);
        sound(220);delay(200);nosound;
        writeln ('  RUNTIME-ERROR IN AWL');
        writeln ('  Zykluszeit überschritten ');
        write ('  weiter mit <tasten> !!!!');
        repeat
        until keypressed;
        tasten:=ord(readkey);
        window (10,10,40,15);textcolor(black);textbackground(black);clrscr;
     end
end;                               { **** ENDE RUN_AWL ****}
