program sps_simulator;

{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
{ distributed under the GNU General Public License V2 or any later	}


{  $define newio }
uses 	dos,crt,porting,printer,popmenu,browse,PhysMach,
{$ifdef LINUX }
		linux,unix;
{$endif}
{$ifdef WIN32 }
		windows;
{$endif}
{$M 16384,0,100000} 

{$DEFINE SPS}

{$i ./sps.h}
{$i ./fileserv.pas}
{$i ./edit.pas}
{$i ./run_awl.pas}
{$i ./kop.pas}

{ new platform: Zaurus = Linux on ARM CPU }
{$undefine ZAURUS}

procedure checkScreenSize;

begin
     screenx:=GetScreenMaxX;
     screeny:=GetScreenMaxY;
     if ((screenx<minScreenX) or (screeny<minScreenY)) then
     begin
     	writeln('Screen is too small - minimum Screensize is',minScreenX,' x ',minScreenY);
     	halt(2);
     end;
end;

procedure configuration;

var  f                 : text;
     zeile,conf_path,
     help_path         : string80;
     befehl            : char;
     gleich,i          : byte;
     error             : integer;
     zahl              : byte;

begin
     i:=0;
     conf_path:='/etc/sps.cfg';
     assign(f,conf_path);
     {$I-} reset(f); {$I+}
     if ioresult <> 0 then begin
	{ systemwide configfile not found, look in the startpath for a config file }
	if length(start_pfad)=3 then conf_path:=start_pfad+'sps.cfg'
	else conf_path:=start_pfad+'/sps.cfg';
	assign(f,conf_path);
	{$I-} reset(f); {$I+}
	if ioresult <> 0 then begin
		writeln (#7,'ERROR reading config file');
		writeln ('Configfile not found');
		halt(1);
	end	
     end
     else begin
        while not eof(f) do begin
           readln(f,zeile);
           inc(i);
           befehl:=upcase(zeile[1]);
           dummy_string:=copy(zeile,2,length(zeile));
           val(dummy_string,zahl);
           case befehl of
                'C'  : begin
                          if (error > 0) or (zahl=1023) then pio:=false
                          else ;
                       end;
                'E'  : if error = 0 then ;
                'A'  : if error = 0 then ;
                'Z'  : if error = 0 then ;
                'V'  : zeilenvorschub :=zahl;
                'G'  : grosschrift    :=zahl;
                'L'  : seitenlaenge   :=zahl;
                'F'  : formfeed       :=zahl;

           else begin
{$ifdef ZAURUS}
                window(1,1,21,59);
{$else}
                window(1,1,25,80);
{$endif}
                textbackground(black);
                textcolor(lightgray);
                clrscr;
                writeln(#7,'Error reading Config file');
                writeln('in line ',i,' unknown command');
                halt(1);
             end;
           end;
        end;
        close (f);
     end;
     if length(start_pfad)=3 then conf_path:=start_pfad+'sps.doc'
     else conf_path:=start_pfad+'/sps.doc';
	 ReadListFromFile(conf_path,doc_start);
end;


procedure menu;                    { Hauptmenu }

var   Auswahl      : char;

begin
     balken_pkte[1]:='File';
     balken_pkte[2]:='Edit';
     balken_pkte[3]:='Run';
     balken_pkte[4]:='Kop';
     balken_pkte[5]:='Docu';
     balken_pkte[6]:='Quit';
     copy_right:='(c) H. Eilers';
     repeat
           BackGround:=lightgray;ForeGround:=Black;
           checkScreenSize;
           Highlighted:=red;
           balken(balken_pkte,6,copy_right,auswahl);
           case Auswahl of
               'F' : fileservice;
               'E' : edit;
               'R' : run_awl;
               'K' : kop;
               'D' : browsetext('[Docu]',doc_start,1,2,GetScreenMaxX,GetScreenMaxY);
               'Q' : ;
           else begin
                  sound(220); delay(200); nosound;
              end;
           end;
     until auswahl='Q';
     if sicher then begin
        save_screen;
        textbackground(red);textcolor(lightgray);
        my_wwindow(trunc(screenx/2-18),trunc(screeny/2-3),trunc(screenx/2+18),trunc(screeny/2+3),'','',true);
        writeln ('Attention, AWL not saved ');
        write ('Save ? (y/n)');
        cursor_on;
        repeat
           repeat

           until keypressed;
           taste:=upcase(readkey);
        until (taste='Y') or (taste='N');
        cursor_off;
        restore_screen;
        if taste='Y' then begin
			textbackground(black);textcolor(black);
			window(1,2,screenx,screeny);
			clrscr;
			menu;
		end;	
     end;
end;                               {**** ENDE  HAUPTMENU **** }

begin                              { SPS_SIMULATION }
     for i := 1 to anweismax do begin
           anweisung[i]:=anweis[i];
           if (length(anweis[i]) < 3) then begin
	        repeat
	            anweisung[i]:=concat(anweisung[i],' ');
		until (length(anweisung[i]) = 3);
	   end;
     end;
     textcolor(lightgray);textbackground(black); clrscr;
     checkScreenSize;
     cursor_off;
     clrscr;
     textbackground(lightgray);textcolor(Black);
     my_wwindow(trunc(screenx/2-25),trunc(screeny/2-2),trunc(screenx/2+25),trunc(screeny/2+2),'','',true);
     writeln(' SPS SIMULATOR V ',version);
     write(' Build on ',datum,' (c) 1989-2006 by H. Eilers ');
     getdir(0,start_pfad);
     start_pfad:='.';
     configuration;
     directvideo:=false;
	 {graphmode:=m640x480;}
     {graphdriver:=D8bit;}
     programm:=false;
     sicher:=false;
     name:='NONAME.SPS';
     delay(4000);
     window(trunc(screenx/2-25),trunc(screeny/2-2),trunc(screenx/2+25),trunc(screeny/2+2));
     textbackground(black);textcolor(black);clrscr;
     menu;
     {closegraph;}
     window (1,1,screenx,screeny);
     textcolor(white);textbackground(black); clrscr;
     normvideo;
     cursor_on;
end. 









