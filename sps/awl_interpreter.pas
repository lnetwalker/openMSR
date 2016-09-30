{ this is the interpreter for sps files }
{ interpreter version 1.2}

{ copyright (C) 2007 by Hartmut Eilers <hartmut@eilers.net>			}
{ distributed under the GNU General Public License V2 or any later	}

function timeNow:Real;
begin
	gettime(std,min,sec,ms);
	usec:=0;
	timeNow:=(((std*60+min)*60+sec)*1000+ms)*1000+usec;
end;


procedure RPMs;
begin
	if (runs=0) then begin
		time1:=timeNow;
	end;
	inc(runs);
	if ( runs = TimeRuns ) then begin
		runs:=0;
		time2:=(timeNow-time1)/TimeRuns;
		if ( time2=0 ) then time2:=0.0000001;		{ 1 �second }
		durchlaufeProSec:=trunc(1000000/time2);
{$ifdef SPS}
		GotoXY(35,16);
		clreol;
		write('Cycletime Tz=',(time2/1000):5:2,' ms =',DurchlaufeProSec:5,' CPS ');
{$endif}
	end;	
end;


procedure toggle_internal_clock (var m1,m2,m3 : boolean);   { toggelt die internen clock-marker }

begin
    m3:=not(m3);
    if m3 then m2:=not(m2);
    if m2 and m3 then m1:=not(m1);
end;                               { **** ENDE TOGGLE_INTERNAL_CLOCK **** }

function mehrfach (z:word):boolean;

begin
	mehrfach:=true;
	if (operation[z+1]=anweisung[1]) or					{ UN(	}
		(operation[z+1]=anweisung[3]) or				{ UN	}
		(operation[z+1]=anweisung[5]) or				{ U(	}
		(operation[z+1]=anweisung[20]) or				{ NOP	}
		(operation[z+1]=anweisung[11]) or				{ EN	}
		(operation[z+1]=anweisung[25]) or				{ PE	}
		(operation[z+1]=anweisung[30]) or				{ EP	}
		(operation[z+1]=anweisung[31]) or				{ AN(	}
		(operation[z+1]=anweisung[32]) or				{ AN	}
		(operation[z+1]=anweisung[33]) or				{ A(	}
		(operation[z+1]=anweisung[34]) or				{ A		}
		(operation[z+1]=anweisung[12]) 					{ U		}
	 then mehrfach:=false
end;



procedure interpret;               { interpretiert einen durchlauf der awl }

var
	akku,help         : boolean;
	k                 : word;
	klammer,token     : byte;
	klammerakku       : array[1..255] of boolean;
	klammeroper       : array[1..255] of string3;
	aktuell,anweis    : string3;
	analog_akku       : longint;
	timestring	 : string;


procedure verkn;                   { verkn�pft akku mit hilfsregister }

procedure zerleg;                  {negiert ggf den zustand eines operanden}

var
	inv               : boolean;{und weist ihn dem Hilfsregister zu }

begin
	inv:=false;
	if (aktuell='ON ') or (aktuell='UN ') or (aktuell='AN ') then inv:=true;
	case operand[k] of
	 	'I':	if inv then
				help:=not(eingang[par[k]])
			else
				help:=eingang[par[k]];
		'E':	if inv then
				help:=not(eingang[par[k]])
			else
				help:=eingang[par[k]];
		'O':	if inv then
				help:=not(ausgang[par[k]])
			else
				help:=ausgang[par[k]];
		'A':	if inv then
				help:=not(ausgang[par[k]])
			else
				help:=ausgang[par[k]];
		'M':	if inv then
				help:=not(marker[par[k]])
			else
				help:=marker[par[k]];
		'T':	if inv then
				help:=not(timer[par[k]])
			else
				help:=timer[par[k]];
		'C':	if inv then
				help:=not(zahler[par[k]])
			else
				help:=zahler[par[k]];
		'Z':	if inv then
				help:=not(zahler[par[k]])
			else
			  help:=zahler[par[k]];
		'J':	if debug then writeln('analoh input');
	else
	    begin
		{ errorabfrage }
		writeln (' unknown operand line: ',k);
		halt(1);
	    end;
	end;
	inv:=false;
end;                               { **** ENDE ZERLEG *****       }

begin
	case token of
		1,2,5,6,31,33   : begin                    { UN(,ON(,U(,O(,AN(,A( }
				inc(klammer);
				klammerakku[klammer]:=akku;
				akku:=true;
				klammeroper[klammer]:=aktuell;
			end
		else
				zerleg;
	end;
	case token of
		3: 	akku:=akku and help;			{ UN	}
		4:	akku:=akku or help;		      	{ ON	}
		12:	if (operand[k]='J') then		{ U	}
			 	analog_akku:=analog_in[par[k]]			
			else
				akku:=akku and help;
		13:	akku:=akku or help;			{ O	}
		32: 	akku:=akku and help;			{ AN	}
		34: 	akku:=akku and help;			{ A	}
     end
end;                               { **** ENDE VERKN ****}


procedure zuweisen;                { weist den akkuinhalt einem ausg. od merker}
begin
	if token=7 then akku:=not(akku);
	case operand[k] of
		'O':	ausgang[par[k]]:=akku;
		'A':	ausgang[par[k]]:=akku;
		'M':	marker[par[k]]:=akku;
	{else}
		{f�r sp�tere errorabfrage }
	end;
	if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE ZUWEISEN **** }

procedure setzen;                  { setzt einen ausg. od. merker auf log 1}
begin
	if akku then begin
		case operand[k] of
			'O':	ausgang[par[k]]:=true;
			'A':	ausgang[par[k]]:=true;
			'M':	marker [par[k]]:=true;
		{else}
			{ f�r sp�tere Fehlermeldung }
		end
	end;
	if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE SETZEN **** }

procedure rucksetzen;              { setzt einen ausg. od. merker auf log 0 }
begin
	if akku then begin
		case operand[k] of
			'O' : ausgang[par[k]]:=false;
			'A' : ausgang[par[k]]:=false;
			'M' : marker [par[k]]:=false;
		{else}
			{ f�r sp�tere Fehlermeldung }
		end
	end;
	if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE RUCKSETZEN **** }

procedure klammer_zu;              { beendet letzte klammer und verkn�pft }
var 
	helper			: boolean ;
begin
	{ ON( bzw UN(  bzw AN(}
	if (klammeroper[klammer]='ON(') or (klammeroper[klammer]='UN(') or (klammeroper[klammer]='AN(') then begin
		helper:=not(akku);
		akku:=helper;
	end;
	if (klammeroper[klammer]='O( ') or (klammeroper[klammer]='ON(') then akku:=akku or klammerakku[klammer];
	if (klammeroper[klammer]='U( ') or (klammeroper[klammer]='UN(') or (klammeroper[klammer]='AN(') or (klammeroper[klammer]='A( ')then
		akku:=akku and klammerakku[klammer];
	klammer:=klammer-1;
end;                               { **** ENDE KLAMMER_ZU **** }

procedure set_timer;               {timer auf startwert setzen}
var 
	dummy	: integer;

begin
	if akku and not(lastakku[par[k]]) then begin
		{ negative parameter means that a analog input value should be used as parameter }
		if ( par[k+1] > 0 ) then
        		t[par[k]]:=par[k+1]
		else begin	
			write(#7);
			dummy:=par[k+1]*-1;
			t[par[k]]:=analog_in[dummy];
		end;
		timer[par[k]]:=false;
		lastakku[par[k]]:=true;
	end
	else if not(akku) then begin
		t[par[k]]:=65535;
		timer[par[k]]:=false;
		lastakku[par[k]]:=false
	end;
	akku:=true
end;                               { **** ENDE SET_TIMER ****}

procedure set_counter;             { counter auf startwert setzen }

begin
	if akku and not(lastakku[par[k]+8]) then begin
		z[par[k]]:=par[k+1];
		zahler[par[k]]:=false;
		lastakku[par[k]+8]:=true
	end
	else if not(akku) then begin
		z[par[k]]:=65535;
		zahler[par[k]]:=false;
		lastakku[par[k]+8]:=false
	end;
	akku:=true
end;                               { **** ENDE SET_COUNTER ****}


procedure analog_equal;			{ check for anaologig equal  	}

begin
	akku:=false;
	if (par[k] = analog_akku) then akku:=true;	
end;					{ **** ENDE ANALOG_EQUAL	}

procedure analog_less;			{ check for anaologig less than }

begin
	akku:=false;
	if (analog_akku < par[k]) then akku:=true;
end;					{ **** ENDE ANALOG_less	}

procedure analog_great;			{ check for anaologig greater than }

begin
	akku:=false;
	if (analog_akku > par[k]) then akku:=true;
end;					{ **** ENDE ANALOG_great	}

procedure jump;
begin
	 K:=par[k]-1;
	 akku:=true
end;

procedure execute;			{ executes an external program 	}

begin
	{ an external program should be launched if the akku is true	}
	{ the returncode of that programm is stored in the ANALOG_AKKU	}
	{ because it could be a 8 Bit value. the best effort is, that	}
	{ one can act on different return values with EQ,GT and LT	}
	{ you have to ensure, that output of the program is redirected	}
	if ( akku ) then begin
		{$ifdef LINUX}
			{$ifndef ZAURUS}
			analog_akku := fpsystem(comment[k]);
			{$endif}
		{$else}
		exec(GetEnv('COMSPEC'),comment[k]);
		analog_akku:=DosExitCode;
		{$endif}
	end;
end;

procedure cond_jump;
begin
	if akku then begin
		k:=par[k]-1;
		akku:=true
	end
	else 
		akku:=true;
end;

	
begin
	k:=0;
	watchdog:=0;
	akku:=true;
	analog_akku:=0;
	help:=false;
	klammer:=0;
	repeat
		inc(k);
		inc(watchdog);
		aktuell:=operation[k];
		if watchdog > awl_max then aktuell:='EN ';
		token:=0;
		repeat
			inc(token);
			anweis:=anweisung[token];
		until (aktuell=anweis) or (token>anweismax);
		//if ( debug ) then writeln ('Nr ',k,' aktuell ',aktuell,'  Token: ',token);
		case token of
			1..6:	verkn;					{ UN( .. O(	}
			7:	zuweisen;				{ =      	}
			8:	cond_jump;				{ JI 		}
			9:	set_timer;				{ TE 		}
			10:	set_counter;				{ ZR 		}
			11:	;					{ EN   		}
			12,13:	verkn;					{ U O		}
			14:	klammer_zu;				{ ) 		}
			15:	zuweisen;				{ =N 		}
			16:	setzen;					{ S 		}
			17:	rucksetzen;				{ R 		}
			18:	jump;					{ J 		}
			19:	;					{ K 		}
			20:	;					{ NOP 		}
			21:	analog_equal;		     		{ EQ 		}
			22:	analog_less;    	    		{ LT 		}
			23:	analog_great;        			{ GT 		}
			24:	execute;                		{ $		}
			25:	;					{ PE		}
			26,27:	jump;					{ JP,SP		}
			28,29:	cond_jump;				{ JC,SPB	}
			30:	;					{ EP		}
			31:	verkn;					{ AN(		}
			32:	verkn;					{ AN		}
			33:	verkn;					{ A(		}
			34:	verkn;					{ A		}
		{else}
			{ f�r sp�tere Fehlerabfrage }
		end;
	until ( aktuell = 'EN ') or (aktuell = 'PE ') or (aktuell='EP ');
	Str((time2/1000):5:2,timestring);
	if (aktuell='EN ') or (aktuell='PE ')  or (aktuell='EP ') then comment[k]:='Zykluszeit Tz='+timestring+' ms';
	if ( debug ) then begin
		for k:=8 downto 1 do
			if (k=8) then
				write ('interpreter: E 8-1 ',eingang[k],' ')
			else
				write (eingang[k],' ');
		writeln;
		for k:=8 downto 1 do 
			if (k=8) then
				write ('interpreter: A 8-1 ',ausgang[k],' ')
			else   
				write (ausgang[k],' ');
		writeln
	end;		
end;                               { **** ENDE INTERPRET **** }
