program Qgtmy;

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



uses qgtk2,      glib2,gdk2,gtk2,sysutils;

var lbl, edit, boxV: qwidget;

begin
qstart('Qgtk my', nil, nil);
boxV := qBoxV;

qPack:=false;
 lbl:=qlabel('hi');
 edit:=qedit('');


 gtk_box_pack_start(GTK_BOX(boxV), lbl, false, false, 0);
 gtk_box_pack_start(GTK_BOX(boxV), edit, false, false, 0);

 gtk_widget_show_all(boxV);


 qGo;
end.