program xpm2pas;


{ Convert xpm pictures to pascal unit for usage with  qgtk2.pas


  (c) 2002-2005 Jirka Bubenicek  -  hebrak@yahoo.com


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



uses DOS;

var
 D, N, E, N0 : String;
 Nnames : array[1..100] of string;
 finput, foutput : string;
 fi, fo : text;
 ch : char;
 s, s0, s1, s2, s3, s4: string;
 iii, i, j, i1,i2,i3,i4,er, er1, er2, er3, er4 : integer;
 startl : boolean;

begin
writeln('convert xpm pictures to pascal unit');
if (paramcount=0) or (paramstr(1)='-h') then
 begin
  writeln('Usage: xpm2pas file1.xpm file2.xpm ...');
  writeln('Create file xpmpic.pas');
  writeln('Pictures can use max about 8000 colors');
  writeln('max width for less than 90 colors is 255, for pictures with more colors is 127');
  halt;
 end;

{*****}
for iii:=1 to paramcount do
begin
finput:=paramstr(iii);
FSplit(finput, D, N, E);
if  upcase(E)<>'.XPM' then
  begin
  writeln(' Bad file type. Use xpm2pas -h');
  halt;
 end;
Nnames[iii]:=N;


end; {for iii}

foutput:='xpmpic.pas';
N0:='xpmpic';

assign(fo, foutput);
{$I-}
reset(fo);close(fo);
{$I+}
if IOResult = 0 then
 begin
  writeln(foutput, ' exists, overwrite?  y/n');
  readln(s);
  if s<>'y' then halt;
 end;
rewrite(fo);
writeln(fo,'unit ',N0,';');
writeln(fo,'');
writeln(fo,'{Created by xpm2pas for usage with qgtk.pas}');
writeln(fo,'');
writeln(fo,'interface');
writeln(fo,'uses glib2;');
writeln(fo,'');
for iii:=1 to paramcount do
  writeln(fo,'var ',Nnames[iii],'_d : ppgchar;');
writeln(fo,'');
writeln(fo,'implementation');





for iii:=1 to paramcount do
begin
finput:=paramstr(iii);
FSplit(finput, D, N, E);

 assign(fi, finput);

 {$I-}
 reset(fi);
 {$I+}
if IOResult <> 0 then
   begin
    writeln(finput, ' not exists!');
    writeln(fo,'..... *************** xpm2pas crashed  ****************');
    close(fo);
    halt;
   end;


er:=0;
readln(fi,s);
if s<>'/* XPM */' then er:=1;
readln(fi,s);
if copy(s,1,13)<>'static char *' then er:=1;
readln(fi,s);
if s[1]='/' then readln(fi,s);
s0:=''; s1:='';  s2:=''; s3:='';  s4:='';
for i:= 1 to length(s) do
 begin
  if (s[i]=' ') or (s[i]='"') then
    begin
     if s0='' then continue;
     if s1='' then begin s1:=s0; s0:=''; continue; end;
     if s2='' then begin s2:=s0; s0:=''; continue; end;
     if s3='' then begin s3:=s0; s0:=''; continue; end;
     if s4='' then begin s4:=s0; s0:=''; continue; end;
    end;
    s0:=s0+s[i];
 end;
val(s1,i1,er1);
val(s2,i2,er2);
val(s3,i3,er3);
val(s4,i4,er4);
{ writeln(i1 , ' ',i2, ' ',i3, ' ',i4);}
if er1+er2+er3+er4+er<>0 then
 begin
  writeln('Problem with xpm file ', finput, ' Unknown xpm heading.');
  writeln(fo,'..... *************** xpm2pas crashed  ****************');
  close(fo);
  close(fi);
  halt;
 end;
if i4>2 then
 begin
  writeln('Too many colors in ',finput, ' (max 8000)');
  writeln(fo,'..... *************** xpm2pas crashed  ****************');
  close(fo);
  close(fi);
  halt;
 end;
if  ( (i4=1)and(i1>255) ) or ( (i4=2)and(i1>127) ) then
 begin
  writeln('xpm file ',finput,' is too wide,');
  writeln('max width for less than 90 colors is 255, for pictures with more colors is 127');
  writeln(fo,'..... *************** xpm2pas crashed  ****************');
  close(fo);
  close(fi);
  halt;
 end;





writeln(fo,'const ',N,'_xpm : array[0..',i2+i3,'] of pchar =');
writeln(fo,'(''',i1, ' ', i2, ' ', i3, ' ', i4,''',');

i:=0; j:=-1;
startl:=true;
while not eof(fi) do
begin
read(fi,ch);
if startl and (ch='/') then begin readln(fi,s); read(fi,ch); end;
startl:=false;
if ch=#10 then begin inc(i); startl:=true; end;
if (j<0) and (i=i2+i3-1) then j:=1;
if j>0 then inc(j);
if j>=i4*i1+5 then break;

case ch of '"' : ch:='''';
           '''': ch:='"';
end;

write(fo,ch);

end;

writeln(fo);
writeln(fo,');');
writeln(fo,'');
end; {for iii}

writeln(fo,'');
writeln(fo,'begin');
for iii:=1 to paramcount do
writeln(fo,Nnames[iii],'_d:=ppgchar(',Nnames[iii],'_xpm);');

writeln(fo,'end.');

close(fi);
close(fo);
writeln('Done');

end.
