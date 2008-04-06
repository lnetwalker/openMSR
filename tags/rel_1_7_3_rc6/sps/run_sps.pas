program runsps;
{$M 16000,0,0}                   { 16000 Bytes STACK , kein HEAP }

{ porting to linux startet at 27.05.99 				}
{ don't blame me for "bad" code						}
{ some of the code inside is from my earliest steps }
{ in pascal and some of my least steps after years	}
{ where I coded not	 one simple line in pascal :) 	}
{ If you have improvements please contact me at 	}
{ hartmut@eilers.net								}
{ all code is copyright by Hartmut Eilers			}
{ the code is distributed under the GNU 			}
{ general public license							}
{ history 											}
{	27.05.1999    	start of Linux Port				}
{ 	03.10.2000	  	start of Version 1.7.1			}
{	11.10.2000	  	installed fpc 1.0 				}
{	11.10.2000	  	start analog processing 		}
{					EQ,LT,GT						}
{	10.09.2005	  	restructure code to support 	}
{					different hardware 				}
{	12.10.2005		started code to read 			}
{					configuaration file				}
{					set TAB STops to 4 started to 	}
{					beauitify code					}
{                                                   }
{   25.10.2005      run_sps is fully configurable,	}
{					hardware may be mixed			}
{	12.04.2006		added driver for joystick 		}
{					analog processing works ! 		}

{ virtual machine version 1.1						}
{ physical machine version 1.3						}


{$define newio}
{ undef newio if you need a binary running without 	}
{ iowarrior library e.g. DIL/Net PC					}
{ for windows only newio works						} 
uses 	dos,crt,
{$ifdef LINUX }
		oldlinux,dil_io_access,lp_io_access,pio_io_access,joy_io_access,
{$endif}
{$ifdef newio }
		iowkit_io_access;
{$else}
		iow_io_access;
{$endif}



{$i ./sps.h}
{$i ./run_awl.h }
{$i ./awl_interpreter.pas}
{$i ./physical_machine.pas }

const 
{$ifdef LINUX}
	Platform = ' Linux ';
{$else}
	Platform = ' Windows ';
{$endif}	
    ProgNamVer  =' RUN_SPS  for'+Platform+version+' '+datum+' ';
    Copyright   ='      (c)  1989 - 2006 by Hartmut Eilers ';

var	i					: integer;



procedure sps_laden;

var	f              		:text;
	zeile		   		:string[48];
	i,code  	   		:integer;   { code is currently a dummy, may be used for error detection }
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

begin                              		{ hp run_awl                      }
    get_input;                      	{ INPUTS lesen                    }
	get_analog;							{ analoge inputs lesen			  }
    count_down;                     	{ TIMER / ZAHLER aktualisieren    }
	handle_timer;
    interpret;                      	{ einen AWLdurchlauf abarbeiten   }
    set_output;                     	{ OUTPUTS ausgeben                }
    toggle_internal_clock(marker[62],marker[63],marker[64]);{ interne TAKTE M62-M64 toggeln   }
	if watchdog > awl_max then esc:=true;
	RPMs;
    if (debug) then begin
    	delay (1000);
    	writeln ('###########################################################################');
    end;
end;                               { **** ENDE RUN_AWL ****          }


begin                              { SPS_SIMULATION           }
    { signal handling is needed here, also the program should go in background 	}
    { and at least there should be something done with the load			}
    { set a very nice priority }

{$ifdef LINUX}
    nice(20);
{$endif}
    init;
	extern:=true;
	load_cfg;
    write(ProgNamVer);
	writeln(HWPlatform);
    writeln(copyright);
    sps_laden;
    if (debug) then begin
	 	for i:=1 to awl_max do writeln (i:3,operation[i]:5, operand[i]:4,par[i]:4,comment[i]:22);
		writeln (' Configured input ports :');
		for i:=1 to group_max do writeln(i:3,i_address[i]:6,i_devicetype[i]:6);
		writeln (' Configured output ports :');
		for i:=1 to group_max do writeln(i:3,o_address[i]:6,o_devicetype[i]:6);
		writeln (' Configured counter ports :');
		for i:=1 to group_max do writeln(i:3,c_address[i]:6,c_devicetype[i]:6);
	end;	
    writeln('AWL gestartet');
    repeat
		run_awl
    until keypressed or esc;	
	if esc then writeln('Error: Watchdog error...!');	
end.                               { **** SPS_SIMULATION **** }