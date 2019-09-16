Unit PopMenu;

{Diese Unit stellt Prozeduren zur Fenstertechnik sowie Popup Verwaltung }
{ zur Verfuegung                                                        }
{ (c) 02/11/90 by Hartmut Eilers 	               	                    }

{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
{ distributed under the GNU General Public License V2 or any later	    }

INTERFACE

{$ifdef MacOSX}
{$define LINUX}
{$endif}


{$ifdef LINUX}
uses crt,unix,dos,baseunix,termio,porting;
{$endif}

{$ifdef WIN32}
uses windows,crt,dos;
{$endif}

type string80=string[80];
     string20=string[20];
     string15=string[15];
     string12=string[12];
     string1 =string[1];
     string9 =string[9];
     Popup_Choice = array [1..12] of string20;
     Balken_choice = array [1..6] of string9;

const
	p_up = #72;
	p_dw = #80;
	p_le = #75;
	p_re = #77;
	esc  = #27;
	enter= #13;
	tab  = #9;
    bckspc =#8;
	ErrorMaxX=109;
	ErrorMaxY=29;

var BackGround,ForeGround,Highlighted : byte;
    screen_buffer                     : array[0..3999] of byte;
    screenx,screeny                   : word;

procedure checkScreenSize;
procedure save_screen;
procedure restore_screen(x1,y1,x2,y2:word);
procedure cursor_off;
procedure cursor_on;
procedure my_wwindow(x1,y1,x2,y2:byte;uber,unter:string12;shadow:boolean);

procedure dropdown(x,y:byte;uber:string12;Items:Popup_Choice;
                  NrOfItems:byte;var Choice:char);

procedure Balken(Items:balken_choice;NrOfItems:byte;info:string15;
                 var choice:char);

procedure popmenuInit(x,y:word);
procedure popmsg(lang,hoch:word;uber:string12;msg:string);

function  filebrowser( startpath:string80;titel:string;dialogtype:char):string80;
function  GetScreenMaxX:word;
function  GetScreenMaxY:word;
function  ReadString:string80;


IMPLEMENTATION

type
	doc_pointer = ^doc_record;	{ in this double linked list	}
	doc_record = record		    { the text entries are stored }
		entry    : string[255];
		nach,			        { zeiger auf den nachfolgenden Eintrag in Liste }
		vor      : doc_pointer;	{ zeiger auf den vorherigen Eintrag }
		selected : boolean;	    { true -> Eintrag ist angewaehlt }
		isDir	 : boolean;
	end;


const
	debug = true;

var
	minScreenX 		    : word; { minimum window size x }
	minScreenY		    : word; {  minimum screen size y }
    DBG                 : text;


Function IntToStr (I : Longint) : String;

Var S : String;

begin
 Str (I,S);
 IntToStr:=S;
end;



procedure writeLOG(MSG: string);
begin
	{$I-}
	writeln(DBG,MSG);
	flush(DBG);
	{$I+}
	if IOResult <>0 then writeln ('error writing debug file');
end;


procedure checkScreenSize;

begin
     screenx:=GetScreenMaxX;
     screeny:=GetScreenMaxY;
     if ((screenx<minScreenX) or (screeny<minScreenY)) then
     begin
	    write(#7);
     	writeln('Screen is too small - minimum Screensize is',minScreenX,' x ',minScreenY);
     	halt(2);
     end;
end;


procedure popmenuInit(x,y:word);
begin
	minScreenX:=x;
	minScreenY:=y;
end;

function ShowTextList(zeiger:doc_pointer;zeilen:word):doc_pointer;
var line_cnt	: word;
begin
	for line_cnt:=1 to zeilen do begin
		gotoxy(1,line_cnt);
		write('                                       ');
	end;
	line_cnt:=0;
	gotoxy(1,1);
	repeat
		inc(line_cnt);
		textcolor(black);
		if (zeiger^.selected) then textcolor(red);
		write(zeiger^.entry);
		if (zeiger^.isDir) then write('     <DIR>');
		if ( zeiger^.nach <> nil ) then zeiger:=zeiger^.nach;
		if (line_cnt < zeilen ) then writeln;
	until (line_cnt = zeilen ) or ( zeiger^.nach=nil);
	ShowTextList:=zeiger^.nach;
end;


{ For Linux I got a method to find updated sizes }
{ for the rest the variables are read }
{ Linux as currently a bug when resizing windows }
{ see tag LINUXBUG }

function GetScreenMaxX:word;
var	number : word;
begin
	val(getenv('COLUMNS'),number);
	GetScreenMaxX:=number;
end;

function GetScreenMaxY:word;
var	number : word;
begin
	val(getenv('LINES'),number);
	GetScreenMaxY:=number;
end;

procedure save_screen;
begin
	//SaveScreenRegion(1,1,GetScreenMaxX,GetScreenMaxy,myConsoleBuf);
end;

procedure restore_screen(x1,y1,x2,y2:word);
begin
	//RestoreScreenRegion(x1,y1,x2,y2,myConsoleBuf);
end;

function ReadString:string80;
var
  Input     : string[80];
  KeyPress  : char;
  counter   : byte;
  baseX,
  baseY     : byte;

begin
  baseX:=wherex;
  baseY:=wherey;
  counter:=1;
  KeyPress:=' ';
  Input:='';
  repeat
{$IFNDEF keyfix}
           if (keypressed) then begin
             KeyPress := ReadKey;
             if ord(KeyPress) = 0 then KeyPress:=ReadKey;
{$ENDIF}
{$IFDEF keyfix}
           if my_keypressed() then begin
             KeyPress:=my_readkey();
{$ENDIF}
            case KeyPress of
               { enter key }
               enter : begin
                       end;
               { cancelled by escape key ?                             }
               esc  :  begin
                         KeyPress:=enter;
                         Input:='';
                         counter:=0;
                       end;
               bckspc: if counter>1 then begin
                         dec(counter);
                         gotoxy(baseX+counter,baseY);
                         write(' ');
                         Input:=copy(Input,1,counter-1);
                      end;
               else begin
                 gotoxy(baseX+counter,baseY);
                 write(KeyPress);
                 Input:=Input+KeyPress;
                 inc(counter);
               end;

            end;
            if debug then writeLOG('Readstring key pressed, evaluated position '+IntToStr(counter-1));
            if debug then writeLOG(Input);

          end;
  until KeyPress=enter;
  if debug then writeLOG('Readstring pressed enter, String='+copy(Input,1,counter-1));
  ReadString:=copy(Input,1,counter-1);
end;

procedure cursor_off;              {cursor ausschalten}

begin
	{$ifdef WIN32}
	CursorOff;
	{$endif}

	{$ifdef LINUX}
	fpsystem('/usr/bin/tput civis');
	{$endif}
end;                               { **** ENDE CURSOR_OFF **** }

procedure cursor_on;               { cursor einschalten }


begin
	{$ifdef WIN32}
	CursorOn;
	{$endif}

	{$ifdef LINUX}
	fpsystem('/usr/bin/tput cnorm');
	{$endif}
end;                               { **** ENDE CURSOR_ON **** }


procedure schatten (x1,y1,x2,y2:byte);  { schattierung zeichnen }

var i               : byte;

begin
   for i:=y1 to y2 do begin       { rechten schatten }
       gotoxy(x2+1,i);
       write('#');
   end;
   for i:=x1+1 to x2 do begin     { unteren schatten  }
       gotoxy(i,y2+1);
       write('#');
   end;
end;


procedure frame(x1,y1,x2,y2: word;uber,unter:string12);

var i		: word;

begin
     for i:=x1 to x2-1 do begin            { waagrechte linie zeichnen }
         gotoxy(i,y1);
         write ('-');                        { oben }
         gotoxy(i,y2);
         write('-');                         { unten }
     end;
     for i:=y1 to y2-1 do begin            { senkrechte linie zeichnen }
         gotoxy(x1,i);
         write('|');                         { links }
         gotoxy(x2,i);
         write('|');                         { rechts }
     end;
     gotoxy(x1,y1);                        { ecken zeichnen }
     write('+');
     gotoxy(x1,y2);
     write('+');
     gotoxy(x2,y1);
     write('+');
     gotoxy(x2,y2);
     write('+');
     gotoxy(x1+2,y1);                      { Ueberschrift }
     write(uber);
     gotoxy(x2-length(unter)-1,y2);        { unterschrift }
     write(unter);
end;

procedure popmsg(lang,hoch:word;uber:string12;msg:string);

var
	xmitte,ymitte,
	x1,y1,
	x2,y2,
	j,k		: word;

begin
	{ mitte des verfügbaren Bildschirms }
	xmitte:=trunc(GetScreenMaxX/2);
	ymitte:=trunc(GetScreenMaxY/2);

	{ obere linke ecke berechnen }
	x1:=xmitte-trunc(lang/2);
	y1:=ymitte-trunc(hoch/2);

	{ untere rechte ecke berechnen }
	x2:=x1+lang;
	y2:=y1+hoch;

	{ Bildschirm speichern}
	save_screen;
	{ fensterrahmen zeichnen }
	frame(x1,y1,x2+1,y2+1,uber,'any key');
	schatten(x1,y1+1,x2+1,y2+1);

	{ Fenster löschen }
	gotoxy(x1+1,y1+1);
	for j:=x1+1 to x2-2 do
		for k:=y1+1 to y2-2 do begin
			gotoxy(j,k);
			write(' ');
		end;

	gotoxy(x1+1,y1+1); write(msg);
	repeat
	until keypressed;
	readkey;

	{ Bildschirm wieder herstellen }
	restore_screen(x1-3,y1-3,x2+3,y2+3);
end;


procedure my_wwindow (x1,y1,x2,y2:byte;uber,unter:string12;shadow:boolean);

{ erzeugen eines windows mit rahmen, Ueberschrift, unterschrift und schatten }

begin
	window(x1,y1,x2,y2);
	frame (1,1,x2-x1,y2-y1,uber,unter);
	if shadow then schatten(1,2,x2-x1,y2-y1);   { schatten }
	window(x1+1,y1+1,x2-2,y2-2);            { schreibflaeche erzeugen und }
	clrscr;                                 { loeschen }
end;                               { **** ENDE WWINDOW **** }


procedure PrintLine(x,y:byte;textzeile:string20;i:byte);

var   j     : byte;

begin
     { start linux specific, because of garbled screen }
     textcolor(black);textbackground(white);
     { end linux spec }
     gotoxy(x,y);
     write(textzeile);
     for j:= length(textzeile) to i-1 do begin
         gotoxy(x+j,y);
         write(' ');
     end;
     textcolor(Highlighted);
     gotoxy(x,y);
     write(textzeile[1]);
     textcolor(foreground);
end;



procedure dropdown (x,y:byte;uber:string12;Items:Popup_Choice;
                NrOfItems:byte;var Choice:char);

var MaxLen,i,x2,y2,
    zeile,altezeile      : byte;
    KeyPress             : char;
    Help                 : string1;

begin
     MaxLen := 0;
     textbackground(backGround);textcolor(foreground);
	 Highlighted:=red;
	 { check for longest item }
     for i:= 1 to NrOfItems do
         if length(Items[i])>MaxLen then MaxLen:=length(Items[i]);
     y2:=y+NrOfItems+2;
     x2:=x+MaxLen+3;
     { draw a window big enough for the longest item }
     my_wwindow (x,y,x2,y2,uber,'<ESC>',true);
     cursor_off;
     { print all menu items }
     for i:= 1 to NrOfItems do PrintLine(1,i,Items[i],MaxLen);
     textbackground(ForeGround);textcolor(BackGround);
     { mark the first item as active }
	 Highlighted:=green;
     PrintLine(1,1,Items[1],MaxLen);
     Choice:=' ';
     zeile:=1;
     altezeile:=1;
     repeat
{$IFNDEF keyfix}
           if (keypressed) then begin
             KeyPress := ReadKey;
             if ord(KeyPress) = 0 then KeyPress:=ReadKey;
{$ENDIF}
{$IFDEF keyfix}
           if my_keypressed() then begin
             KeyPress:=my_readkey();
{$ENDIF}
             case KeyPress of
               p_dw : if zeile <> NrOfItems then zeile:=zeile+1
                      else zeile:=1;
               p_up : if zeile <> 1 then zeile:=zeile-1
                      else zeile:=NrOfItems;
               enter: begin
                        Help:=copy(Items[zeile],1,1);
                        choice:=Help[1];
                      end;
               esc  : choice:=esc;

               else begin
                 for i:= 1 to NrOfItems do
                 if copy(Items[i],1,1) = upcase(KeyPress) then
                   choice:=upcase(KeyPress);
               end;
             end;
          end;

           if zeile <> altezeile then begin
              textbackground(backGround);textcolor(foreground);
			  Highlighted:=red;
              printLine(1,altezeile,Items[altezeile],MaxLen);
              textbackground(foreground);textcolor(backGround);
			  Highlighted:=green;
              PrintLine(1,zeile,Items[zeile],MaxLen);
           end;
           //gotoxy(5,zeile);write(ord(KeyPress));
           altezeile:=zeile;
     until choice<>' ';
end;

procedure balken(Items:balken_choice;NrOfItems:byte;info:string15;var choice:char);

var i,
    spalte,altespalte    : byte;
    KeyPress             : char;
    Help                 : string1;
	ItemWidth		     : byte;
	currX   		     : word;
	dummy,dummy1:string;


begin
	ItemWidth:=9;
    spalte:=1;
    altespalte:=1;
	currX:=0;
	window(1,1,255,255);
	textbackground(foreground);textcolor(background);
	clrscr;
	KeyPress:=#255;
	if debug then writeLOG('balken prepared, starting event loop');
    repeat
	       { terminal window was resized, or first call, so repaint menu }
		   if (currX<>GetScreenMaxX) then begin
		        if debug then writeLOG('window resize/repaint');
				currX:=GetScreenMaxX;
				window (1,1,currX,1);
				clrscr;
				PrintLine(1,1,' ',currX);
				cursor_off;
				Highlighted:=red;
				for i:= 0 to NrOfItems-1 do PrintLine(i*ItemWidth+1,1,Items[i+1],ItemWidth);
				gotoxy(GetScreenMaxX-length(info)-1,1);write(info);
				textbackground(ForeGround);textcolor(BackGround);
				Highlighted:=green;
				PrintLine(1,1,Items[1],ItemWidth);
             str(currX,dummy);
             str(GetScreenMaxX,dummy1);
		   end;
           { handle keypress }
{$IFNDEF keyfix}
           if (keypressed) then begin
             KeyPress := ReadKey;
             if ord(KeyPress) = 0 then KeyPress:=ReadKey;
{$ENDIF}
{$IFDEF keyfix}
           if my_keypressed() then begin
             KeyPress:=my_readkey();
{$ENDIF}
            if debug then writeLOG('key pressed, evaluating');
            case KeyPress of
               { left and right arrow keys                             }
               p_le : begin
                        if spalte > 1 then
                          spalte:=spalte-1
                        else spalte:=NrOfItems;
                      end;
               p_re : begin
                        if spalte < NrOfItems then inc(spalte)
                        else begin
                          spalte:=1;
                        end;
                      end;
               { selection by pressing enter over one item             }
               enter : begin
                         help:=copy(Items[spalte],1,1);
                         choice:=help[1];
                       end;
               { cancelled by escape key ?                             }
               esc  :  begin
                         KeyPress:=enter;
                         choice:=esc;
                       end;

               else begin
                 { check wether one of the Items was selected with the first }
                 { char of the Item                                          }
                 for i:= 1 to NrOfItems do
                   if copy(Items[i],1,1) = upcase(KeyPress) then begin
                     { yes, this one was selected                          }
                     choice:=upcase(KeyPress);
                      KeyPress:=enter; { enter to signal end of selection   }
                   end;
                 end;

            end;
          end;

          { change the highlight from one item to the next            }
          if spalte <> altespalte then begin
            if debug then writeLOG('mark change...');
            textbackground(backGround);textcolor(foreground);
		    Highlighted:=red;
            printLine((altespalte-1)*ItemWidth+1,1,Items[altespalte],ItemWidth);
            textbackground(foreground);textcolor(background);
		    Highlighted:=green;
            PrintLine((spalte-1)*ItemWidth+1,1,Items[spalte],ItemWidth);
          end;

          altespalte:=spalte;

     until KeyPress=enter;  { loop until one selection is made            }
     cursor_on;
     if debug then writeLOG('balkenfinished');
end;



function filebrowser( startpath:string80;titel:string;dialogtype:char):string80;

{ this function provides a filebrowser to browse through the	}
{ directory hirarchy, if enter is pressed on a directory its 	}
{ opened and browsed, if enter is pressed on a file, the	    }
{ window is closed and the fqfn is returned. if you press	    }
{ ESC the window is closed and the returned filename is "esc" 	}

var KeyPress 	    : char;
	sr    	: searchrec;		{ structure needed for the directory access }
	fz    	: datetime;
	z1,z2,
	d_start : doc_pointer;		{ pointer to the start of the dir list  }
	screen_length,
	spalte,c		: byte;
	selected		: boolean;
	searchpath,path,
	filename		: string;

begin
	{ read the directory an build up the double linked list }
	selected:=false;
	path:=startpath;
	spalte:=3;
	filename:='';
	textbackground(lightgray);textcolor(black);
	my_wwindow (trunc(GetScreenMaxX/2)-25,trunc(GetScreenMaxY/2)-10,trunc(GetScreenMaxX/2)+25,trunc(GetScreenMaxY/2)+10,titel,'<ESC/ENTER>',true);
	screen_length:=(trunc(GetScreenMaxY/2)+10)-(trunc(GetScreenMaxY/2)-10)-3;
	if (dialogtype='S') then begin
		screen_length:=screen_length-2;
		textcolor(black);
		gotoxy(1,screen_length+1);
		for c:=1 to 48 do write ('-');
	end;
	repeat
		searchpath:=path+'/*';
	    if debug then writeLOG('reading directory: '+searchpath);
		new(z1);
		z1^.vor:=nil;				{ start setzten - nil zeigt Anfang }
		d_start:=z1;
		{$I-}findfirst (searchpath,anyfile,sr);{$I+}
		while (doserror=0) do
		begin
			if sr.attr <> 39 then begin
				unpacktime (sr.time,fz);
				if (copy(sr.name,1,1) <>'.') or (length(sr.name)<3) then begin
					{ its not a hidden file, its . , .. or a normal file }
					{write('name=',sr.name);readln;}
					z1^.entry := sr.name;
					if sr.attr=$10 then z1^.isDir := true
					else z1^.isDir := false;
					if (sr.name='.') or (sr.name='..') then z1^.isDir := true;
					new(z2);
					z2^.vor:=z1;
					z1^.nach:=z2;
					z1^.selected:=false;
					z1:=z2;
				end;
			end;
			{$I-}findnext (sr);{$I+}
		end;
		z1^.nach:=nil; 		{ end of the linked list }
		{write('list build, ready to open window');readln;}
		{ open a window and print the dir list in it }
		z1:=d_start;
		z1^.selected:=true;
		ShowTextList(z1,screen_length);
		if debug then writeLOG('showing listing...');
		repeat
{$IFNDEF keyfix}
			if (keypressed)then begin
			  KeyPress:=readkey;
			  if (KeyPress=#0) then KeyPress:=readkey;
{$ENDIF}
{$IFDEF keyfix}
			if (my_keypressed)then begin
			  KeyPress:=my_readkey;
{$ENDIF}
			  case KeyPress of
				p_up : begin
					z1^.selected:=false;
					if ( z1^.vor <> nil) then z1:=z1^.vor;
					z1^.selected:=true;
				   end;
				p_dw : begin
					z1^.selected:=false;
					if ( z1^.nach <> nil ) then z1:=z1^.nach;
					z1^.selected:=true;
		    	   end;
				enter: ;
				esc	 :
				else if (DialogType='S') then begin   // save Dialog
					 filename:=filename+KeyPress;
					 inc(spalte);
					 gotoxy(1,screen_length+2);
					 clreol;
					 write (filename,'#');
				end
			  end;
			  ShowTextList(z1,screen_length);
			end;
		until (KeyPress=enter) or (KeyPress=esc);
		if (KeyPress=enter) then
		  if (z1^.isDir)  then begin
		    if debug then writeLOG('Directory '+z1^.entry+' selected');
		    path:=path+'/'+z1^.entry;
		    selected:=false;
		    filename:='';
		  end
		  else begin
			selected:=true;
		    if debug then writeLOG('File '+z1^.entry+' selected');
			if (DialogType='S') and (filename<>'') then filebrowser:=path+'/'+filename
			else filebrowser:=path+'/'+z1^.entry;
		  end;
		if ( KeyPress=esc ) then begin
			selected:=true;
			filebrowser:='esc';
		end;
		KeyPress:=p_up;
	until selected;
	window(trunc(GetScreenMaxX/2)-25,trunc(GetScreenMaxY/2)-10,trunc(GetScreenMaxX/2)+25,trunc(GetScreenMaxY/2)+10);
	textbackground(black);textcolor(black);clrscr;
end;


begin
  Highlighted:=red;
  if debug then begin
    // debug Log
    {$ifdef Windows}
  	assign(DBG,'\temp\popmenu_dbg.log');
  	{$endif}
  	{$ifdef Linux}
	  assign(DBG,'/tmp/popmenu_dbg.log');
    {$endif}
	  rewrite(DBG);
  end;
end.
