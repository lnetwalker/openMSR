Unit PopMenu;

{Diese Unit stellt Prozeduren zur Fenstertechnik sowie Popup Verwaltung }
{ zur Verfügung                                                         }
{ (c) 02/11/90 by Hartmut Eilers 	               	                }

INTERFACE

uses crt,mouse,linux,dos;
{ unit graph,getgraph entfernt, dos durch linux ersetzt  }

type string80=string[80];
     string20=string[20];
     string15=string[15];
     string12=string[12];
     string1 =string[1];
     string9 =string[9];
     Popup_Choice = array [1..12] of string20;
     Balken_choice = array [1..6] of string9;

const p_up = #73;
      p_dw = #81;
      esc  = #27;
      enter= #13;
      	
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
function filebrowser( path:string80):string80;


IMPLEMENTATION

type	doc_pointer = ^doc_record;	{ in this double linked list	}
	doc_record = record		{ the text entries are stored }
		entry : string[255];
		nach,			{ zeiger auf den nachfolgenden Eintrag in Liste }
		vor  : doc_pointer;	{ zeiger auf den vorherigen Eintrag }
		selected : boolean;	{ true -> Eintrag ist angewählt }
		screenpos : byte;
	end;


const 	screenx = 80;	{ this is the max screen width should be computed }
	screeny = 25;	{ this is the max screen height should be computed }
			{ these values are computed now, but screenx and }
			{ screeny are used as fallbacks if the actual size }
			{ can't be determined }

var dummy,position     : byte;    { dummy fuer mausposition }
    return,escape      : boolean; { linke / rechte maustaste }


function ShowTextList(zeiger:doc_pointer;zeilen:word):doc_pointer;
var line_cnt	: word;
begin
	line_cnt:=0;
	zeiger^.screenpos:=1;
	gotoxy(1,1);clrscr;
	repeat
		inc(line_cnt);
		zeiger^.screenpos:=line_cnt;
		if (zeiger^.selected) then begin
			{if zeiger^.screenpos }
			textcolor(red);
			write(zeiger^.entry);
			textcolor(white);
		end
		else write(zeiger^.entry);
		zeiger:=zeiger^.nach;
		if (line_cnt < zeilen ) then writeln;
	until (line_cnt = zeilen );
	ShowTextList:=zeiger^.vor;
end;


function MoveTextList(zeiger:doc_pointer;taste : char; zeilen:word):doc_pointer;
begin
	case taste of
		#73 : begin
			if zeiger^.selected then begin
				zeiger^.selected:=false;
				zeiger:=zeiger^.vor;
				zeiger^.selected:=true;
			end;
		      end;		
	end;		
	gotoxy(1,1);
	write(taste);
	zeiger:=ShowTextList(zeiger,zeilen);
	MoveTextList:=zeiger; 
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
	CursorOff
end;                               { **** ENDE CURSOR_OFF **** }

procedure cursor_on;               { cursor einschalten }


begin
	CursorOn;	
end;                               { **** ENDE CURSOR_ON **** }





procedure my_wwindow (x1,y1,x2,y2:byte;uber,unter:string12;shadow:boolean);

{ erzeugen eines windows mit rahmen, überschrift, unterschrift und schatten }

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
     gotoxy(2,1);                            { überschrift }
     write(uber);
     gotoxy(x2-x1-length(unter)-1,y2-y1);    { unterschrift }
     write(unter);
     if shadow then schatten(x1,y1,x2,y2);   { schatten }
     window(x1+1,y1+1,x2-2,y2-2);            { schreibfläche erzeugen und }
     clrscr;                                 { löschen }
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

var MaxLen,i,x2,y2,Pfeil,
    Zeile,AlteZeile      : byte;
    Taste                : char;
    Help                 : string1;

begin
     mouse_event:=false;
     check_mouse(mouseinstalled);
     MaxLen := 0;
     textbackground(backGround);textcolor(foreground);
     for i:= 1 to NrOfItems do
         if length(Items[i])>MaxLen then MaxLen:=length(items[i]);
     y2:=y+NrOfItems+2;
     x2:=x+MaxLen+3;
     my_wwindow (x,y,x2,y2,uber,'<ESC>',true);
     cursor_off;
     for i:= 1 to NrOfItems do PrintLine(1,i,Items[i],MaxLen);
     textbackground(ForeGround);textcolor(BackGround);
     PrintLine(1,1,Items[1],MaxLen);
     Help:=copy(Items[1],1,1);
     Choice:=help[1];
     zeile:=1;
     if mouseinstalled then begin
        mouse_area(x,x2-4,y,y2-3);
        mouse_on;
     end;
     repeat
           repeat
             mouse_event:=false;
             if mouseinstalled then begin
                mouse_status(dummy,position,return,escape);
                if (return or escape) then mouse_event:=true;
             end;
           until KeyPressed or mouse_event;
           if KeyPressed then Taste := ReadKey
           else taste:=' ';
           altezeile:=zeile;
           if ord(taste) = 0 then begin;
              Pfeil:=ord(readkey);
              case pfeil of
                 72 : if zeile <> 1 then dec(zeile)
                      else Zeile:=NrOfItems;
                 80 : if zeile <> NrOfItems then inc(zeile)
                      else zeile:=1;
              end;
           end;
           if zeile <> altezeile then begin
              if mouseinstalled then mouse_off;
              textbackground(backGround);textcolor(foreground);
              printLine(1,AlteZeile,Items[altezeile],maxlen);
              textbackground(foreground);textcolor(background);
              PrintLine(1,zeile,Items[zeile],MaxLen);
              if mouseinstalled then mouse_on;
           end;
           if taste=#13 then begin
              help:=copy(Items[zeile],1,1);
              choice:=help[1];
           end;
           for i:= 1 to NrOfItems do
               if copy(Items[i],1,1) = upcase(taste) then begin
                  choice:=upcase(taste);
                  taste:=chr(13);
               end;
           if taste=#27 then begin
              taste:=#13;
              choice:=#27;
           end;
           if mouse_event then begin
              taste:=#13;
              if escape then choice:=#27
              else begin
                   help:=copy(Items[position-1],1,1);
                   choice:=help[1];
              end;
           end;
     until taste =#13;
     if mouseinstalled then mouse_off;
end;

procedure balken(Items:balken_choice;NrOfItems:byte;info:string15;
                 var choice:char);

var i,Pfeil,
    spalte,Altespalte    : byte;
    Taste                : char;
    Help                 : string1;


begin
     mouse_event:=false;
     textbackground(backGround);textcolor(foreground);
     window (1,1,GetScreenMaxX,1);
     clrscr;
     cursor_off;
     for i:= 0 to NrOfItems-1 do PrintLine(i*10+1,1,Items[i+1],10);
     gotoxy(GetScreenMaxX-length(info)-1,1);write(info);
     textbackground(ForeGround);textcolor(BackGround);
     PrintLine(1,1,Items[1],9);
     help:=copy(Items[1],1,1);
     choice:=help[1];
     spalte:=1;
     if mouseinstalled then begin
        mouse_area(0,79,0,0);
        mouse_on;
     end;
     repeat
           repeat
           mouse_event:=false;
             if mouseinstalled then begin
                mouse_status(position,dummy,return,escape);
                if return then mouse_event:=true;
             end;
           until KeyPressed or mouse_event;
           if KeyPressed then Taste := ReadKey
           else taste:=' ';
           altespalte:=spalte;
           if ord(taste) = 0 then begin;
              Pfeil:=ord(readkey);
              case pfeil of
                 75 : if spalte <> 1 then dec(spalte)
                      else spalte:=NrOfItems;
                 77 : if spalte <> NrOfItems then inc(spalte)
                      else spalte:=1;
              end;
           end;
           if spalte <> altespalte then begin
              if mouseinstalled then mouse_off;
              textbackground(backGround);textcolor(foreground);
              printLine((altespalte-1)*10+1,1,Items[altespalte],9);
              textbackground(foreground);textcolor(background);
              PrintLine((spalte-1)*10+1,1,Items[spalte],9);
              if mouseinstalled then mouse_on;
           end;
           if taste=#13 then begin
              help:=copy(Items[spalte],1,1);
              choice:=help[1];
           end;
           for i:= 1 to NrOfItems do
               if copy(Items[i],1,1) = upcase(taste) then begin
                  choice:=upcase(taste);
                  taste:=chr(13);
               end;
           if taste=#27 then begin
              taste:=#13;
              choice:=#27;
           end;
           if mouse_event and (dummy=0) then begin
              taste:=#13;
              help:=copy(Items[trunc(position/10)+1],1,1);
              choice:=help[1];
           end;

     until taste =#13;
     cursor_on;
     if mouseinstalled then mouse_off;
end;



function filebrowser( path:string80):string80;

{ this function provides a filebrowser to browse through the	}
{ directory hirarchy, if enter is pressed on a directory its 	}
{ opened and browsed, if enter is pressed on a file, the	}
{ window is closed and the fqfn is returned. if you press	}
{ ESC the window is closed and the returned filename is empty 	}

var 	taste 	: char;
	sr    	: searchrec;		{ structure needed for the directory access }
	fz    	: datetime;
	z1,z2,
	d_start,
	z_akt	: doc_pointer;		{ pointer to the start of the dir list }
	zeilen_counter	: word;		{ counter for the number of dir entries }
	screen_length	: byte;

begin
	{ read the directory an build up the double linked list }
	new(z1);
	z1^.vor:=nil;				{ start setzten - nil zeigt Anfang }
	d_start:=z1;
	path:=path+'/*';
	{write(path);
	write('ready to biuld list');readln;}
	{$I-}findfirst (path,anyfile,sr);{$I+}
	while (doserror=0) do
	begin
		if sr.attr <> 39 then begin
			unpacktime (sr.time,fz);
			if (copy(sr.name,1,1) <>'.') or (length(sr.name)<3) then begin
				{ its not a hidden file, its . , .. or a normal file }
				{write('name=',sr.name);readln;}
				z1^.entry := sr.name;
				{ fill the name with blanks up to 15 chars }
				if (length(z1^.entry)<15) then 
					repeat
						z1^.entry:=z1^.entry+ ' ';
					until ( length (z1^.entry)>14)
				else z1^.entry:=copy(z1^.entry,1,15);
				{write('|');readln;			}
				if sr.attr=$10 then z1^.entry := z1^.entry +' <DIR>';
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
	textbackground(blue);textcolor(white);
	my_wwindow (trunc(GetScreenMaxX/2)-25,trunc(GetScreenMaxY/2)-10,trunc(GetScreenMaxX/2)+25,trunc(GetScreenMaxY/2)+10,path,'<ESC>/<ENTER>',true);	
	screen_length:=(trunc(GetScreenMaxY/2)+10)-(trunc(GetScreenMaxY/2)-10)-3;
	z1:=d_start;
	z1^.selected:=true;
	zeilen_counter:=1;
	z_akt:=ShowTextList(z1,screen_length);
	repeat
		taste:=readkey;
		case taste of
			p_up : z_akt:=MoveTextList(z_akt,p_up,screen_length);
			p_dw : z_akt:=MoveTextList(z_akt,p_dw,screen_length);
			enter: begin
				z_akt:=d_start;
				while ((not(z_akt^.selected)) and (z_akt^.nach <> nil)) do z_akt:=z_akt^.nach
			       end;
		end;	
	until (taste=enter) or (taste=esc);
	if ( taste=esc ) then filebrowser:=''  { ESC was pressed so close window and exit with empty string }
	else filebrowser:=z_akt^.entry;	
	window(trunc(GetScreenMaxX/2)-25,trunc(GetScreenMaxY/2)-10,trunc(GetScreenMaxX/2)+25,trunc(GetScreenMaxY/2)+10);
	textbackground(black);textcolor(black);clrscr;
end;


begin
     startseg:=$b800;
{     if Graph_mode=hga then startseg:=$b000;}
     if mouseinstalled then mouse_cursor(0,$ffff,$ff00);
end.
