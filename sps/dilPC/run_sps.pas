program runsps;
{$M 16000,0,0}                   { 16000 Bytes STACK , kein HEAP }

uses dos,crt,dil_io_access,linux,systemlog;

{ porting to linux startet at 27.05.99 				}
{ don't blame me for "bad" code					}
{ some of the code inside is from my earliest steps in pascal 	}
{ and some of my least steps after years where I coded not	}
{ one simple line in pascal :) If you have improvements		}
{ please contact me at hartmut@eilers.net			}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}


type  string12=string[12];
      string3 =string[3];


const awl_max     =500;
      control_port=$ff;		{ all port adresses are dummy values 			}
      port_a      =$ff;		{ you only have the outport for the out signal 1-8 	}
      port_b      =$ff;		{ and the inport with the signals in 3 to 8		}
      port_c      =$ff;		{ counters are not available with the printer port	}
      ProgNamVer  =' RUN_SPS           V 1.7.0 for DIL/NetPC Linux ';
      Copyright   ='      (c)  1990-2001 by H.EILERS ';
      power       : array[0..7] of byte =(1,2,4,8,16,32,64,128);
      anweisung   : array[1..20] of string3
                  = ('O  ','ON ','O( ','ON(','U  ',
                     'UN ','U( ','UN(',')  ','=  ',
                     '=N ','S  ','R  ','J  ','JI ',
                     'K  ','TE ','ZR ','NOP','EN ');


var
     x                 	: word;
     y                 	: byte;
     t,z               	: array[1..8]  of word;
     marker            	: array[1..64] of boolean;
     eingang,ausgang,
     timer,zahler,zust 	: array[1..8]  of boolean;
     lastakku          	: array[1..16] of boolean;
     token             	: array[1..awl_max] of byte;
     znr               	: array[1..awl_max] of integer;
     operation         	: array[1..awl_max] of string3;
     operand           	: array[1..awl_max] of char;
     par               	: array[1..awl_max] of word;
     comment           	: array[1..awl_max] of string[22];
     { prefix for logging via syslog }
     logprefix		: ansistring;

procedure sps_laden;

var  f              :text;
     zeile          :string[48];
     i,code         :integer;
     name           :string;

procedure get_file_name;           { namen des awl-files einlesen   }

begin
     write (' Filename : ');
     readln (name);
     if pos('.',name)=0 then name:=name+'.sps';
end;                               { **** ENDE GET_FILE_NAME **** }



begin
     i:=0;
     if paramcount=0 then get_file_name  { keine Aufrufparameter }
     else begin
          name:=paramstr(1);
          if pos('.',name)=0 then name:=name+'.sps';
     end;
     syslog(log_info,'loading program %s',name);
     assign (f,name);
     {$I-} reset (f); {$I+}
     if ioresult <> 0 then
     begin
          sound(220);delay(200);nosound;
          writeln (' SPS-File nicht gefunden');
          halt(1);
     end;
     writeln(' Lade Programm ',name);
     while not(eof(f)) do
     begin
          inc(i);
          readln (f,zeile);
          val (copy(zeile,1,3),znr[i],code);
          operation[i] := copy(zeile,5,3);
          operand[i] := zeile[9];
          val (copy(zeile,11,5),par[i],code);
          comment[i] := copy (zeile,17,22);
     end;
     close (F);
     doserror:=0;
end;                               {**** ENDE SPS_LADEN **** }



procedure init;                    { initialisieren aller Variablen }

begin
     for x:=1 to 64 do Marker[x]:=false;
     for x:=1 to 16 do lastakku[x]:=false;
     for x:=1 to  8 do begin
         ausgang[x]:=false;
         eingang[x]:=false;
         zahler[x]:=false;
         timer[x]:=false;
         t[x]:=0;
         z[x]:=0;
         zust[x]:=false;
     end;
     for x:=1 to awl_max do begin  { pseudo compilierung }
         y:=0;
         repeat
            inc(y);
         until (operation[x]=anweisung[y]) or (y>20);
         if operation[x]=anweisung[y] then token[x]:=y
         else token[x]:=0;
     end;
end;                               { ****ENDE INIT ****}




procedure run_awl;
{interrupt; }

procedure toggle_internal_clock;   { toggelt die internen clock-marker }

begin
    marker[64]:=not(marker[64]);
    if marker[64] then marker[63]:=not(marker[63]);
    if marker[63] and marker [64] then marker[62]:=not(marker[62]);
end;                               { **** ENDE TOGGLE_INTERNAL_CLOCK **** }



procedure get_input;               { ließt eingangswerte ein }

var  wert,i           :byte;

begin
     wert:=read_ports(port_a);
     for i:=7 downto 0 do begin
         if wert>=power[i] then begin
            eingang[i+1]:=true;
            wert:=wert-power[i]
         end
         else eingang[i+1]:=false;
     end
end;                               {****  ENDE GET_INPUT ****}

procedure interpret;               { interpretiert eine zeile der awl }

var    akku,help         : boolean;
       k,param           : word;
       klammer,akt_token : byte;
       klammerakku       : array[1..255] of boolean;
       klammeroper       : array[1..255] of byte;


procedure verkn;                   { verknüpft akku mit hilfsregister }

procedure zerleg;                  {negiert ggf den zustand eines operanden}

var    inv               : boolean;{und weist ihn dem Hilfsregister zu }

begin
     inv:=false;
     if (akt_token=2) or (akt_token=6) then  { 'ON ' bzw. 'UN ' }
        inv:=true;
     case operand[k] of
          'E':  if inv then
                   help:=not(eingang[param])
                else
                   help:=eingang[param];
          'A':  if inv then
                   help:=not(ausgang[param])
                else
                   help:=ausgang[param];
          'M':  if inv then
                   help:=not(marker[param])
                else
                   help:=marker[param];
          'T':  if inv then
                   help:=not(timer[param])
                else
                   help:=timer[param];
          'Z':  if inv then
                   help:=not(zahler[param])
                else
                   help:=zahler[param];
     end;
     inv:=false;
end;                               { **** ENDE ZERLEG *****       }

begin
     case akt_token of
          3,4,7,8   : begin
                           inc(klammer);
                           klammerakku[klammer]:=akku;
                           akku:=true;
                           klammeroper[klammer]:=akt_token;
                      end
     else
          zerleg;
     end;
     case akt_token of
          1,2       : akku:=akku or help;
          5,6       : akku:=akku and help;
     end
end;                               { **** ENDE VERKN ****}


function mehrfach (z:word):boolean;{ testet auf mehrfachzuweisungen }

begin
     mehrfach:=true;
     if (token[z+1]=5) or          { 'U  '}
        (token[z+1]=6) or          { 'UN '}
        (token[z+1]=7) or          { 'U( '}
        (token[z+1]=8) then mehrfach:=false { 'UN('}
end;


procedure zuweisen;                { weist den akkuinhalt einem ausg. od merker}
begin
     if akt_token=11 then akku:=not(akku); { anweisung ist '=N '}
     case operand[k] of
          'A'      : ausgang[param]:=akku; {akkuwert dem entspr. Param. zuweis}
          'M'      : marker[param]:=akku;
     end;
     if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE ZUWEISEN **** }

procedure setzen;                  { setzt einen ausg. od. merker auf log 1}
begin
    if akku then begin             { wenn akku wahr }
       case operand[k] of          { dann entspr. param. auf log. 1 setzen }
            'A' : Ausgang[param]:=true;
            'M' : marker [param]:=true;
       end
    end;
    if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE SETZEN **** }

procedure rucksetzen;              { setzt einen ausg. od. merker auf log 0 }
begin
    if akku then begin
       case operand[k] of          { wie bei setzen, jedoch auf log. 0 }
            'A' : Ausgang[param]:=false;
            'M' : marker [param]:=false;
       end
    end;
    if not(mehrfach(k)) then akku:=true
end;                               { **** ENDE RUCKSETZEN **** }

procedure klammer_zu;              { beendet letzte klammer und verknüpft }
var helper : boolean ;
begin
     if (klammeroper[klammer]=4)or(klammeroper[klammer]=8) then begin {'ON('bzw 'UN('}
        helper:=not(klammerakku[klammer]);
        klammerakku[klammer]:=helper;
     end;	
     if (klammeroper[klammer]=3)or(klammeroper[klammer]=4) then {'O(' bzw 'ON('}
        akku:=akku or klammerakku[klammer];
     if (klammeroper[klammer]=7)or(klammeroper[klammer]=8) then {'U(' bzw 'UN('}
        akku:=akku and klammerakku[klammer];
     klammer:=klammer-1;           { eine klammer abgearbeitet }
end;                               { **** ENDE KLAMMER_ZU **** }

procedure set_timer;               {timer auf startwert setzen}

begin
     if akku and not(lastakku[param]) then begin
        t[param]:=par[k+1];
        timer[param]:=false;
        lastakku[param]:=true;
     end
     else if not(akku) then begin
        t[param]:=0;
        timer[param]:=false;
        lastakku[param]:=false
     end;
     akku:=true
end;                               { **** ENDE SET_TIMER ****}

procedure set_counter;             { counter auf startwert setzen }

begin
     if akku and not(lastakku[param+8]) then begin { pos Flanke im akku ? }
        z[param]:=par[k+1];        { ja => sollwert aus K konstante nehmen}
        zahler[param]:=false;      { ZAHLER auf log 0 setzen   }
        lastakku[param+8]:=true    { akku = true speichern     }
     end
     else if not(akku) then begin  { nein => akku = log 0 ?    }
             z[param]:=0;          { ja => sollwert=0          }
             zahler[param]:=false; { ZAHLER auf log 0 setzen   }
             lastakku[param+8]:=false { akku=falsch speichern  }
          end;
     akku:=true                    { neuen satzbeginn erwarten }
end;                               { **** ENDE SET_COUNTER ****}

begin
     K:=1;
     akku:=true;
     help:=false;
     klammer:=0;
     while token[k] <> 20 do
     begin
          akt_token:=token[k];
          param:=par[k];
          case akt_token of
               1..8    : verkn;              { 'O' .. 'UN('}
               9       : klammer_zu;         { ')' }
               10,11   : zuweisen;           { '='; '=N' }
               12      : setzen;             { 'S' }
               13      : rucksetzen;         { 'R' }
               14      : begin               { 'J' }
                              K:=param-1;
                              akku:=true
                         end;
               15      : if akku then begin  { 'JI'}
                            k:=param-1;
			    akku:=true
                         end
                         else akku:=true;
               16      : ;                   { 'K' }
               17      : set_timer;          { 'TE'}
               18      : set_counter         { 'ZR'}
          end;
          inc(k);
     end;
end;                               { **** ENDE INTERPRET **** }

procedure set_output;              { gibt Ausg.werte an I/O Port B}
var       k,wert      : byte;
begin
     wert:=0;
     for  k:=7 downto 0 do wert:=wert+power[k]*ord(ausgang[k+1]);
     write_ports(port_b,wert);
end;                               { **** ENDE SET_OUTPUT **** }

procedure count_down;                    { zählt timer und counter herunter }

var c,wert              : byte;

begin
     for c:=1 to 8 do begin
         if t[c] > 0 then t[c]:=t[c]-1;       { Zeitzähler decrementieren  }
         if t[c]=0 then timer[c]:=true  { zeitzähler = 0? ja ==> TIMER auf 1}
     end;
     wert:=read_ports(port_c);                      { ZÄHLEReingänge lesen  }
     for c:=1 to 8 do begin
        if wert mod 2 = 0 then zust[c]:=false { wenn low dann 0 speichern   }
        else
          if not(zust[c]) then begin          { wenn pos. Flanke am Eingang }
            zust[c]:=true;                    { dann 1 speichern            }
            if z[c]>0 then z[c]:=z[c]-1;      {und ISTwert herunterzälen } 
            if z[c]=0 then zahler[c]:=true;   { wenn ISTwert 0 dann ZAHLER 1}
          end;
        wert := wert div 2
     end
end;                               { **** ENDE COUNT_DOWN ****       }


begin                              { hp run_awl                      }
      get_input;                      { INPUTS lesen                    }
      interpret;                      { einen AWLdurchlauf abarbeiten   }
      set_output;                     { OUTPUTS ausgeben                }
      count_down;                     { TIMER / ZAHLER aktualisieren    }
      toggle_internal_clock;          { interne TAKTE M62-M64 toggeln   }
end;                               { **** ENDE RUN_AWL ****          }


begin                              { SPS_SIMULATION           }
      { signal handling is needed here, also the program should go in background 	}
      { and at least there should be something done with the load			}
      { set a very nice priority }
      nice(20);
      prefix:=format('run_sps[%d] ',[i]);
      openlog(pchar(prefix),LOG_NOWAIT,LOG_DEBUG);
      syslog(log_info,'started run_sps');
      writeln(ProgNamVer);
      writeln(copyright);
      sps_laden;
      writeln('AWL gestartet');
      init;
      repeat
	 run_awl;
      until false;	     	
end.                               { **** SPS_SIMULATION **** }
