{ this is the interpreter for sps files }

procedure toggle_internal_clock (var m1,m2,m3 : boolean);   { toggelt die internen clock-marker }

begin
    m3:=not(m3);
    if m3 then m2:=not(m2);
    if m2 and m3 then m1:=not(m1);
end;                               { **** ENDE TOGGLE_INTERNAL_CLOCK **** }



procedure interpret;               { interpretiert einen durchlauf der awl }

var    akku,help         : boolean;
       k                 : word;
       klammer,token     : byte;
       klammerakku       : array[1..255] of boolean;
       klammeroper       : array[1..255] of string3;
       aktuell,anweis    : string3;
       analog_akku       : longint;
       timestring	 : string;


procedure verkn;                   { verknüpft akku mit hilfsregister }

procedure zerleg;                  {negiert ggf den zustand eines operanden}

var    inv               : boolean;{und weist ihn dem Hilfsregister zu }

begin
     inv:=false;
     if (aktuell='ON ') or (aktuell='UN ') then
        inv:=true;
     case operand[k] of
          'E':  if inv then
                   help:=not(eingang[par[k]])
                else
                   help:=eingang[par[k]];
          'A':  if inv then
                   help:=not(ausgang[par[k]])
                else
                   help:=ausgang[par[k]];
          'M':  if inv then
                   help:=not(marker[par[k]])
                else
                   help:=marker[par[k]];
          'T':  if inv then
                   help:=not(timer[par[k]])
                else
                   help:=timer[par[k]];
          'Z':  if inv then
                   help:=not(zahler[par[k]])
                else
                   help:=zahler[par[k]];
          {else}
          { für spätere errorabfrage }
          end;
     inv:=false;
end;                               { **** ENDE ZERLEG *****       }

begin
     case token of
          1,2,5,6   : begin
                           inc(klammer);
                           klammerakku[klammer]:=akku;
                           akku:=true;
                           klammeroper[klammer]:=aktuell;
                      end
     else
          zerleg;
     end;
     case token of
          3         : akku:=akku and help;
          4         : akku:=akku or help;		      
          12        : if (operand[k]='J') then 
			  analog_akku:=analog_in[par[k]]			
		      else
			  akku:=akku and help;
          13        : akku:=akku or help;		      			
     end
end;                               { **** ENDE VERKN ****}


function mehrfach (z:word):boolean;

begin
     mehrfach:=true;
     repeat
       inc(z);
     until operation[z]<>anweisung[19];
     if (operation[z]=anweisung[5]) or
        (operation[z]=anweisung[6]) or
        (operation[z]=anweisung[7]) or
        (operation[z]=anweisung[8]) then mehrfach:=false
end;


procedure zuweisen;                { weist den akkuinhalt einem ausg. od merker}
begin
     if token=7 then akku:=not(akku);
     case operand[k] of
          'A'      : ausgang[par[k]]:=akku;
          'M'      : marker[par[k]]:=akku;
     {else}
     {für spätere errorabfrage }
     end;
     if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE ZUWEISEN **** }

procedure setzen;                  { setzt einen ausg. od. merker auf log 1}
begin
    if akku then begin
       case operand[k] of
            'A' : Ausgang[par[k]]:=true;
            'M' : marker [par[k]]:=true;
       {else}
       { für spätere Fehlermeldung }
       end
    end;
    if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE SETZEN **** }

procedure rucksetzen;              { setzt einen ausg. od. merker auf log 0 }
begin
    if akku then begin
       case operand[k] of
            'A' : Ausgang[par[k]]:=false;
            'M' : marker [par[k]]:=false;
       {else}
       { für spätere Fehlermeldung }
       end
    end;
    if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE RUCKSETZEN **** }

procedure klammer_zu;              { beendet letzte klammer und verknüpft }
var helper : boolean ;
begin
     if (klammeroper[klammer]='ON(')  or (klammeroper[klammer]='UN(') then begin{ ON( bzw UN( }
     
     	 helper:=not(klammerakku[klammer]);
         klammerakku[klammer]:=helper;
     end;	 
     if (klammeroper[klammer]='O( ') or (klammeroper[klammer]='ON(') then
        akku:=akku or klammerakku[klammer];
     if (klammeroper[klammer]='U( ') or (klammeroper[klammer]='UN(') then
        akku:=akku and klammerakku[klammer];
     klammer:=klammer-1;
end;                               { **** ENDE KLAMMER_ZU **** }

procedure set_timer;               {timer auf startwert setzen}

begin
     if akku and not(lastakku[par[k]]) then begin
        t[par[k]]:=par[k+1];
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

procedure execute;			{ executes an external program 	}

begin
	{ an external program should be launched if the akku is true	}
	{ the returncode of that programm is stored in the ANALOG_AKKU	}
	{ because it could be a 8 Bit value. the best effort is, that	}
	{ one can act on different return values with EQ,GT and LT	}
	{ you have to ensure, that output of the program is redirected	}
	if ( akku ) then begin
		analog_akku := shell (comment[k]);
	end;
end;
	
begin
     K:=1;
     watchdog:=1;
     akku:=true;
     analog_akku:=0;
     help:=false;
     klammer:=0;
     aktuell:=operation[k];
     while aktuell <> 'EN ' do
     begin
          token:=0;
          repeat
             inc(token);
             anweis:=anweisung[token];
          until (aktuell=anweis) or (token>anweismax);
          case token of
               1..6    : verkn;			{ UN( .. O(	}
	       7       : zuweisen;              { =      	}
               8       : if akku then begin	{ JI 		}
                            k:=par[k]-1;
                            akku:=true
                         end
                         else akku:=true;
               9       : set_timer;		{ TE 		}
               10      : set_counter;		{ ZR 		}
               11      : ;			{ EN 		}
	       12,13   : verkn;			{ U O		}
               14      : klammer_zu;		{ ) 		}
               15      : zuweisen;		{ =N 		}
               16      : setzen;		{ S 		}
               17      : rucksetzen;		{ R 		}
               18      : begin			{ J 		}
                              K:=par[k]-1;
                              akku:=true
                         end;
               19      : ;			{ K 		}
               20      : ;			{ NOP 		}
	       21      : analog_equal;	     	{ EQ 		}
	       22      : analog_less;        	{ LT 		}
	       23      : analog_great;        	{ GT 		}
	       24      : execute                { $		}
	       	       
          {else}
          { für spätere Fehlerabfrage }
          end;
          inc(k);
          inc(watchdog);
          aktuell:=operation[k];
          if watchdog > awl_max then aktuell:='EN ';
     end;
     Str(time2:5:2,timestring);
     if aktuell='EN ' then comment[k]:='Zykluszeit Tz='+timestring+' ms';
end;                               { **** ENDE INTERPRET **** }
