
procedure edit;                    {editieren von awl}

const      CR           =#13;
           ESC          =#27;
           BCKSPCE      =#8;
           loesch       = '                                              ';


var zeile,spalte,zeilnum    : byte;
    eingabe                 : char;
    textzeile               : string[48];
    saved_text		    : string[48];

procedure auflist(s,e:byte);       {listen einer awl}

var x                       : byte;
begin
     gotoxy(1,1);
     for x:=s to e do begin
         write (znr[x]:3,' ',operation[x],' ',operand[x],' ');
         if par[x]>=0 then write(par[x]:5) else write('     ');
         writeln(' ',comment[x]);
     end;
     spalte:=5;
end;                               {****ENDE AUFLIST ****}


procedure korrekt_jump(rufer:string12;nr:byte); { korrigiert die Sprung- }
                                                { ziele bei einf. od. lösch.}
var z                       : byte;

begin
     for z:=1 to zeilnum do begin
         if (operation[z]=anweisung[14]) or
            (operation[z]=anweisung[15]) then begin  { 'J' oder 'JI' }
            if par[z] >= nr then
               if rufer = 'EINFÜGEN ' then inc(par[z])
               else dec(par[z]);
         end;
     end;
end;                                {****ENDE KORREKT_JUMP****}


function lies_zeilnummer(rufer:string12):byte; { erfragt vom benutzer eine }
                                               { Zeilennummer              }
var z                       : byte;
    eingabe                 : string;

begin
     repeat
        gotoxy(1,wherey);
        write(rufer,'Zeilennummer:');
        readln(eingabe);
        val(eingabe,z);
     until (z>0) and (z<awl_max);
     lies_zeilnummer:=z;
     z:=0;
end;                               { ****ENDE LIES_ZEILNUMMER **** }

procedure einfug;                  { einfügen einer zeile in die awl }
const ident='EINFÜGEN ';
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

procedure loeschen;                { löschen einer zeile der awl }
const ident='LÖSCHEN ';
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

var j,znum,p,c              : byte;
    error                   : integer;
    text_dummy		    : string;
    byte_dummy              : byte;


begin
	{ I try to document this procedsure now ( after some years ) }
	{ I slip over the input line character for character ( with the j var ) }
	{ and look what I read. if I find something that I know about I stop, }
	{ take the readed part of the line, form whatever it was ( operation, operand, rtc }
	{ delete that from the input line and start over from beginning }
	
	
     c:=0; { this counter is used to compute the position where the comment starts in the entered line }
     { check wether the line starts with numbers }	 
     j:=0;
     repeat
        inc(j);
     until (ord(textzeile[j]) < 48) or (ord(textzeile[j]) > 57);	{ between 48 and 57 are the numbers in ASCII Code }
     { no numbers found }
     if j=1 then znum:=zeilnum
     else begin
        { numbers found, so read the line number }
        text_dummy:=copy(textzeile,1,j-1);
        val(text_dummy,znum);
	{ delete this part from the entered line }
        delete(textzeile,1,j-1);
	{ remember the length of the found linenumber in c }
	c:=j-1;
        zeilnum:=zeilnum-1;
     end;
     znr[znum]:=znum;


     { now look for valid operations }
     j:=0;
     { special handling for execution of external programs }
     if ( textzeile[1] = '$' ) then
        { in the commandline for external programs may be chars that 	}
	{ could be wrong interpretet as operations, so the $ command	}
	{ is special traeted here					}
     	j:=24
     else begin	
        repeat
           inc(j);
           p:=pos(anweis[j],copy(textzeile,1,3))
        until (p>0) or (j>anweismax);
     end;	
     operation[znum]:=anweis[j];	
     while length(operation[znum])<3 do operation[znum]:=operation[znum]+' ';
     delete(textzeile,1,length(anweis[j]));
     { add the length of the operation to the counter c }
     c:=c+length(anweis[j]);
     
     { end of programm detected, so set flag that interpreter can run on that code }
     if j=11 then programm:=true;
     
     { these operations didn't need an operand }
     if (j=19) or (j=18)  or (j=8) or (j=21) or (j=22) or (j=23) then
        { JI, J, K, EQ, LT, GT }
        operand[znum]:=' '
     else  { these operations didn't need an operand nor a parameter }
        if (j=24) or (j=11) or (j=14) then begin		{ that's EN, ) or $ command }
		par[znum]:= (-1);
		operand[znum]:=' ';
	     end	
        else { now get the operand from the line }
             begin
        	operand[znum]:=textzeile[1];
        	delete(textzeile,1,1);
		{ inc counter because an operand is 1 char long }
		inc(c);
             end;
     
     { find numbers that could be usefull parameters }
     if ( par[znum] < 0 ) then 
     else begin
     	j:=0;
     	repeat
        	inc(j);
     	until (ord(textzeile[j]) < 48) or (ord(textzeile[j]) > 57);
     	text_dummy:=copy(textzeile,1,j-1);
     	c:=c+j-1;
     	val(text_dummy,byte_dummy);
     	par[znum]:=byte_dummy;
     	delete(textzeile,1,j-1);
     end;

	{ the rest is a comment }
     comment[znum]:=copy(saved_text,c+1,length(saved_text)-(c+1));
     
     { print the formatted line }
     gotoxy(1,wherey);
     write(loesch);
     gotoxy(1,wherey);
     write (znr[znum]:3,' ',operation[znum],' ',operand[znum],' ');
     if par[znum]>=0 then write(par[znum]:5) else write('     ');
     write(' ',comment[znum]);
     saved_text:=loesch;
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
        f1              = #82;      { bei linux auf einfg }
        f2              = #83;      { bei linux aud entf  }

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
{     writeln(ord(eingabe));}
     case eingabe of
          f1      : einfug;
          f2      : loeschen;
          auf     : if zeile>1 then begin
                       clrscr;
                       dec(zeile);
                       if zeilnum-1 >= zeile+screeny-6 then auflist(zeile,zeile+screeny-6)
                       else auflist(zeile,zeilnum-1);
                       gotoxy(1,wherey);
                       write(zeilnum:3,' ');
                    end;
          ab      : if zeile<zeilnum-1 then begin
                       clrscr;
                       inc(zeile);
                       if zeile+screeny-6 <= zeilnum-1 then auflist(zeile,zeile+screeny-6)
                       else auflist (zeile,zeilnum-1);
                       gotoxy(1,wherey);
                       write(zeilnum:3,' ');
                    end;
          pgup    : if zeile > 1 then begin
                       clrscr;
                       if zeile-screeny-6 < 1 then begin
                          zeile:=1;
                          if zeile+screeny-6 < zeilnum-1 then auflist(zeile,zeile+screeny-6)
                          else auflist(zeile,zeilnum-1);
                       end
                       else begin
                          zeile:=zeile-screeny-6;
                          if zeile+screeny-6 < zeilnum-1 then auflist(zeile,zeile+screeny-6)
                          else auflist(zeile,zeilnum-1);
                       end;
                       gotoxy(1,wherey);
                       write(zeilnum:3,' ');
                    end;
          pgdwn   : if zeile < zeilnum-1 then begin
                       clrscr;
                       if zeile+38 < zeilnum-1 then begin
                          zeile:=zeile+screeny-6;
                          auflist(zeile,zeile+screeny-6);
                       end
                       else begin
                          if zeilnum-screeny-6>1 then begin
                             zeile:=zeilnum-screeny-6;
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
     saved_text:=loesch;                                                                                         
     cursor_on;
     textbackground(green);textcolor(black);
     my_wwindow(screenx-28,3,screenx-2,screeny-1,'[HELP]','',true);
     if mouseinstalled then begin
        mouse_area(53,75,5,7);
        mouse_on;
     end;
     writeln(' EDITOR - Control :');
     writeln;
     writeln(' INSERT -> Insert');
     writeln(' DEL  -> delete ');
     write(' PgUP / PgDwn / UP / DWN');
     writeln;
     writeln(' AWL-Commands :');
     writeln;
     writeln(' Operations');
     writeln('    U / UN / U( / UN( ');
     writeln('    O / ON / O( / ON( ');
     writeln(' Assignments');
     writeln('    = / =N / S  / R');
     writeln(' Timer , Counter');
     writeln('    TE / ZR / K ');
     writeln(' Jumps');
     writeln('    J  / JI');
     writeln(' Misc.');
     write  ('    NOP / EN ');
     textbackground(lightgray);textcolor(blue);
     my_wwindow(1,2,screenx-30,screeny,'[EDIT]','<ESC>',false);
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
		saved_text[spalte-4]:=eingabe;
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
        writeln('Attention, AWL is too long');
        writeln('Max. ',awl_max,' Lines possible');
        writeln;
        writeln('press any key');
        repeat
        until keypressed;
     end;
     if mouseinstalled then mouse_off;
     window (1,2,screenx,screeny);textbackground(black);textcolor(black);
     clrscr;
     cursor_off;
end;                               { ***** ENDE EDIT ****}




























