program fktplot;

uses qgtk2;


type string80 = string [80];
     string5  = string [5];
     array30  = array [1..30] of real;
     token    = array [1..80] of integer;

const version = '0.1';
      datum   = '12/02/2008';
      anzahl  = 240;
	debug = false;
	GetScreenMaxX=800;
	GetSCreenMaxY=480;

var formel       : string80;
    xmin,xmax,dx,
    yfact,ymin,
    ymax,maxy    : real;
    y,x          : array[1..240] of real;
    zahlen       : array30;
    funk         : token;
    fm           : byte;
    i,j,k,xfact,
    y_axis,
    zero_line,
    x_rand,y_rand,
    y_ver        : integer;
    x_wert,y_wert: string[6];
    ende         : boolean;


   procedure holparm;
   begin
      writeln('Programmende durch Formel=ende');
      write('Formel : Y=');readln(formel);
      for i:= 1 to length(formel) do formel[i]:=upcase(formel[i]);
      if formel='ENDE' then begin
         halt(0);
      end;
      write('XMIN   : ');readln(xmin);
      repeat
         write('XMAX   : ');readln(xmax);
      until xmax > xmin;
   end;

   procedure fehler(fcode:byte);

   var err_msg : array [1..11] of string[40];

   begin
       err_msg[1]:='Operand ohne Operator';
       err_msg[2]:='Unbekannte Funktion';
       err_msg[3]:='Operator ohne Operand';
       err_msg[4]:='Letzter Operand fehlt';
       err_msg[5]:='Kein Klammerausgleich';
       err_msg[6]:='Falsches Zeichen';
       err_msg[7]:='gebrochener Exponent';
       err_msg[8]:='Logarithmus <= null';
       err_msg[9]:='Funktion nur zwischen -1< x <1 definiert';
       err_msg[10]:='Division durch null';
       err_msg[11]:='Radikant <= null';
   end;


   procedure codier(formel:string80;var funk:token;
                    var zahlen:array30;var fm:byte);

   (*  Umwandlung der Formel in Token                                       *)

   var  ifkt,iz,klammer,
        i,k,ftyp,klasse   : byte;
        opernd,grzstd     : boolean;
        fwort             : string5;
        fzahl             : real;


      function woklass(wort:string5):byte;

      (*   Decodieren und Klassifizieren eines Wortes                       *)

      const namen : array[1..17] of string5
                  = ('EXP  ','LN   ','LOG  ','SIN  ','COS  ','TAN  ','ASIN ',
                     'ACOS ','ATAN ','SINH ','COSH ','TANH ','SQRT ','ABS  ',
                     'PI   ','E    ','X    ');
      var z       : byte;

      begin
        z:=0;
        repeat
          inc(z);
        until (wort=namen[z]) or (z=18);
        if z=18 then woklass:=99
        else woklass:=z+13;
      end;
     (*   ENDE  FUNCTION WOKLASS                                            *)


     procedure bassym ( zeile:string80 ; var zeig,typ:byte;
                        var wort:string5 ; var zahl:real);

     (*    Zerlegen der Funktion in Basissymbole                            *)

     var ascii,puffer,lang,i : byte;
         expo                : real;
         vzahl,nzahl,err     : integer;


     begin
       wort:='';
       zahl:=0;
       expo:=1.0;
       while ord(zeile[zeig])=32 do inc(zeig);      (* BLANKS �bergehen     *)
       ascii:=ord(zeile[zeig]);
       case ascii of

         40 : begin
                typ:=12;                            (* Klammer auf          *)
                inc(zeig);
              end;

         41 : begin
                typ:=13;                            (* Klammer zu           *)
                inc(zeig);
              end;

         42 : begin
                typ:=3;                             (* Mal-Zeichen          *)
                inc(zeig);
              end;

         43 : begin
                typ:=2;                             (* Plus-Zeichen         *)
                inc(zeig);
              end;

         45 : begin
                typ:=1;                             (* Minus-Zeichen        *)
                inc(zeig);
              end;

         47 : begin
                typ:=4;                             (* Durch-Zeichen        *)
                inc(zeig);
              end;

         94 : begin
                typ:=5;                             (* Hoch-Zeichen         *)
                inc(zeig);
              end;

       else begin
         puffer:=zeig;
         while (ascii>=48) and (ascii<=57) do begin
           inc(zeig);
           ascii:=ord(zeile[zeig]);
         end;
         if puffer <> zeig then begin
            typ:=11;
            if zeile[zeig]='.' then begin
               val(copy(zeile,puffer,zeig-puffer),vzahl,err);
               inc(zeig);
               ascii:=ord(zeile[zeig]);
               puffer:=zeig;
               while (ascii>=48) and (ascii<=57) do begin
                 inc(zeig);
                 ascii:=ord(zeile[zeig]);
               end;
               val(copy(zeile,puffer,zeig-puffer),nzahl,err);
               for i:=1 to zeig-puffer do expo:=expo*0.1;
               zahl:=vzahl+nzahl*expo;
            end
            else val(copy(zeile,puffer,zeig-puffer),zahl,err);
         end
         else begin
            while (ascii>=65) and (ascii<=90) do begin
              wort:=wort+chr(ascii);
              inc(zeig);
              ascii:=ord(zeile[zeig]);
            end;
            if puffer<>zeig then begin
               lang:=length(wort);
               if lang < 5 then for i:=lang to 5 do wort:=wort+' ';
               typ:=10;
            end;
           end;
         end;
       end;
     end;   (* ENDE PROZEDUR Bassym                                        *)


   begin
     for k:=1 to 20 do begin                 (* Zahlen- und Funktionsstack *)
         funk[k]:=0;
         Zahlen[k]:=0;
     end;
     for k:=21 to 80 do funk[k]:=0;          (* l�schen                    *)
     ifkt:=1;
     iz:=4;
     klammer:=0;
     i:=1;
     fm:=0;
     grzstd:=true;
     opernd:=true;
     repeat
       bassym (formel,i,ftyp,fwort,fzahl);
(*       writeln(fzahl);*)
       if (ftyp=10) or (ftyp=11) then begin
          if not opernd then begin
             fm:=1;
             exit;
          end;
          if ftyp=10 then begin
             klasse:=woklass(fwort);
             if (klasse>13) and (klasse<28) then begin
                funk[ifkt]:=klasse+256*klammer;
                inc(ifkt);
             end
             else
                case klasse of
                  28 : begin
                         funk[ifkt]:=-2;
                         inc(ifkt);
                         opernd:=false;
                         zahlen[2]:=pi;
                       end;
                  29 : begin
                         funk[ifkt]:=-3;
                         inc(ifkt);
                         opernd:=false;
                         zahlen[3]:=exp(1);
                       end;
                  30 : begin
                         funk[ifkt]:=-1;
                         inc(ifkt);
                         opernd:=false;
                       end
                else begin
                   fm:=2;
                   exit;
                  end
                end
          end
          else begin
             zahlen[iz]:=fzahl;
             funk[ifkt]:=-iz;
             inc(iz);
             inc(ifkt);
             opernd:=false;
          end
       end
       else if ftyp < 6 then begin
          if not opernd then begin
             funk[ifkt]:=ftyp+256*klammer;
             inc(ifkt);
             opernd:=true;
            end
          else begin
             if (ftyp=1) and grzstd then begin
                zahlen[iz]:=-1;
                funk[ifkt]:=-iz;
                inc(iz);
                inc(ifkt);
                funk[ifkt]:=3+256*klammer;
                inc(ifkt);
               end
             else begin
                fm:=6;
                exit;
               end;
          end;
          grzstd:=false;
       end
       else begin
         case ftyp of
           13 : begin
                 dec(klammer);
                 grzstd:=false;
                end;
           12 : begin
                 inc(klammer);
                 grzstd:=true;
                end;
           else begin
                fm:=6;
                exit
             end
         end
       end;
     until i > length(formel);
     funk[ifkt]:=0;
     if opernd then begin
        fm:=4;
        exit;
     end;
     if klammer > 0 then begin
        fm:=5;
        exit;
     end;
   end;      (* ENDE Prozedur CODIER                                       *)


   function FX (x : real;funk : token;zahlen : array30):real;

   type intarray30 = array[1..30] of byte;

   var wert        : array30;
       oper        : intarray30;
       io,iw,ifkt,
       iz          : byte;
       ostack,op,
       fstack,f    : integer;


   function arith (op1 : real;zeich : byte;op2 : real):real;

   const fehler=1073741824;    (* 2 hoch 30 *)

   function pot(x,n:real):real;
   var     i : byte;
           y : real;
           ni: integer;

   begin
        if trunc(n)=n then begin
           if n=0 then y:=1
           else begin
              if n>0 then begin
                 y:=x;
                 for i:=1 to trunc(n-1) do y:=y*x;
              end;
              if n<0 then begin
                 y:=x;
                 ni:=trunc(abs(n))-1;
                 for i:=1 to ni do y:=y*x;
                 if y<>0 then y:=1/y
                 else y:=0;
              end;
           end;
           pot:=y;
        end
        else pot:=fehler+100;
   end;


   function log10 ( X :real):real;
   begin
        log10:=ln(x)/ln(10);
   end;

   function tan( x: real):real;
   begin
        tan:=sin(x)/cos(x);
   end;

   function sinh(x:real):real;
   begin
        sinh:=(exp(x)-exp(-x))/2;
   end;

   function cosh(x:real):real;
   begin
        cosh:=(exp(x)+exp(-x))/2;
   end;

   function tanh(x:real):real;
   begin
        tanh:=sinh(x)/cosh(x);
   end;

   function arcsin(x:real):real;
   begin
        if (x<=-1) or (x>=1) then arcsin:=fehler+300
        else arcsin:=arctan(x/sqrt(-x*x+1));
   end;

   function arccos(x:real):real;
   begin
        if (x<=-1) or (x>=1) then arccos:=fehler+300
        else arccos:=-arctan(x/sqrt(-x*x+1))+pi/2;
   end;


   begin
     case zeich of

       1 : arith:=op1-op2;

       2 : arith:=op1+op2;

       3 : arith:=op1*op2;

       4 : if op2=0 then arith:=fehler+400
           else arith:=op1/op2;

       5 : arith:=pot(op1,op2);          (* X hoch n *)

       14: arith:=exp(op1);              (* e hoch x *)

       15: if op1<=0 then arith:=fehler+200  (* ln *)
           else arith:=ln(op1);

       16: if op1<0 then arith:=fehler+200
           else arith:=log10(op1);       (* log *)

       17: arith:=sin(op1);

       18: arith:=cos(op1);

       19: arith:=tan(op1);

       20: arith:=arcsin(op1);

       21: arith:=arccos(op1);

       22: arith:=arctan(op1);           (* arctan *)

       23: arith:=sinh(op1);             (* sinh *)

       24: arith:=cosh(op1);             (* cosh *)

       25: arith:=tanh(op1);             (* tanh *)

       26: if op1 > 0 then arith:=sqrt(op1)
           else  arith:=fehler+500;

       27: arith:=abs(op1);

     end;            (* CASE *)
   end;              (* ARITH *)


   procedure pushop;
   begin
       inc(io);
       oper[io]:=op;
   end;


   procedure testop;
   begin
     if io = 0 then begin
       if op <> 0 then pushop;
     end
     else begin
        ostack:=oper[io];
        fstack:=ostack;
        f:=op;
        ostack:= ostack mod 256;
        if f-fstack > 0 then pushop
        else begin
           if (ostack>13) and (ostack<28) then inc(iw);
           wert[iw-1]:=arith(wert[iw-1],ostack,wert[iw]);
           dec(iw);
           if f-fstack < 0 then begin
              dec(io);
              testop;
           end
           else oper[io]:=op;
        end;
     end;
   end;


   begin
      zahlen[1]:=x;
      ifkt:=0;
      iw:=0;
      io:=0;
      repeat
        inc(ifkt);
        if funk[ifkt]<0 then begin
           inc(iw);
           iz:=-funk[ifkt];
           wert[iw]:=zahlen[iz];
        end
        else begin
           op:=funk[ifkt];
           testop;
        end;
      until funk[ifkt]=0;
      fx:=wert[1];
   end;      (* ENDE Function FX                                          *)


   procedure funktionswerte_berechnen;
   const fehler = 1073741824;
   begin
     dx:=(xmax-xmin)/(anzahl-2);
     ymax:=0;
     ymin:=0;
     x[1]:=xmin;
     for i:=1 to anzahl do begin
        y[i]:=fx(x[i],funk,zahlen);
        if y[i]>=1048576 then begin
           if (y[i]>fehler) and (y[i]<fehler+150) then fm:=7;
           if (y[i]>fehler+150) and (y[i]<fehler+250) then fm:=8;
           if (y[i]>fehler+250) and (y[i]<fehler+350) then fm:=9;
           if (y[i]>fehler+350) and (y[i]<fehler+450) then fm:=10;
           if (y[i]>fehler+450) and (y[i]<fehler+550) then fm:=11;
           exit;
        end;
        if debug then writeln(i,' ',x[i],' ',y[i]);
        if y[i]>ymax then ymax:=y[i];
        if y[i]<ymin then ymin:=y[i];
        x[i+1]:=x[i]+dx;
     end;
     if ymax>abs(ymin) then maxy:=2*ymax
                       else maxy:=2* abs(ymin);
     if debug then writeln('maxy=',maxy);
   end;


procedure funktion_zeichnen;

	var
		oldx,oldy,maxx,maxy		:word;


begin
       oldy:=GetScreenMaxY-y_rand-trunc(y[1]*yfact+zero_line)+y_ver;
       oldx:=x_rand;
	j:=oldx;
       for i:=2 to anzahl do begin
		k:=GetScreenMaxY-y_rand-trunc(y[i]*yfact+zero_line)+y_ver;
		inc(j,xfact);
		qline(oldx,oldy,j,k);
		oldx:=j;
		oldy:=k;
       end;
end;


procedure onCreate;

	procedure  beschriftung;
	begin
		formel:='Y='+formel;
		j:=10;
		k:=20;
		qdrawtext(j,k,formel);
		(* Y-Achse *)
		for i:=3 downto -3 do begin
			k:=GetScreenMaxY-Y_rand-trunc((i*maxy/6)*yfact+zero_line)+y_ver;
			qline(x_rand-4,k,x_rand+4,k);
			if i<>0 then str(i*maxy/6:6:3,y_wert)
			else Y_wert:=' 0.00';
			qdrawtext(0,k,y_wert);
		end;
		(* X-Achse *)
		i:=0;
		j:=x_rand;
		k:=GetScreenMaxY-y_rand+y_ver+24;
		str(x[1]:4:2,x_wert);
		qdrawtext(j,k,x_wert);
		repeat
			inc(i,40);
			j:=i*xfact+x_rand;
			k:=GetScreenMaxY-y_rand+y_ver;
			qline (j,k+8,j,k+12);
			str(x[i]:6:3,x_wert);
			qdrawtext(j,k+24,x_wert);
		until i=240;
         end;


begin
	x_rand:=60;
	y_rand:=80;
	y_ver:=15;
	xfact:=trunc((GetScreenMaxX-80)/anzahl);
	yfact:=(GetScreenMaxY-y_rand-20)/maxy;
	y_axis:=GetScreenMaxY-y_rand-10;

	{ white Background }
	qsetClr( qWhite );
	qfillrect( 0, 0,GetScreenMaxX-1, GetScreenMaxY-1);
	qsetClr( qBlack );
	qrect(0,0,GetScreenMaxX-1,GetScreenMaxY-1);

	{ Nulllinie berechnen }
	zero_line:=trunc((GetScreenMaxY-y_rand)/2);

	{ Y-Achse zeichnen }
	qline(x_rand,0+y_ver,x_rand,GetScreenMaxY-y_rand);

	{ X Achse zeichnen }
	qline(x_rand,y_axis+20+y_ver,xfact*anzahl+x_rand+10,y_axis+20+y_ver);
	qline(x_rand,zero_line+y_ver,xfact*anzahl+x_rand+10,zero_line+y_ver);
	beschriftung;
	funktion_zeichnen;
end;





begin
	qstart('Fktplot  '+version+' '+datum, nil, nil);
        holparm;
        codier(formel,funk,zahlen,fm);
        if fm=0 then funktionswerte_berechnen;
        if fm=0 then qdrawstart(800,480, @onCreate,nil, nil);

	qgo;
end.