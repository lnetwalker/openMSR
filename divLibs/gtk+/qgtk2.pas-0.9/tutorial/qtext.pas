program QgtkText;

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


var wtext, butro : qwidget;
    txtch : boolean; 
    fname : string;

procedure fontsel;
begin
qFontselect('font');
qtextApplyFont(wtext);
end;



procedure reado;
begin
if qToggleGetA(butro) then qtextSetNoEdit(wtext)
                      else qtextSetEdit(wtext);

end;


procedure load;
begin
if txtch then 
  if qdialog('File not saved. Lost changes?','Yes','No','')=2 then exit; 
fname:=qFileselect('Load file',  '');
if not qtextload(wtext,fname ) then
  begin qdialog('I/O Error', 'OK','',''); exit; end;
txtch:=false;
end;



function FileExists(FileName: String): Boolean;
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 FileMode := 0;
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }




procedure save;
var fn : string;
begin
fn:=qFileselect('Save file', fname);
if fn='' then exit;
if fileExists(fn) then
 if qdialog('File exists! Overwrite?', 'Yes', 'No','' )=2 then exit;
if not qtextsave(wtext, fn) then
  begin qdialog('I/O Error', 'OK','',''); exit; end;
txtch:=false;
end;

procedure onclose;
begin
if txtch then 
  if qdialog('File not saved. Lost changes?','Yes','No','')=2 then 
        qcandestroy:=false;
end;


procedure txtchange;
begin
 txtch:=true;
end;


begin
//     qshowW32console;
fname:='noname';
txtch:=false;
qstart('Hello text!', nil, @onclose);
 

qLabel(' T E X T ');
qnextrowResize;
wtext:=qtext(600,100, @txtchange);
qnextrow;


qbutton('font', @Fontsel);
qbutton('load', @load);
qbutton('save', @save);
butro:=qbuttonToggle('readonly', @reado);

qlabel('       ');
qButton('QUIT', @qDestroy);

qGo;

end.
