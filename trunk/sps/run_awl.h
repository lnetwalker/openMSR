{ these are the global vars and constants needed to run an awl }

const	
	marker_max		= 255;
	io_max			= 128;
	cnt_max			= 16;
	tim_max			= 16;
	akku_max		= 16;
	analog_max		= 16;  	      
	power			: array [0..7] of byte =(1,2,4,8,16,32,64,128);
       

var
{$IFDEF SPS}       
	extern,grafik,
	hard_copy		: boolean;
	std,min,sec,
	ms,usec			: word;
	tasten,
	maxaus			: byte;
	ein_alt,aus_alt,
	e,a				: array[1..io_max] of boolean;
	zeit			: string[5];
	time1			: real;
	runs,TimeRuns,maxTimeRuns,
	durchlaufeProSec,
	durchlauf,
	durchlauf100,
	oldUmins		: LongInt;
	esc				: boolean;
	   
{$ENDIF}       
	x				: word;
	watchdog		: word;
	t				: array[1..tim_max]	 of word;	 
	z				: array[1..cnt_max]	 of word;	 
	marker 			: array[1..marker_max] of boolean;
	eingang,ausgang	: array[1..io_max]	 of boolean; 
	timer			: array[1..tim_max]	 of boolean;
	zahler			: array[1..cnt_max]	 of boolean;
	lastakku		: array[1..akku_max]   of boolean;
	analog_in		: array[1..analog_max] of word;	
	zust			: array[1..io_max]	 of boolean;
	time2			: real;
