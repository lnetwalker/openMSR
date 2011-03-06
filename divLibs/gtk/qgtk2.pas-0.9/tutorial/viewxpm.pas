program viewxpm;

{ Demo program for  qgtk2.pas

  Quick programming with gtk in pascal,
  Freepascal, gtk+

  (c) 2002 Jirka Bubenicek  -  hebrak@yahoo.com


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



uses dos, qgtk2;

var lbl0, list: qwidget;
    ready: boolean;
    pic : qpic;



function gdir: string;
var dir : string;
begin
getdir(0,dir);
gdir:=dir;
if (dir[length(dir)]='\') or (dir[length(dir)]='/') then exit;
if pos('/',dir)>0 then dir:=dir+'/' else dir:=dir+'\';
gdir:=dir;
end;

procedure cdir(dir:string);
var dirt : string;
begin
if (dir[length(dir)]='/') or (dir[length(dir)]='\') then
      dir:= copy(dir,1,length(dir)-1);
dirt:=gdir;      
{$I-}
chdir(dir);
{$I+}
if ioresult<>0 then chdir(dirt); 
end;


function dirattr(dirinfo: searchrec): boolean;
begin
 if (dirinfo.attr =16) or (dirinfo.attr =17) or (dirinfo.name='..')
    then dirattr:=true else dirattr:=false;
end;


procedure readdir;
var dirinfo :searchrec;
begin
ready:=false;
qlabelset(lbl0, gdir);
qlistclear(list);


findfirst('*', anyfile-volumeid, dirinfo);
while doserror=0 do
 begin 
  if dirattr(dirinfo) and
     ( (dirinfo.name[1]<>'.') or (dirinfo.name='..')) then
       qlistadd(list, ' /'+dirinfo.name);
   findnext(dirinfo);
 end;
findfirst('*.xpm', anyfile-volumeid, dirinfo);
while doserror=0 do
 begin
  if not dirattr(dirinfo) then qlistadd(list, dirinfo.name);
   findnext(dirinfo);
 end;

ready:=true;
end;


procedure lch;
var s : string;
begin
if not ready then exit;
qfillrect(0,0,420,420);
s:=qlistitem(list);
if length(s)>2 then if s[2]='/' then  exit;

  qpicfromxpm(s, pic);
  qdrawpic(0,0, pic);
end;


procedure l2click;
var s : string;
begin
s:=qlistitem(list);

if length(s)>2 then
   if s[2]='/' then
      begin
       cdir(copy(s,3,length(s) ) );
       readdir;
      end;
end;




procedure start;
begin
 ready:=true;
 qsetClr(999900750);
  qfillrect(0,0,420,420);
end;


begin
ready:=false;
qstart('viewxpm', nil, nil);
qnextrowleft;
lbl0:=qlabel('');                         
qframe;
list:=qlist(200,420, true,  @lch, @l2click);
qframe;
qdrawstart(420,420, @start,nil,nil);

readdir;
qGo;
end.