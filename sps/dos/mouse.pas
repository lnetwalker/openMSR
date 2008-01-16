unit mouse;
{ stellt grundlegende mouseroutinen zur verfuegung }
{ achtung im moment nur fuer textmode }
{ (c) Jun/92 by HuSoft }
interface

const mouse_int=$33;

var
mouse_event : boolean;
{mouseinstalled = true ---> mousetreiber installiert }
{mouseinstalled = false --> mousetreiber nicht installiert }
mouseinstalled :boolean;
mouseX,mouseY : byte;
Leftbutton,Rightbutton : boolean;

procedure check_mouse(var inst_flag : boolean);
procedure mouse_area(left,right,top,bottom:byte);
procedure mouse_on;
procedure mouse_off;
procedure mouse_status(var hor_pos,vert_pos :byte;
                       var left_butt,right_butt:boolean);
procedure mouse_cursor(typ , schirm_mask , cursor_mask : word);

implementation
uses dos;
var  old_left , old_right , akt_left , akt_right : boolean;

procedure check_mouse(var inst_flag : boolean);
{ returns true if mouse installed }
var regs : registers;
begin
     inst_flag:=false;
     regs.ax:=0;
     intr(mouse_int,regs);
     if regs.ax <> 0 then inst_flag:=true;
end;


procedure mouse_area(left,right,top,bottom:byte);
{ definiert den bereich in dem die mouse wurschteln darf }
var regs : registers;
begin
     regs.ax:=$7;
     regs.cx:=left shl 3;
     regs.dx:=right shl 3;
     intr(mouse_int,regs);
     regs.ax:=$8;
     regs.cx:=top shl 3;
     regs.dx:=bottom shl 3;
     intr(mouse_int,regs);
end;

procedure mouse_on;
{schaltet mousezeiger ein }
var regs : registers;
begin
     regs.ax:=$1;
     intr(mouse_int,regs);
end;


procedure mouse_off;
{schaltet mousezeiger aus }
var regs : registers;
begin
     regs.ax:=$2;
     intr(mouse_int,regs);
end;

procedure mouse_status(var hor_pos,vert_pos :byte;
                       var left_butt,right_butt:boolean);
{ liefert den status der mouse tasten und die position des zeigers zuruck }
var regs : registers;
    state : word;
begin
     akt_left:=false;
     akt_right:=false;
     left_butt:=false;
     right_butt:=false;
     regs.ax:=$3;
     intr(mouse_int,regs);
     hor_pos:=regs.cx shr 3; {durch 8 teilen fuer textkoordinaten }
     vert_pos:=regs.dx shr 3;
     state:=regs.bx;
     if state = 1 then akt_left:=true;
     if state = 2 then akt_right:=true;
     if akt_left and not(old_left) then left_butt:=true;
     if akt_right and not(old_right) then right_butt:=true;
     old_left:=akt_left;
     old_right:=akt_right;
end;

procedure mouse_cursor(typ , schirm_mask , cursor_mask : word);
{ legt das erscheinungsbild des mousezeigers fest }
var regs : registers;
begin
     regs.ax:=$a;
     regs.bx:=typ;
     regs.cx:=schirm_mask;
     regs.dx:=cursor_mask;
     intr(mouse_int,regs);
end;

begin
     mouseinstalled:=false;
     old_left:=false;
     old_right:=false;
     akt_left:=false;
     akt_right:=false;
     check_mouse(mouseinstalled);
     if mouseinstalled then mouse_cursor(0,$ffff,$ff00);
end.