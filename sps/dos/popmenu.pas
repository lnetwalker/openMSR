Unit PopMenu;

(* Diese Unit stellt Prozeduren zur Fenstertechnik sowie Popup Verwaltung *)
(* zur Verfgung                                                          *)
(* (c) 02/11/90 by HuSoft	                 			  *)	

INTERFACE

uses Graph,crt,dos,mouse,getgraph;

type string20=string[20];
     string15=string[15];
     string12=string[12];
     string1 =string[1];
     string9 =string[9];
     Popup_Choice = array [1..12] of string20;
     Balken_choice = array [1..6] of string9;


var BackGround,ForeGround,Highlighted : byte;
    startseg                          : word;
    regs                              : registers;
    screen_buffer                     : array[0..3999] of byte;

procedure save_screen;
procedure restore_screen;
procedure cursor_off;
procedure cursor_on;
procedure wwindow(x1,y1,x2,y2:byte;uber,unter:string12;shadow:boolean);
procedure Popup(x,y:byte;uber:string12;Items:Popup_Choice;
                NrOfItems:byte;var Choice:char);
procedure Balken(Items:balken_choice;NrOfItems:byte;info:string15;
                 var choice:char);


implementation


var dummy,position     : byte;    { dummy fuer mausposition }
    return,escape      : boolean; { linke / rechte maustaste }



procedure save_screen;
var  i : word;
begin
     for i:=0 to 3999 do
         screen_buffer[i]:=mem[startseg:i];
end;

procedure restore_screen;
var  i : word;
begin
     for i:=0 to 3999 do
         mem[startseg:i]:=screen_buffer[i];
end;


procedure cursor_off;              {cursor ausschalten}

var regs            : registers;
begin
     regs.AX:=$0100;
     regs.CX:=$2607;
     intr($10,regs);
end;                               { **** ENDE CURSOR_OFF **** }

procedure cursor_on;               { cursor einschalten }

var regs            : registers;
begin
     regs.AX:=$0100;
     if graph_mode=hga then regs.CX:=$0c0d
     else regs.cx:=$0607;          {Herc cx=0c0d ; cga/ega cx=0607 }
     intr($10,regs);
end;                               { **** ENDE CURSOR_ON **** }




procedure wwindow;

{ erzeugen eines windows mit rahmen, berschrift, unterschrift und schatten }

       procedure schatten (x1,y1,x2,y2:byte);  { schattierung zeichnen }

       var i               : byte;

       begin
            for i:=2 to y2-y1+1 do begin       { rechten schatten }
                gotoxy(x2-x1+1,i);
                write('±');
            end;
            for i:=2 to x2-x1+1 do begin       { linken schatten  }
                gotoxy(i,y2-y1+1);
                write('±');
            end;
       end;



var i               : byte;
begin
     if shadow then window(x1,y1,x2+1,y2+1)
     else window(x1,y1,x2,y2);
     for i:=2 to x2-x1-1 do begin            { waagrechte linie zeichnen }
         gotoxy(i,1);
         write ('Í');                        { oben }
         gotoxy(i,y2-y1);
         write('Í');                         { unten }
     end;
     for i:=2 to y2-y1-1 do begin            { senkrechte linie zeichnen }
         gotoxy(1,i);
         write('º');                         { links }
         gotoxy(x2-x1,i);
         write('º');                         { rechts }
     end;
     gotoxy(1,1);                            { ecken zeichnen }
     write('É');
     gotoxy(x2-x1,1);
     write('»');
     gotoxy(1,y2-y1);
     write('È');
     gotoxy(x2-x1,y2-y1);
     write('¼');
     gotoxy(2,1);                            { berschrift }
     write(uber);
     gotoxy(x2-x1-length(unter)-1,y2-y1);    { unterschrift }
     write(unter);
     if shadow then schatten(x1,y1,x2,y2);   { schatten }
     window(x1+1,y1+1,x2-2,y2-2);            { schreibfl„che erzeugen und }
     clrscr;                                 { l”schen }
end;                               { **** ENDE WWINDOW **** }


procedure PrintLine(x,y:byte;textzeile:string20;i:byte);

var   j     : byte;

begin
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



procedure popup;

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
     wwindow (x,y,x2,y2,uber,'<ESC>',true);
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

procedure balken;

var i,Pfeil,
    spalte,Altespalte    : byte;
    Taste                : char;
    Help                 : string1;


begin
     mouse_event:=false;
     textbackground(backGround);textcolor(foreground);
     window (1,1,80,1);
     clrscr;
     cursor_off;
     for i:= 0 to NrOfItems-1 do PrintLine(i*10+1,1,Items[i+1],10);
     gotoxy(62,1);write(info);
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





begin
     startseg:=$b800;
     if Graph_mode=hga then startseg:=$b000;
     if mouseinstalled then mouse_cursor(0,$ffff,$ff00);
end.

