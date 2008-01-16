
procedure run_awl;                 { abarbeiten einer AWL }

const  power             : array[0..7] of byte =(1,2,4,8,16,32,64,128);

var    extern,grafik,
       hard_copy         : boolean;
       std,min,sec,ms,x  : word;
       taste,
       maxaus            : byte;
       watchdog          : word;
       t,z               : array[1..8]  of word;
       marker            : array[1..64] of boolean;
       eingang,ausgang,
       ein_alt,aus_alt,
       timer,zahler,e,a,
       lastakku          : array[1..16] of boolean;
       zust              : array[1..8]  of boolean;
       zeit              : string[5];
       time1,time2       : real;

procedure run_awl_menu;

begin
     cursor_off;
     textcolor(black);textbackground(green);
     wwindow (2,22,80,25,'[HELP]','',false);
     write(' 1-8 -> ZÑhler ; F1-F8 -> EingÑnge ; F9 -> Intern/Extern ; F10 -> Grafik');
     textbackground(white);
     wwindow (2,2,80,21,'[RUN]','<ESC>',false);
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
     gotoxy(1,14);writeln('ZéHLERWERT:');
end;


procedure toggle_internal_clock;   { toggelt die internen clock-marker }

begin
    marker[64]:=not(marker[64]);
    if marker[64] then marker[63]:=not(marker[63]);
    if marker[63] and marker [64] then marker[62]:=not(marker[62]);
end;                               { **** ENDE TOGGLE_INTERNAL_CLOCK **** }


procedure print_in_out;            { gibt die zustÑnde der ein-/ausgÑnge  }
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
  write(ord(eingang[1]):1,ord(eingang[2]):1,ord(eingang[3]):1);
  write(ord(eingang[4]):1,ord(eingang[5]):1,ord(eingang[6]):1);
  writeln(ord(eingang[7]):1,ord(eingang[8]):1);
  gotoxy (10,9);
  write(ord(ausgang[1]):1,ord(ausgang[2]):1,ord(ausgang[3]):1);
  write(ord(ausgang[4]):1,ord(ausgang[5]):1,ord(ausgang[6]):1);
  writeln(ord(ausgang[7]):1,ord(ausgang[8]):1);
  gotoxy (13,13);
  write (t[1]:5,' ',t[2]:5,' ',t[3]:5,' ',t[4]:5,' ');
  writeln(t[5]:5,' ',t[6]:5,' ',t[7]:5,' ',t[8]:5,' ');
  gotoxy (13,14);
  write (z[1]:5,' ',z[2]:5,' ',z[3]:5,' ',z[4]:5,' ');
  writeln(z[5]:5,' ',z[6]:5,' ',z[7]:5,' ',z[8]:5,' ');
  writeln;
  if extern then write('   EXTERNAL SIGNALS')
  else write('   INTERNAL SIGNALS');
end;                              { **** ENDE PRINT_IN_OUT **** }



procedure get_input;               { lie·t eingangswerte ein }

var taste2           :byte;

procedure read_input;              { I/O Port A lesen        }
var  wert,i           :byte;

begin
     if pio then wert:=port[port_a];
     for i:=7 downto 0 do  begin
         if wert>=power[i] then begin
            eingang[i+1]:=true;
            wert:=wert-power[i]
         end
         else eingang[i+1]:=false;
     end
end;                               { **** ENDE READ__INPUT ****}

begin
     if extern then read_input;
     if (taste=80) or (taste=112) then Hard_copy:=true;
     case taste of
         49 : dec(z[1]);
         50 : dec(z[2]);
         51 : dec(z[3]);
         52 : dec(z[4]);
         53 : dec(z[5]);
         54 : dec(z[6]);
         55 : dec(z[7]);
         56 : dec(z[8]);
     end;
     if taste=0 then begin
        if keypressed then taste2:=ord(readkey);
        {$ifdef Demo}
        if (taste2=67) and not(pio_use) then extern:=not(extern);
        {$endif}
        if taste2=68 then grafik:=not(grafik);
        if extern then read_input
        else
           case taste2 of
                59 : eingang[1]:=not(eingang[1]);
                60 : eingang[2]:=not(eingang[2]);
                61 : eingang[3]:=not(eingang[3]);
                62 : eingang[4]:=not(eingang[4]);
                63 : eingang[5]:=not(eingang[5]);
                64 : eingang[6]:=not(eingang[6]);
                65 : eingang[7]:=not(eingang[7]);
                66 : eingang[8]:=not(eingang[8]);
           else

           end;
        end;
end;                               {****  ENDE GET_INPUT ****}

procedure interpret;               { interpretiert eine zeile der awl }

var    akku,help         : boolean;
       k                 : word;
       klammer,token     : byte;
       klammerakku       : array[1..255] of boolean;
       klammeroper       : array[1..255] of string3;
       aktuell,anweis    : string3;


procedure verkn;                   { verknÅpft akku mit hilfsregister }

procedure zerleg;                  {negiert ggf den zustand eines operanden}

var    inv               : boolean;{und weist ihn dem Hilfsregister zu }

begin
     inv:=false;
     if (aktuell='ON ') or (aktuell='UN ') then
        inv:=true;
     case operand[k] of
          'E':  if inv then
                   help:=not(eingang[par[k]])
                else
                   help:=eingang[par[k]];
          'A':  if inv then
                   help:=not(ausgang[par[k]])
                else
                   help:=ausgang[par[k]];
          'M':  if inv then
                   help:=not(marker[par[k]])
                else
                   help:=marker[par[k]];
          'T':  if inv then
                   help:=not(timer[par[k]])
                else
                   help:=timer[par[k]];
          'Z':  if inv then
                   help:=not(zahler[par[k]])
                else
                   help:=zahler[par[k]];
          else
          { fÅr spÑtere errorabfrage }
          end;
     inv:=false;
end;                               { **** ENDE ZERLEG *****       }

begin
     case token of
          3,4,7,8   : begin
                           inc(klammer);
                           klammerakku[klammer]:=akku;
                           akku:=true;
                           klammeroper[klammer]:=aktuell;
                      end
     else
          zerleg;
     end;
     case token of
          1,2       : akku:=akku or help;
          5,6       : akku:=akku and help;
     end
end;                               { **** ENDE VERKN ****}


function mehrfach (z:word):boolean;

begin
     mehrfach:=true;
     repeat
       inc(z);
     until operation[z]<>anweisung[19];
     if (operation[z]=anweisung[5]) or
        (operation[z]=anweisung[6]) or
        (operation[z]=anweisung[7]) or
        (operation[z]=anweisung[8]) then mehrfach:=false
end;


procedure zuweisen;                { weist den akkuinhalt einem ausg. od merker}
begin
     if token=11 then akku:=not(akku);
     case operand[k] of
          'A'      : ausgang[par[k]]:=akku;
          'M'      : marker[par[k]]:=akku;
     else
     {fÅr spÑtere errorabfrage }
     end;
     if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE ZUWEISEN **** }

procedure setzen;                  { setzt einen ausg. od. merker auf log 1}
begin
    if akku then begin
       case operand[k] of
            'A' : Ausgang[par[k]]:=true;
            'M' : marker [par[k]]:=true;
       else
       { fÅr spÑtere Fehlermeldung }
       end
    end;
    if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE SETZEN **** }

procedure rucksetzen;              { setzt einen ausg. od. merker auf log 0 }
begin
    if akku then begin
       case operand[k] of
            'A' : Ausgang[par[k]]:=false;
            'M' : marker [par[k]]:=false;
       else
       { fÅr spÑtere Fehlermeldung }
       end
    end;
    if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE RUCKSETZEN **** }

procedure klammer_zu;              { beendet letzte klammer und verknÅpft }
begin
     if (klammeroper[klammer]='ON(') or (klammeroper[klammer]='UN(') then
        klammerakku[klammer]:=not(klammerakku[klammer]);
     if (klammeroper[klammer]='O( ') or (klammeroper[klammer]='ON(') then
        akku:=akku or klammerakku[klammer];
     if (klammeroper[klammer]='U( ') or (klammeroper[klammer]='UN(') then
        akku:=akku and klammerakku[klammer];
     klammer:=klammer-1;
end;                               { **** ENDE KLAMMER_ZU **** }

procedure set_timer;               {timer auf startwert setzen}

begin
     if akku and not(lastakku[par[k]]) then begin
        t[par[k]]:=par[k+1];
        timer[par[k]]:=false;
        lastakku[par[k]]:=true;
     end
     else if not(akku) then begin
        t[par[k]]:=65535;
        timer[par[k]]:=false;
        lastakku[par[k]]:=false
     end;
     akku:=true
end;                               { **** ENDE SET_TIMER ****}

procedure set_counter;             { counter auf startwert setzen }

begin
     if akku and not(lastakku[par[k]+8]) then begin
        z[par[k]]:=par[k+1];
        zahler[par[k]]:=false;
        lastakku[par[k]+8]:=true
     end
     else if not(akku) then begin
             z[par[k]]:=65535;
             zahler[par[k]]:=false;
             lastakku[par[k]+8]:=false
          end;
     akku:=true
end;                               { **** ENDE SET_COUNTER ****}

begin
     K:=1;
     watchdog:=1;
     akku:=true;
     help:=false;
     klammer:=0;
     aktuell:=operation[k];
     while aktuell <> 'EN ' do
     begin
          token:=0;
          repeat
             inc(token);
             anweis:=anweisung[token];
          until (aktuell=anweis) or (token>20);
          case token of
               1..8    : verkn;
               9       : klammer_zu;
               10,11   : zuweisen;
               12      : setzen;
               13      : rucksetzen;
               14      : begin
                              K:=par[k]-1;
                              akku:=true
                         end;
               15      : if akku then begin
                            k:=par[k]-1;
                            akku:=true
                         end
                         else akku:=true;
               16      : ;
               17      : set_timer;
               18      : set_counter;
               19      : ;
               20      :
          else
          { fÅr spÑtere Fehlerabfrage }
          end;
          inc(k);
          inc(watchdog);
          aktuell:=operation[k];
          if watchdog > awl_max then aktuell:='EN ';
     end;
     if aktuell='EN ' then comment[k]:='Zykluszeit Tz='+zeit+' ms';
end;                               { **** ENDE INTERPRET **** }

procedure set_output;              { gibt Ausg.werte an I/O Port B}
var       k,wert      : byte;
begin
     if extern then begin
        wert:=0;
        for  k:=0 to 7 do wert:=wert+power[k]*ord(ausgang[k+1]);
        if pio then port[port_b]:=wert;
     end
end;                               { **** ENDE SET_OUTPUT **** }

procedure count_down;              { zÑhlt timer und counter herunter }

var c,wert              : byte;

begin
     for c:=1 to 8 do begin
         if t[c] >= 0 then t[c]:=t[c]-1;
         if t[c]=0 then timer[c]:=true
     end;
     if extern then begin
        if pio then wert:=port[port_c];
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


procedure set_hi_low;              {zeichnet linie fÅr hi/ bzw. low }
var x                     : byte;
    z                     : word;
begin
     for x:=1 to 8 do begin
         z:=(x+3) * yfakt-8*ord(eingang[x]);
         if e[x] then begin
            line(y-8,z,y,z);
            if ein_alt[x]<>eingang[x] then begin
               line(y-8,(x+3)*yfakt,y-8,(x+3)*yfakt-8);
               setlinestyle(dashedln,0,normwidth);
               line(y-8,(x+3)*yfakt,y-8,(maxaus+15)*yfakt);
               setlinestyle(solidln,0,normwidth);
            end;
         end;
         z:=(x+15)*yfakt-8*ord(ausgang[x]);
         if a[x] then begin
            line(y-8,z,y,z);
            if aus_alt[x]<>ausgang[x] then
               line(y-8,(x+15)*yfakt,y-8,(x+15)*yfakt-8);
         end;
         ein_alt[x]:=eingang[x];
         aus_alt[x]:=ausgang[x];
     end;
     set_output;
end;                               { **** ENDE SET_HI_LOW ****}


begin                              { hp impuls }
     save_screen;
     hard_copy:=false;
     setgraphmode(graphmode);
     grapherror:=graphresult;
     if grapherror=0 then begin
        setfillstyle(emptyfill,black);
        maxx:=getmaxx;maxy:=getmaxy;
        xfakt:=round(maxx/80);yfakt:=round(maxy/25);
        settextjustify(lefttext,bottomtext);
        rectangle(0,0,maxx,maxy);
        meldung:='SPS-Simulator '+version+' (c) by COMTOOLS '+datum;
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
              if keypressed then taste:=ord(readkey);
              get_input;
              interpret;
              bar(12*xfakt,2*yfakt-8,14*xfakt,2*yfakt);
              if extern then
                 outtextxy(round(maxx/4-8*xfakt),2*yfakt,'EXTERNAL SIGNALS')
              else
                 outtextxy(round(maxx/4-8*xfakt),2*yfakt,'INTERNAL SIGNALS');
              toggle_internal_clock;
              set_hi_low;
              count_down;
          end;
          if extern then port[port_b]:=$00;
          outtextxy(round(maxx/2-23*xfakt),3*yfakt,
                  '<F 10 Taste fuer zurueck   <P> fuer Hardcopy>');
          if hard_copy then begin
(*             hgrcopy (0,0,maxx,maxy,1,maxx,maxy);*)
             print_screen(maxx,maxy);
             hard_copy:=false;
          end;
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
     if keypressed then taste:=ord(readkey)
     else taste:=ord('d');
     if mouseinstalled then begin
          mouse_status (mouseX,mouseY,Leftbutton,Rightbutton);
          if Rightbutton then taste:=27;
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
     detectgraph(graphdriver,graphmode);
     initgraph(graphdriver,graphmode,'');
     grapherror:=graphresult;
     if grapherror<>0 then begin
        writeln('Grafikfehler: ',grapherrormsg(grapherror));
        halt(grapherror);
     end;
     restorecrtmode;
     restore_screen;
     for x:=1 to 64 do Marker[x]:=false;
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
     taste:=32;
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
     time1:=((std*60+min)*60+sec)*100+ms;
     for x:=1 to 20 do begin
         if keypressed then taste:=ord('d')          { Dummy wegen Zeiterm}
         else taste:=ord('d');
         get_input;
         if grafik then impuls;
         interpret;
         set_output;
         print_in_out;
         gotoxy(1,17);write('Checking AWL');
         count_down;
         toggle_internal_clock;
         if watchdog > awl_max then taste:=27;
     end;
     gettime(std,min,sec,ms);
     time2:=((((std*60+min)*60+sec)*100+ms)-time1)/20;
     str(time2:5:0,zeit);
     GotoXY(1,17);write('Zykluszeit Tz='+zeit+' ms');
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
           toggle_internal_clock;
           if watchdog > awl_max then taste:=27;
     until taste=27;
     if mouseinstalled then mouse_off;
     window (2,2,80,25);textcolor(black);textbackground(black);clrscr;
     if extern then port[port_b]:=$00;
     if watchdog > awl_max then begin
        textcolor(black);textbackground(white);
        wwindow (10,10,40,15,'[WATCHDOG]','<bel.TASTE>',true);
        sound(220);delay(200);nosound;
        writeln ('  RUNTIME-ERROR IN AWL');
        writeln ('  Zykluszeit Åberschritten ');
        write ('  weiter mit <TASTE> !!!!');
        repeat
        until keypressed;
        taste:=ord(readkey);
        window (10,10,40,15);textcolor(black);textbackground(black);clrscr;
     end
end;                               { **** ENDE RUN_AWL ****}
