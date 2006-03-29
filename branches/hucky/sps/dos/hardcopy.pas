(* HARDCOPY.PAS         31/10/90      (c) by HuSoft     *)


procedure hgrcopy (left,top,right,bottom,size,maxx,maxy:word);

                          {erzeugt eine hardcopy des grafikausschnittes }

const zweih1              : array [0..7] of byte = (128,64,32,16,8,4,2,1);
      zweih2              : array [0..3] of byte = (192,48,12,3);
      zweih4              : array [0..1] of byte = (240,15);
      zweih8              : array [0..0] of byte = (255);

var  bitnumber,i,j,decrement,y,n,spalte,breite,hoehe,ptrres : integer;

function screenbit(x,y:word):boolean;

                                   { testet ob pixel gesetzt oder nicht }
begin
     screenbit := getpixel(x,y)>0;
end;                               {**** ENDE SCREENBIT ****}


function params_ok:boolean;        { checkt die Åbergebenen parameter }
var ok                    : boolean;
begin
     ok:=true;
     if (left<0) or (right>maxx) or (left>right) or (top>0)
        or (bottom>hoehe) or (top>bottom)
        or not (size in [1,2,4,8]) then ok:=false;
     bitnumber:=size*(right-left+1);
     if bitnumber > ptrres then ok:=false;
end;                               {**** ENDE PARAMS_OK ****}

begin                              {hp hgrcopy          }
     breite:=maxx;
     hoehe:=maxy;
     ptrres:=breite+1;
     if params_ok then begin
        y:=top;
        decrement:=8 div size;
        {$I-}
        write (lst,chr(27),chr(51),chr(24));
        if ioresult<> 0 then begin
           sound(220);delay(200);nosound;
           exit;
        end;
        {$I+}
        while y<= bottom do begin
            write(lst,'       ');
            write(lst,chr(27),chr(76),chr(lo(bitnumber)),chr(hi(bitnumber)));
            for i:= left to right do begin
                spalte:=0;
                for n:= y to pred(y+decrement) do
                    if n<= bottom then
                       if screenbit(i,n) then
                          case size of
                               1: spalte :=spalte or zweih1[n-y];
                               2: spalte :=spalte or zweih2[n-y];
                               3: spalte :=spalte or zweih4[n-y];
                               4: spalte :=spalte or zweih8[n-y];
                          end;
                for j:= 1 to size do
                     write(lst,chr(spalte));
            end;
            writeln(lst);
            y:=y+decrement;
        end;
        write(lst,chr(27),chr(50));
        write(lst,chr(12));
     end;
end;                               { **** ENDE HGRCOPY ****}


procedure Print_Screen(maxx,maxy:word);

const pot : array[0..7] of byte = (128,64,32,16,8,4,2,1);

var nr_of_bits   : word;
    i            : byte;
    x,y          : Word;
    spaltenwert  : byte;

begin
     nr_of_bits:=maxx+1;
     write(lst,chr(27),chr(51),chr(24));
     y:=0;
     repeat
         write(lst,'   ');
         write(lst,chr(27),chr(76),chr(lo(nr_of_bits)),chr(hi(nr_of_bits)));
         for x:=0 to maxx do begin
             spaltenwert:=0;
             for i:=0 to 7 do
                 if  getpixel(x,y+i)>0 then
                     spaltenwert:=spaltenwert or pot[i];
             write(lst,chr(spaltenwert));
         end;
         writeln(lst);
         inc(y,8);
     until y>=maxy;
     write(lst,chr(27),chr(50));
     write(lst,chr(12));
end;