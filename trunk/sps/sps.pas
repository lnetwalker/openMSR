program sps_simulator;
 
uses dos,porting,mouse,linux,crt,printer,popmenu,ports;
{,lp_io_access;}

{ Linux Portierung							}

{ unit environ entfernt			 				}

{ graph,intzeit,getgraph,autograf  entfernt 				}


{$M 16384,0,100000} 


{$i ./sps.h}
{$i ./fileserv.pas}
{$i ./edit.pas}
{$i ./run_awl.pas}
{$i ./info.pas}

procedure configuration;

var  f                 : text;
     zeile,conf_path,
     help_path         : string80;
     befehl            : char;
     gleich,i          : byte;
     error             : integer;
     zahl              : byte;
     z1,z2             : doc_pointer;

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
                window(1,1,25,80);
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
     assign(f,conf_path);
     {$I-} reset(f); {$I+}
     if ioresult <> 0 then begin
        writeln (#7,'Error reading  DOCfiles');
        writeln ('DOCfile not found ',conf_path);
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

            
procedure menu;                    { Hauptmenu }

var   Auswahl      : char;

begin
     balken_pkte[1]:='File';
     balken_pkte[2]:='Edit';
     balken_pkte[3]:='Run';
     balken_pkte[4]:='Docu';
     balken_pkte[5]:='Quit';
     copy_right:='(c) H. Eilers';
     repeat
           BackGround:=lightgray;ForeGround:=blue;
	   Highlighted:=red;
           balken(balken_pkte,5,copy_right,auswahl);
           case Auswahl of
               'F' : fileservice;
               'E' : edit;
               'R' : run_awl;
               'D' : info(doc_start);
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
        if taste='Y' then 
	begin
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
     screenx:=GetScreenMaxX;
     screeny:=GetScreenMaxY;
     if ((screenx<minScreenX) or (screeny<minScreenY)) then
     begin
     	writeln('Screen is too small - minimum Screensize is',screenx,' x ',screeny);
     	halt(2);
     end;
     cursor_off;
     clrscr;
     textbackground(lightgray);textcolor(blue);
     my_wwindow(trunc(screenx/2-20),trunc(screeny/2-2),trunc(screenx/2+20),trunc(screeny/2+2),'','',true);
     writeln(' SPS SIMULATOR V ',version);
     write(' Build on ',datum,' (c) by H. Eilers ');
     getdir(0,start_pfad);
     start_pfad:='.';
     configuration;
     directvideo:=false;
{     graphdriver:=ord(graph_mode);}
     programm:=false;
     sicher:=false;
     name:='NONAME.SPS';
     delay(4000);
     window(trunc(screenx/2-20),trunc(screeny/2-2),trunc(screenx/2+20),trunc(screeny/2+2));
     textbackground(black);textcolor(black);clrscr;
     menu;
{     closegraph;}
     window (1,1,screenx,screeny);
     textcolor(white);textbackground(black); clrscr;
     cursor_on;
     normvideo;
end. 









