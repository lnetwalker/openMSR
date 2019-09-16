program runsps;
{$M 16000,0,0}                   { 16000 Bytes STACK , kein HEAP }

{ porting to linux startet at 27.05.99 							}
{ don't blame me for "bad" code											}
{ some of the code inside is from my earliest steps }
{ in pascal and some of my least steps after years	}
{ where I coded not	 one simple line in pascal :) 	}
{ If you have improvements please contact me at 		}
{ hartmut@eilers.net																}
{ all code is copyright by Hartmut Eilers						}
{ the code is distributed under the GNU 						}
{ general public license														}
{ history 																					}
{	27.05.1999    		start of Linux Port							}
{ 	03.10.2000	  	start of Version 1.7.1					}
{	11.10.2000	  	installed fpc 1.0 								}
{	11.10.2000	  	start analog processing 					}
{				EQ,LT,GT																		}
{	10.09.2005	  	restructure code to support 			}
{				different hardware 													}
{	12.10.2005		started code to read 								}
{				configuaration file													}
{				set TAB STops to 4 started to 							}
{				beauitify code															}
{                                                   }
{	25.10.2005 		run_sps is fully configurable,			}
{				hardware may be mixed												}
{	12.04.2006		added driver for joystick 					}
{				analog processing works ! 									}
{	03.02.2008		introduced PhysMach Unit for Hardware access 	}

{ virtual machine version 1.1												}
{ physical machine version PhysMach									}

uses
	dos,crt;

	{ global variables and constant definitions of the sps project 	}
	{ all global values should be defined here, if you see any	}
	{ ugly constant values in the code, please replace them with	}
	{ symbolic names and define the names in this file		}
	{ and please remember: the project is running since the early	}
	{ 90's !It was first used in Dezember 1989			}
	{ there is code of all my Pascal programming states		}
	{ included beginner to "rebeginner" after years of no single	}
	{ line written in pascal! thanks for not blaming me ;)		}

	{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>	}
	{ distributed under the GNU General Public License V2 or any later}
	type
		 			string3 =string[3];
		      string12=string[12];
		      string15 =string[15];
		      string80=string[80];
					DeviceTypeArray		= array[1..16] of char;


	const
	      	debug       = false;
	      	awl_max     = 2000;
	      	anweismax   = 37;
	      	minScreenX  = 80;
	      	minScreenY  = 25;
	      	{ include the SPS Version and build date }
	      	version     = 'emb_SPS_0.1 ';
	      	datum       = '30.04.2019';
	       { attention, it is important to keep the order of	}
			   { the sps commands, because the bytecode interpreter }
			   { relies on the order! (the editor formatter too!)	}
			   { write new commands without blanks, they will be 	}
			   { added where needed	     							}
			   { only append new commands !!						}
			   { check procedure formatiere in edit.pas and the 	}
			   { interpreter in awl_interpreter.pas	and run_sps.pas	}
	      	anweis      : array [1..anweismax] of string3 =(
	                        'UN(','ON(','UN','ON','U(','O(','=N','JI','TE',
	                        'ZR','EN','U','O',')','=','S','R','J','K','NOP',
													'EQ','LT','GT','$','PE','JP','SP','SPB','JC','EP',
													'AN(','AN','A(','A','DEC','INC','LDD');

					p_up = #72;
					p_dw = #80;
					p_le = #75;
					p_re = #77;
					esc  = #27;
					enter= #13;
					tab  = #9;

					Platform = ' embedded C ';
					ProgNamVer  =' RUN_SPS  for '+Platform+version+' '+datum+' ';
					Copyright   =' (c)  1989 - 2017 by Hartmut Eilers ';

					io_max			= 128;
					group_max		= round(io_max/8);
					marker_max		= 255;
					akku_max		= 16;
					cnt_max			= 16;
					tim_max			= 16;
					analog_max		= 64;
					DeviceTypeMax		= 16;


	var

	{ these variables are used by sps.pas and run_sps.pas }
	     operand           : array[1..awl_max] of char;
	     par               : array[1..awl_max] of longint;
	     operation         : array[1..awl_max] of string3;
	     anweisung	       : array[1..anweismax] of string3;
	     znr               : array[1..awl_max] of integer;
	     comment           : array[1..awl_max] of string;
	     ConfFile					 : string;


			 { these are the global vars and constants needed to run an awl }

			 { copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
			 { distributed under the GNU General Public License V2 or any later	}


			 	extern			: boolean;
			 	escape  		: boolean;
			 	watchdog		: word;
			 	time1,time2	: real;
			 	runs,TimeRuns,
			 	std,min,sec,
			 	ms,usec			: word;

				i						: integer;

				{ vars from PhysMach }
				marker 							: array[1..marker_max]   of boolean;
				eingang,ausgang			: array[1..io_max]	 of boolean;
				zust								: array[1..io_max]	 of boolean;
				lastakku						: array[1..akku_max]     of boolean;
				zahler							: array[1..cnt_max]	 of boolean;
				timer								: array[1..tim_max]	 of boolean;
				t										: array[1..tim_max]	 of word;
				z										: array[1..cnt_max]	 of word;
				analog_in						: array[1..analog_max]   of integer;

				HWPlatform					: string;

				durchlaufeProSec,
				durchlauf,
				durchlauf100				: word;

				i_address,
				o_address,
				c_address,
				a_address						: array [1..group_max] of LongInt;
				i_devicetype,
				o_devicetype,
				c_devicetype,
				a_devicetype,
				u_devicetype				: array [1..analog_max] of char;
				DeviceList					: DeviceTypeArray;
				CfgLine							: String;
				initstring					: string;

				{ this is the interpreter for sps files }
				{ interpreter version 1.2}

				{ copyright (C) 2017 by Hartmut Eilers <hartmut@eilers.net>			}
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
					if (operation[z+1]=anweisung[1]) or				{ UN(	}
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
					timestring	 			: string;


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
						'J':	if debug then writeln('analog input');
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
						'J':    analog_in[par[k]]:=analog_akku;
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
						writeln('exec not implemented on embedded Hardware! ');
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


				procedure decrement;
				begin
				end;


				procedure increment;
				begin
				end;


				procedure loadconst;
				begin
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
						until ((aktuell=anweis) or (token>anweismax));
						case token of
							1..6:	verkn;										{ UN( .. O(	}
							7:	zuweisen;				    				{ =      	}
							8:	cond_jump;				    			{ JI 		}
							9:	set_timer;				    			{ TE 		}
							10:	set_counter;								{ ZR 		}
							11:	;					        					{ EN   		}
							12,13:	verkn;									{ U O		}
							14:	klammer_zu;				    			{ ) 		}
							15:	zuweisen;				    				{ =N 		}
							16:	setzen;					    				{ S 		}
							17:	rucksetzen;				    			{ R 		}
							18:	jump;					    					{ J 		}
							19:	;					        					{ K 		}
							20:	;					        					{ NOP 		}
							21:	analog_equal;		     				{ EQ 		}
							22:	analog_less;    	    			{ LT 		}
							23:	analog_great;        				{ GT 		}
							24:	execute;                		{ $		    }
							25:	;					        					{ PE		}
							26,27:	jump;										{ JP,SP		}
							28,29:	cond_jump;							{ JC,SPB	}
							30:	;					        					{ EP		}
							31:	verkn;					    				{ AN(		}
							32:	verkn;					    				{ AN		}
							33:	verkn;					    				{ A(		}
							34:	verkn;					    				{ A		    }
							35: decrement;                  { DEC       }
							36: increment;                  { INC       }
							37: loadconst;                  { LDD       }
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




procedure sps_laden;

var
	f				:text;
	zeile		   		:string[48];
	i,code  	   		:integer;
{ code is currently a dummy, may be used for error detection }
	name		   		:string;

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
	for i := 1 to anweismax do begin
		anweisung[i]:=anweis[i];
		if (length(anweis[i]) < 3) then begin
			repeat
				anweisung[i]:=concat(anweisung[i],' ');
		 	until (length(anweisung[i]) = 3);
		end;
	end;

	close (F);
	doserror:=0;
end;                               {**** ENDE SPS_LADEN **** }


procedure run_awl;
{interrupt; }

begin                             				{ hp run_awl                      }
	PhysMachReadDigital;                   	{ INPUTS lesen                    }
	PhysMachReadAnalog;											{ analoge inputs lesen			  }
	PhysMachCounter;                     		{ TIMER / ZAHLER aktualisieren    }
	PhysMachTimer;
	interpret;                      				{ einen AWLdurchlauf abarbeiten   }
	PhysMachWriteDigital;										{ OUTPUTS ausgeben                }
	PhysMachWriteAnalog;
	toggle_internal_clock(marker[62],marker[63],marker[64]);{ interne TAKTE M62-M64 toggeln   }
	if watchdog > awl_max then escape:=true;
	RPMs;
	if (debug) then begin
		delay (1000);
    		writeln ('###########################################################################');
	end;
end;                               { **** ENDE RUN_AWL ****          }


begin                              { SPS_SIMULATION           }
	if paramcount < 2 then ConfFile:='.run_sps.cfg'
	else ConfFile:= paramstr(2);
	PhysMachInit;
	PhysMachloadCfg(ConfFile);
	write(ProgNamVer);
	writeln(copyright);
	writeln('detected Hardware: ',HWPlatform);
	sps_laden;
	if (debug) then begin
		writeln (' Configured input ports :');
		for i:=1 to group_max do writeln(i:3,i_address[i]:6,i_devicetype[i]:6);
		writeln (' Configured output ports :');
		for i:=1 to group_max do writeln(i:3,o_address[i]:6,o_devicetype[i]:6);
		writeln (' Configured counter ports :');
		for i:=1 to group_max do writeln(i:3,c_address[i]:6,c_devicetype[i]:6);
	end;
	TimeRuns:=150;

	writeln('AWL gestartet, press any key to stop');
	repeat
		run_awl;
		delay(15);
	until keypressed or escape;
	if escape then writeln('Error: Watchdog error...!');

	PhysMachEnd;
end.                               { **** SPS_SIMULATION **** }
