Unit PopMenu;

{Diese Unit stellt Prozeduren zur Fenstertechnik sowie Popup Verwaltung }
{ zur Verf�gung                                                         }
{ (c) 02/11/90 by Hartmut Eilers 	               	                }

{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
{ distributed under the GNU General Public License V2 or any later	}

INTERFACE

{$undef ZAURUS}

{$ifdef LINUX}
uses crt,linux,dos;
{$endif}

{$ifdef WIN32}
uses crt,dos;
{$endif}

type string80=string[80];
     string20=string[20];
     string15=string[15];
     string12=string[12];
     string1 =string[1];
     string9 =string[9];
     Popup_Choice = array [1..12] of string20;
     Balken_choice = array [1..6] of string9;

const p_up = #72;
      p_dw = #80;
	  p_le = #75;
	  p_re = #77;
      esc  = #27;
      enter= #13;
	  tab  = #9;
      	
var BackGround,ForeGround,Highlighted : byte;
    startseg                          : word;
{    regs                              : registers;}
    screen_buffer                     : array[0..3999] of byte;

procedure save_screen;
procedure restore_screen;
procedure cursor_off;
procedure cursor_on;
procedure my_wwindow(x1,y1,x2,y2:byte;uber,unter:string12;shadow:boolean);
function  GetScreenMaxX:word;
function  GetScreenMaxY:word;

procedure dropdown(x,y:byte;uber:string12;Items:Popup_Choice;
                NrOfItems:byte;var Choice:char);
procedure Balken(Items:balken_choice;NrOfItems:byte;info:string15;
                 var choice:char);
function filebrowser( startpath:string80;titel:string;dialogtype:char):string80;


IMPLEMENTATION

type	
	doc_pointer = ^doc_record;	{ in this double linked list	}
	doc_record = record		{ the text entries are stored }
		entry : string[255];
		nach,			{ zeiger auf den nachfolgenden Eintrag in Liste }
		vor  : doc_pointer;	{ zeiger auf den vorherigen Eintrag }
		selected : boolean;	{ true -> Eintrag ist angew�hlt }
		isDir	: boolean;
	end;


const 	
	screenx = 80;	{ this is the max screen width should be computed }
	screeny = 25;	{ this is the max screen height should be computed }
			{ these values are computed now, but screenx and }
			{ screeny are used as fallbacks if the actual size }
			{ can't be determined }
	debug = false;

var dummy,position     : byte;    { dummy fuer mausposition }
    return,escape      : boolean; { linke / rechte maustaste }


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
end;



function GetScreenMaxX:word;
var	number : word;
begin
	val(getenv('COLUMNS'),number);
	if (number <= 0) then GetScreenMaxX:=screenx
	else GetScreenMaxX:=number;
end;

function GetScreenMaxY:word;
var	number : word;
begin
	val(getenv('LINES'),number);
	if  (number <= 0) then GetScreenMaxY:=screeny
	else GetScreenMaxY:=number;
end;

procedure save_screen;
{var  i : word;}
begin
{     for i:=0 to 3999 do}
{         screen_buffer[i]:=mem[startseg:i];}
end;

procedure restore_screen;
{var  i : word;}
begin
{     for i:=0 to 3999 do}
{         mem[startseg:i]:=screen_buffer[i];}
end;


procedure cursor_off;              {cursor ausschalten}

begin
	{$ifdef WIN32}
	CursorOff
	{$endif}

	{$ifdef LINUX}
	write(#27'[?25l');
	{$endif}
end;                               { **** ENDE CURSOR_OFF **** }

procedure cursor_on;               { cursor einschalten }


begin
	{$ifdef WIN32}
	CursorOn;	
	{$endif}

	{$ifdef LINUX}
	write(#27'[?25h');
	{$endif}
end;                               { **** ENDE CURSOR_ON **** }





procedure my_wwindow (x1,y1,x2,y2:byte;uber,unter:string12;shadow:boolean);

{ erzeugen eines windows mit rahmen, �berschrift, unterschrift und schatten }

procedure schatten (x1,y1,x2,y2:byte);  { schattierung zeichnen }

var i               : byte;

begin
   for i:=2 to y2-y1+1 do begin       { rechten schatten }
       gotoxy(x2-x1+1,i);
       write('#');
   end;
   for i:=2 to x2-x1+1 do begin       { linken schatten  }
       gotoxy(i,y2-y1+1);
       write('#');
   end;
end;


var i               : byte;

begin
     if shadow then window(x1,y1,x2+1,y2+1)
     else window(x1,y1,x2,y2);
     for i:=2 to x2-x1-1 do begin            { waagrechte linie zeichnen }
         gotoxy(i,1);
         write ('-');                        { oben }
         gotoxy(i,y2-y1);
         write('-');                         { unten }
     end;
     for i:=2 to y2-y1-1 do begin            { senkrechte linie zeichnen }
         gotoxy(1,i);
         write('|');                         { links }
         gotoxy(x2-x1,i);
         write('|');                         { rechts }
     end;
     gotoxy(1,1);                            { ecken zeichnen }
     write('+');
     gotoxy(x2-x1,1);
     write('+');
     gotoxy(1,y2-y1);
     write('+');
     gotoxy(x2-x1,y2-y1);
     write('+');
     gotoxy(2,1);                            { �berschrift }
     write(uber);
     gotoxy(x2-x1-length(unter)-1,y2-y1);    { unterschrift }
     write(unter);
     if shadow then schatten(x1,y1,x2,y2);   { schatten }
     window(x1+1,y1+1,x2-2,y2-2);            { schreibfl�che erzeugen und }
     clrscr;                                 { l�schen }
end;                               { **** ENDE WWINDOW **** }


procedure PrintLine(x,y:byte;textzeile:string20;i:byte);

var   j     : byte;

begin
     { start linux specific, because of garbled screen }
     textcolor(black);textbackground(white);
     { end linux spec }
     gotoxy(x+1,y);
     write(copy (textzeile,2,length(textzeile)-1));
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
    Zeile,AlteZeile      : byte;
    Taste,Pfeil          : char;
    Help                 : string1;

begin
     MaxLen := 0;
     textbackground(backGround);textcolor(foreground);
	 Highlighted:=red;
     for i:= 1 to NrOfItems do
         if length(Items[i])>MaxLen then MaxLen:=length(items[i]);
     y2:=y+NrOfItems+2;
     x2:=x+MaxLen+3;
     my_wwindow (x,y,x2,y2,uber,'<ESC>',true);
     //cursor_off;
     for i:= 1 to NrOfItems do PrintLine(1,i,Items[i],MaxLen);
     textbackground(ForeGround);textcolor(BackGround);
	 Highlighted:=green;
     PrintLine(1,1,Items[1],MaxLen);
     Help:=copy(Items[1],1,1);
     Choice:=help[1];
     zeile:=1;
     repeat
		   Taste := ReadKey;
           altezeile:=zeile;
           if ord(taste) = 0 then begin;
              Pfeil:=readkey;
              case pfeil of
                 p_up : if zeile <> 1 then dec(zeile)
                      else Zeile:=NrOfItems;
                 p_dw : if zeile <> NrOfItems then inc(zeile)
                      else zeile:=1;
              end;
           end;
           if zeile <> altezeile then begin
              textbackground(backGround);textcolor(foreground);
			  Highlighted:=red;
              printLine(1,AlteZeile,Items[altezeile],maxlen);
              textbackground(foreground);textcolor(backGround);
			  Highlighted:=green;
              PrintLine(1,zeile,Items[zeile],MaxLen);
           end;
           if taste=enter then begin
              help:=copy(Items[zeile],1,1);
              choice:=help[1];
           end;
           for i:= 1 to NrOfItems do
               if copy(Items[i],1,1) = upcase(taste) then begin
                  choice:=upcase(taste);
                  taste:=chr(13);
               end;
           if taste=esc then begin
              taste:=enter;
              choice:=esc;
           end;
     until taste =enter;
end;

procedure balken(Items:balken_choice;NrOfItems:byte;info:string15;
                 var choice:char);

var i,
    spalte,Altespalte    : byte;
    Taste,Pfeil          : char;
    Help                 : string1;
	ItemWidth            : byte;



begin
{$ifdef ZAURUS}
	 Itemwidth:=6;
{$else}
	 ItemWidth:=9;
{$endif}
     textbackground(backGround);textcolor(foreground);
	 Highlighted:=red;
     window (1,1,GetScreenMaxX,1);
     clrscr;
     //cursor_off;
     for i:= 0 to NrOfItems-1 do PrintLine(i*ItemWidth+1,1,Items[i+1],ItemWidth);
     if debug then gotoxy(GetScreenMaxX-length(info)-1,1);write(info);
     textbackground(ForeGround);textcolor(BackGround);
	 Highlighted:=green;
     PrintLine(1,1,Items[1],ItemWidth);
     help:=copy(Items[1],1,1);
     choice:=help[1];
     spalte:=1;
     repeat
           Taste := ReadKey;
           altespalte:=spalte;
           if ord(taste) = 0 then begin;
              Pfeil:=readkey;
              case pfeil of
                 p_le : if spalte <> 1 then dec(spalte)
                      else spalte:=NrOfItems;
                 p_re : if spalte <> NrOfItems then inc(spalte)
                      else spalte:=1;
              end;
           end;
           if spalte <> altespalte then begin
             textbackground(backGround);textcolor(foreground);
			 Highlighted:=red;
              printLine((altespalte-1)*ItemWidth+1,1,Items[altespalte],ItemWidth);
              textbackground(foreground);textcolor(background);
			  Highlighted:=green;
              PrintLine((spalte-1)*ItemWidth+1,1,Items[spalte],ItemWidth);
           end;
           if taste=enter then begin
              help:=copy(Items[spalte],1,1);
              choice:=help[1];
           end;
           for i:= 1 to NrOfItems do
               if copy(Items[i],1,1) = upcase(taste) then begin
                  choice:=upcase(taste);
                  taste:=chr(13);
               end;
           if taste=esc then begin
              taste:=enter;
              choice:=esc;
           end;
     until taste =enter;
     cursor_on;
end;



function filebrowser( startpath:string80;titel:string;dialogtype:char):string80;

{ this function provides a filebrowser to browse through the	}
{ directory hirarchy, if enter is pressed on a directory its 	}
{ opened and browsed, if enter is pressed on a file, the	}
{ window is closed and the fqfn is returned. if you press	}
{ ESC the window is closed and the returned filename is "esc" 	}

var 	taste 	: char;
	sr    	: searchrec;		{ structure needed for the directory access }
	fz    	: datetime;
	z1,z2,
	d_start,
	z_akt	: doc_pointer;		{ pointer to the start of the dir list }
	zeilen_counter	: word;		{ counter for the number of dir entries }
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
		zeilen_counter:=1;
		ShowTextList(z1,screen_length);
		repeat
			taste:=readkey;
			if (taste=#0) then taste:=readkey;
			case taste of
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
				else if (DialogType='S') then begin
					 filename:=filename+taste;
					 inc(spalte);
					 gotoxy(1,screen_length+2);
					 clreol;
					 write (filename,'#');
				end
			end;
			ShowTextList(z1,screen_length);
		until (taste=enter) or (taste=esc);
		if (z1^.isDir) and (filename='') then path:=path+'/'+z1^.entry
		else begin
			selected:=true;
			if (DialogType='S') and (filename<>'') then filebrowser:=path+'/'+filename
			else filebrowser:=path+'/'+z1^.entry;
		end;
		if ( taste=esc ) then begin
			selected:=true;
			filebrowser:='esc';
		end;	
	until selected;
	window(trunc(GetScreenMaxX/2)-25,trunc(GetScreenMaxY/2)-10,trunc(GetScreenMaxX/2)+25,trunc(GetScreenMaxY/2)+10);
	textbackground(black);textcolor(black);clrscr;
end;


begin
     startseg:=$b800;
{     if Graph_mode=hga then startseg:=$b000;}
	Highlighted:=red;
end.
