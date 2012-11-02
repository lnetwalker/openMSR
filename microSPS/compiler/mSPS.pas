program mSPS;

uses StringCut;

{ this is the microSPS compiler which compiles OpenSPS 	}
{ instruction lists into a hex data file for the atmel 	}
{ microcontrolers ATtiny2313 and ATmega644			}
{ (c) 2011 by H.Eilers <hartmut@eilers.net			}
{ License: see file License for Details			}

type  string3 =string[3];

const
    debug	= false;
    
    version     = {$I %MSPSVERSION% };
    datum       = {$I %DATE%};

    awl_max     = 2000;		// the length of the AWL for SPS
    tinyAwl_max = 40;			// the number of lines possible in the 2313
    
    tIOmax	= 8;			// max of 8 In/outputs are allowed for 2313
    tMmax	= 16;			// max of 16 markers is allowed for 2313
    
    SPSmax	= 34;			// the number of commands implemented in the sps in general
    mSPSmax	= 20;			// the number of commands implemented in the mSPS
    tSPSmax	= 12;			// the number of command implemented in the 2313
    
    epsize	= 128;
    
    projectURL	= 'http://www.openmsr.org/index.php?mSPS';
    
    tinySPSCMD	: array [1..tSPSmax] of byte = (1,2,5,6,10,11,12,13,14,15,16,20);
    {
	das ist die liste der implementierten mSPS commands für ATtiny2313
	es sind die token der mSPS wird benutzt zum test ob ein cmd implementiert ist 
    }
	
    mSPSanweis	: array [1..mSPSmax] of byte =(13,4,6,2,12,3,5,1,14,15,7,16,17,18,8,19,9,10,20,11);

    {
      zur Referenz: mSPSanweis ist die liste der implementierten cmds, der Index zeigt auf das
      jeweilige commando der microSPS, der Wert ist der Index von SPSanweis
      
      Liste der mSPS commands    
	'O ','ON','O(','ON(','U','UN','U(','UN(',')','=','=N','S','R','J','JI','K','TE','ZR','NOP','EN'

      diese Liste wird beim crossassemblieren benutzt um die SPS commandotoken in
      mSPS commando token zu übersetzen.
    }
    
    SPSanweis      : array [1..SPSmax] of string3 =(
	'UN(','ON(','UN','ON','U(','O(','=N','JI','TE',
	'ZR','EN','U','O',')','=','S','R','J','K','NOP',
	'EQ','LT','GT','$','PE','JP','SP','SPB','JC','EP',
	'AN(','AN','A(','A');
    
var
    operand           	: array[1..awl_max] of string;
    par               	: array[1..awl_max] of longint;
    operation         	: array[1..awl_max] of string3;
    k,j,x		: word;
    CPU			: string;
    opertok		: byte;
    operpoint		: byte;
    eeprom		: array[1..epsize] of byte;
    checksum		: word;
    
    

function dez2hex(number : byte):string;
{
    Ausgabe einer dezimalzahl als hex string
    wird beim erzeugen des IntelHexFiles fürs EEPROM benutzt.
}
const
    s: array [0..15] of char =
	('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
var
    y		: byte;
    shex	: string;
    
begin
    shex:='';
    y:=(number mod 16);
    number:=trunc(int(number/16));
    shex:=s[number]+s[y];
    dez2hex:=shex;
end;


procedure loadSPS(name:string);
var	f		: text;
	zeile		: string;
	SplitLine	: StringArray;
	zn		: word;
	
begin
    {$I-}
    assign(f,name);
    reset(f);
    {$I+}
    if IOResult<>0 then begin
	writeln('Error opening awl ',name);
	halt(1);
    end;
    while not(eof(f)) do begin
	{$I-}
	readln(f,zeile);
	{$I+}
	if IOResult <> 0 then begin
	    writeln('error reading line ',zn);
	    halt(1);
	end;  
	zeile:=RemoveDoubleChars(zeile,' ');
	if zeile[1]=' ' then zeile:=copy(zeile,2,length(zeile));
	if debug then writeln('read: ',zeile);
	SplitLine:=StringSplit(zeile,' ');
	val(SplitLine[1],zn);
	operation[zn]:=SplitLine[2];
	operand[zn]:=SplitLine[3];
	val(SplitLine[4],par[zn]);
	if debug then writeln(zn,' ',operation[zn],' ',operand[zn],' ',par[zn]);
    end;
end;


function normalizeCommand( cmd : byte  ): byte;
{
    diese funktion führt die alternativen cmds auf ihre standard cmds zurück
}

begin
	case cmd of
	    25,30	: normalizeCommand:=11;	{ PE,EP = EN }
	    28,29	: normalizeCommand:=8;		{ SPB,JC = JI }
	    26,27	: normalizeCommand:=18;	{ JP,SP = J }
	    34		: normalizeCommand:=12;	{ A = U }
	    33		: normalizeCommand:=5;		{ A( = U( }
	    32		: normalizeCommand:=3;		{ AN = UN }
	    31		: normalizeCommand:=1;		{ AN( = UN( }
	else
	    normalizeCommand:=cmd;	{ keine alternative daher standard zurückgeben }
	end;
end;

function tokenizeCmd( cmd : String3 ):byte;
{
    wandelt ein commando in den entsprechenden token um 
}

var
    i		: byte;
    match	: boolean;
    
begin
    i:=0;
    match:=false;
    repeat	{ loop over the cmdlist }
	inc(i);
	if ( cmd = SPSanweis[i] ) then match:=true; { i found a command }
    until match or ( i = SPSmax );	{ end the loop }
    if debug then writeln('tokenizeCmd: cmd=',cmd,' token=',i);
    { return token or 0 for error }
    if match then tokenizeCmd:=i
    else tokenizeCmd:=0;
end;


begin
    // init the eeprom
    for k:=1 to epsize do eeprom[k]:=255;
    // start with things
    writeln('mSPS compiler Version ',version, ' build ',datum);
    writeln('(c) 2011 by Hartmut Eilers <hartmut@eilers.net>');
    writeln('see ',projectURL,' for help');
    if (paramcount <> 2 ) then begin
	writeln('please provide the IL and cpu as parameter!');
	writeln('e.g. mSPS ampel.sps 2313');
	halt(1);
    end;
    CPU:=paramstr(2);
    loadSPS(paramstr(1));
    // now crossassemble the AWL
    k:=0;
    repeat
	inc(k);
	// first check the length
	if ( CPU = '2313' ) then 
	    if k > tinyAwl_max then begin
		writeln('IL too long! max=',tinyAwl_max);
		halt(1);
	    end;
	    
	// normalize and tokenize the operation
        opertok:=normalizeCommand(tokenizeCmd(operation[k]));
        if ( opertok = 0 ) then begin
	    writeln('Unknown command in line ',k);
	    writeln('reading: ',operation[k],' ',operand[k],' ',par[k]);
	    halt(1);
	end;
	// crossassemble the operation
	j:=0;
	repeat
	    inc(j);
	until (opertok=mSPSanweis[j]) or (j=mSPSmax);
	if (opertok=mSPSanweis[j]) then
	    opertok:=j
	else begin
	    writeln('Unimplemented command in line ',k);
	    writeln('reading: ',operation[k],' ',operand[k],' ',par[k]);
	    halt(1);
	end;
	// check weather operation is implemented for the choosen CPU
	j:=0;
	repeat
	    inc(j);
	until (opertok=tinySPSCMD[j]) or (j=tSPSmax);
	if (opertok<>tinySPSCMD[j]) then begin
	    writeln(' Operation not implemented for choosen CPU in line ',k);
	    writeln('reading: ',operation[k],' ',operand[k],' ',par[k]);
	    halt(1);
	end; 
	// now the operation is finished, check for the rest
	if ( operand[k] = 'T' ) or ( operand[k] ='Z' ) then begin
	    if ( CPU = '2313' ) then begin
		// only Input/Outputs and Markers are allowed
		writeln('Timers/Counters not implemented for CPU');
		halt(1);
	    end;
	end
	else if ( operand[k]='E' ) or ( operand[k]='A' ) then begin
		if (par[k] > tIOmax) then begin
		    writeln('only ',tIOmax,' in/outputs are allowed');
		    writeln('reading: ',operation[k],' ',operand[k],' ',par[k]);
		    halt(1);
		end;
		if (operand[k]='E') then
		    operpoint:=par[k]		// no offset for inputs
		else
		    operpoint:=par[k] + 8;	// outputs have an offset of 8
	    end
	    else begin
		// must be a marker
		if (par[k] > tMmax) then begin
		    writeln('only ',tMmax,' markers are allowed');
		    writeln('reading: ',operation[k],' ',operand[k],' ',par[k]);
		    halt(1);
		end;
		operpoint:=par[k]+32		// markers have an offset of 32
	    end;
	// store the assembled cmd and parameter in the eeprom array
	eeprom[k]:=opertok;
	eeprom[k+tinyAwl_max]:=operpoint;
    until (opertok=20);		// that's the 'EN' operation in mSPS!
    
    // dump the eeprom contents in Intel hex format
    // see: http://en.wikipedia.org/wiki/Intel_HEX
    for k:=0 to trunc((epsize-1)/16) do begin
	write(':1000',dez2hex(k*16),'00');		
	checksum:=$10+k*16;
	for x:= 0 to 15 do begin
	    checksum:=checksum+eeprom[k*16+x+1];
	    write (dez2hex(eeprom[k*16+x+1]));
	end; 
	checksum:=256-(checksum and 255);

	writeln(dez2hex(checksum));
    end;
    writeln(':00000001FF');
end.

