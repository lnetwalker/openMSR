program camels;

{ Demo program for  qgtk2.pas

  Quick programming with gtk in pascal,
  Freepascal, gtk+

  (c) 2002 Jirka Bubenicek  - hebrak@yahoo.com


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


uses qgtk2;

var bkpic,
    camel1l, camel2l, camel1p, camel2p, camelTl, camelTp, camelT0: qpic;
    autoCamel, manualCamel, hil1, hil2 : qfgobj;
    iautocam, xautocam, yautocam,
    imanualcam, xmanualcam, ymanualcam, iTmanualcam : integer;

procedure oncreate;
begin
qpicFromXpm('desert.xpm', bkpic);
qdrawpic(0,0, bkpic);
hil2.newFromXpm('desert2.xpm', 332, 218, 309, 49 );
hil2.show;
qpicFromXpm('camel1.xpm', camel1p);
qpicFromXpm('camel1l.xpm', camel1l);
qpicFromXpm('camel2.xpm', camel2p);
qpicFromXpm('camel2l.xpm', camel2l);
qpicFromXpm('cameltl.xpm', camelTl);
qpicFromXpm('cameltp.xpm', camelTp);
qpicFromXpm('camelt0.xpm', camelT0);
xautocam:=0; yautocam:=208;
autocamel.newFromXpm('camel1.xpm', xautocam, yautocam, 74, 59);
autocamel.show;
iautocam:=1;
hil1.newFromXpm('desert1.xpm', 0, 236, 363, 44 );
hil1.show;
xmanualcam:=300; ymanualcam:=198;
manualcamel.newFromXpm('camel1.xpm', xmanualcam, ymanualcam, 74, 59);
manualcamel.tobk;
manualcamel.show;
imanualcam:=1;
iTmanualCam:=0;
qdrawtext(30,30,'use arrow keys for driving a camel');
qline(50,50,70,50); qline(50,50,60,54); qline(50,50,60,46);
qline(90,50,110,50); qline(110,50,100,54); qline(110,50,100,46);
end;


procedure autoCamelStep;
begin
if iautocam=1 then autocamel.setpic(camel1p);
if iautocam=2 then autocamel.setpic(camel2p);
xautocam:=xautocam+5;
if xautocam>640 then xautocam:=-80;
autocamel.move(xautocam,yautocam);
inc(iautocam);
if iautocam>2 then iautocam:=1;
end;


procedure manualCamelStep;
begin
case imanualcam of 0 : exit;
                   1 : manualcamel.setpic(camel2p);
                   2 : manualcamel.setpic(camel1p);
                  -1 : manualcamel.setpic(camel2l);
                  -2 : manualcamel.setpic(camel1l);
end;

if imanualcam >0 then begin xmanualcam:=xmanualcam+7; inc(imanualcam); end;
if imanualcam <0 then begin xmanualcam:=xmanualcam-7; dec(imanualcam); end;
if imanualcam>2 then imanualcam:=1;
if imanualcam<-2 then imanualcam:=-1;
if xmanualcam>640 then xmanualcam:=-80;
if xmanualcam<-80 then xmanualcam:=640;
manualcamel.move(xmanualcam,ymanualcam);

iTmanualcam:=0;
end;



procedure manualCamelTurn;
begin
imanualCam:=0;
case iTmanualcam of 1 : manualcamel.setpic(camelTp);
                    2 : manualcamel.setpic(camelT0);
                    3 : manualcamel.setpic(camelTl);
                    4 : manualcamel.setpic(camel1l);
                   -1 : manualcamel.setpic(camelTl);
                   -2 : manualcamel.setpic(camelT0);
                   -3 : manualcamel.setpic(camelTp);
                   -4 : manualcamel.setpic(camel1p);
end;
if iTmanualcam>0 then inc(iTmanualcam);
if iTmanualcam<0 then dec(iTmanualcam);
if iTmanualcam>4 then begin iTmanualcam:=0; imanualcam:=-1; end;
if iTmanualcam<-4 then begin iTmanualcam:=0; imanualcam:=1; end;
manualcamel.show;
end;


procedure ontimer;
begin
autoCamelStep;

if qkeykode=qkRight then
  begin
   if imanualcam<0 then begin iTmanualcam:=-1;  imanualcam:=0; end;
   manualCamelStep;
  end;

if qkeykode=qkLeft then
  begin
   if imanualcam>0 then begin iTmanualcam:=1;  imanualcam:=0; end;
   manualCamelStep;
  end;

if imanualcam=0 then manualCamelTurn;

if 
qkeykode=qkup then 
   begin 
    manualcamel.tobk; 
    ymanualcam:=198;  
    manualcamel.move(xmanualcam,ymanualcam);
   end;
if 
qkeykode=qkdown then 
   begin 
    manualcamel.tofg;
    ymanualcam:=230; 
    manualcamel.move(xmanualcam,ymanualcam);
   end; 

qkeykode:=0;
end;



begin
qstart('Camels', nil, nil);
qdrawstart(640,440, @oncreate,nil, nil);
qtimerstart(250, @ontimer);

qGo;
end.