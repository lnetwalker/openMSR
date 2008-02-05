unit qgtk2;

{ qgtk2.pas 0.9

  Quick programming with gtk2 in pascal
  
  Freepascal 2.0: http://www.freepascal.org/
  gtk2+: http://www.gtk.org/


  (c) 2005 Jirka Bubenicek  -  hebrak@yahoo.com
      http://home.tiscali.cz/bubenic/nase.gnu/qgtk_en.htm


  License: GNU GENERAL PUBLIC LICENSE

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

}



interface

uses
 glib2,gdk2,gtk2,pango, sysutils 
{$ifdef Win32}, windows {$endif},     qlocale;



type qWidget = pGtkWidget;

     qpic = record
        pxmp:  PGdkPixmap;
        mask:  pGdkBitmap;
     end;

     qfgobj = object
       no : integer;
       constructor newFromXpm(fname : string; x, y, width, height : integer);
       constructor newFromXpm_d(data:ppgchar; x, y, width, height : integer);
       procedure  setPic(Pic : qpic);
       procedure move(x,y : integer);
       procedure show;
       procedure hide;
       procedure tobk;
       procedure tofg;
       destructor free;
      end;


var qx, qy : longint;   {mouse position in DrawA}
    qmousebut : integer;
    qkey : char;
    qkeykode : longint;
    qkeystate : integer; {4 -Ctrl, 8 - Alt,  2,3 - CapsLock }
    qmainWindow,   qdrawArea : qWidget;
    qfontname : string;

    qPack, qAutoupdate : boolean;
    qCanDestroy :boolean; {you can set it in ondestroy procedure to false}


const
      qkUp  =65362;  {qkeykode}
      qkLeft=65361;
      qkDown =65364;
      qkRight=65363;
      qkEsc =65307;
      qkEnter=65293;

      qWhite =999999999;
      qBlack =        0;
      qRed   =999000000;
      qgreen =   666000;
      qBlue  =      999;
      qYellow=999999000;
      qGray  =666666666;
      qPurple=666000666;
      qAqua  =   999999;
      qBrown =666333000;


  qfontname0 :  string='0'; 
  qfontname1 :  string={$ifdef Win32}'arial 12'{$else}'* 12'{$endif};
  
      qtabfocus: Boolean=false;  {tab key not switch focus  }


function fontspl(fname: string) : string; //***************************************--------

procedure qstart(wcaption : string; onkey, ondestroy : Tprocedure);

procedure qsetfocus(wid: qwidget);

procedure qmnu(caption : string);
procedure qsubmnu(caption : string; proc : tprocedure);

procedure qNextRow;
procedure qNextRowResize;  {set window resizable}
procedure qNextRowLeft;
procedure qseparator;
procedure qFrame;
procedure qEndFrame;

function qBoxv : qWidget;

function qlabel( caption :string) :qWidget;
function qlabelWrap(caption :string; width : integer) :qWidget;
procedure qlabelset(labl : qWidget ; caption: string);

function qlabelXpm( xpmFile :string) :qWidget;
function qlabelXpm_d(Data : ppgchar) :qWidget;

function qedit(text: string) :qWidget;
procedure qeditset(edit : qWidget ; text: string);
function qeditget(edit : qWidget) : string;

function qbutton( caption : string; proc : tprocedure  ) :qWidget;

function qbuttonXpm(xpmFile, hint : string; proc : tprocedure  ) :qWidget;

function qbuttonXpm_d(Data: ppgchar; hint: string; proc: tprocedure):qWidget;

function qbuttonToggle( caption : string; proc : tprocedure  ) :qWidget;
function qToggleGetA(button : qWidget) : boolean;
procedure qToggleSetA(button : qWidget);
procedure qToggleSetN(button : qWidget);

function qprogress(width :integer): qWidget;
procedure qprogressSet(progress:qwidget; percentage:integer ); {percentage 1..100}

function qtext(width, height : integer; onchange : Tprocedure) : qWidget;
function qtextlength(txt : qWidget) : longint;
procedure qtextsetp(txt : qWidget; i : longint);
function qtextgetp(txt : qWidget) : longint;
procedure qtextinsert( txt : qWidget; text : string);
procedure qtextdel(txt : qWidget; startp, endp : longint);
procedure qtextaddline( txt : qWidget; text : string);
function qtextstring(txt : qWidget; startp, endp : longint) : string;
procedure qtextsel(txt : qWidget; startp, endp : longint);
procedure qtextcopy(txt : qWidget);
procedure qtextpaste(txt : qWidget);
procedure qtextcut(txt : qWidget);
function qtextSelEnd(txt : qWidget): longint;
function qtextSelStart(txt : qWidget): longint;
procedure qtextApplyFont(txt : qWidget);
procedure qtextSetEdit(txt : qWidget);
procedure qtextSetNoEdit(txt : qWidget);
function qtextload(txt : qWidget; filename : string) : boolean;
function qtextsave(txt : qWidget; filename : string) : boolean;

function qlist(width, height:integer; sorted: boolean;
                   onchange, on2click :tprocedure ) : qWidget;
procedure qlistAdd(list: qWidget; text : string);
procedure qlistInsert(list: qWidget; text : string);
procedure qlistDelRow(list: qWidget);
procedure qlistClear(list: qWidget);
function qlistItem(list: qWidget) : string;
procedure qlistselect(list: qWidget; row : integer);
function qlistselrow(list : qWidget) : integer;
function qlistrowcount(list : qWidget) : integer;

function qFileSelect(caption: string; filename:string ): string;
function qFontSelect(caption: string ) : string; {set qfontname, return fontname}
function qClrSelect(caption: string) : longint; {RRRGGGBBB,  999000000 is red}
function qdialog(message, but1capt, but2capt, but3capt : string): integer;
function qinput(message, inputstr : string): string;

procedure qshow(widget : qWidget);
procedure qhide(widget : qWidget);

procedure qdestroy;
procedure qGo;
procedure qMainIter;

procedure qdrawstart(width, height : integer;
           onstart, procclick, procmove : tprocedure );
	   
function qsetClr(rgb: longint ) : boolean; {RRRGGGBBB,  999000000 is red}
procedure qpoint( x, y : integer );
procedure qrect( x, y, width, height : integer );
procedure qfillrect( x, y, width, height  : integer);
procedure qfillellipse( x, y, width, height  : integer);
procedure qellipse( x, y, width, height  : integer);
procedure qline( x1, y1, x2, y2: integer );
procedure qfont(size:integer);   {for size=0 use size in qfontname0}
procedure qdrawtext(x,y : integer; s : string);
procedure qdrawpic(x, y  : integer; pic: qpic );
procedure qgetpic(x,y, width, height  : integer; var pic : qpic );
procedure qpicFromXpm(xpmfile : string; var pic : qpic);
procedure qpicFromXpm_d(data : ppgchar; var pic : qpic);
procedure qupdateRect(x, y, w, h : integer);

procedure qtimerstart(interval : longint;  proc : tprocedure  );

function qsecwindow(caption: string) : qWidget;
procedure qshowsec(secwind : qwidget);
procedure qshowsecmodal(secwind : qwidget);
procedure qhidesec(secwind : qwidget);

procedure qshowW32console;
procedure qhideW32console;

{**************}
function  efocus_out_event (widget : qWidget ; event: PGdkEventFocus ) : gboolean; cdecl;
function  ebutton_press_event (widget : qWidget ; event: PGdkEventbutton ) : gboolean; cdecl;
procedure widgetQpack(wid: qwidget);
function Pchastr( s : string): Pchar;
{**************}

implementation

Type Tfgobj = record
       pic: qpic;
       x, y, w, h : integer;
       visible : boolean;
      end;


var window, boxH, boxV, fileselw, fontselw, colselw,
      menu_bar, m0, mi, m0i, boxV0, boxh0 :qWidget;
     activewindow  : qWidget;
    button_bar_tips : pGtkTooltips;
        achjo: array[0..255] of Char;
    idialbut:integer;
    inputrestr : string;
    inputedit : qwidget;
    drawclick, drawmove, startproc, keyproc,
             timerproc,  fixmodalproblemproc   : Tprocedure;
    destroyproc : Tprocedure;
    drawA :qWidget;
    DrawGC : pgdkgc;
    color : pgdkcolor;
    cmap : pGdkColormap;
    poprve, secmodal, inframe, qPackLeft, clrOk : boolean;
    drawWidth, drawHeight: integer;
    fileselected, fontselected : string;
    fujcolor, oldcolor : array [0..3] of gdouble;
    qfontname0a,  qfontname1a,   fontnold : string;
    

    Gdkwin:PGdkWindow;

    fgobjs : array [1..99] of Tfgobj;
    fgobjindx : array[1..99] of integer;

    listselrow, listrowcount : array[1..99] of integer;
    listchange, list2click : array[1..99] of Tprocedure;
    clists :  array[1..99] of PGtkCLIST;
    cviews :  array[1..99] of pGtkWidget;
    cbuffers :  array[1..99] of pGtkTextBuffer;
    listscount, textscount : integer;
    qlrowcount, qlselrow, modallevel : integer;

{ Backing pixmap for drawing area }
const
  pixmap : PGdkPixmap = NIL;
  bk_pxmp00 :  PGdkPixmap =nil;
  drawrun : boolean=false;
  startrun: boolean=false;

  hW32console : integer=0;  {for hide console in win32}
  w32consoleVisible : boolean=false;




{  without unit qlocale:
function encode(s: string):string;
begin
encode:=s;
end;

function decode(s: string):string;
begin
decode:=s;
end;
}





function Pchastr( s : string): Pchar;
begin
s:=encode(s);
strPcopy(achjo,s);
Pchastr:=achjo;
end;



{ This callback quits the program }
function delete_event (widget : qWidget ; event: pGdkEvent; data: pgpointer ): gboolean; cdecl;
begin
  qdestroy;
  if qcandestroy then
  delete_event:=false
  else  delete_event:=true;
end;


function delete_eventsec (widget : qWidget ; event: pGdkEvent; data: pgpointer ): gboolean; cdecl;
begin
  qhidesec(widget);
  delete_eventsec:=true;
end;



procedure mycallback(widget : qWidget ; data: Tprocedure ); cdecl;
begin
if data<>nil then data;  {run procedure}
end;




function  key_press_event (widget : qWidget ; event: PGdkEventKey ) : gboolean; cdecl;
var keyst : string;
begin
case event^.keyval of 65505, 65507, 65513, 65508 :
                       begin {shift, left-right ctrl alt} end;
   else
    begin
     keyst:=pchar(event^._string);
     qkey:=#0;
     qkeykode:=event^.keyval;
     if qkeykode=65421 then qkeykode:=qkEnter;
     qkeystate:= event^.state;
     if length(keyst)>0 then qkey:=keyst[1];
     if keyproc<>nil then keyproc;
    end;
end;
  key_press_event := false;
end;



function fontspl(fname: string) : string;
var i,j, k : integer;
begin
k:=0;
for i:=0 to 4 do
 begin
  j:=length(fname)-i;
  if fname[j]=' ' then
   begin
    k:=j;
    break;
   end;
 end;
fontspl:=copy(fname,1,k-1); 
end;




procedure qshowW32console;
begin
{$ifdef Win32}
if not w32consolevisible and (hW32console<>0) then
   ShowWindow(hW32console, SW_show);
w32consolevisible:=true;
{$endif}
end;

procedure qhideW32console;
begin
{$ifdef Win32}
if w32consolevisible then
   ShowWindow(hW32console, SW_hide);
w32consolevisible:=false;
{$endif}
end;




procedure qstart(wcaption:string; onkey, ondestroy : Tprocedure);
begin
 if startrun then
   begin writeln('qError - qstart can run only once'); exit; end;
  startrun:=true;
{$ifdef Win32}
hW32console:=GetForegroundWindow;
if not w32consoleVisible then ShowWindow(hW32console, 0);
{$endif}
 qautoupdate:=true;
 qmousebut:=0;
 gtk_set_locale();
 gtk_init (@argc, @argv);
  window := gtk_window_new (GTK_WINDOW_TOPLEVEL);
  activewindow:=window;
  gtk_window_set_title (GTK_WINDOW (window), Pchastr(wcaption) );
  g_signal_connect (G_OBJECT (window), 'delete_event',
                    G_CALLBACK (@delete_event), NIL);
  g_signal_connect (G_OBJECT (window), 'key_press_event',
         G_CALLBACK (@key_press_event), NIL);
boxV := gtk_vbox_new(FALSE, 1);
gtk_container_add (GTK_CONTAINER (window), boxV);
 menu_bar := gtk_menu_bar_new ();
 gtk_box_pack_start (GTK_BOX (boxV), menu_bar, FALSE, FALSE, 0);
qPackLeft:=false;
 boxH := gtk_hbox_new(true, 1);
gtk_box_pack_start(GTK_BOX(boxV), boxH, false, false, 0);

gtk_widget_show (BoxV);
gtk_widget_show (BoxH);
inframe:=false;

button_bar_tips:=gtk_tooltips_new();

qkey:=#0;
qkeykode:=0;
qkeystate:=0;
keyproc:=onkey; 
modallevel:=0;
destroyproc:=ondestroy;
poprve:=true;
new(color);
cmap:= gdk_colormap_get_system();
oldcolor[0]:=1;
oldcolor[1]:=1;
oldcolor[2]:=1;

if (qfontname0='0') then qfontname0:=qfontname1; 
qfontname:=qfontname0;
Fontnold:=qfontname;
qfontname0a:=fontspl(qfontname0);
qfontname1a:=fontspl(qfontname1);
listscount:=0;
textscount:=0;
qPack:=true;
qcandestroy:=true;
                         {not resziable window}
  gtk_window_set_policy ( GTK_WINDOW(window),0,0,0);
qmainwindow:=window;
fixmodalproblemproc:=nil;
{  if (xpos>0) and (ypos>0) then
        gtk_widget_set_uposition(window, xpos, ypos);}
end;


procedure qsetfocus(wid: qwidget);
begin
  GTK_WIDGET_SET_FLAGS (wid, GTK_can_FOCUS);
  gtk_widget_grab_focus(wid);
end;



procedure widgetQpack(wid: qwidget);
begin
if not qPack then exit;
if qPackLeft then
      gtk_box_pack_start(GTK_BOX(boxH), wid, false, false, 0)
 else gtk_box_pack_start(GTK_BOX(boxH), wid, true, true, 0);
  gtk_widget_show (wid);
end;


procedure qNextRow;
begin
qpackleft:=false;
boxH := gtk_hbox_new(true, 1);
gtk_box_pack_start(GTK_BOX(boxV), boxH, false, false, 0);
gtk_widget_show (BoxH);
end;



procedure qNextRowResize;
begin
qpackleft:=false;
boxH := gtk_hbox_new(true, 1);
gtk_box_pack_start(GTK_BOX(boxV), boxH, true, true, 0);
gtk_widget_show (BoxH);
gtk_window_set_policy ( GTK_WINDOW(activewindow),1,1,0);
end;


procedure qNextRowLeft;
begin
qpackleft:=true;
boxH := gtk_hbox_new(FALSE, 1);
gtk_box_pack_start(GTK_BOX(boxV), boxH, false, false, 0);
gtk_widget_show (BoxH);
end;


procedure qseparator;
var separator : qwidget;
begin
qnextrow;
separator := gtk_hseparator_new ();
widgetqpack(separator);
qnextrow;
end;


procedure qFrame;
var separator : qwidget;
begin
qpackleft:=true;
if not inframe then
  begin
   qnextrowleft;
   boxV0:=boxV;
   boxh0:=boxh;
  end
 else
  begin
   boxh:=boxh0;
   separator := gtk_vseparator_new ();
    gtk_box_pack_start(GTK_BOX(boxH), separator, false, false, 0);
   gtk_widget_show (separator);
  end;

boxV := gtk_vbox_new(FALSE, 1);
 gtk_box_pack_start(GTK_BOX(boxH), boxV, true, true, 0);
 gtk_widget_show (boxV);
qnextrow;
inframe:=true;
end;


procedure qEndFrame;
begin
boxv:=boxv0;
qnextrow;
inframe:=false;
end;


function qBoxv : qWidget;
var  BoxV : qWidget;
begin
 BoxV := gtk_vbox_new(FALSE, 0);
 widgetqpack(boxV);
 qboxv:=Boxv;
end;


function qsecwindow(caption: string) : qWidget;
var secw : qWidget;
begin
secw := gtk_window_new (GTK_WINDOW_TOPLEVEL);
 activewindow:=secw;
qsecwindow:=secw;
gtk_window_set_position(GTK_WINDOW(secw), GTK_WIN_POS_MOUSE );
boxV := gtk_vbox_new(FALSE, 0);
gtk_container_add (GTK_CONTAINER (qsecwindow), boxV);
 menu_bar := gtk_menu_bar_new ();
 gtk_box_pack_start (GTK_BOX (boxV), menu_bar, FALSE, FALSE, 2);
qPackLeft:=false; 
boxH := gtk_hbox_new(true, 1); 
gtk_box_pack_start(GTK_BOX(boxV), boxH, false, false, 1);

gtk_widget_show (BoxV);
gtk_widget_show (BoxH);
inframe:=false;
gtk_window_set_title (GTK_WINDOW (secw), Pchastr(caption) );
g_signal_connect (G_OBJECT (secw), 'delete_event',
                    G_CALLBACK (@delete_eventsec), NIL);
g_signal_connect (G_OBJECT (secw), 'key_press_event',
             G_CALLBACK (@key_press_event), NIL);
gtk_window_set_policy ( GTK_WINDOW(secw),0,0,0);
end;


procedure qshowsecmodal(secwind : qwidget);
begin
secmodal:=true;
inc(modallevel);
gtk_window_set_modal(GTK_WINDOW(secwind), secmodal);
gtk_window_set_transient_for(GTK_WINDOW(secwind),GTK_WINDOW(qmainwindow) );  //*** on top
qshow(secwind);
gtk_main ();
end;


procedure qshowsec(secwind : qwidget);
begin
if secmodal then 
  begin 
   qshowsecmodal(secwind); 
   exit; 
  end;
gtk_window_set_modal(GTK_WINDOW(secwind), secmodal);
qshow(secwind);
end;


procedure qhidesec(secwind : qwidget);
begin
qhide(secwind);
if secmodal then
  begin
   dec(modallevel);
gtk_window_set_transient_for(GTK_WINDOW(secwind), nil ); //*** not on top
   gtk_main_quit();
  end; 
if modallevel=0 then secmodal:=false;
end;



{*********************************  mnu ***********************************}
procedure qmnu(caption : string);
begin
m0:= gtk_menu_new();
m0i:= gtk_menu_item_new_with_label (pchastr(caption));
gtk_widget_show(m0i);
gtk_menu_item_set_submenu(GTK_MENU_ITEM (m0i), m0 );
gtk_menu_bar_append((menu_bar), m0i);
gtk_widget_show (menu_bar);
end;


procedure qsubmnu(caption : string; proc : tprocedure);
begin
      if caption[1]='-' then
         begin               {separation line}
          mi:=gtk_menu_item_new();
          gtk_menu_append ( (m0), mi);
          gtk_widget_show(mi);
          caption:=copy(caption,2,length(caption));
         end;
      mi:= gtk_menu_item_new_with_label (pchastr(caption));
      gtk_menu_append ( (m0), mi);
      gtk_widget_show(mi);
      g_signal_connect (G_OBJECT (mi), 'activate',
                G_CALLBACK (@mycallback), proc );

end;
{**************************************************************************}





function qbutton( caption : string; proc : tprocedure  ) :qWidget;
var  button :qWidget;
begin
  button := gtk_button_new_with_label (Pchastr(caption));
     g_signal_connect (G_OBJECT (button), 'clicked',
                 G_CALLBACK (@mycallback), proc );
widgetQpack(button);
  qbutton:=button;
if not qtabfocus then  GTK_WIDGET_unSET_FLAGS (button, GTK_can_FOCUS);
end;





function qbuttonXpm(xpmFile, hint : string; proc : tprocedure  ) :qWidget;
var  button :qWidget;
     pcha: PChar;
    pixmapwid : qWidget;
    _pixmap :   pGdkPixmap;
    mask   : pGdkBitmap;
    style  : pGtkStyle;
begin
  style := gtk_widget_get_style(window);
  _pixmap := gdk_pixmap_colormap_create_from_xpm (window^.window,
                   cmap, mask,  @style^.bg[GTK_STATE_NORMAL], Pchastr(xpmFile));
  pixmapwid := gtk_pixmap_new (_pixmap, mask);
  gtk_widget_show( pixmapwid );
  button := gtk_button_new ();
  gtk_container_add (GTK_CONTAINER (button), pixmapwid);


     g_signal_connect (G_OBJECT (button), 'clicked',
                 G_CALLBACK (@mycallback), proc );
widgetQpack(button);
  qbuttonXpm:=button;
if not qtabfocus then GTK_WIDGET_unSET_FLAGS (button, GTK_can_FOCUS);  
if hint='' then exit;
Pcha:=pchastr(hint);
gtk_tooltips_set_tip(GTK_TOOLTIPS (button_bar_tips), button, pcha, pcha);
end;



function qbuttonXpm_d(Data:ppgchar; hint:string; proc:tprocedure) :qWidget;
var  button :qWidget;
     pcha: PChar;
    pixmapwid : qWidget;
    _pixmap :   pGdkPixmap;
    mask   : pGdkBitmap;
    style  : pGtkStyle;
begin
  style := gtk_widget_get_style(window);
  _pixmap := gdk_pixmap_colormap_create_from_xpm_d (window^.window,
                   cmap, mask,  @style^.bg[GTK_STATE_NORMAL], data);
  pixmapwid := gtk_pixmap_new (_pixmap, mask);
  gtk_widget_show( pixmapwid );
  button := gtk_button_new ();
  gtk_container_add (GTK_CONTAINER (button), pixmapwid);
     g_signal_connect (G_OBJECT (button), 'clicked',
                 G_CALLBACK (@mycallback), proc );
 widgetQpack(button);
  qbuttonXpm_d:=button;
if not qtabfocus then GTK_WIDGET_unSET_FLAGS (button, GTK_can_FOCUS);  
if hint='' then exit;
Pcha:=pchastr(hint);
gtk_tooltips_set_tip(GTK_TOOLTIPS (button_bar_tips), button, pcha, pcha);
end;




function qbuttonToggle( caption : string; proc : tprocedure  ) :qWidget;
var  button  :qWidget;
begin
  button := gtk_toggle_button_new_with_label(Pchastr(caption));
     g_signal_connect (G_OBJECT (button), 'clicked',
                 G_CALLBACK (@mycallback), proc );
 widgetQpack(button);
  qbuttontoggle:=button;
if not qtabfocus then   GTK_WIDGET_unSET_FLAGS (button, GTK_can_FOCUS);
end;


function qToggleGetA(button : qWidget) : boolean;
begin
qToggleGetA:=gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(button) );
end;


procedure qToggleSetA(button : qWidget);
begin
if qToggleGetA(button) then exit;
gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(button), true );
end;

procedure qToggleSetN(button : qWidget);
begin
if not qToggleGetA(button) then exit;
gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(button), false );
end;



function qlabel( caption :string) :qWidget;
var  labl :qWidget;
begin
  labl:=gtk_label_new(Pchastr(caption));
 widgetQpack(labl);
  qlabel:=labl;
end;


function qlabelWrap(caption :string; width : integer) :qWidget;
var  labl :qWidget;
begin
  labl:=gtk_label_new(Pchastr(caption));
  gtk_widget_set_usize(labl, width, -1);
 widgetQpack(labl);
   gtk_misc_set_alignment(GTK_MISC(labl), 0.0, 0.0);
   gtk_label_set_justify( GTK_LABEL(labl),GTK_JUSTIFY_LEFT);
   gtk_label_set_line_wrap( GTK_LABEL(labl), true);
   qlabelWrap:=labl;
end;


procedure qlabelset(labl : qWidget ; caption: string);
begin
gtk_label_set_text( GTK_LABEL(labl) , Pchastr(caption));
end;




function qlabelXpm( xpmFile :string) :qWidget;
var  labl :qWidget;
    _pixmap :   pGdkPixmap;
    mask   : pGdkBitmap;
    style  : pGtkStyle;

begin
  style := gtk_widget_get_style(window);
  _pixmap := gdk_pixmap_colormap_create_from_xpm (window^.window,
                   cmap, mask,  @style^.bg[GTK_STATE_NORMAL], Pchastr(xpmFile));
 labl := gtk_pixmap_new (_pixmap, mask);
  widgetQpack(labl);
  qlabelXpm:=labl;
end;


function qlabelXpm_d(Data : ppgchar) :qWidget;
var  labl :qWidget;
    _pixmap :   pGdkPixmap;
    mask   : pGdkBitmap;
    style  : pGtkStyle;

begin
  style := gtk_widget_get_style(window);
  _pixmap := gdk_pixmap_colormap_create_from_xpm_d(window^.window,
                   cmap, mask,  @style^.bg[GTK_STATE_NORMAL], data);
 labl := gtk_pixmap_new (_pixmap, mask);
  widgetQpack(labl);
  qlabelXpm_d:=labl;
end;





function  efocus_out_event (widget : qWidget ; event: PGdkEventFocus ) : gboolean; cdecl;
begin
if not qtabfocus then  GTK_WIDGET_unSET_FLAGS (widget, GTK_CAN_FOCUS);
  efocus_out_event := false;
end;

function  ebutton_press_event (widget : qWidget ; event: PGdkEventbutton ) : gboolean; cdecl;
begin
 GTK_WIDGET_SET_FLAGS (widget, GTK_CAN_FOCUS);
 ebutton_press_event := false;
end;                    


function qedit(text : string) :qWidget;
var  edit :qWidget;
begin
  edit:= gtk_entry_new();
  qeditset(edit,text);
widgetQpack(edit);
  qedit:=edit;
 if not qtabfocus then  GTK_WIDGET_unSET_FLAGS (edit, GTK_CAN_FOCUS);
    g_signal_connect (G_OBJECT (edit), 'focus_out_event',
     G_CALLBACK (@efocus_out_event), NIL);
    g_signal_connect (G_OBJECT (edit), 'button_press_event',
     G_CALLBACK (@ebutton_press_event), NIL);     
qsetfocus(edit);
end;


procedure qeditset(edit : qWidget ; text: string);
begin
gtk_entry_set_text( GTK_ENTRY(edit) , Pchastr(text));
end;

function qeditget(edit : qWidget) : string;
var pcha: PChar;
begin
pcha:= gtk_entry_get_text( GTK_ENTRY(edit) );
qeditget:=decode(pchar(pcha));
end;


function qprogress(width :integer): qWidget;
var progr : qwidget;
begin
progr:=gtk_progress_bar_new;
gtk_widget_set_usize(progr, width, -1);
 widgetQpack(progr);
qprogress:=progr; 
end;

procedure qprogressSet(progress:qwidget; percentage:integer );
var r : real;
begin
r:=percentage/100;
if r<0 then r:=0;
if r>1 then r:=1;
gtk_progress_set_percentage(GTK_PROGRESS(progress), r );
end;


procedure qshow(widget : qWidget);
begin
 gtk_widget_show (widget);
end;

procedure qhide(widget : qWidget);
begin
 gtk_widget_hide (widget);
end;


procedure qdestroy;
begin
qcandestroy:=true;
if destroyproc<>nil then destroyproc;
if qcandestroy then gtk_exit(0);
end;




function timerListModalproblemcallback( data: gpointer ): gboolean; cdecl;
begin    {fix problem with doubleclick on list in modal window  }
if fixmodalproblemproc<>nil then  fixmodalproblemproc;
fixmodalproblemproc:=nil;
timerListModalproblemcallback:=true;
end;

procedure qGo;
begin
gtk_timeout_add(9, @timerListModalproblemcallback , nil );
  gtk_widget_show (window);
  gtk_main ();
end;


procedure qMainIter;
begin
while gtk_events_pending()<>0 do gtk_main_iteration();
end;



function timercallback( data: gpointer ): gboolean; cdecl;
begin
if timerproc<>nil then timerproc;
timercallback:=true;
end;


procedure qtimerstart(interval : longint;  proc : tprocedure  );
begin
timerproc:=proc;
gtk_timeout_add( interval, @timercallback , nil );
end;





{********************************* text **************************}
procedure textchange(widget : qWidget ; data: Tprocedure ); cdecl;
begin
if data<>nil then data;  {run procedure}
end;


function indtext(thetext : PGtkwidget) : integer;
var i, ii : integer;     
begin                         
indtext:=-1;                
for i:=1 to textscount do       
  if thetext=cviews[i] then ii:=i;
 indtext:=ii;               
end;



function qtext(width, height : integer; onchange : Tprocedure ) : qWidget;
var  txtview, scrolled_window : qWidget;
     buffer: pGtkTextBuffer;
begin
 if textscount>=99 then  
    begin writeln('qError - only max 99 qtexts suported '); exit; end;
    inc(textscount);

txtview := gtk_text_view_new (); 
buffer := gtk_text_view_get_buffer (GTK_TEXT_VIEW (txtview)); 
scrolled_window := gtk_scrolled_window_new(nil, nil);  
gtk_widget_set_usize(scrolled_window, width, height);  
gtk_scrolled_window_set_policy(pGtkScrolledWindow(scrolled_window), 
                                GTK_POLICY_automatic , GTK_POLICY_always); 
gtk_container_add (GTK_CONTAINER (scrolled_window), txtview); 

qtextApplyFont(txtview);            

  g_signal_connect (G_object (buffer), 'changed',
                 G_CALLBACK (@textchange), onchange );
  if not qtabfocus then GTK_WIDGET_unSET_FLAGS (txtview, GTK_CAN_FOCUS);
  g_signal_connect (G_OBJECT (txtview), 'focus_out_event',
          G_CALLBACK (@efocus_out_event), NIL);
  g_signal_connect (G_OBJECT (txtview), 'button_press_event',
         G_CALLBACK (@ebutton_press_event), NIL);   

widgetQpack(scrolled_window);
  gtk_widget_show ( txtview );
gtk_text_view_set_wrap_mode(PGTKTextView(txtview), GTK_WRAP_WORD);
cviews[textscount]:=PGTKWIDGET(txtview);
cbuffers[textscount]:=PGTKtextBuffer(buffer);

qsetfocus(txtview);
qtext:=txtview;    
end;



function qtextlength(txt : qWidget) : longint;
var  buff : PGTKTEXTBUFFER;
    i: longint;
begin
i:=indtext(txt); 
buff:=cbuffers[i];
qtextlength:= gtk_text_buffer_get_char_count(buff );
end;



procedure qtextsetp(txt : qWidget; i : longint);
var  buff : PGTKTEXTBUFFER;
    ii: longint;
    iter : TGtkTextIter;
begin
ii:=indtext(txt); 
buff:=cbuffers[ii];
gtk_text_buffer_get_iter_at_offset(buff, @iter, i);
gtk_text_buffer_place_cursor(buff, @iter);
gtk_text_view_scroll_to_iter (pGTKtextVIEW(txt), @iter, 0.1, false, 0, 0);
end;


function qtextgetp(txt : qwidget) : longint;
var  buff : PGTKTEXTBUFFER;
    ii: longint;
    iter : TGtkTextIter;
    insmark : pGtkTextMark;
begin
ii:=indtext(txt); 
buff:=cbuffers[ii];
insmark:=gtk_text_buffer_get_insert (buff);
gtk_text_buffer_get_iter_at_mark(buff, @iter, insmark);
qtextgetp:= gtk_text_iter_get_offset( @iter );
end;



procedure qtextinsert( txt : qWidget; text : string);
var i, p : longint;
   buff : PGTKTEXTBUFFER;
begin
i:=indtext(txt);
buff:=cbuffers[i];
p:=qtextgetp(txt);
gtk_text_buffer_insert_at_cursor(buff,Pchastr(text), -1);
qtextsetp(txt,p);
end;


procedure qtextdel(txt : qWidget; startp, endp : longint);
var  buff : PGTKTEXTBUFFER;
     startiter,  enditer : TGtkTextIter;
     ii : longint;
begin
ii:=indtext(txt); 
buff:=cbuffers[ii];
gtk_text_buffer_get_iter_at_offset(buff, @startiter, startp);
gtk_text_buffer_get_iter_at_offset(buff, @enditer, endp);
gtk_text_buffer_delete(buff, @startiter, @enditer);
end;


procedure qtextaddline( txt : qWidget; text : string);
begin
qtextsetp(txt,-1);
if (qtextstring(txt,qtextlength(txt)-1,-1)=#10) or (qtextlength(txt)=0)
 then qtextinsert(txt,text+#10)
 else qtextinsert(txt,#10+text+#10);
end;


function qtextstring(txt : qWidget; startp, endp : longint) : string;
var pcha: PChar;
     buff : PGTKTEXTBUFFER;
     startiter,  enditer : TGtkTextIter;
     ii : longint;
begin
ii:=indtext(txt); 
buff:=cbuffers[ii];
gtk_text_buffer_get_iter_at_offset(buff, @startiter, startp);
gtk_text_buffer_get_iter_at_offset(buff, @enditer, endp);
pcha:=gtk_text_buffer_get_text(buff, @startiter, @enditer, false );
qtextstring:=decode(pchar(pcha));
g_free(pcha);
end;


procedure qtextsel(txt : qWidget; startp, endp : longint);
var  buff : PGTKTEXTBUFFER;
     iter : TGtkTextIter;
     ii : longint;
begin
qtextsetp(txt, startp);
ii:=indtext(txt); 
buff:=cbuffers[ii];
gtk_text_buffer_get_iter_at_offset(buff, @iter, endp);
gtk_text_buffer_move_mark_by_name (buff, 'selection_bound', @iter );
end;



procedure qtextcopy(txt : qWidget);
var  buff : PGTKTEXTBUFFER;
     ii : longint;
begin
ii:=indtext(txt); 
buff:=cbuffers[ii];
gtk_text_buffer_copy_clipboard (buff, gtk_clipboard_get (gdk_atom_intern('CLIPBOARD', false) )  );
end;

procedure qtextpaste(txt : qWidget);
var  buff : PGTKTEXTBUFFER;
     ii, s, e : longint;
     uff:pgchar;
begin
s:=qtextselstart(txt);
e:=qtextselend(txt);
if s<>e then qtextdel(txt,s,e);
ii:=indtext(txt); 
buff:=cbuffers[ii];  
uff:=gtk_clipboard_wait_for_text( gtk_clipboard_get ( gdk_atom_intern('CLIPBOARD', false)));
if pchar(uff)='' then exit;
gtk_text_buffer_insert_at_cursor(buff,uff, -1);
g_free(uff);
end;


procedure qtextcut(txt : qWidget);
var  buff : PGTKTEXTBUFFER;
     ii : longint;
begin
ii:=indtext(txt); 
buff:=cbuffers[ii];
gtk_text_buffer_cut_clipboard (buff, gtk_clipboard_get (gdk_atom_intern('CLIPBOARD', false) ),
                 false );
end;



function qtextSelEnd(txt : qWidget): longint;
var s, e : longint;
     buff : PGTKTEXTBUFFER;
     startiter,  enditer : TGtkTextIter;
     ii : longint;
begin
ii:=indtext(txt); 
buff:=cbuffers[ii];
gtk_text_buffer_get_selection_bounds (buff,  @startiter, @enditer);
e:= gtk_text_iter_get_offset( @enditer );  
s:= gtk_text_iter_get_offset( @startiter );  
 qtextselend:=e;
 if s>e then qtextselend:=s;
end;


function qtextSelStart(txt : qWidget): longint;
var s, e : longint;
     buff : PGTKTEXTBUFFER;
     startiter,  enditer : TGtkTextIter;
     ii : longint;
begin
ii:=indtext(txt); 
buff:=cbuffers[ii];
gtk_text_buffer_get_selection_bounds (buff,  @startiter, @enditer);
e:= gtk_text_iter_get_offset( @enditer );  
s:= gtk_text_iter_get_offset( @startiter ); 
 qtextselstart:=s;
 if s>e then qtextselstart:=e;
end;



procedure qtextApplyFont(txt : qWidget);
var 
    font_desc : pPangoFontDescription;
begin
font_desc := pango_font_description_from_string (pchastr(qfontname )  ); 
gtk_widget_modify_font (txt, font_desc); 
pango_font_description_free (font_desc);
end;





procedure qtextSetEdit(txt : qWidget);
begin
gtk_text_view_set_editable(GTK_TEXT_view (txt), TRUE);
end;

procedure qtextSetNoEdit(txt : qWidget);
begin
gtk_text_view_set_editable(GTK_TEXT_view (txt), false);
end;



function qtextload(txt : qWidget; filename : string) : boolean;
var f : text;
    ch : char;
    s : string;
    i : integer;
    buff : PGTKTEXTBUFFER;
begin
i:=indtext(txt);
buff:=cbuffers[i];
qtextload:=false;
if filename='' then exit;
assign(f, filename);
{$I-}
reset(f);
{$I+}
if IOResult <> 0 then exit;
qtextdel(txt, 0, -1);
while not eof(f) do
 begin
 s:='';
  while not eof(f) do
   begin
    {$I-}
     read(f,ch);
    {$I+}
    if IOResult <> 0 then exit;    
    if ch<>#13 then s:=s+ch;
    if ord(ch)<127 then break;        {utf8}
   end;    
  gtk_text_buffer_insert_at_cursor(buff,Pchastr(s), -1);

 end;
qtextsetp(txt,0);
{$I-}
close(f);
{$I+}
if IOResult <> 0 then exit;
qtextload:=true;
end;


function qtextsave(txt : qWidget; filename : string) : boolean;
var f : text;
    i : longint;
begin
qtextsave:=false;
if filename='' then exit;
assign(f, filename);
{$I-}
rewrite(f);
{$I+}
if IOResult <> 0 then exit;
for i:=0 to qtextlength(txt)-1 do
 begin
  {$I-}
  write(f,qtextstring(txt,i,i+1));
  {$I+}
  if IOResult <> 0 then exit;
 end;
{$I-} 
close(f);
{$I+}
if IOResult <> 0 then exit;
qtextsave:=true;
end;





{****************************    list   *****************************}
function indlist(thelist : PGtkCLIST) : integer;
var i, ii : integer;
begin
indlist:=-1;
for i:=1 to listscount do
  if thelist=clists[i] then ii:=i;
 indlist:=ii;
end;


function  lbutton_press_event (widget : qWidget ; event: PGdkEventbutton ) : gboolean; cdecl;
var list2cl : tprocedure; i: integer;
begin
list2cl:=nil;
 i:=indlist(pGtkcList(widget));
 if i>0 then list2cl:=list2click[i];
 GTK_WIDGET_SET_FLAGS (widget, GTK_CAN_FOCUS);
 if event^._type=GDK_2BUTTON_PRESS then
       if list2cl<>nil then  fixmodalproblemproc:= list2cl;  
 lbutton_press_event := false;
end;     


function  list_key_event (widget : qWidget ; event: PGdkEventKey ) : gboolean; cdecl;
var list2cl : tprocedure; i: integer;
begin
list2cl:=nil;
 i:=indlist(pGtkcList(widget));
 if i>0 then list2cl:=list2click[i];
case event^.keyval of 65505, 65507, 65513, 65508 :
                       begin {shift, left-right ctrl alt} end;
   else
     if (qkEnter=event^.keyval) or (65421{numkeyEnter}=event^.keyval) then
           if list2cl<>nil then list2cl;
end;
  list_key_event := false;
end;



procedure lselection_made (thelist : PGtkCLIST ; row, column: gint;
                  event :  PGdkEventButton ; data : gpointer); cdecl;
var listsel : tprocedure; i : integer;
begin
 i:=indlist( thelist );
 listsel:=nil;
 if i>0 then begin listsel:=listchange[i]; qlselrow:=listselrow[i]; end;
qlselrow:=row;              
listselrow[i]:=qlselrow;   
if (qlrowcount>0) and (qlselrow>-1) and (listsel<>nil) then listsel;
end;



function qlist(width, height : integer; sorted : boolean;
         onchange, on2click : tprocedure ) : qWidget;
var scrolled_window, clist : qWidget;
begin
 if listscount>=99 then
   begin writeln('qError - only max 99 qlists suported '); exit; end;
inc(listscount);
scrolled_window := gtk_scrolled_window_new(nil, nil);
gtk_widget_set_usize(scrolled_window, width, height);
gtk_scrolled_window_set_policy(pGtkScrolledWindow(scrolled_window),GTK_POLICY_NEVER,GTK_POLICY_always);
clist := gtk_clist_new(1);
gtk_clist_set_selection_mode (pGtkcList(clist),GTK_SELECTION_BROWSE);
gtk_container_add (GTK_CONTAINER (scrolled_window), clist);    
gtk_clist_set_auto_sort(pGtkcList(clist), sorted);
listchange[listscount]:=onchange;
list2click[listscount]:=on2click;
  if not qtabfocus then GTK_WIDGET_unSET_FLAGS (clist, GTK_CAN_FOCUS);
    g_signal_connect (G_OBJECT (clist), 'focus_out_event',
     G_CALLBACK (@efocus_out_event), NIL);             
    g_signal_connect (G_OBJECT (clist), 'button_press_event',
     G_CALLBACK (@lbutton_press_event), NIL);     
 g_signal_connect(G_OBJECT(clist), 'select_row',
                     tGCALLBACK(@lselection_made),   NIL);
 g_signal_connect (G_OBJECT (clist), 'key_press_event',
            G_CALLBACK (@list_key_event), NIL);        

widgetQpack(scrolled_window);
  gtk_widget_show ( clist );
listselrow[listscount]:=-1;
listrowcount[listscount]:=0;
clists[listscount]:=pGtkcList(clist);
qsetfocus(clist);
qlist:=clist;
end;


procedure qlistAdd(list:qWidget; text : string);
var tx : array[0..0] of pgchar;
    i: integer;
begin
qlrowcount:=-1; qlselrow:=-1;
 i:=indlist(pGtkcList(list));
 if i>0 then
    begin qlrowcount:=listrowcount[i]; qlselrow:=listselrow[i]; end;
if qlselrow=-1 then qlselrow:=0;    
tx[0]:=pchastr(text);
gtk_clist_append( PgtkClist(list), tx );
inc(qlrowcount);
listrowcount[i]:=qlrowcount;
listselrow[i]:=qlselrow;
qlistselect(list, qlselrow );
end;


procedure qlistinsert(list:qWidget; text : string);
var tx : array[0..0] of pgchar;
    i, row: integer;
begin
qlrowcount:=-1; qlselrow:=-1;
 i:=indlist(pGtkcList(list));
 if i>0 then
    begin qlrowcount:=listrowcount[i]; qlselrow:=listselrow[i]; end;
if qlselrow=-1 then qlselrow:=0;     
row:=qlselrow;
tx[0]:=pchastr(text);
gtk_clist_insert( PgtkClist(list), row, tx );
inc(qlrowcount);
if qlselrow<qlrowcount-1 then inc(qlselrow);
listrowcount[i]:=qlrowcount;
listselrow[i]:=qlselrow;
qlistselect(list, qlselrow);
end;


procedure qlistDelRow(list : qWidget );
var  i, row: integer;
begin
qlrowcount:=-1; qlselrow:=-1;
 i:=indlist(pGtkcList(list));
 if i>0 then
    begin qlrowcount:=listrowcount[i]; qlselrow:=listselrow[i]; end;
row:=qlselrow;
if (row>=qlrowcount) or (row<0) then exit;
gtk_clist_remove( PgtkClist(list), row );
dec(qlrowcount);
if qlselrow>qlrowcount-1 then qlselrow:=qlrowcount-1;
listrowcount[i]:=qlrowcount;
listselrow[i]:=qlselrow;
qlistselect(list, qlselrow);
end;


procedure qlistclear(list : qWidget );
var i:integer;
begin
gtk_clist_clear( PgtkClist(list) );
qlrowcount:=0;
qlselrow:=-1;
 i:=indlist(pGtkcList(list));
listrowcount[i]:=qlrowcount;
listselrow[i]:=qlselrow;
end;


function qlistItem(list : qWidget ) : string;
var txt: PgChar;   s : string;
    row, i : integer;
begin
qlrowcount:=-1; qlselrow:=-1;
 i:=indlist(pGtkcList(list));
 if i>0 then
    begin qlrowcount:=listrowcount[i]; qlselrow:=listselrow[i]; end;
row:=qlselrow;
if (row>=qlrowcount) or (row<0) then begin qlistitem:=''; exit; end;
gtk_clist_get_text(PgtkClist(list), row, 0, @txt );
s:=txt;
qlistitem:=decode(s);
end;


procedure qlistselect(list : qWidget;  row : integer);
var i:integer;
begin
i:=indlist(pGtkcList(list));
gtk_clist_select_row (PgtkClist(list), row, 0);
 if i>0 then listselrow[i]:=row;
end;


function qlistselrow(list : qWidget) : integer;
var i:integer;
begin
  i:=indlist(pGtkcList(list));
 if i>0 then  qlistselrow:=listselrow[i];
end;

function qlistrowcount(list : qWidget) : integer;
var i:integer;
begin
  i:=indlist(pGtkcList(list));
 if i>0 then  qlistrowcount:=listrowcount[i];
end;



{*********************** FileSelection *********************************}
procedure file_ok_sel( w:qWidget; fs:PGtkFileSelection );cdecl;
begin
fileselected:=gtk_file_selection_get_filename (GTK_FILE_SELECTION (fs));
gtk_grab_remove(fileselw);
gtk_main_quit();
end;

procedure file_cancel_sel( w:qWidget; fs:PGtkFileSelection );cdecl;
begin
fileselected:='';
gtk_grab_remove(fileselw);
gtk_main_quit();
end;


procedure qFileSelStart(caption: string; filename:string );
begin
fileselw := gtk_file_selection_new (pchastr(caption));
gtk_window_set_position(GTK_WINDOW(fileselw), GTK_WIN_POS_MOUSE );
 g_signal_connect (G_OBJECT (GTK_FILE_SELECTION (fileselw)^.ok_button),
    'clicked',  G_CALLBACK (@file_ok_sel), fileselw );
 g_signal_connect (G_OBJECT (GTK_FILE_SELECTION (fileselw)^.cancel_button),
    'clicked', G_CALLBACK (@file_cancel_sel), fileselw );
 g_signal_connect (G_OBJECT (fileselw), 'delete_event',
                    G_CALLBACK (@file_cancel_sel), NIL);
gtk_window_set_transient_for(GTK_WINDOW(fileselw),GTK_WINDOW(qmainwindow) );  //*** on top
gtk_file_selection_set_filename (GTK_FILE_SELECTION(fileselw),pchastr(filename) );
gtk_file_selection_hide_fileop_buttons(GTK_FILE_SELECTION(fileselw));
end;


function qFileselect(caption: string;  filename:string ): string;
begin
qFileSelStart(caption, filename );
qFileselect:='';
qshow(fileselw);
gtk_grab_add(fileselw);
gtk_main();
qFileselect:=fileselected;
gtk_widget_destroy(fileselw);
end;


{****************************   fontsel   *****************************}
procedure font_ok_sel( w:qWidget; fs:PGtkFontSelectionDialog );cdecl;
begin
fontselected:=gtk_font_selection_dialog_get_font_name (GTK_Font_SELECTION_Dialog (fs));
if fontselected<>'' then
 begin
  fontnold:=fontselected;                               
  qfontname:=fontselected;
 end;     
gtk_grab_remove(fontselw);
gtk_main_quit();
end;

procedure font_cancel_sel( w:qWidget; fs:PGtkFontSelectionDialog );cdecl;
begin
fontselected:='';
gtk_grab_remove(fontselw);
gtk_main_quit();
end;


procedure qFontSelStart(caption: string );
begin
fontselw := gtk_font_selection_dialog_new (pchastr(caption));
gtk_window_set_position(GTK_WINDOW(fontselw), GTK_WIN_POS_MOUSE );
 g_signal_connect (G_OBJECT (GTK_Font_SELECTION_dialog (fontselw)^.ok_button),
    'clicked', G_CALLBACK (@font_ok_sel), fontselw );
 g_signal_connect (G_OBJECT (GTK_Font_SELECTION_dialog (fontselw)^.cancel_button),
    'clicked',G_CALLBACK (@font_cancel_sel), fontselw );
 g_signal_connect (G_OBJECT (fontselw), 'delete_event',
                    G_CALLBACK (@font_cancel_sel), NIL);
qfontname0a:= fontspl(qfontname0);
gtk_window_set_transient_for(GTK_WINDOW(fontselw),GTK_WINDOW(qmainwindow) );  //*** on top
gtk_font_selection_dialog_set_font_name (GTK_Font_SELECTION_Dialog (fontselw),
                  pchastr(fontnold)    );
end;


function qFontselect(caption: string ) : string;
begin
qFontSelStart(caption);
qFontselect:='';
qshow(fontselw);
gtk_grab_add(fontselw);
gtk_main();
qFontselect:=fontselected;
gtk_widget_destroy(fontselw);
end;



{****************************   colorsel   *****************************}
procedure col_ok_sel( w:qWidget; cs:PGtkcolorSelectionDialog );cdecl;
begin
gtk_color_selection_get_color(GTK_color_SELECTION( (cs)^.colorsel),
                                 @fujcolor   );
clrOk:=true;
oldcolor:=fujcolor;
gtk_grab_remove(colselw);
gtk_main_quit();
end;

procedure col_cancel_sel( w:qWidget; cs:PGtkcolorSelectionDialog );cdecl;
begin
fujcolor:=oldcolor;
clrOk:=false;
gtk_grab_remove(colselw);
gtk_main_quit();
end;


procedure qcolSelStart(caption: string );
begin
colselw := gtk_color_selection_dialog_new (pchastr(caption));
gtk_window_set_position(GTK_WINDOW(colselw), GTK_WIN_POS_MOUSE );
qhide(GTK_color_SELECTION_dialog (colselw)^.help_button);
 g_signal_connect (G_OBJECT (GTK_color_SELECTION_dialog (colselw)^.ok_button),
    'clicked', G_CALLBACK (@col_ok_sel), colselw );
 g_signal_connect (G_OBJECT (GTK_color_SELECTION_dialog (colselw)^.cancel_button),
    'clicked', G_CALLBACK (@col_cancel_sel), colselw );
 g_signal_connect (G_OBJECT (colselw), 'delete_event',
                    G_CALLBACK (@col_cancel_sel), NIL);
gtk_window_set_transient_for(GTK_WINDOW(colselw),GTK_WINDOW(qmainwindow) );  //*** on top
fujcolor[0]:=1;
fujcolor[1]:=1;
fujcolor[2]:=1;
end;


function qclrSelect(caption: string) : longint;
var r,g,b : longint;
begin
clrOk:=false;
qcolSelStart(caption );
gtk_color_selection_set_color(GTK_color_SELECTION(
       (GTK_color_SELECTION_dialog(colselw))^.colorsel),
                                 @oldcolor   );
qshow(colselw);
gtk_grab_add(colselw);
gtk_main();
r:=round(fujcolor[0]*999);
g:=round(fujcolor[1]*999);
b:=round(fujcolor[2]*999);
if clrOk then qclrSelect:=1000000*r+1000*g+b else qclrSelect:=-1;
gtk_widget_destroy(colselw);
end;



{****************************    dialog    *****************************}
procedure dButt1( w:qWidget; di:qWidget );cdecl;
begin
idialbut:=1;
gtk_grab_remove(di);
gtk_widget_destroy(di);
gtk_main_quit();
end;

procedure dButt2( w:qWidget; di:qWidget );cdecl;
begin
idialbut:=2;
gtk_grab_remove(di);
gtk_widget_destroy(di);
gtk_main_quit();
end;

procedure dButt3( w:qWidget; di:qWidget );cdecl;
begin
idialbut:=3;
gtk_grab_remove(di);
gtk_widget_destroy(di);
gtk_main_quit();
end;


function dial0 (w : qWidget ; event: pGdkEvent; data: pgpointer ): gboolean; cdecl;
begin
idialbut:=0;
gtk_grab_remove(w);
gtk_widget_destroy(w);
gtk_main_quit();
dial0:=false;
end;


function qdialog(message, but1capt, but2capt, but3capt : string): integer;
var dialog, cont, labl, button1, button2, button3, hbox : qWidget;
begin
idialbut:=0;
dialog := gtk_dialog_new();
cont  := gtk_hbox_new(true,0);
gtk_container_set_border_width (GTK_CONTAINER (cont), 10);
gtk_window_set_position(GTK_WINDOW(dialog), GTK_WIN_POS_MOUSE );
gtk_window_set_title (GTK_WINDOW (dialog), 'Dialog' );
gtk_window_set_transient_for(GTK_WINDOW(dialog),GTK_WINDOW(qmainwindow) );  //*** on top
labl := gtk_label_new (pchastr(message));
hbox := gtk_hbox_new(true, 0);
if but1capt<>'' then
 begin
  button1 := gtk_button_new_with_label(pchastr(but1capt));
  g_signal_connect (G_OBJECT (button1),
    'clicked', G_CALLBACK (@dbutt1), dialog );
  gtk_box_pack_start(GTK_BOX(hbox), button1, false,true,  2);
 end;

if but2capt<>'' then
 begin
  button2 := gtk_button_new_with_label(pchastr(but2capt));
  g_signal_connect (G_OBJECT (button2),
    'clicked', G_CALLBACK (@dbutt2), dialog );
  gtk_box_pack_start(GTK_BOX(hbox), button2, false,true,  2);
 end;

if but3capt<>'' then
 begin
  button3 := gtk_button_new_with_label(pchastr(but3capt));
  g_signal_connect (G_OBJECT (button3),
    'clicked', G_CALLBACK (@dbutt3), dialog );
  gtk_box_pack_start(GTK_BOX(hbox), button3, false,true,  2);
 end;

g_signal_connect (G_OBJECT (dialog), 'delete_event',
                    G_CALLBACK (@dial0), nil);

gtk_container_add (GTK_CONTAINER (GTK_DIALOG(dialog)^.action_area),
                                   hbox);
gtk_container_add (GTK_CONTAINER (cont),labl);
gtk_container_add (GTK_CONTAINER (GTK_DIALOG(dialog)^.vbox),cont);
gtk_window_set_policy ( GTK_WINDOW(dialog),0,0,0);
gtk_widget_show_all (dialog);
gtk_grab_add(dialog);
gtk_main();
qdialog:=idialbut;
end;


{****************************    input    *****************************}
procedure iokBut( w:qWidget; inp :qWidget );cdecl;
begin
inputrestr:=qeditget(inputedit); 
gtk_grab_remove(inp);
gtk_widget_destroy(inp);
gtk_main_quit();
end;

procedure icancBut( w:qWidget; inp:qWidget );cdecl;
begin
inputrestr:='';
gtk_grab_remove(inp);
gtk_widget_destroy(inp);
gtk_main_quit();
end;


function inpu0 (w : qWidget ; event: pGdkEvent; data: pgpointer ): gboolean; cdecl;
begin
inputrestr:='';
gtk_grab_remove(w);
gtk_widget_destroy(w);
gtk_main_quit();
inpu0:=false;
end;


function qinput(message, inputstr : string): string;
var dialog, labl, button1, button2, hbox, vbox : qWidget;
begin
dialog := gtk_dialog_new();
gtk_window_set_position(GTK_WINDOW(dialog), GTK_WIN_POS_MOUSE );
gtk_window_set_title (GTK_WINDOW (dialog), 'Input' );
gtk_window_set_transient_for(GTK_WINDOW(dialog),GTK_WINDOW(qmainwindow) );  //*** on top
labl := gtk_label_new (pchastr(message));
inputedit:= gtk_entry_new();
qeditset(inputedit, inputstr);
hbox := gtk_hbox_new(true, 0);
vbox := gtk_vbox_new(false, 0);
gtk_container_set_border_width (GTK_CONTAINER (vbox), 10);

  button1 := gtk_button_new_with_label('OK');
  g_signal_connect (G_OBJECT (button1),
    'clicked', G_CALLBACK (@iokbut), dialog );
  gtk_box_pack_start(GTK_BOX(hbox), button1, false,true,  2);

  button2 := gtk_button_new_with_label('Cancel');
  g_signal_connect (G_OBJECT (button2),
    'clicked', G_CALLBACK (@icancbut), dialog );
  gtk_box_pack_start(GTK_BOX(hbox), button2, false,true,  2);

gtk_box_pack_start(GTK_BOX(vbox), labl, false,false, 0);
gtk_box_pack_start(GTK_BOX(vbox), inputedit, false,false, 0);

g_signal_connect (G_OBJECT (dialog), 'delete_event',
                    G_CALLBACK (@inpu0), nil);

gtk_container_add (GTK_CONTAINER (GTK_DIALOG(dialog)^.action_area),
                                   hbox);
gtk_container_add (GTK_CONTAINER (GTK_DIALOG(dialog)^.vbox),vbox);
gtk_window_set_policy ( GTK_WINDOW(dialog),0,0,0);
gtk_widget_show_all (dialog);
gtk_grab_add(dialog);
qsetfocus(inputedit);
gtk_main();
qinput:=inputrestr;
end;




{****************************     draw    *****************************}
procedure qpicdraw00(pic: qpic; xs, ys, x, y, w, h  : integer );
var  clip_rect : TGdkRectangle;
begin
  if pic.pxmp = nil then exit;
  gdk_gc_set_clip_origin(DrawGc, x-xs, y-ys);
  gdk_gc_set_clip_mask(DrawGC, pic.mask);
  gdk_draw_pixmap (pixmap, drawGc, pic.pxmp ,xs, ys, x, y, w, h);
  clip_rect.x := 0;
  clip_rect.y := 0;
  clip_rect.width := drawWidth;
  clip_rect.height :=drawHeight;
  gdk_gc_set_clip_origin(DrawGc, 0, 0);
  gdk_gc_set_clip_rectangle(DrawGc, @clip_rect);
end;



procedure qupdateRect(x, y, w, h : integer);
var update_rect : TGdkRectangle;
begin
  update_rect.x := x;
  update_rect.y := y;
  update_rect.width :=w;
  update_rect.height :=h;
  gtk_widget_draw (drawA, @update_rect);
end;



function setRGB3(r,g,b: longint ) : boolean;
begin
setRGB3:=true;
if r>65535 then begin r:=65535; setRGB3:=false; end;
if r<0 then begin r:=0; setRGB3:=false; end;
if g>65535 then begin g:=65535; setRGB3:=false; end;
if g<0 then begin g:=0; setRGB3:=false; end;
if b>65535 then begin b:=65535; setRGB3:=false; end;
if b<0 then begin b:=0; setRGB3:=false; end;
color^.red:=r;
color^.green:=g;
color^.blue:=b;
if gdk_color_alloc(cmap, color)=1 then
     gdk_gc_set_foreground(drawGC, color)
  else setRGB3:=false;
end;



function qSetClr(rgb : longint): boolean;
var r,g,b: longint;
begin
r:=  trunc(rgb/1000000);
g:=trunc( (rgb-1000000*r)/1000 );
b:=        rgb-1000000*r -1000*g;
r:=round(r*65535/999);
g:=round(g*65535/999);
b:=round(b*65535/999);
qSetClr:=setrgb3(r,g,b);
end;




{ Create a new backing pixmap of the appropriate size }
function  configure_event (widget : qWidget; event: PGdkEventConfigure): gboolean; cdecl;
begin
if poprve then
begin
  poprve:=false;
  gdkwin:=widget^.window;
  if pixmap<>NIL then gdk_pixmap_unref(pixmap);
  pixmap := gdk_pixmap_new(widget^.window, drawWidth, drawHeight, -1);
  DrawGC:=gdk_gc_new( pixmap  );
  qsetClr(0);
  gdk_draw_rectangle (pixmap,
                      PGtkStyle(widget^.style)^.white_gc,
                      gint(true),
                      0, 0,  drawWidth, drawHeight);
  if startproc<>nil then startproc;

end;
  configure_event := TRUE;

end;


{ Redraw the screen from the backing pixmap }
function  expose_event (widget : qWidget ; event : PGdkEventExpose ) : gboolean; cdecl;
var i,j, sx, sy, sw, sh, dx, dy, x2, y2, x, y, w, h, ox, oy, ow, oh : integer;
begin
x:= event^.area.x;        if x<0 then x:=0;
y:= event^.area.y;        if y<0 then y:=0;
w:= event^.area.width;
h:= event^.area.height;
 if bk_pxmp00<>NIL then gdk_pixmap_unref(bk_pxmp00);
  bk_pxmp00 := gdk_pixmap_new(gdkwin, w, h, -1);
    gdk_draw_pixmap (bk_pxmp00, drawGc, pixmap
                     ,x, y, 0, 0,w, h  );

for j:=1 to 99 do
 begin
   i:=fgobjindx[j];
   ox:=fgobjs[i].x;
   oy:=fgobjs[i].y;
   ow:=fgobjs[i].w;
   oh:=fgobjs[i].h;
  if (ow>0) and (oh>0) and fgobjs[i].visible then
   begin
    if x+w<ox then continue;
    if x>ox+ow then continue;
    if y+h<oy then continue;
    if y>oy+oh then continue;
    if ox>x then begin sx:=0; dx:=ox; end else begin sx:=x-ox; dx:=x; end;
    if ox+ow>x+w then x2:=x+w else x2:=ox+ow;
    sw:=x2-dx; if sw<0 then continue;
    if oy>y then begin sy:=0; dy:=oy; end else begin sy:=y-oy; dy:=y; end;
    if oy+oh>y+h then y2:=y+h else y2:=oy+oh;
    sh:=y2-dy; if sh<0 then continue;

    qpicdraw00(fgobjs[i].pic,  sx,  sy,  dx, dy,  sw,  sh  );
   end;
 end;

  gdk_draw_pixmap(widget^.window,
                  PGtkStyle(widget^.style)^.fg_gc[gtk_WIDGET_STATE (widget)],
                  pixmap, x, y, x, y, w, h );

  expose_event:= FALSE;
gdk_draw_pixmap (pixmap, drawGc, bk_pxmp00 , 0, 0, x, y, w, h);
end;


procedure qpoint( x, y : integer );
begin
  gdk_draw_point (pixmap, drawGc,x, y );
  if qautoupdate then qupdateRect(x,y,1,1);
end;



{ Draw a rectangle on the screen }
procedure qrect( x, y, width, height : integer);
begin
  gdk_draw_rectangle (pixmap, drawGc,  0, x, y, width, height);
  if qautoupdate then qupdateRect(x, y, width+1, height+1  );
end;

procedure qfillrect( x, y, width, height  : integer);
begin
  gdk_draw_rectangle (pixmap, drawGc,  1, x, y, width, height);
  if qautoupdate then qupdateRect(x, y, width+1, height+1  );
end;



procedure qellipse( x, y, width, height : integer);
begin
 gdk_draw_arc (pixmap, drawGc, 0, x, y, width, height, 0, 24000);
 if qautoupdate then qupdateRect(x, y, width+1, height+1  );
end;

procedure qfillellipse( x, y, width, height : integer);
begin
 gdk_draw_arc (pixmap, drawGc, 1, x, y, width, height, 0, 24000);
 if qautoupdate then qupdateRect(x, y, width+1, height+1  );
end;



procedure qline( x1, y1, x2, y2: integer );
var xr, yr : integer;
begin
  gdk_draw_line(pixmap, drawGC , x1, y1, x2, y2);
 if x1>x2 then xr:=x2 else xr:=x1;
 if y1>y2 then yr:=y2 else yr:=y1;  
 if qautoupdate then qupdateRect(xr, yr, abs(x2-x1)+1, abs(y2-y1)+1  );
end;


procedure qfont(size:integer);
var s, sv, font0a  : string;
begin
font0a:=fontspl(qfontname0);
if qfontname0='0' then
 begin font0a:=qfontname1a;  end;
if size<=0 then size:=0;
str(size,sv);
if size=0 then s:=qfontname0
 else      s:=font0a +' '+ sv;
qfontname:=s;  
end;


procedure qdrawtext(x,y : integer; s : string);
var Pcha : pchar;
    font_desc : pPangoFontDescription; 
    layout: pPangolayout;
    w, h, xu, yu, hu, wu, cu : longint;
begin 
if s='' then exit;
layout:= pango_layout_new(gdk_pango_context_get());
font_desc := pango_font_description_from_string (pchastr(qfontname )  );  
pango_layout_set_font_description(layout, font_desc);
pango_font_description_free (font_desc);

Pcha:=pchastr(s); 
pango_layout_set_text(layout, pcha, -1);
pango_layout_get_pixel_size( layout, @w, @h);  
cu:=round(h/10);
y:=y-h+2*cu;
xu:=x-2*cu; yu:=y-cu; hu:=h+2*cu; wu:=w+4*cu; 
gdk_draw_layout(pixmap, drawGC, x, y, layout);
if qautoupdate then qupdateRect(xu, yu, wu,  hu);
g_object_unref(layout);
end;



function  button_press_event (widget : qWidget ; event: PGdkEventButton ) : gboolean; cdecl;
begin
  qmousebut:=event^.button;
    qx:=trunc(event^.x);
    qy:=trunc(event^.y);
    if drawclick<>nil then drawclick;
  button_press_event := TRUE;
GTK_WIDGET_grab_Focus (drawA);
end;


function  motion_notify_event (widget : qWidget ; event: PGdkEventMotion ) : gboolean; cdecl;
var x, y : longint ;
  state  : longint;
begin
  if (event^.is_hint<>0) then begin
    gdk_window_get_pointer (event^.window, @x, @y, @state);
  end else begin
    x := trunc(event^.x);
    y := trunc(event^.y);
    state := event^.state;
  end;
  qmousebut:=0;
  if (state and gdk_BUTTON1_MASK)<>0 then qmousebut:=1;
  if (state and gdk_BUTTON2_MASK)<>0 then qmousebut:=2;
  if (state and gdk_BUTTON3_MASK)<>0 then qmousebut:=3;
  qx:=x;
  qy:=y;
  if drawmove<>nil then drawmove;
  motion_notify_event := TRUE;
end;




procedure qdrawstart(width, height : integer;
          onstart, procclick, procmove : tprocedure );
var i : integer;
begin
 if drawrun then
   begin writeln('qError - qdrawstart can run only once'); exit; end;
   drawrun:=true;
startproc:=onstart;
  drawWidth:=width;
  drawHeight:=height;
  drawA := gtk_drawing_area_new ();
  qdrawArea:=drawA;
  gtk_drawing_area_size (PGtkDRAWINGAREA (drawA), width, height);

  { Signals used to handle backing pixmap }
  g_signal_connect (G_OBJECT (drawA), 'expose_event',
         G_CALLBACK (@expose_event), NIL);
  g_signal_connect (G_OBJECT(drawA),'configure_event',
         G_CALLBACK (@configure_event), NIL);

  { Event signals }
  g_signal_connect (G_OBJECT (drawA), 'motion_notify_event',
         G_CALLBACK (@motion_notify_event), NIL);
  g_signal_connect (G_OBJECT (drawA), 'button_press_event',
         G_CALLBACK (@button_press_event), NIL);
  gtk_widget_set_events (drawA, gdk_EXPOSURE_MASK
                           or gdk_LEAVE_NOTIFY_MASK
                           or gdk_BUTTON_PRESS_MASK
                           or gdk_POINTER_MOTION_MASK
                           or gdk_POINTER_MOTION_HINT_MASK);
  drawclick:=procclick;
  drawmove:=procmove;

  widgetQpack(drawA);

  for i:=1 to 99 do
   begin
    fgobjs[i].pic.pxmp:=nil;
    fgobjs[i].pic.mask:=nil;
    fgobjs[i].x:=0;
    fgobjs[i].y:=0;
    fgobjs[i].w:=0;
    fgobjs[i].h:=0;
    fgobjs[i].visible:=false;
    fgobjindx[i]:=i;
   end;
GTK_WIDGET_SET_FLAGS (drawA, GTK_CAN_FOCUS);
end;


procedure qgetpic(x,y, width, height  : integer; var pic : qpic );
begin
 if pic.pxmp<>NIL then gdk_pixmap_unref(pic.pxmp);
 pic.pxmp := gdk_pixmap_new(gdkwin, width, height, -1);
    gdk_draw_pixmap (pic.pxmp, drawGc, pixmap
                     ,x, y, 0, 0,width, height  );
 pic.mask:=nil;
end;





procedure qdrawpic(x, y  : integer; pic: qpic );
begin
qpicdraw00(pic, 0, 0, x, y, -1, -1 );
if qautoupdate then qupdateRect(x, y, drawwidth, drawheight );
end;



procedure qpicFromXpm(xpmfile : string; var pic : qpic);
var xmask   : pGdkBitmap;
begin
pic.pxmp:=gdk_pixmap_create_from_xpm (gdkwin, xmask,
              nil, Pchastr(xpmfile));
pic.mask:=xmask;
end;


procedure qpicFromXpm_d(data : ppgchar; var pic : qpic);
var xmask   : pGdkBitmap;
begin
pic.pxmp:=gdk_pixmap_create_from_xpm_d(gdkwin, xmask,
              nil, data);
pic.mask:=xmask;
end;





{*************************** qfgobj ****************************************}
constructor qfgobj.newFromXpm(fname : string; x, y, width, height : integer);
var i, n : integer;
begin
if (width<=0) or (height<=0) then
  begin
   writeln('qfgobj.width or .height <=0');
   exit;
  end;
n:=0;
for i:=1 to 99 do
  if (fgobjs[i].w<=0) or (fgobjs[i].h<=0) then begin n:=i;  break; end;
if n=0 then
  begin
   writeln('error - too many qfgobjs');
   exit;
  end;
  no:=n;
  qpicFromXpm(fname, fgobjs[no].pic);
 fgobjs[no].x:=x;
 fgobjs[no].y:=y;
 fgobjs[no].w:=width;
 fgobjs[no].h:=height;
 fgobjs[no].visible:=false;
end;


constructor qfgobj.newFromXpm_d(data : ppgchar; x, y, width, height : integer);
var n, i : integer;
begin
if (width<=0) or (height<=0) then
  begin
   writeln('qfgobj.width or .height <=0');
   exit;
  end;
n:=0;
for i:=1 to 99 do
  if (fgobjs[i].w<=0) or (fgobjs[i].h<=0) then begin n:=i; break; end;
if n=0 then
  begin
   writeln('error - too many qfgobjs');
   exit;
  end;
 no:=n;
 qpicFromXpm_d(data, fgobjs[no].pic);
 fgobjs[no].x:=x;
 fgobjs[no].y:=y;
 fgobjs[no].w:=width;
 fgobjs[no].h:=height;
 fgobjs[no].visible:=false;
end;


procedure qfgobj.setPic(Pic : qpic);
begin
fgobjs[no].pic:=Pic;
end;


procedure qfgobj.show;
begin
fgobjs[no].visible:=true;
if qautoupdate then
 qupdateRect(fgobjs[no].x, fgobjs[no].y, fgobjs[no].w, fgobjs[no].h);
end;


procedure qfgobj.hide;
begin
fgobjs[no].visible:=false;
if qautoupdate then
 qupdateRect(fgobjs[no].x, fgobjs[no].y, fgobjs[no].w, fgobjs[no].h);
end;


procedure qfgobj.move(x, y:integer);
var cx, cy, cw, ch : integer;
begin
  cx:=fgobjs[no].x;
  cy:=fgobjs[no].y;
  cw:=fgobjs[no].w;
  ch:=fgobjs[no].h;
  if (cw<=0) or (ch<=0) then
    begin
     writeln('error - move, no exist qfgobj ',no);
     exit;
    end;
  cw:=abs(x-cx)+cw;
  ch:=abs(y-cy)+ch;
  if x<cx then cx:=x;
  if y<cy then cy:=y;
 fgobjs[no].x:=x;
 fgobjs[no].y:=y;
 if qautoupdate and fgobjs[no].visible then qupdateRect(cx,cy,cw,ch);
end;


procedure qfgobj.tobk;
var i, j : integer;
begin
j:=0;
for i:=1 to 99 do if no=fgobjindx[i] then begin j:=i; break; end;
if j=0 then begin writeln('err qfgobj.tobk'); exit; end;
for i:=j-1 downto 1 do fgobjindx[i+1]:=fgobjindx[i];
fgobjindx[1]:=no;
if qautoupdate then qupdateRect(fgobjs[no].x, fgobjs[no].y,
                               fgobjs[no].w, fgobjs[no].h);
end;


procedure qfgobj.tofg;
var i, j : integer;
begin
j:=0;
for i:=1 to 99 do if no=fgobjindx[i] then begin j:=i; break; end;
if j=0 then begin writeln('err qfgobj.tofg'); exit; end;
for i:=j+1 to 99 do fgobjindx[i-1]:=fgobjindx[i];
fgobjindx[99]:=no;
if qautoupdate then qupdateRect(fgobjs[no].x, fgobjs[no].y,
                               fgobjs[no].w, fgobjs[no].h);
end;



destructor qfgobj.free;
begin
 fgobjs[no].w:=0;
 fgobjs[no].h:=0;
 fgobjs[no].visible:=false;
end;
{*************************** qfgobj ****************************************}



end.
