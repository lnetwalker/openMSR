
procedure fileservice;             { Filehandling }

var  	auswahl		: char;
     	menu_pkt	: popup_choice;
		akt_pfad	: string[255];





procedure loeschen;                { loeschen einer awl im speicher }

var i               :word;
    answ            :char;

begin
     window (20,15,60,15);
     textbackground (lightgray); textcolor (Black); clrscr;
     write('delete AWL (y/n)');
     repeat
     until keypressed;
     answ:=readkey;
     clrscr;
     if upcase(answ)='Y' then begin
        write('deleting AWL ...');
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
     else write('AWL not deleted');
     delay (2000);
     window (20,15,60,15);
     textbackground (black); textcolor (black); clrscr;
end;                               { **** ENDE LOESCHEN ****}


procedure SPS_Laden;               { Laden eines SPS_files }

var  f              :text;
     zeile          :string;
     i		        :integer;
     dummy_text     :string;
     dummy_zahl     :byte;

begin
     i:=0;
     name:=filebrowser('.','[Load]','L');
	 if (name='esc') then exit;
     assign (f,name);
     {$I-} reset (f); {$I+}
     if ioresult <> 0 then     begin
          sound (220); delay (200); nosound;
          window (20,15,60,15);
          textbackground (lightgray); textcolor (red);clrscr;
          write ('SPS-File: ',name,' not found');
          delay (999);
          window (20,15,60,15);
          textbackground (black); textcolor (black); clrscr;
          exit;
     end;
     window (20,15,80,15);
     textbackground (lightgray); textcolor (Black); clrscr;
     write('Loading program ',name);
     delay (1000);
     while not(eof(f)) do
     begin
          inc(i);
          readln (f,zeile);
          if zeile[2]=' ' then dummy_text:=copy(zeile,3,1)
          else if zeile[1]=' ' then dummy_text:=copy(zeile,2,2)
          else dummy_text:=copy(zeile,1,3);
          val (dummy_text,dummy_zahl);
          znr[i]:=dummy_zahl;
          operation[i] := copy(zeile,5,3);
          operand[i] := zeile[9];

          if zeile[14]=' ' then dummy_text:=copy(zeile,15,1)
          else if zeile[13]=' ' then dummy_text:=copy(zeile,14,2)
          else if zeile[12]=' ' then dummy_text:=copy(zeile,13,3)
          else if zeile[11]=' ' then dummy_text:=copy(zeile,12,4)
          else dummy_text:=copy(zeile,11,5);
          val (dummy_text,dummy_zahl);
          par[i]:=dummy_zahl;

          comment[i] := copy (zeile,17,length(zeile)-17+1);
     end;
     window (20,15,80,15);
     textbackground (black); textcolor (black); clrscr;
     programm:=true;
     close (F);
end;                               {**** ENDE SPS_LADEN **** }

procedure sps_sichern;             {sichern einer awl}

var i             : byte;
    f             : text;

begin
	 if not(programm) then exit;
     i:=1;
     name:=filebrowser('.','[Save]','S');
	 if (name='esc') then exit;
     assign (f,name);
     {$I-} rewrite (f); {$I+}
     if ioresult <> 0 then
     begin
          sound (220); delay (200); nosound;
          window (20,15,60,15);
          textbackground (lightgray); textcolor (red);clrscr;
          write ('Could not save SPS-File ',name);
          delay (999);
          window (20,15,60,15);
          textbackground (black); textcolor (black); clrscr;
          exit;
     end;
     window (20,15,80,15);
     textbackground (lightgray); textcolor (Black); clrscr;
     write('Saving Programm ',name);
     delay (1000);
     repeat
          writeln (f,znr[i]:3,' ',operation[i],' ',operand[i],' ',par[i]:5,' ',comment[i]);
          inc(i);
     until (operation[i-1]='EN ') or (operation[i-1]='PE ');
     window (20,15,80,15);
     textbackground (black); textcolor (black); clrscr;
     close (F);
     sicher:=false;
end;                               { **** ENDE SPS_SICHERN ****}


procedure ausdruck;                { Drucken eines SPS-Files }

var   i,z,s             : byte;
      std,min,sec,dum,
      jahr,mon,tag,wota : word;
	  printer			: text;

begin
     if not(programm) then exit;
     window (20,15,60,15);
     textbackground (lightgray); textcolor (Black); clrscr;
     write('Printing ...');
     delay (1000);
	 
	 {$ifdef LINUX}
	 assignlst (printer,'|/usr/bin/lpr -m');
	 rewrite(printer);
	 {$else}
	 printer:=lst;
	 {$endif}
     
	 
	 i := 0;
     z := 0;
     s := 1;
	 {$ifdef LINUX}
     gettime(std,min,sec);
	 getdate(jahr,mon,tag);
	 {$else}
	 gettime(std,min,sec,dum);
	 getdate(jahr,mon,tag,wota);
	 {$endif}
	
     {$I-}write (printer,chr(zeilenvorschub),chr(zeilenvorschub));{$I+}
     if ioresult <> 0 then begin
        sound(220);delay(200);nosound;
        clrscr;
        write(' Printer not ready!!!');
        delay(3000);
        window (20,15,60,15);
        textbackground (black); textcolor (black); clrscr;
        exit;
     end;
     writeln (printer,chr(grosschrift),'  SPS-Simulator (c) by Hartmut Eilers ');
     write (printer,chr(zeilenvorschub));
     write (printer,'     Date : ',tag:2,'.',mon:2,'.',jahr:4);
     writeln (printer,'   Time  : ',std:2,'.',min:2);
     writeln (printer,'     Filename : ',name);
     write (printer,'     Page : ');
     writeln(printer,s);
     write (printer,chr(zeilenvorschub));
     repeat
          inc (i);
          write (printer,'       ',znr[i]:3,' ',operation[i]:3,' ',operand[i],' ');
          if par[i]>0 then write (printer,par[i]:5) else write(printer,'     ');
          writeln (printer,' ',comment[i]:22);
          inc(z);
          if z=seitenlaenge then begin
             z:=0;
             inc(s);
             write (printer,chr(formfeed));
             write (printer,chr(zeilenvorschub),chr(zeilenvorschub),chr(zeilenvorschub));
             writeln (printer,'     Seite : ',s,'Filename : ':40,name);
             write (printer,chr(zeilenvorschub));
          end;
     until (upcase(operation[i,1]) = 'E') and (upcase(operation[i,2]) = 'N');
     write (printer,chr(formfeed));
	 close(printer);
     window (20,15,60,15);
     textbackground (black); textcolor (black); clrscr;
end;                               {**** ENDE DRUCKEN ****}

procedure inhalt;                  { Directory lesen }

var  
     sr    : SearchRec;
     pfad  : string[60];
     fz    : datetime;

begin
     window (20,15,80,15);
     textbackground (lightgray); textcolor(Black); clrscr;
     cursor_on;
     write ('Pfad :'); readln (pfad);
     cursor_off;
     window (20,15,80,15);
     textbackground (black); textcolor(black); clrscr;
     if length(pfad)=0 then
        begin
          getdir (0,pfad);
          if pfad[length(pfad)] <> '/' then pfad:=pfad+'/*'
          else pfad:=pfad+ '*';
        end
     else
        if (pos('.',pfad))=0 then
           if pfad[length(pfad)] <> '/' then pfad:=pfad+'/*'
           else pfad:=pfad+'*';
     findfirst (pfad,anyfile,sr);
    if doserror <> 0 then
     begin
          sound(220); delay(200); nosound;
          window (20,15,45,15);
          textbackground (lightgray); textcolor(Black); clrscr;
          gotoxy(1,1);write ('  no Files found  ');
          delay (500);
          window (20,15,45,15);
          textbackground (black); textcolor (black); clrscr;
          exit;
     end;
     textbackground (lightgray); textcolor (Black);gotoxy(1,1);
     my_wwindow (20,4,54,24,'[DIRECTORY]','<any key>',true);
{     writeln(pfad);}
     while doserror=0 do
     begin
          while (doserror=0) and (wherey < 18) do
          begin
               if sr.attr=40 then begin
                  textcolor(lightgray);textbackground(blue);
                  write ('Diskname : ',sr.name);
                  textcolor(Black);textbackground(lightgray);
               end
               else if sr.attr <> 39 then begin
                  unpacktime (sr.time,fz);
                  write (sr.name);
                  if sr.attr=$10 then begin
                     textcolor(Black);
                     gotoxy(9,wherey);
                     write('<DIR>');
                     textcolor(Black);
                  end;
                  gotoxy(15,wherey); write (fz.day:2,'.',fz.month:2,'.',fz.year);
                  gotoxy(26,wherey); writeln (fz.hour:2,'.',fz.min:2);
               end;
               findnext (sr);
          end;
          textcolor(blue+blink);
          gotoxy (1,22); write ('press any key to continue...');
          repeat
          until keypressed;
          readkey;
          gotoxy (1,22); write ('                            ');
          textcolor(Black);clrscr; gotoxy (1,1);
     end;
     window (20,4,54,25); textbackground (black); clrscr;
end;                               {**** ENDE DIRECTORY ****}

procedure chngepfad;

var  aktpfad,neupfad   :string;

begin                              { Pfad wechseln }
     window (20,15,80,15);
     textbackground (lightgray); textcolor(Black); clrscr;
     getdir (0,aktpfad);
     write('New path : ');
     cursor_on;
     readln(neupfad);
     cursor_off;
     {$I-}
     chdir(neupfad);
     {$I+}
     if ioresult<>0 then begin
        chdir(aktpfad);
	clrscr;textcolor(red);
        write(#7,'  Directory not found ! press any key... ');
	repeat
    until keypressed;
    readkey;
	textcolor(Black);
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



                                   { start Filehandling }

begin                              { Menu Filehandling}
     backGround:=15;ForeGround:=0;highlighted:=3;
     menu_pkt[1]:='New';
     menu_pkt[2]:='Load';
     menu_pkt[3]:='Save';
     menu_pkt[4]:='Print';
     menu_pkt[5]:='Directory';
     menu_pkt[6]:='Change Dir';
     repeat
          backGround:=lightgray;ForeGround:=Black;highlighted:=cyan;
          dropdown(1,2,'[FILE]',Menu_Pkt,6,auswahl);
	  	  getdir(0,akt_pfad);
          case auswahl of
               'N' : loeschen;
               'L' : sps_laden;
               'S' : sps_sichern;
               'P' : Ausdruck;
               (*'D' : filebrowser(akt_pfad);*)
	       	   'D' : inhalt;
               'C' : chngepfad;
               
			   #27 : ;
          	   
			   else begin
                 sound(220); delay(200); nosound;
               end
          end
     until auswahl=#27;
     cursor_off;
     window (1,2,15,13); textbackground (black); textcolor (black); clrscr;

end;                               {**** ENDE FILEHANDLING ****}
























