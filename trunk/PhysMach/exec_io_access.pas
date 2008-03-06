Unit exec_io_access;
{$MODE OBJFPC}{$H+}
{ diese Unit stellt Funktionen zum I/O Access auf ein externes	}
{ Programm zur Verfügung					}
{ Attention: its just a raw hack - not finished			}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}

INTERFACE

function exec_read_ports(io_port:longint):byte;
function exec_write_ports(io_port:longint;byte_value:byte):byte;
function exec_hwinit(initdata:string):boolean;
function exec_read_analog(io_port:longint):Cardinal;

implementation

uses baseunix,unix;

function RunCommand(var j: integer; Command: string):String;
{ execute external command and capture output of command }
var
	file1	: text;
	s,t	: ansistring;
	n,err	: longint;

begin
	j:=0;
	n:=popen(file1, Command, 'r');
	
	if n=-1 then begin
		err:=errno;
		writeln(n,' ',err);
	end;
	t:='';
	while not eof(file1) do begin
		Readln(file1,s);
		t:=t+s+Chr(10);
		inc(j);
	end;
	pclose(file1);
	RunCommand := t;
end;

const
	debug=false;

var
	RunCmd	: array[1..4] of string;
	cnt	: byte;
	power	: array [1..8] of byte =(1,2,4,8,16,32,64,128);



function BinToInt(binval:string):Integer;
var
	i,k,wert	: Integer;
begin
	i:=1;
	k:=1;
	wert:=0;
	while i <= length(binval) do begin				{ wert errechnen }

		if debug then writeln('exec_io_access exec_read_ports Loop: char_pointer=',i,' BinCalcPointer=',k,' Value=',wert);
 
		case binval[i] of
			'1' : 	begin			{ 1 speichern }
					wert:=wert+power[k];
					inc(k);
				end;
			'0' :	inc(k);			{ 0 merken }
			' ' :	if debug then writeln('blank detected ');	{ blanks ignorieren }
		else							{ fehlerhafter return wert }
			if debug then writeln('exec_io_access ERROR: wrong return value ',binval);
		end;
		inc(i);
	end;
	BinToInt:=wert;
end;



function exec_read_ports(io_port:longint):byte;
{ execute the program, the output must be in the form 'n n n n n n n n' with n=[1|0] }
var
	ReturnValue		: string;
	dev			: byte;
	dummy			: LongInt;

begin
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);	{ will be ignored, currently just one port }

	ReturnValue:=RunCommand(dummy,RunCmd[dev]);	{ externes Programm ausführen }
	exec_read_ports:=BinToInt(ReturnValue);
end;




function exec_write_ports(io_port:longint;byte_value:byte):byte;	
begin

end;



function exec_read_analog(io_port:longint):Cardinal;
var
	ReturnValue,ReturnString	: string;
	ReturnArray			: array[1..8] of string;
	ReturnValueLength,i,k		: integer;
	wert				: Cardinal;
	dev				: byte;

begin
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);

	if debug then writeln('exec_io_access RunCmd[',dev,']=',RunCmd[dev]);
	ReturnValue:=RunCommand(ReturnValueLength,RunCmd[dev]);	{ externes Programm ausführen }
	ReturnValueLength:=length(ReturnValue);
	if debug then writeln('exec_io_access read device port: ',io_port,' ReturnValue : ',ReturnValue,' length ',ReturnValueLength); 
	i:=1;			{ marker for positions }
	k:=1;			{ counter for the values }
	wert:=0;
	repeat			{ übergehe alle werte bis zum gewünschten }
		i:=pos(' ',ReturnValue);
		if (i=0) then i:=Length(ReturnValue);
		ReturnArray[k]:=copy(ReturnValue,1,i-1);
		ReturnValue:=copy(ReturnValue,i+1,length(ReturnValue)-i);
		if debug then writeln('ReturnArray[',k,']=',ReturnArray[k]);
		inc(k);
	until (k>io_port);// or (i>ReturnValueLength);
	val(ReturnArray[io_port],wert);
	exec_read_analog:=wert;

end;




function exec_hwinit(initdata:string):boolean;
var
	i		: integer;
begin
	inc(cnt);
	i:=1;
	while i <= length(initdata) do begin
		if debug then write(initdata[i]);
		if (initdata[i]=':') then initdata[i]:=' ';
		inc(i);
	end;
	RunCmd[cnt]:=initdata;
end;


begin
	cnt:=0;
end.
