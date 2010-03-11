unit FunctionSolver;

{ unit FunctionSolver					}
{ (c) 1983 - 2008 by Hartmut Eilers			}
{ this unit implements everything needed to evaluate	}
{ formulars and calculate them				}
{ exported funtions are					}
{ codier and FX						}
{ codier gets the formular as string			}
{ and returns the formular in two arrays suitable	}
{ for FX to calculate the result			}


{ $Id$ }

interface

type 
	string80 = string [80];
	string5  = string [5];
	array30  = array [1..30] of real;
	token    = array [1..80] of integer;


var
	FSfm	: byte;
	FSerr_msg : array [1..11] of string[40];


procedure codier(formel:string80;var funk:token;var zahlen:array30);
function FX (x : real;funk : token;zahlen : array30):real;

implementation

const		debug = false;


function uppercase(s:string):string;
var 	i : word;

begin
	for i:=1 to length(s) do
		if s[i] in ['a'..'z'] then s[i]:=chr(ord(s[i])-32);
	uppercase:=s;
end;


procedure FSInit();

begin
	FSfm:=0;
	FSerr_msg[1]:='Operand ohne Operator';
	FSerr_msg[2]:='Unbekannte Funktion';
	FSerr_msg[3]:='Operator ohne Operand';
	FSerr_msg[4]:='Letzter Operand fehlt';
	FSerr_msg[5]:='Kein Klammerausgleich';
	FSerr_msg[6]:='Falsches Zeichen';
	FSerr_msg[7]:='gebrochener Exponent';
	FSerr_msg[8]:='Logarithmus <= null';
	FSerr_msg[9]:='Funktion nur zwischen -1< x <1 definiert';
	FSerr_msg[10]:='Division durch null';
	FSerr_msg[11]:='Radikant <= null';
end;


procedure codier(formel:string80;var funk:token;var zahlen:array30);

   (*  Umwandlung der Formel in Token                                       *)

var
	ifkt,iz,klammer,
	i,k,ftyp,klasse   : byte;
	opernd,grzstd     : boolean;
	fwort             : string5;
	fzahl             : real;


{ PRIVATE FUNTIONS }

function woklass(wort:string5):byte;
(*   Decodieren und Klassifizieren eines Wortes                       *)
const 
	NumberOfElements=17;
	namen : array[1..NumberOfElements] of string5
                  = ('EXP  ','LN   ','LOG  ','SIN  ','COS  ','TAN  ','ASIN ',
                     'ACOS ','ATAN ','SINH ','COSH ','TANH ','SQRT ','ABS  ',
                     'PI   ','E    ','X    ');
var 
	z       : byte;

begin
	z:=0;
	repeat
		inc(z);
	until (wort=namen[z]) or (z=NumberOfElements+1);
	if z=NumberOfElements+1 then woklass:=99
	else woklass:=z+13;
end;
(*   ENDE  FUNCTION WOKLASS                                            *)


procedure bassym ( zeile:string80 ; var zeig,typ:byte;
                        var wort:string5 ; var zahl:real);

(*    Zerlegen der Funktion in Basissymbole                            *)

var 
	ascii,puffer,lang,i : byte;
	expo                : real;
	vzahl,nzahl,err     : integer;


begin
	wort:='';
	zahl:=0;
	expo:=1.0;
	while ord(zeile[zeig])=32 do inc(zeig);      (* BLANKS �bergehen     *)
	ascii:=ord(zeile[zeig]);
	if debug then writeln('Zeile[',zeig,']=',zeile[zeig],' ascii=',ascii);
	case ascii of
	
			40 : 	begin
					typ:=12;                            (* Klammer auf          *)
					inc(zeig);
				end;
		
			41 : 	begin
					typ:=13;                            (* Klammer zu           *)
					inc(zeig);
				end;
		
			42 : 	begin
					typ:=3;                             (* Mal-Zeichen          *)
					inc(zeig);
				end;
		
			43 : 	begin
					typ:=2;                             (* Plus-Zeichen         *)
					inc(zeig);
				end;
		
			45 : 	begin
					typ:=1;                             (* Minus-Zeichen        *)
					inc(zeig);
				end;
		
			47 : 	begin
					typ:=4;                             (* Durch-Zeichen        *)
					inc(zeig);
				end;
	
			94 : 	begin
					typ:=5;                             (* Hoch-Zeichen ^        *)
					inc(zeig);
				end;
	
			else begin
				puffer:=zeig;
				while (ascii>=48) and (ascii<=57) do begin
					inc(zeig);
					ascii:=ord(zeile[zeig]);
				end;
				if puffer <> zeig then begin		// Es ist eine Zahl
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
						for i:=1 to zeig-puffer do 
							expo:=expo*0.1;
						zahl:=vzahl+nzahl*expo;
					end
					else val(copy(zeile,puffer,zeig-puffer),zahl,err);
				end
				else begin		// es ist eine Funktion e.g. cos,sin oä
					if debug then writeln( 'bassym: funktion detected, wort=',wort,' ascii=',ascii);
					while (ascii>=65) and (ascii<=90) do begin
						wort:=wort+chr(ascii);
						inc(zeig);
						ascii:=ord(zeile[zeig]);
					end;
					if debug then writeln( 'bassym: wort=',wort);
					if puffer<>zeig then begin
						lang:=length(wort);
						if lang < 5 then 
							for i:=lang to 5 do 
								wort:=wort+' ';
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
	formel:=uppercase(formel);
	ifkt:=1;
	iz:=4;
	klammer:=0;
	i:=1;
	FSfm:=0;
	grzstd:=true;
	opernd:=true;
	repeat
		bassym (formel,i,ftyp,fwort,fzahl);
		if debug then writeln('Formel=',formel,' i=',i,' ftyp=',ftyp,' fwort=',fwort,'fzahl=',fzahl);
		if (ftyp=10) or (ftyp=11) then begin		// funktion oder Zahl
			if not opernd then begin
				FSfm:=1;
				exit;
			end;
			if ftyp=10 then begin			// funktion
				klasse:=woklass(fwort);
				if (klasse>13) and (klasse<28) then begin
					funk[ifkt]:=klasse+256*klammer;
					inc(ifkt);
				end
				else
					case klasse of
						28 : 	begin				// PI
								funk[ifkt]:=-2;
								inc(ifkt);
								opernd:=false;
								zahlen[2]:=pi;
							end;
						29 :	begin				// E
								funk[ifkt]:=-3;
								inc(ifkt);
								opernd:=false;
								zahlen[3]:=exp(1);
							end;
						30 : 	begin				// X
								funk[ifkt]:=-1;
								inc(ifkt);
								opernd:=false;
							end
						else begin
							FSfm:=2;
							exit;
						end
					end
			end
			else begin			// eine Zahl
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
					FSfm:=6;
					exit;
				end;
			end;
			grzstd:=false;
		end
		else begin
			case ftyp of
				13 :	begin
						dec(klammer);
						grzstd:=false;
					end;
				12 : 	begin
						inc(klammer);
						grzstd:=true;
					end;
				else begin
					FSfm:=6;
					exit
				end
			end
		end;
	until i > length(formel);
	funk[ifkt]:=0;
	if opernd then begin
		FSfm:=4;
		exit;
	end;
	if klammer > 0 then begin
		FSfm:=5;
		exit;
	end;
end;      (* ENDE Prozedur CODIER                                       *)

{ ************************ FX *****************************************}

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
        else begin 
		pot:=fehler+100;
		FSfm:=7;
	end;
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
        if (x<=-1) or (x>=1) then begin
		arcsin:=fehler+300;
		FSfm:=9;
	end
        else arcsin:=arctan(x/sqrt(-x*x+1));
   end;

   function arccos(x:real):real;
   begin
        if (x<=-1) or (x>=1) then begin
		arccos:=fehler+300;
		FSfm:=9;
	end
        else arccos:=-arctan(x/sqrt(-x*x+1))+pi/2;
   end;


   begin
     case zeich of

       1 : arith:=op1-op2;

       2 : arith:=op1+op2;

       3 : arith:=op1*op2;

       4 : if op2=0 then begin
		arith:=fehler+400;
		FSfm:=10;
	   end
           else arith:=op1/op2;

       5 : arith:=pot(op1,op2);          (* X hoch n *)

       14: arith:=exp(op1);              (* e hoch x *)

       15: if op1<=0 then begin
		arith:=fehler+200;  	(* ln *)
		FSfm:=8;
	   end
           else arith:=ln(op1);

       16: if op1<0 then begin
		arith:=fehler+200;
		FSfm:=8;
	   end
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
           else  begin
		arith:=fehler+500;
		FSfm:=11;
	   end;

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




begin
	FSInit();
end.
