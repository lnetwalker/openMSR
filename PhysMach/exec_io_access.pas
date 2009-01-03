Unit exec_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf ein externes	}
{ Programm zur Verfügung					}
{ Attention: its just a raw hack - not finished			}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}

INTERFACE

function exec_read_ports(io_port:longint):byte;
function exec_write_ports(io_port:longint;byte_value:byte):byte;
function exec_hwinit(initdata:string;DeviceNumber:byte):boolean;
function exec_read_analog(io_port:longint):integer;

implementation

uses CommonHelper;

const
	debug=true;

var
	RunCmd	: array[1..4] of AnsiString;
	cnt	: byte;



function exec_read_ports(io_port:longint):byte;
{ execute the program, the output must be in the form 'n n n n n n n n' with n=[1|0] }
var
	ReturnValue		: string;
	dev			: byte;

begin
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);	{ will be ignored, currently just one port }
	if debug then writeln('exec_read_ports->io_port=',io_port,' dev=',dev);
	ReturnValue:=RunCommand(RunCmd[dev]);	{ externes Programm ausführen }
	exec_read_ports:=BinToInt(ReturnValue);
end;




function exec_write_ports(io_port:longint;byte_value:byte):byte;	
begin

end;



function exec_read_analog(io_port:longint):integer;
var
	ReturnValue			: string;
	ReturnArray			: array[1..8] of string;
	ReturnValueLength,i,k		: integer;
	wert				: integer;
	dev				: byte;
	cmd				: AnsiString;

begin
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);

	if debug then writeln('exec_io_access RunCmd[',dev,']=',RunCmd[dev],'#');
	cmd:=copy(RunCmd[dev],1,length(RunCmd[dev]));
	//cmd:='digitemp.sh';
	ReturnValue:=RunCommand(cmd);	{ externes Programm ausführen }
	ReturnValueLength:=length(ReturnValue);
	if debug then writeln('exec_io_access read device port: ',io_port,' ReturnValue : ',ReturnValue,' length ',ReturnValueLength);
	i:=1;			{ marker for positions }
	k:=1;			{ counter for the values }
	wert:=0;
	repeat			{ übergehe alle werte bis zum gewünschten }
		i:=pos(' ',ReturnValue);
		if (i=0) then ReturnArray[k]:=copy(ReturnValue,1,length(ReturnValue))
		else          ReturnArray[k]:=copy(ReturnValue,1,i-1);
		ReturnValue:=copy(ReturnValue,i+1,length(ReturnValue));
		if debug then writeln('ReturnValue=',ReturnValue,' ReturnArray[',k,']=',ReturnArray[k]);
		inc(k);
	until (k>io_port);// or (i>ReturnValueLength);
	if ReturnArray[io_port][1]='-' then begin
		ReturnArray[io_port]:=copy(ReturnArray[io_port],2,length(ReturnArray[io_port]));
		if debug then writeln('ReturnArray[io_port]=',ReturnArray[io_port]);
		val (ReturnArray[io_port],wert);
		wert:=wert*-1;
		if debug then writeln('wert=',wert);
	end
	else
		val (ReturnArray[io_port],wert);

	exec_read_analog:=wert;

end;




function exec_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
	i		: integer;
begin
	inc(cnt);
	i:=1;
	while i <= length(initdata) do begin
		if debug then write(initdata[i]);
		if (initdata[i]=':') then initdata:=copy(initdata,1,length(initdata)-1);
		inc(i);
	end;
	RunCmd[cnt]:=initdata;
	if debug then writeln ('exec_hwinit RunCmd[',cnt,']=',RunCmd[cnt]);
end;


begin
	cnt:=0;
end.
