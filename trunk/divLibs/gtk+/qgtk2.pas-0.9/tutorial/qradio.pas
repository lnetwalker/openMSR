program Qradio;

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

var br1, br2, br3, br1x, br2x, br3x : qwidget;
    ar1, ar2, ar3 : boolean;

procedure showrbuts;
begin
qhide(br1x); qhide(br2x); qhide(br3x);
qshow(br1); qshow(br2); qshow(br3);
ar1:=false; ar2:=false; ar3:=false;
end;

procedure b1c;
begin
showrbuts;
qhide(br1); qshow(br1x);
ar1:=true;
end;


procedure b2c;
begin
showrbuts;
qhide(br2); qshow(br2x);
ar2:=true;
end;


procedure b3c;
begin
showrbuts;
qhide(br3); qshow(br3x);
ar3:=true;
end;


begin
qstart('Qgtk radio', nil, nil);

qLabel('');
qnextrowleft;
qLabel('  ');
br1:=qbutton(' _ ', @b1c); br1x:=qbutton(' X ', nil);
qlabel(' prvni radio');
qnextrowleft;
qLabel('  ');
br2:=qbutton(' _ ', @b2c); br2x:=qbutton(' X ', nil);
qlabel(' druhej');
qnextrowleft;
qLabel('  '); 
br3:=qbutton(' _ ', @b3c); br3x:=qbutton(' X ', nil);
qlabel(' a to je treti');
qnextrow;
qLabel(''); 
b1c;



qnextrowleft;
qLabel('  ');
qbuttontoggle('    ', nil); qlabel(' check button   ');
qnextrowleft;
qLabel('  ');
qbuttontoggle('    ', nil); qlabel(' dalsi check');

qnextrow;
qLabel(''); 

qgo;
end.