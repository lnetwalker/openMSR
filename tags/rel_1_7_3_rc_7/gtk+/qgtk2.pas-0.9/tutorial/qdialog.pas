program Qgtkdialog;

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

var  lbl, secw, secw2 : qwidget;


procedure filesel;
begin
qlabelset(lbl,qFileselect('vyber soubor', '')  );
end;



procedure clrsel;
var rgb : longint;
    s : string;
begin
rgb:=qClrselect('color');
if rgb<0 then exit; {= cancel}
qsetClr(rgb);
qfillrect(400,5,95,40);
str(rgb,s);
qlabelset(lbl,'rgb='+s );
end;


procedure fontsel;
begin
qlabelset(lbl,qFontselect('font') );
qsetClr(qWhite);
qfillrect(0,0,400,50);
qsetClr(qBlack);
qdrawtext(10,40,'ABCDEFGH abcdefgh uff');

end;


procedure dialog;
var i: integer;
    s : string;
begin
i:=  qdialog('qdialog is dialog', 'Ok - 1', 'Button 2', '3');
str(i,s);
qlabelset(lbl,'dialog button '+s);
end;

procedure input;
begin
qlabelset(lbl, qinput('ahoj', 'kuk') );
end;

procedure secbut1;
begin
qlabelset(lbl, 'sec butt' );
end;

procedure ahoj;
begin
 qlabelset(lbl, 'ahoj' );
end;

procedure showsecw;
begin qshowsec(secw); end;

procedure showsecmodalw;
begin qshowsecmodal(secw); end;

procedure hidesecw;
begin qhidesec(secw); end;

procedure showsecw2;
begin qshowsec(secw2); end;

procedure hidesecw2;
begin qhidesec(secw2); end;


procedure onclose;
begin
if qdialog('Quit?','Yes', 'No','') =1 then
      qcandestroy:=true
 else qcandestroy:=false;
end;



begin
qstart('Qgtk dialogy...', nil, @onclose);

qmnu('dialogy');
qsubmnu('dialog 3 button', @dialog);
qsubmnu('input', @input);
qsubmnu('file', @filesel);
qsubmnu('color', @clrsel);
qsubmnu('font', @fontsel);
qsubmnu('-secondary window', @showsecw);
qsubmnu('secondary window modal', @showsecmodalw);
qsubmnu('secondary window no 2', @showsecw2);

qmnu('menu');
qsubmnu('ahoj', @ahoj );
qsubmnu('nil', nil );
qsubmnu('-Eeeexit', @qdestroy );

qDrawStart(500,50, nil, nil, nil);
qNextRow;
lbl:=qLabel('x');

qNextRow;

qbutton('dialog',  @dialog);
qbutton('input',  @input);
qbutton('file', @filesel);
qbutton('color', @clrsel);
qbutton('font', @fontsel);
qbutton('sec',   @showsecw);
qbutton('sec modal',  @showsecmodalw);


secw2:=qsecwindow('secwindow 2');
qNextRowResize;
qlabel('This is the second secondary window'+#10+'it is resizable!');
qseparator;
qlabel(''); qbutton('close', @hidesecw2); qlabel('');



secw:=qsecwindow('secwindow');
qlabel('This is the first secondary window'  );
qseparator;
qbutton('close', @hidesecw);
qbutton('sec but1', @secbut1);






qGo;
end.