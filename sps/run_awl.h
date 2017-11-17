{ these are the global vars and constants needed to run an awl }

{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
{ distributed under the GNU General Public License V2 or any later	}

//const	
//	power			: array [0..7] of byte =(1,2,4,8,16,32,64,128);  // *

var
{$IFDEF SPS}
//	tasten,
//	maxaus			: byte;
//	ein_alt,aus_alt,
//	e,a			: array[1..io_max] of boolean;
//	zeit			: string[5];

{$ENDIF}
	extern			: boolean;
	escape  		: boolean;
//	x			: word;		// *
	watchdog		: word;
	time1,time2		: real;
	runs,TimeRuns,
	//maxTimeRuns,
	std,min,sec,
	ms,usec			: word;

