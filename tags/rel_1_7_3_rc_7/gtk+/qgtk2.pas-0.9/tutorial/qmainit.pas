program qgtkMainIt;

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



uses qgtk2;

var  progress : qwidget;


procedure computation;
var j : longint;
    x : real;
begin
 for j:=0 to 30000 do        {  <----- to change speed change "to 30000"   }
         x:=sin(j/1000);
 write('.');
end;


procedure nomIt;
var i :longint;
begin
for i:=1 to 2000 do
begin
 computation;
 qprogressSet(progress,round(i/20));
{ qMainIter;   <---------      }
end;
writeln('done');
end;



procedure mIt;
var i :longint;
begin
for i:=1 to 2000 do
begin
 computation;
 qprogressSet(progress,round(i/20));
qMainIter;  { <---------      }
end;
writeln('done');
end;




begin
 qshowW32console;
qstart('during a long computation', nil, nil);

qLabel('Hello a long computation');
qnextrow;
qbutton(' without qMainIter ', @nomIt);
qbutton(' with qMainIter ', @mIt);
qnextrow;
progress:=qprogress(200);
qnextrow;
qlabel(''); qButton('QUIT button', @qDestroy); qlabel('');

qGo;

end.
