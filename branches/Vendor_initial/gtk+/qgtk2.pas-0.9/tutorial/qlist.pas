program Qgtklist;

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

var etxt, lbl, list : qwidget;



procedure lchange;
var s : string;
begin
str(qlistselrow(list), s);
qlabelset(lbl,s+': '+qlistitem(list) );
end;

procedure add;
begin
 qlistadd(list, qeditget(etxt));
end;

procedure insert;
begin
 qlistinsert( list, qeditget(etxt));
end;

procedure del;
begin
 qlistdelRow( list);
end;

procedure clear;
begin
 qlistclear(list);
end;

procedure lEnter;
begin
qlabelset(lbl,'Enter or 2click on '+ qlistitem(list) );
end;




begin
qstart('Qgtk list', nil, nil);

etxt:=qedit('');
qnextrow;
qbutton('add', @add);
qbutton('insert', @insert);
qbutton('del',  @del);
qbutton('clear', @clear);

qnextrowResize;
list:=qlist(300,300, false, @lchange, @lEnter);

qnextrow;
lbl:=qlabel('qx');

qlistAdd(list,'aaa');
qlistAdd(list,'bbbbb');
qlistAdd(list,'xxxxxxxxx');

qGo;
end.