program sps_simulator;

uses dos,crt,printer,popmenu,intzeit,mouse,getgraph,autograf,environ;

{graph }
{ folgende defines fÅhren zu sonderversionen                             }
{ Handler  = version mit Fenster bei Progstart mit Hinweis HÑndlertest   }
{            darf nicht verkauft werden                                  }
{ Demo     = Demoversion mit kleinen einschrÑnkungen                     }
{ aktivieren der Defines einfach $ voranstellen                          }


{$M 16384,0,100000}
{DEFINE Handler}
{DEFINE Demo}

type  string12=string[12];
      string3 =string[3];
      string80=string[80];
      doc_pointer = ^doc_record;
      doc_record = record
                     zeil : string[76];
                     nach,
                     vor  : doc_pointer;
                   end;



const awl_max     =500;
      version     ='V 1.7';
      datum       ='06.11.93';
      anweisung   : array[1..20] of string3
                  = ('O  ','ON ','O( ','ON(','U  ',
                     'UN ','U( ','UN(',')  ','=  ',
                     '=N ','S  ','R  ','J  ','JI ',
                     'K  ','TE ','ZR ','NOP','EN ');

var  znr               : array[1..awl_max] of integer;
     operation         : array[1..awl_max] of string3;
     operand           : array[1..awl_max] of char;
     par               : array[1..awl_max] of word;
     comment           : array[1..awl_max] of string[22];
     programm,sicher   : boolean;
     graphdriver,
     graphmode,
     grapherror        : integer;
     taste             : char;
     i                 : Word;
     name              : string;
     pio_use,pio       : boolean;
     control_port,
     port_a,
     port_b,
     port_c            : word;
     zeilenvorschub,
     Grosschrift,
     seitenlaenge,
     formfeed          : byte;
     balken_pkte       : balken_choice;
     copy_right        : string15;
     start_pfad        : string80;
     doc_start         : doc_pointer;
     regs              : registers;
     erfolg            : byte;

procedure configuration;

var  f                 : text;
     zeile,conf_path,
     help_path         : string80;
     befehl            : char;
     gleich,i          : byte;
     error             : integer;
     zahl              : word;
     z1,z2             : doc_pointer;

begin
     i:=0;
     if length(start_pfad)=3 then conf_path:=start_pfad+'sps.cfg'
     else conf_path:=start_pfad+'\sps.cfg';
     assign(f,conf_path);
     {$I-} reset(f); {$I+}
     if ioresult <> 0 then begin
        writeln (#7,'Fehler beim Lesen des Configfiles');
        writeln ('Configfile nicht gefunden');
        halt(1);
     end
     else begin
        while not eof(f) do begin
           readln(f,zeile);
           inc(i);
           befehl:=upcase(zeile[1]);
           val(copy(zeile,2,length(zeile)),zahl,error);
           case befehl of
                'C'  : begin
                          if (error > 0) or (zahl=1023) then pio:=false
                          else control_port   :=zahl;
                       end;
                'E'  : if error = 0 then port_a :=zahl;
                'A'  : if error = 0 then port_b :=zahl;
                'Z'  : if error = 0 then port_c :=zahl;
                'V'  : zeilenvorschub :=zahl;
                'G'  : grosschrift    :=zahl;
                'L'  : seitenlaenge   :=zahl;
                'F'  : formfeed       :=zahl;
             else begin
                window(1,1,25,80);
                textbackground(black);
                textcolor(white);
                clrscr;
                writeln(#7,'Fehler beim Lesen des Configfiles');
                writeln('in Zeile ',i,' unbekannter Befehl');
                halt(1);
             end;
           end;
        end;
        close (f);
     end;
     if length(start_pfad)=3 then conf_path:=start_pfad+'sps.doc'
     else conf_path:=start_pfad+'\sps.doc';
     assign(f,conf_path);
     {$I-} reset(f); {$I+}
     if ioresult <> 0 then begin
        writeln (#7,'Fehler beim Lesen des DOCfiles');
        writeln ('DOCfile nicht gefunden');
        halt(1);
     end
     else begin
        new(z1);
        doc_start:=z1;
        readln(f,z1^.zeil);
        z1^.vor:=nil;
        while not eof(f) do begin
           new(z2);
           z1^.nach:=z2;
           readln(f,z2^.zeil);
           z2^.vor:=z1;
           z1:=z2;
        end;
        z1^.nach:=nil;
        close(f);
     end;
end;

{$i c:\source\tvsps\dos-sps\hardcopy.pas}
{$i c:\source\tvsps\dos-sps\fileserv.pas}
{$i c:\source\tvsps\dos-sps\edit.pas}
{$i c:\source\tvsps\dos-sps\run_awl.pas}
{$i c:\source\tvsps\dos-sps\info.pas}


procedure menu;                    { Hauptmenu }

var   Auswahl      : char;

begin
     balken_pkte[1]:='File';
     balken_pkte[2]:='Edit';
     balken_pkte[3]:='Run';
     balken_pkte[4]:='Docu';
     balken_pkte[5]:='Quit';
     copy_right:='(c) S.Kauth';
     repeat
           BackGround:=7;ForeGround:=0;Highlighted:=4;
           balken(balken_pkte,5,copy_right,auswahl);
           case Auswahl of
               'F' : fileservice;
               'E' : edit;
               'R' : run_awl;
               'D' : info(doc_start);
               'Q' : ;
           else
               sound(220); delay(200); nosound
           end;
     until auswahl='Q';
     if sicher then begin
        save_screen;
        textbackground(red);textcolor(white);
        wwindow(28,11,64,15,'','',true);
        writeln ('Achtung, AWL ist nicht gesichert ');
        write ('Sichern ? (j/n)');
        cursor_on;
        repeat
           repeat

           until keypressed;
           taste:=upcase(readkey);
        until (taste='J') or (taste='N');
        cursor_off;
        restore_screen;
        if taste='J' then menu;
     end;
end;                               {**** ENDE  HAUPTMENU **** }

begin                              { SPS_SIMULATION }
     textcolor(white);textbackground(black); clrscr;
     if mem[0:$4fe]=1 then         { wird PIO schon benutzt ? }
        pio_use:=true
     else begin
        mem[0:$4fe]:=1;
        pio_use:=false;
     end;
     {$ifdef Demo}
        TextBackGround(White);TextColor(Blue);
        wwindow(5,2,77,23,'INFO','Enter',true);
        writeln('    Demo der SPS Software (c) by Stephan Kauth COMTOOLS');
        writeln;
        writeln('                  Stephan Kauth COMTOOLS');
        writeln('                  Krummes Land 6 ');
        writeln('                  88690 Uhldingen');
        writeln;
        writeln('    Diese Demo ist in Ihrem Funktionsumfang eingeschrÑnkt.');
        writeln('    Folgende Funktionen sind in der Demo nicht mîglich:');
        writeln('         - echte I/O Steuerung mit einer PIO');
        writeln('         - Steuerung im Hintergrund mit RUN_SPS');
        writeln;
        writeln(' Auf Grund dieser EinschrÑnkungen ist es also nicht mîglich echte');
        writeln(' Steuerungen aufzubauen. Sie kînnen sich jedoch in die');
        writeln(' Programmierung von SPS -Anlagen einarbeiten und Ihre selbst-');
        writeln(' entwickelten SPS - Programme in der Simulation austesten.');
        writeln(' FÅr richtige Steuerungen benîtigen Sie die Vollversion die Sie bei');
        writeln(' oben angegebener Adresse fÅr DM 79.- per Nachnahme bestellen kînnen');
        write('              ------ Weiter mit ENTER -------');
        readln;
        window (1,1,80,25);
        TextColor(White);TextBackground(Black);
     {$endif}
     {$ifdef Handler}
        cursor_off;
        TextBackGround(White);TextColor(RED);
        wwindow(28,9,60,15,'','ENTER',true);
        writeln ('  Testversion fÅr HÑndler');
        writeln ('  Weitergabe oder Verkauf an');
        Writeln ('  Dritte ist verboten');
        readln;
        window(1,1,80,25);
        TextBackGround(black);TextColor(white);
        clrscr;
        Cursor_on;
     {$endif}
     cursor_off;
     clrscr;
     textbackground(white);textcolor(black);
     wwindow(28,11,57,15,'','',true);
     writeln(' SPS  SIMULATOR  ',version);
     write(' (c) ',datum,' by S.Kauth ');
     regs.ax:=$160a;          { check for windows }
     intr($2f,regs);
     if regs.ax = 0 then begin
        textbackground(white);textcolor(red);
        wwindow(10,17,71,21,'[ACHTUNG]','[ENTER]',true);
        writeln(' Der Simulator wird unter Windows ausgefuehrt.  Beachten ');
        write(' Sie die Hinweise in der Dokumentation zum Thema WINDOWS !');
        readln;
        textbackground(black);textcolor(white);
        window(10,17,71,21);
        clrscr;
     end;
     getdir(0,start_pfad);
     erfolg:=delstring('PROMPT=');
     erfolg:=addstring('PROMPT= [SPS] $P$G');
     configuration;
     directvideo:=false;
     graphdriver:=ord(graph_mode);
     programm:=false;
     sicher:=false;
     name:='NONAME.SPS';
     if pio and (not(pio_use)) then port[control_port]:=$99;  { ports programmieren    }
     delay(1000);
     window(10,11,71,21);
     textbackground(black);textcolor(black);clrscr;
     zeit(0,75,15);
     menu;
     closegraph;
     window (1,1,80,25);
     textcolor(white);textbackground(black); clrscr;
     cursor_on;
     if not(pio_use) then mem[0:$4fe]:=0;
     ende_zeit;
end.


