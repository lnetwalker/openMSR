unit porting;

{ enthaelt alles was portiert werden muss  }

interface
uses linux;
function sound(note:byte):byte;
{ mittels write(#7)=beep gefakt }

function nosound:byte;
procedure line (x1,y1,x2,y2:word);
procedure setlinestyle(d1,d2,d3:byte);
procedure setfillstyle(style : byte; color:byte);
function getmaxx:word;
function getmaxy:word;
procedure settextjustify(hor_align,vert_alig:byte );
procedure rectangle (x1,y1,x2,y2:word);
procedure outtextxy(x,y:word;text : string);
procedure bar (x1,y1,x2,y2: word);
function pred(nummer:word):word;
function getpixel(x,y:word):byte;
procedure restorecrtmode;
function grapherrormsg(errcode:word):string;

var {port : array [1..1024] of word;}
    dashedln,solidln,normwidth,emptyfill : byte;
    lefttext,bottomtext : byte;

implementation

{ difficulties with port !!! run_awl.pp }
{                   read(z) !! in run_awl.pp }
{                   gettime resolution !!! run_awl }
{                   str !!! run_awl     }
{                   getdir !!!!! sps }
{                   zykluszeit wird nicht in awl eingetragen bei en Befehl}
{                                !!!! run_awl }

{ see also sps.his and sps.doc for additional informations }
      

   
function grapherrormsg(errcode:word):string;
begin
 
end;


procedure restorecrtmode;
begin
 
end;

function getpixel(x,y:word):byte;
begin
 
end;


function pred(nummer:word):word;
begin
 
end;


procedure line (x1,y1,x2,y2:word);
begin
 
end;

procedure rectangle (x1,y1,x2,y2:word);
begin
 
end;

procedure outtextxy(x,y:word;text : string);
begin
 
end;

procedure bar (x1,y1,x2,y2: word);
begin
 
end;


procedure setlinestyle(d1,d2,d3:byte);
begin
 
end;

procedure setfillstyle(style : byte; color:byte);
begin
 
end;

function getmaxx:word;
begin
 
end;

function getmaxy:word;
begin
 
end;


procedure settextjustify(hor_align,vert_alig:byte );
begin
 
end;


function sound(note:byte):byte;
begin
  write(#7);
end;

function nosound:byte;
begin

end;



begin
 
end.













