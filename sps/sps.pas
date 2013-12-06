program sps_simulator;
{$mode delphi}
{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
{ distributed under the GNU General Public License V2 or any later	}
{ $Id$ }

{  $define newio }
uses 	
{$ifdef LINUX }
		linux,unix,
{$endif}
{$ifdef WIN32 }
		windows,
{$endif}
dos,crt,porting,printer,popmenu,browse,PhysMach;
{$M 16384,0,100000} 

{$DEFINE SPS}

{$ifdef MacOSX}
	{$linklib libad4.dylib}
	{$linklib IOKit.dylib}
{$endif}
	
{$i ./sps.h}
{$i ./fileserv.pas}
{$i ./edit.pas}
{$i ./run_awl.pas}
{$i ./kop.pas}

{ new platform: Zaurus = Linux on ARM CPU }
{$undef ZAURUS}

procedure checkScreenSize;

begin
{$ifdef Gnublin}
     screenx:=GetScreenMaxX;
     screeny:=GetScreenMaxY;
     if ((screenx<minScreenX) or (screeny<minScreenY)) then
     begin
	write(#7);
     	writeln('Screen is too small - minimum Screensize is',minScreenX,' x ',minScreenY);
     	halt(2);
     end;
{$endif}
end;

procedure configuration;

var  
     conf_path         : string80;

begin
    conf_path:=start_pfad+'/sps.doc';
    ReadListFromFile(conf_path,doc_start);
end;


procedure SpsConfig;

var
    befehl		: char;
    zahl		: byte;
    
begin
    //writeln(' Callback called with line: ', CfgLine);
    if length(CfgLine)>0 then befehl:=upcase(CfgLine[1])
    else befehl:=' ';
    dummy_string:=copy(CfgLine,2,length(CfgLine));
    val(dummy_string,zahl);
    //writeln('Befehl : ',befehl,' Zahl : ',zahl);
    case befehl of
	'V'  : zeilenvorschub :=zahl;
	'G'  : grosschrift    :=zahl;
	'L'  : seitenlaenge   :=zahl;
	'F'  : formfeed       :=zahl;
    end;
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
		{ check wether screen size has changed }
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
	{ open a maximum sized window get get a blank screen after resizing window }
	window(1,1,GetScreenMaxX,GetScreenMaxY);
	clrscr;
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
        restore_screen(trunc(screenx/2-18),trunc(screeny/2-3),trunc(screenx/2+18),trunc(screeny/2+3));
        if taste='Y' then begin
			textbackground(black);textcolor(black);
			window(1,2,GetScreenMaxX,GetScreenMaxY);
			clrscr;
			menu;
		end;	
     end;
end;                               {**** ENDE  HAUPTMENU **** }

begin                              { SPS_SIMULATION }
	if ( paramcount > 0 ) then ConfFile:=paramstr(1)
	else ConfFile:='.run_sps.cfg';
	PhysMachInit;
	PhysMachRegCfg(@SpsConfig);
	PhysMachLoadCfg(ConfFile);
	{
	writeln('Zeilenvorschub :',zeilenvorschub);
	writeln('Grossschrift :',grosschrift);
	writeln('Seitenlänge :', seitenlaenge);
	writeln('Formfeed :', formfeed);
	halt(1);
	}
	PhysMachWriteDigital;
	popmenuInit(minScreenX,minScreenY);
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
     my_wwindow(trunc(screenx/2-25),trunc(screeny/2-2),trunc(screenx/2+25),trunc(screeny/2+3),'','',true);
     writeln(' SPS SIMULATOR V ',version);
     write(' Build on ',datum,' (c) 1989-2011 by H. Eilers ');
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
     window(trunc(screenx/2-25),trunc(screeny/2-2),trunc(screenx/2+26),trunc(screeny/2+3));
     textbackground(black);textcolor(black);clrscr;
     menu;
     {closegraph;}
     window (1,1,GetScreenMaxX,GetScreenMaxY);
     textcolor(white);textbackground(black); clrscr;
     normvideo;
     cursor_on;
     PhysMachEnd();
end. 









