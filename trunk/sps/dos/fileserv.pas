procedure fileservice;             { Filehandling }

var  auswahl       : char;
     menu_pkt      : popup_choice;




procedure get_file_name;           { namen des awl-files einlesen   }

begin
     window (20,15,80,15);
     textbackground (white); textcolor (black); clrscr;
     cursor_on;
     write ('Filename : ');
     readln (name);
     cursor_off;
     if pos('.',name)=0 then name:=name+'.sps';
     window (20,15,80,15);
     textbackground (black); textcolor (black); clrscr;
end;                               { **** ENDE GET_FILE_NAME **** }


procedure loeschen;                { loeschen einer awl im speicher }

var i               :word;
    answ            :char;

begin
     window (20,15,60,15);
     textbackground (white); textcolor (black); clrscr;
     write('AWL l”schen (j/n)');
     repeat
     until keypressed;
     answ:=readkey;
     clrscr;
     if upcase(answ)='J' then begin
        write('AWL wird gel”scht');
        for i:=1 to awl_max do begin
           znr[i]:=i;
           operation[i]:='   ';
           operand[i]:=' ';
           par[i]:=0;
           comment[i]:='                     ';
        end;
        programm:=false;
        sicher:=false;
        name:='';
     end
     else write('AWL wird nicht gel”scht');
     delay (3000);
     window (20,15,60,15);
     textbackground (black); textcolor (black); clrscr;
end;                               { **** ENDE LOESCHEN ****}


procedure SPS_Laden;               { Laden eines SPS_files }

var  f              :text;
     zeile          :string[48];
     i,code         :integer;

begin
     i:=0;
     get_file_name;
     assign (f,name);
     {$I-} reset (f); {$I+}
     if ioresult <> 0 then
     begin
          sound (220); delay (200); nosound;
          window (20,15,60,15);
          textbackground (white); textcolor (black);clrscr;
          write ('SPS-File nicht gefunden');
          delay (999);
          window (20,15,60,15);
          textbackground (black); textcolor (black); clrscr;
          exit;
     end;
     window (20,15,80,15);
     textbackground (white); textcolor (black); clrscr;
     write('Lade Programm ',name);
     delay (1000);
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
     window (20,15,80,15);
     textbackground (black); textcolor (black); clrscr;
     programm:=true;
     close (F);
     doserror:=0;
end;                               {**** ENDE SPS_LADEN **** }

procedure sps_sichern;             {sichern einer awl}

var i             : byte;
    f             : text;

begin
     i:=1;
     get_file_name;
     assign (f,name);
     {$I-} rewrite (f); {$I+}
     if ioresult <> 0 then
     begin
          sound (220); delay (200); nosound;
          window (20,15,60,15);
          textbackground (white); textcolor (black);clrscr;
          write ('SPS-File kann nicht gesichert werden');
          delay (999);
          window (20,15,60,15);
          textbackground (black); textcolor (black); clrscr;
          exit;
     end;
     window (20,15,80,15);
     textbackground (white); textcolor (black); clrscr;
     write('Sichere Programm ',name);
     delay (1000);
     repeat
          writeln (f,znr[i]:3,' ',operation[i],' ',operand[i],' ',par[i]:5,' ',comment[i]);
          inc(i);
     until operation[i-1]='EN ';
     window (20,15,80,15);
     textbackground (black); textcolor (black); clrscr;
     close (F);
     doserror:=0;
     sicher:=false;
end;                               { **** ENDE SPS_SICHERN ****}


procedure ausdruck;                { Drucken eines SPS-Files }

var   i,z,s            : byte;
      error            : integer;
      ch               : char;
      std,min,sec,dum,
      jahr,mon,tag,wota: word;

begin
     if not(programm) then exit;
     window (20,15,60,15);
     textbackground (white); textcolor (black); clrscr;
     write('Druckvorgang l„uft');
     delay (1000);
     i := 0;
     z := 0;
     s := 1;
     gettime(std,min,sec,dum);
     getdate(jahr,mon,tag,wota);
     {$I-}write (lst,chr(zeilenvorschub),chr(zeilenvorschub));{$I+}
     if ioresult <> 0 then begin
        sound(220);delay(200);nosound;
        clrscr;
        write('Drucker nicht bereit!!!');
        delay(3000);
        window (20,15,60,15);
        textbackground (black); textcolor (black); clrscr;
        exit;
     end;
     writeln (lst,chr(grosschrift),'  SPS-Simulator (c) by S.Kauth COMTOOLS');
     write (lst,chr(zeilenvorschub));
     write (lst,'     Datum : ',tag:2,'.',mon:2,'.',jahr:4);
     writeln (lst,'   Zeit  : ',std:2,'.',min:2);
     writeln (lst,'     Filename : ',name);
     write (lst,'     Seite : ');
     writeln(lst,s);
     write (lst,chr(zeilenvorschub));
     repeat
          inc (i);
          write (lst,'       ',znr[i]:3,' ',operation[i]:3,' ',operand[i],' ');
          if par[i]>0 then write (lst,par[i]:5) else write(lst,'     ');
          writeln (lst,' ',comment[i]:22);
          inc(z);
          if z=seitenlaenge then begin
             z:=0;
             inc(s);
             write (lst,chr(formfeed));
             write (lst,chr(zeilenvorschub),chr(zeilenvorschub),chr(zeilenvorschub));
             writeln (lst,'     Seite : ',s,'Filename : ':40,name);
             write (lst,chr(zeilenvorschub));
          end;
     until (upcase(operation[i,1]) = 'E') and (upcase(operation[i,2]) = 'N');
     write (lst,chr(formfeed));
     window (20,15,60,15);
     textbackground (black); textcolor (black); clrscr;
end;                               {**** ENDE DRUCKEN ****}

procedure inhalt;                  { Directory lesen }

var  sr    : searchrec;
     pfad  : string[60];
     fz    : datetime;
     ch    : char;
     lw    : byte;

begin
     window (20,15,80,15);
     textbackground (white); textcolor(black); clrscr;
     cursor_on;
     write ('Pfad :'); readln (pfad);
     cursor_off;
     window (20,15,80,15);
     textbackground (black); textcolor(black); clrscr;
     if length(pfad)=0 then
        begin
          getdir (0,pfad);
          if pfad[length(pfad)] <> '\' then pfad:=pfad+'\*.SPS'
          else pfad:=pfad+ '*.SPS';
        end
     else
        if (pos('.',pfad))=0 then
           if pfad[length(pfad)] <> '\' then pfad:=pfad+'\*.*'
           else pfad:=pfad+'*.*';
     findfirst (pfad,anyfile,sr);
     if doserror <> 0 then
     begin
          sound(220); delay(200); nosound;
          window (20,15,45,15);
          textbackground (white); textcolor(black); clrscr;
          gotoxy(1,1);write ('  keine Files gefunden  ');
          delay (500);
          window (20,15,45,15);
          textbackground (black); textcolor (black); clrscr;
          exit;
     end;
     textbackground (white); textcolor (black);gotoxy(1,1);
     wwindow (20,4,54,24,'[DIRECTORY]','<bel.TASTE>',true);
     while doserror=0 do
     begin
          while (doserror=0) and (wherey < 18) do
          begin
               if sr.attr=40 then begin
                  textcolor(white);textbackground(black);
                  write ('Platten-/Diskname : ',sr.name);
                  textcolor(black);textbackground(white);
               end
               else if sr.attr <> 39 then begin
                  unpacktime (sr.time,fz);
                  write (sr.name);
                  if sr.attr=$10 then begin
                     textcolor(blue);
                     gotoxy(9,wherey);
                     write('<DIR>');
                     textcolor(black);
                  end;
                  gotoxy(15,wherey); write (fz.day:2,'.',fz.month:2,'.',fz.year);
                  gotoxy(26,wherey); writeln (fz.hour:2,'.',fz.min:2);
               end;
               findnext (sr);
          end;
          textcolor(black+blink);
          gotoxy (1,22); write ('press any key to continue...');
          repeat
          until keypressed;
          ch:= readkey;
          gotoxy (1,22); write ('                            ');
          textcolor(black);clrscr; gotoxy (1,1);
     end;
     window (20,4,54,25); textbackground (black); clrscr;
end;                               {**** ENDE DIRECTORY ****}

procedure chngepfad;

var  aktpfad,neupfad   :string;
     taste,lw          :char;

begin                              { Pfad wechseln }
     window (20,15,80,15);
     textbackground (white); textcolor(black); clrscr;
     getdir (0,aktpfad);
     write('Neuer Pfad : ');
     cursor_on;
     readln(neupfad);
     cursor_off;
     {$I-}
     chdir(neupfad);
     {$I+}
     if ioresult<>0 then begin
        chdir(aktpfad);
        clrscr;
        write(#7,'  Directory nicht gefunden !! weiter mit TASTE ');
        repeat
        until keypressed;
        Taste:=readkey;
     end
     else begin
         getdir(0,neupfad);
         clrscr;
         write('Pfad : ',neupfad);
         delay(3000);
     end;
     window (20,15,80,15);
     textbackground (black); textcolor(black); clrscr;
end;                               { **** ENDE CHNGEPFAD ****}


procedure os_shell;                { Ausflug ins Betriebssystem }

var Shell_Pfad : string;

begin
    Shell_Pfad:=getenv('COMSPEC');
    save_screen;
    window(1,1,80,25);
    textbackground(black);textcolor(white);
    clrscr;
    cursor_on;
    writeln('Type EXIT to Return to SPS_Simulation....');
    (* writeln(shell_pfad);*)
    exec(Shell_pfad,'');
    if doserror<>0 then
       writeln(#7,'Nicht genug Hauptspeicher zur Verfgung');
    cursor_off;
    restore_screen;
end;                               { **** ENDE OS_SHELL **** }

procedure Konfig;                  { start konfiguration aendern }
type string80=string[80];

function GetString(x,y,FeldColor,SchriftColor,l:byte;Default:string80):String80;
const ENTER     = #13;
      BACKSPACE = #8;
var AltX,AltY,AltFarbe,Pos : byte;
    Taste : char;
    Eingabe : String80;

begin
     Eingabe:=Default;
     Pos:=0;
     AltX:=WhereX;
     AltY:=WhereY;
     AltFarbe:=TextAttr;
     TextBackGround(FeldColor);
     Textcolor(SchriftColor);
     GotoXY(x,y);
     for i:=1 to l do write(' ');
     GotoXY(x,y);
     write(Eingabe);
     GotoXY(x+Pos,Y);
     repeat
       repeat
       until KeyPressed;
       Taste:=ReadKey;
       if (Taste=BACKSPACE) and (Pos>0) then begin
          dec(Pos);
          Eingabe[Pos+1]:=' ';
       end
       else if Taste<>ENTER then begin
          Eingabe[Pos+1]:=Taste;
          inc(Pos);
       end;
       GotoXY(x,y);
       write(Eingabe);
       GotoXY(x+Pos,Y);
     until Taste=ENTER;
     GetString:=Eingabe;
     TextAttr:=AltFarbe;
     GotoXY(AltX,AltY);
end;

var Taste : Char;
    Dummy,OldVal,Conf_path : String;
    Error : Integer;
    f : Text;

begin
     TextBackGround(White);TextColor(Black);
     wwindow(10,4,36,13,'[Konfig...]','<j/J>',true);
     writeln('PIO-Baseadress :');
     writeln('Zeilenvorschub :');
     writeln('Seitenvorschub :');
     writeln('Groáschrift    :');
     Writeln('Seitenl„nge    :');
     writeln;
     write('Fertig (j/J) ?');
     repeat
           Cursor_On;
           repeat
             str(Port_A:4,OldVal);
             dummy:=GetString(18,1,Blue,White,4,OldVal);
             val(dummy,Port_A,error);
             if dummy='none' then begin
                Port_a:=1020;
                error:=0;
             end;
           until error=0;
           Port_B:=Port_A+1;
           Port_C:=Port_A+2;
           Control_Port:=Port_A+3;
           repeat
             str(zeilenvorschub:2,OldVal);
             dummy:=GetString(18,2,Blue,White,2,OldVal);
             val(dummy,Zeilenvorschub,Error);
           until Error=0;
           repeat
             str(formfeed:2,OldVal);
             dummy:=Getstring(18,3,Blue,White,2,OldVal);
             val(dummy,formfeed,error);
           until error = 0;
           repeat
             str(grosschrift:2,OldVal);
             dummy:=GetString(18,4,Blue,White,2,OldVal);
             val(dummy,grosschrift,error);
           until error=0;
           repeat
             str(Seitenlaenge:2,OldVal);
             dummy:=GetString(18,5,Blue,White,2,OldVal);
             val(dummy,seitenlaenge,error);
           until error=0;
           GotoXY(18,7);
           Taste:=ReadKey;
           Cursor_Off;
     until (Taste = 'j') or (Taste='J');
     if length(start_pfad)=3 then conf_path:=start_pfad+'sps.cfg'
     else conf_path:=start_pfad+'\sps.cfg';
     assign(f,conf_path);
     {$I-} rewrite(f); {$I+}
     if ioresult <> 0 then begin
        writeln (#7,'Fehler beim Schreiben des Configfiles');
        exit;
     end
     else begin
          str(Control_Port,dummy);
          writeln(f,'c'+dummy);
          str(Port_A,dummy);
          writeln(f,'e'+dummy);
          str(Port_B,dummy);
          writeln(f,'a'+dummy);
          str(Port_C,dummy);
          writeln(f,'z'+dummy);
          str(zeilenvorschub,dummy);
          writeln(f,'v'+dummy);
          str(grosschrift,dummy);
          writeln(f,'g'+dummy);
          str(seitenlaenge,dummy);
          writeln(f,'l'+dummy);
          str(formfeed,dummy);
          writeln(f,'f'+dummy);
          close(f);
     end;
     TextBackGround(Black);TextColor(Black);
     window(10,4,36,13);
     clrscr;
end;                               { **** Ende Konfiguration ****}


                                   { start Filehandling }

begin                              { Menu Filehandling}
     backGround:=15;ForeGround:=0;highlighted:=3;
     menu_pkt[1]:='Neu';
     menu_pkt[2]:='Laden';
     menu_pkt[3]:='Speichern';
     menu_pkt[4]:='Drucken';
     menu_pkt[5]:='Verzeichn.';
     menu_pkt[6]:='Change Dir';
     menu_pkt[7]:='Os_Shell';
     menu_pkt[8]:='Konfigur.';
     repeat
          backGround:=15;ForeGround:=0;highlighted:=3;
          popup(1,2,'[FILE]',Menu_Pkt,8,auswahl);
          case auswahl of
               'N' : loeschen;
               'L' : sps_laden;
               'S' : sps_sichern;
               'D' : Ausdruck;
               'V' : inhalt;
               'C' : chngepfad;
               'O' : os_shell;
               'K' : Konfig;
               #27 : ;
          else
               sound(220); delay(200); nosound
          end;
     until auswahl=#27;
     cursor_off;
     window (1,2,15,13); textbackground (black); textcolor (black); clrscr;

end;                               {**** ENDE FILEHANDLING ****}
