program FunkIO;

{ This program uses Funksteckdosen connected to any of 	}
{ the hardware supported by PhysMach				}
{ Attention: its just a raw hack - not finished		}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}
{ (c) 2012 by Hartmut Eilers <hartmut@eilers.net>		}

{ $Id:$ }

uses PhysMach, crt;

const
	power		: array [0..7] of byte =(1,2,4,8,16,32,64,128);
	PORTBITS	: array [0..3] of byte =(254,253,251,247);
				// A=1111 1110; B=1111 1101; C=1111 1011; D=1111 0111
	SWITCH_ON=239;		// 1110 1111
	SWITCH_OFF=223;	// 1101 1111
	NoOfOutputs=4;		// how many outputs are used
	AllBitsSet=255;	// 1111 1111

      	version     ={$I %SPSVERSION% };
      	datum       ={$I %DATE%};

{$ifdef LINUX}
	Platform = 'Linux ';
{$else}
{$ifdef win32}
	Platform = 'Windows ';
{$else}
	Platform = 'Unknown ';
{$endif}
{$endif}	
	ProgNamVer  =' FunkIO  for '+Platform+version+' '+datum+' ';
	Copyright   =' (c) 2012 by Hartmut Eilers ';

var	XmitTime	: word;
	OldByteValue	: byte;
	ConfFile	: string;
	result		: byte;


function funk_write():byte;	
var 
	i,j,k,l,OutVal	: byte;
	Input,
	OldInput	: byte;		// detecting changes in the inputs
	
begin
    Input:=0;				// check for changes on the input lines
    for l:=NoOfOutputs-1 downto 0 do	// to check weather there are changes at the inputs 1 to 4
	if eingang[l] then
	    Input:= Input + power[l]; // generate a byte value of eingang 1-4 and compare it with
    if Input <> OldInput then begin	// value from last run, transmit only when changes occure
	for l:=1 to 2 do begin		// transmit the signals twice
		for i:=NoOfOutputs-1 downto 0 do begin			// only the inputs 
			OutVal:=AllBitsSet;					// always start with all high as dummy
			if eingang[i] then
				OutVal:=PORTBITS[i] and SWITCH_ON		// set the bit and the on-bit  to lower
			else
				OutVal:=PORTBITS[i] and SWITCH_OFF;		// set the bit and the off-bit to lower

			for j:=1 to 2 do begin		// zuerst die Signale schicken, danach 1111 1111
				for k:=7 downto 0 do begin			// bits auf ausgänge verteilen
					if OutVal >= power[i] then begin	// the bit is high
						OutVal:=OutVal-power[i];
						ausgang[k]:=true;
					end
					else					// the bit is low
						ausgang[k]:=false;
				end;
				PhysMachWriteDigital;				// write the values out
				delay(XmitTime);				// wait some time
				OutVal:=AllBitsSet;				// load 1111 1111 for second run
			end;
		end;
	end;
	OldInput:=Input;		// save this value for next run
	funk_write:=AllBitsSet;	// signal transmission by return 255
    end
    else
	funk_write:=0;			// nothing transmitted return 0
end;

begin
	XmitTime:=500;			// signal transmit time
	ConfFile:='funkio.cfg';	// read the config
	PhysMachInit;			// init
	PhysMachloadCfg(ConfFile);	// load config
	write(ProgNamVer);
	writeln(copyright);
	writeln('detected Hardware: ',HWPlatform);
	repeat
	{ die Inputs 1 - 4 steuern die Steckdosen A-D }
		PhysMachReadDigital;	// read the inputs
		result := funk_write();// send the signals
	until keypressed;
	PhysMachEnd();			// shutdown everything
end.
