unit environ;

{ schreiben oder loeschen eines strings  im environment  }
{ des laufenden  programmes                              }
{ 13/10/93 (c) by HuSoft                                 }

interface
function delstring(env_var:string):byte;
function addstring(env_var:string):byte;

implementation

uses dos,crt;


var i,psp_segment,psp_offset,environ_seg,environ_offs : word;
    x : integer;
    regs : registers;


function addstring;
begin
     x:=-1;
     repeat
          inc(x);
     until mem[environ_seg:environ_offs+x]=$01;
     for i:=1 to length(env_var) do
         mem[environ_seg:environ_offs+x+i-2]:=ord(env_var[i]);
     memw[environ_seg:environ_offs+x+i-1]:=0;
     memw[environ_seg:environ_offs+x+i+1]:=$0100;
     addstring:=0;
end;


function delstring;
var searchstring : string;
    delstring_laenge : word;
begin
     x:=-1;
     searchstring:='';
     repeat                               {search the string in environment }
          inc(x);
          if mem[environ_seg:environ_offs+x] = 0 then searchstring:=''
          else searchstring:=searchstring+chr(mem[environ_seg:environ_offs+x]);
     until (searchstring=env_var) or (mem[environ_seg:environ_offs+x]=$01);
     if searchstring=env_var then begin
        delstring_laenge:=x;
        repeat
              inc(x);
        until mem[environ_seg:environ_offs+x] = 0;
        delstring_laenge:=x-delstring_laenge+length(searchstring);
        repeat
              inc(x);
              mem[environ_seg:environ_offs+x-delstring_laenge]:=
                 mem[environ_seg:environ_offs+x];
        until mem[environ_seg:environ_offs+x]=$01;
     end;
end;







begin
     regs.ah:=$62;
     msdos(regs);
     psp_segment:=regs.bx;
     psp_offset:=0;
     environ_seg:=memw[psp_segment:psp_offset+$2c];
     environ_offs:=0;
end.




