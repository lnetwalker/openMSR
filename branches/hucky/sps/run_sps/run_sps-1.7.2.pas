program runsps;
{$M 16000,0,0}                   { 16000 Bytes STACK , kein HEAP }

{ $Id$ }

uses dos,crt,linux,popmenu,io_access;
{ porting to linux startet at 27.05.99 				}
{ don't blame me for "bad" code					}
{ some of the code inside is from my earliest steps in pascal 	}
{ and some of my least steps after years where I coded not	}
{ one simple line in pascal :) If you have improvements		}
{ please contact me at hartmut@eilers.net			}
{ all code is copyright by Hartmut Eilers			}
{ the code is distributed under the GNU general public license	}
{ history 							}
{	27.05.1999 start of Linux Port				}
{ 	03.10.2000 start of Version 1.7.1			}
{	11.10.2000 installed fpc 1.0				}
{	11.10.2000 start analog processing EQ,LT,GT		}

{$i ./sps.h}
{$i ./run_awl.h }
{$i ./awl_interpreter.pas}

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
	  writeln ('try to read line ',i);
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
var y,x	: word;
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
         until (operation[x]=anweisung[y]) or (y>anweismax);
         if operation[x]=anweisung[y] then token[x]:=y
         else token[x]:=0;
     end;
     writeln(' INIT ended');
end;                               { ****ENDE INIT ****}




procedure run_awl;

begin                              { hp run_awl                      }
      get_input;                      { INPUTS lesen                    }
      interpret;                      { einen AWLdurchlauf abarbeiten   }
      set_output;                     { OUTPUTS ausgeben                }
      count_down;                     { TIMER / ZAHLER aktualisieren    }
                                      { interne TAKTE M62-M64 toggeln   }
      toggle_internal_clock(marker[62],marker[63],marker[64]);          
end;                               { **** ENDE RUN_AWL ****          }


begin                              { SPS_SIMULATION           }
      { signal handling is needed here, also the program should  	}
      { go in background and at least there should be something 	}
      { done with the load						}
      { set a very nice priority 					}
      nice(20);
      writeln(version,' run_sps daemon');
      writeln(datum);
      sps_laden;
      writeln('AWL gestartet');
      init;
      repeat
	 run_awl;
      until KeyPressed;	     	
end.                               { **** SPS_SIMULATION **** }
