program runsps;
{$M 16000,0,0}                   { 16000 Bytes STACK , kein HEAP }

{ porting to linux startet at 27.05.99 				}
{ don't blame me for "bad" code						}
{ some of the code inside is from my earliest steps }
{ in pascal and some of my least steps after years	}
{ where I coded not	 one simple line in pascal :) 	}
{ If you have improvements please contact me at 	}
{ hartmut@eilers.net								}
{ all code is copyright by Hartmut Eilers					}
{ the code is distributed under the GNU 					}
{ general public license							}
{ history 									}
{	27.05.1999    		start of Linux Port				}
{ 	03.10.2000	  	start of Version 1.7.1				}
{	11.10.2000	  	installed fpc 1.0 				}
{	11.10.2000	  	start analog processing 			}
{				EQ,LT,GT					}
{	10.09.2005	  	restructure code to support 			}
{				different hardware 				}
{	12.10.2005		started code to read 				}
{				configuaration file				}
{				set TAB STops to 4 started to 			}
{				beauitify code					}
{                                                   				}
{	25.10.2005 		run_sps is fully configurable,			}
{				hardware may be mixed				}
{	12.04.2006		added driver for joystick 			}
{				analog processing works ! 			}
{	03.02.2008		introduced PhysMach Unit for Hardware access 	}

{ virtual machine version 1.1							}
{ physical machine version PhysMach						}

{ $Id$ }

uses
{$ifdef LINUX }
	unix,linux,SysUtils,BaseUnix,
{$endif}
	dos,crt,PhysMach,CommonHelper;

{$i ./sps.h}
{$i ./run_awl.h }
{$i ./awl_interpreter.pas}

const
{$ifdef LINUX}
	Platform = ' Linux ';
{$else}
{$ifdef win32}
	Platform = ' Windows ';
{$else}
	Platform = ' Unknown ';
{$endif}
{$endif}
	ProgNamVer  =' RUN_SPS  for'+Platform+version+' '+datum+' ';
	Copyright   =' (c)  1989 - 2019 by Hartmut Eilers ';

var
	i					: integer;
	paramcnt 	: integer;
	Configfile: String;
	name		  : String;
	Daemonize	: Boolean;

{$ifdef LINUX}
	{ vars for daemonizing }
	bHup,
	bTerm : boolean;
	aOld,
	aTerm,
	aHup : pSigActionRec;
	ps1  : psigset;
	sSet : cardinal;
	pid  : pid_t;
	secs : longint;
	zerosigs : sigset_t;


{ handle SIGHUP & SIGTERM }
procedure DoSig(sig : longint);cdecl;
begin
   case sig of
      SIGHUP : bHup := true;
      SIGTERM : bTerm := true;
   end;
end;
{$endif}

procedure get_file_name;           { namen des awl-files einlesen   }

begin
	write (' Filename : ');
	readln (name);
	if pos('.',name)=0 then name:=name+'.sps';
end;                               { **** ENDE GET_FILE_NAME **** }


procedure sps_laden(name:string);

var
	f				:text;
	zeile		   		:string[48];
	i,code  	   		:integer;
{ code is currently a dummy, may be used for error detection }

begin
	i:=0;
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

	begin 																	{ hp run_awl                      }
	PhysMachReadDigital;										{ INPUTS lesen                    }
	PhysMachReadAnalog;											{ analoge inputs lesen			  		}
	PhysMachCounter;												{ TIMER / ZAHLER aktualisieren    }
	PhysMachTimer;
	interpret;															{ einen AWLdurchlauf abarbeiten   }
	PhysMachWriteDigital;										{ OUTPUTS ausgeben                }
	PhysMachWriteAnalog;
	toggle_internal_clock(marker[62],marker[63],marker[64]);{ interne TAKTE M62-M64 toggeln   }
	if watchdog > awl_max then escape:=true;
	RPMs;
	if (debug) then begin
		delay (1000);
    		debugLOG ('run_sps',2,'###########################################################################');
	end;
end;                               { **** ENDE RUN_AWL ****          }


begin                              { SPS_SIMULATION           }
	ConfFile:='';
	Daemonize:=false;
	debug:=false;
	if paramcount=0 then get_file_name  { keine Aufrufparameter }
	else begin
		for paramcnt:=1 to paramcount do begin
			if (paramstr(paramcnt)='-c') then
				ConfFile:= paramstr(paramcnt+1);
			if (paramstr(paramcnt)='-f') then
				name:= paramstr(paramcnt+1);
			if (paramstr(paramcnt)='-b') then
				Daemonize:=true;
			if (paramstr(paramcnt)='-d') then
				debug:=true;
		end;
		if pos('.',name)=0 then name:=name+'.sps';
	end;
	if (ConfFile = '') then
		ConfFile:='.run_sps.cfg';
	if ( debug ) then begin
		if ( debugFilename('run_sps.dbg') <> 0 ) then begin
			writeln('error open debugfile run_sps.dbg');
			halt(1);
		end;
		DebugResult:=PhysMachDebug(true);
	end;
	PhysMachInit;
	PhysMachloadCfg(ConfFile);
	write(ProgNamVer);
	writeln(copyright);
	writeln('detected Hardware: ',HWPlatform);
	sps_laden(name);
	if (debug) then begin
	 	//for i:=1 to awl_max do writeln (i:3,operation[i]:5, operand[i]:4,par[i]:4,comment[i]:22);
		//writeln (' Configured input ports :');
		//for i:=1 to group_max do writeln(i:3,i_address[i]:6,i_devicetype[i]:6);
		//writeln (' Configured output ports :');
		//for i:=1 to group_max do writeln(i:3,o_address[i]:6,o_devicetype[i]:6);
		//writeln (' Configured counter ports :');
		//for i:=1 to group_max do writeln(i:3,c_address[i]:6,c_devicetype[i]:6);
	end;
	TimeRuns:=150;

	{$ifdef LINUX}
	if (Daemonize) then begin
		writeln('AWL wird im Hintergrund gestartet, send SIGTERM to quit ...');

		{ set a very nice priority }
		//nice(20);

		{ signal handling is done here, also the program goes in background 	}

		fpsigemptyset(zerosigs);

		{ set global daemon booleans }
		bHup := true; { to open log file }
		bTerm := false;

		{ block all signals except -HUP & -TERM }
		sSet := $ffffbffe;
		ps1 := @sSet;
		fpsigprocmask(sig_block,ps1,nil);

		{ setup the signal handlers }
		new(aOld);
		new(aHup);
		new(aTerm);
		aTerm^.sa_handler{.sh} := SigactionHandler(@DoSig);

		aTerm^.sa_mask := zerosigs;
		aTerm^.sa_flags := 0;
		{$ifndef BSD}                {Linux'ism}
	  	aTerm^.sa_restorer := nil;
		{$endif}
		aHup^.sa_handler := SigactionHandler(@DoSig);
		aHup^.sa_mask := zerosigs;
		aHup^.sa_flags := 0;
		{$ifndef BSD}                {Linux'ism}
	  	aHup^.sa_restorer := nil;
		{$endif}
		fpSigAction(SIGTERM,aTerm,aOld);
		fpSigAction(SIGHUP,aHup,aOld);

		{ daemonize }
		pid := fpFork;
		Case pid of
	    0 : Begin { we are in the child }
	      Close(input);  { close standard in }
	      Close(output); { close standard out }
	      Assign(output,'/dev/null');
	      ReWrite(output);
	      Close(stderr); { close standard error }
	      Assign(stderr,'/dev/null');
	      ReWrite(stderr);
	    End;
	    -1 : secs := 0;     { forking error, so run as non-daemon }
	    Else Halt;          { successful fork, so parent dies }
		End;

		{ begin processing loop }
		Repeat
			If bHup Then Begin
				{ do nothing at the moment }
				bHup := false;
			End;
			{----------------------}
			{ Do your daemon stuff }
			run_awl;
			{----------------------}
			If bTerm Then
				BREAK
			Else
				{ wait a while }
				delay(5);
		Until bTerm;

	end
	else begin
	{$endif}
		writeln('AWL gestartet, press any key to stop');
		repeat
			run_awl;
			delay(25);
		until keypressed or escape;
		if escape then begin
			writeln('Error: Watchdog error...!');
			halt;
		end;
	{$ifdef LINUX}
	end;
	{$endif}
	PhysMachEnd;
end.                               { **** SPS_SIMULATION **** }
