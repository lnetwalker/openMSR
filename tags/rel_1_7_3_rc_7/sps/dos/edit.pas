
procedure edit;                    {editieren von awl}

const      CR           =#13;
           ESC          =#27;
           BCKSPCE      =#8;
           loesch       = '                                              ';
           anweis       : array [1..20] of string3 =(
                          'UN(','ON(','UN','ON','U(','O(','=N','JI','TE',
                          'ZR','EN','U','O',')','=','S','R','J','K','NOP');


var zeile,spalte,zeilnum    : byte;
    eingabe                 : char;
    textzeile               : string[48];


procedure auflist(s,e:byte);       {listen einer awl}

var x                       : byte;
begin
     gotoxy(1,1);
     for x:=s to e do begin
         write (znr[x]:3,' ',operation[x],' ',operand[x],' ');
         if par[x]>0 then write(par[x]:5) else write('     ');
         writeln(' ',comment[x]);
     end;
     spalte:=5;
end;                               {****ENDE AUFLIST ****}


procedure korrekt_jump(rufer:string12;nr:byte); { korrigiert die Sprung- }
                                                { ziele bei einf. od. lîsch.}
var z                       : byte;

begin
     for z:=1 to zeilnum do begin
         if (operation[z]=anweisung[14]) or
            (operation[z]=anweisung[15]) then begin  { 'J' oder 'JI' }
            if par[z] >= nr then
               if rufer = 'EINFöGEN ' then inc(par[z])
               else dec(par[z]);
         end;
     end;
end;                                {****ENDE KORREKT_JUMP****}


function lies_zeilnummer(rufer:string12):byte; { erfragt vom benutzer eine }
                                               { Zeilennummer              }
var z                       : byte;
begin
     repeat
        gotoxy(1,wherey);
        write(rufer,'Zeilennummer:');
        read(z);
     until (z>0) and (z<awl_max);
     lies_zeilnummer:=z;
end;                               { ****ENDE LIES_ZEILNUMMER **** }

procedure einfug;                  { einfÅgen einer zeile in die awl }
const ident='EINFöGEN ';
var x,y                     : byte;

begin
  if zeilnum < awl_max then begin
     x:=lies_zeilnummer(ident);
     for y:=zeilnum downto x do begin
         znr[y+1]:=znr[y]+1;
         operation[y+1]:=operation[y];
         operand[y+1]:=operand[y];
         par[y+1]:=par[y];
         comment[y+1]:=comment[y];
     end;
     operation[x]:='NOP';
     operand[x]:=' ';
     par[x]:=0;
     comment[x]:='                      ';
     inc(zeilnum);
     korrekt_jump(ident,x);
     clrscr;
     if x+19 < zeilnum-1 then auflist(x,x+19)
     else auflist(x,zeilnum-1);
     zeile:=x;
     gotoxy(1,wherey);
     write(zeilnum:3,' ');
     sicher:=true;
   end;
end;                               { **** ENDE EINFUG **** }

procedure loeschen;                { lîschen einer zeile der awl }
const ident='LôSCHEN ';
var x,y                     : byte;

begin
     x:=lies_zeilnummer(ident);
     for y:=x to zeilnum do begin
         znr[y]:=znr[y+1]-1;
         operation[y]:=operation[y+1];
         operand[y]:=operand[y+1];
         par[y]:=par[y+1];
         comment[y]:=comment[y+1];
     end;
     dec(zeilnum);
     korrekt_jump(ident,x);
     clrscr;
     if x+19 < zeilnum-1 then auflist(x,x+19)
     else auflist(x,zeilnum-1);
     zeile:=x;
     gotoxy(1,wherey);
     write(zeilnum:3,' ');
     sicher:=true;
end;                               { **** ENDE LOESCHEN **** }

procedure formatiere;              {formatieren einer awl-zeile}

var j,znum,p                : byte;
    error                   : integer;

begin
     j:=0;
     repeat
        inc(j);
     until (ord(textzeile[j]) < 48) or (ord(textzeile[j]) > 57);
     if j=1 then znum:=zeilnum
     else begin
        val(copy(textzeile,1,j-1),znum,error);
        delete(textzeile,1,j-1);
        zeilnum:=zeilnum-1;
     end;
     znr[znum]:=znum;
     j:=0;
     repeat
        inc(j);
        p:=pos(anweis[j],copy(textzeile,1,3))
     until (p>0) or (j>19);
     operation[znum]:=anweis[j];
     while length(operation[znum])<3 do operation[znum]:=operation[znum]+' ';
     delete(textzeile,1,length(anweis[j]));
     if j=11 then programm:=true;
     if (j=19) or (j=18) or (j=14) or (j=11) or (j=8) then
        operand[znum]:=' '
     else begin
        operand[znum]:=textzeile[1];
        delete(textzeile,1,1);
     end;
     j:=0;
     repeat
        inc(j);
     until (ord(textzeile[j]) < 48) or (ord(textzeile[j]) > 57);
     val(copy(textzeile,1,j-1),par[znum],error);
     delete(textzeile,1,j-1);
     comment[znum]:=textzeile;
     gotoxy(1,wherey);
     write(loesch);
     gotoxy(1,wherey);
     write (znr[znum]:3,' ',operation[znum],' ',operand[znum],' ');
     if par[znum]>0 then write(par[znum]:5) else write('     ');
     write(' ',comment[znum]);
end;                               {**** ENDE FORMATIEREN****}

procedure carret;                  {erzeugen eines zeilenvorschubes}

begin
     formatiere;
     spalte:=5;
     writeln;
     if wherey=21 then inc(zeile);
     inc(zeilnum);
     textzeile:=loesch;
     sicher:=true;
     write(zeilnum:3,' ');
end;                               { **** ENDE CARRET **** }

procedure steuer;                  { auswertung der Steuertasten}

const   auf             = #72;
        ab              = #80;
        pgup            = #73;
        pgdwn           = #81;
        f1              = #59;
        f2              = #60;

begin
     if keypressed then eingabe:= readkey
     else if mouse_event and mouseinstalled then begin
             if leftbutton and (mouseY=5) then eingabe:=f1;
             if leftbutton and (mouseY=6) then eingabe:=f2;
             if leftbutton and (mouseY=7) then begin
                if (mouseX>52) and (mouseX<57) then eingabe:=pgup;
                if (mouseX>59) and (mouseX<65) then eingabe:=pgdwn;
                if (mouseX>67) and (mouseX<70) then eingabe:=auf;
                if (mouseX>72) and (mouseX<76) then eingabe:=ab;
             end;
     end;
     case eingabe of
          f1      : einfug;
          f2      : loeschen;
          auf     : if zeile>1 then begin
                       clrscr;
                       dec(zeile);
                       if zeilnum-1 >= zeile+19 then auflist(zeile,zeile+19)
                       else auflist(zeile,zeilnum-1);
                       gotoxy(1,wherey);
                       write(zeilnum:3,' ');
                    end;
          ab      : if zeile<zeilnum-1 then begin
                       clrscr;
                       inc(zeile);
                       if zeile+19 <= zeilnum-1 then auflist(zeile,zeile+19)
                       else auflist (zeile,zeilnum-1);
                       gotoxy(1,wherey);
                       write(zeilnum:3,' ');
                    end;
          pgup    : if zeile > 1 then begin
                       clrscr;
                       if zeile-19 < 1 then begin
                          zeile:=1;
                          if zeile+19 < zeilnum-1 then auflist(zeile,zeile+19)
                          else auflist(zeile,zeilnum-1);
                       end
                       else begin
                          zeile:=zeile-19;
                          if zeile+19 < zeilnum-1 then auflist(zeile,zeile+19)
                          else auflist(zeile,zeilnum-1);
                       end;
                       gotoxy(1,wherey);
                       write(zeilnum:3,' ');
                    end;
          pgdwn   : if zeile < zeilnum-1 then begin
                       clrscr;
                       if zeile+38 < zeilnum-1 then begin
                          zeile:=zeile+19;
                          auflist(zeile,zeile+19);
                       end
                       else begin
                          if zeilnum-19>1 then begin
                             zeile:=zeilnum-19;
                             auflist(zeile,zeilnum-1);
                          end
                          else begin
                             zeile:=1;
                             auflist(zeile,zeilnum-1);
                          end;
                       end;
                       gotoxy(1,wherey);
                       write(zeilnum:3,' ');
                    end;
          end;

end;                               { **** ENDE STEUER ****}
                                   { beginn von edit }
begin
     checkeof :=false;
     textzeile:=loesch;
     cursor_on;
     textbackground(green);textcolor(black);
     wwindow(52,3,78,24,'[HELP]','',true);
     if mouseinstalled then begin
        mouse_area(53,75,5,7);
        mouse_on;
     end;
     writeln(' EDITOR - Steuerung :');
     writeln;
     writeln('    F1 -> EinfÅgen');
     writeln('    F2 -> Lîschen ');
     write(' PgUP / PgDwn / UP / DWN');
     writeln;
     writeln(' AWL-Befehle :');
     writeln;
     writeln(' VerknÅpfung');
     writeln('    U / UN / U( / UN( ');
     writeln('    O / ON / O( / ON( ');
     writeln(' Zuweisen,Setzen');
     writeln('    = / =N / S  / R');
     writeln(' Timer , ZÑhler');
     writeln('    TE / ZR / K ');
     writeln(' SprÅnge');
     writeln('    J  / JI');
     writeln(' Sonstiges');
     write  ('    NOP / EN ');
     textbackground(white);
     wwindow(1,2,50,25,'[EDIT]','<ESC>',false);
     zeile:=1;spalte:=5;
     zeilnum:=1;
     if programm then begin
        while operation[zeilnum]<>'EN ' do inc(zeilnum);
        inc(zeilnum);
        if zeilnum>20 then auflist(1,20)
        else auflist(1,zeilnum-1);
     end;
     gotoxy(1,wherey);
     write(zeilnum:3,' ');
     repeat
           mouse_event:=false;
           eingabe:=' ';
           repeat
             if mouseinstalled then begin
                mouse_status(mouseX,mouseY,Leftbutton,Rightbutton);
                if Leftbutton or Rightbutton then mouse_event:=true;
             end;
           until keypressed or mouse_event ;
           if keypressed then eingabe:=readkey
           else if mouseinstalled then begin
                   if leftbutton then eingabe:=#0;
                   if rightbutton then eingabe:=esc;
                end;
           case eingabe of
                cr      : carret;
                #0      : steuer;
                bckspce : begin
                            dec(spalte);
                            if spalte <= 5 then spalte:=5;
                            gotoxy(spalte,wherey);write(' ');
                            textzeile[spalte]:=' ';
                            gotoxy(spalte,wherey);
                          end
           else begin
                textzeile[spalte-4]:=upcase(eingabe);
                write(eingabe);
                inc(spalte);
                if spalte > 38 then spalte:=38;
                end;
            end;
     until (eingabe=esc) or (zeilnum=awl_max);

     if zeilnum=awl_max then begin
        clrscr;
        sound(220);delay(200);nosound;
        gotoxy(1,10);
        writeln('ACHTUNG!! Ihre AWL ist zu lang fÅr mich');
        writeln('Ich kann max. ',awl_max,' Zeilen verarbeiten');
        writeln;
        writeln('Weiter mit bel. <TASTE> ');
        repeat
        until keypressed;
     end;
     if mouseinstalled then mouse_off;
     window (1,2,80,25);textbackground(black);textcolor(black);
     clrscr;
     cursor_off;
end;                               { ***** ENDE EDIT ****}

