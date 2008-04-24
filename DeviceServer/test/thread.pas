{$mode objfpc}  
{$threading on}  
 
uses  
  sysutils {$ifdef unix},cthreads{$endif} ;  
 
const  
  threadcount = 100;  
  stringlen = 10000;  
 
var  
   finished : longint;  
 
threadvar  
   thri : longint;  
 
function f(p : pointer) : longint;  
 
var  
  s : ansistring;  
 
begin  
  Writeln('thread ',longint(p),' started');  
  thri:=0;  
  while (thri
    begin  
    s:=s+'1';  
    inc(thri);  
    end;  
  Writeln('thread ',longint(p),' finished');  
  InterLockedIncrement(finished);  
  f:=0;  
end;  
 
var  
   i : longint;  
 
begin  
   finished:=0;  
   for i:=1 to threadcount do  
     BeginThread(@f,pointer(i));  
   while finished
   Writeln(finished);  
end.
