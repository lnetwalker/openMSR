program popenworkaround;
{$MODE OBJFPC}{$H+}
uses Baseunix,Unix;

Var    S : AnsiString;
   fin,fout : text;


begin
   AssignStream(fin,fout,'./digitemp.sh','');
   if fpgeterrno<>0 then
       writeln ('error from POpen : errno : ', fpgeterrno);

   while not eof (fin) do begin
       readln (fin,S);
       Writeln ('>',S);
   end;
   pclose(fout);
end.

