Unit http_io_access;

{ diese Unit stellt Funktionen zum I/O Access via				} 
{ HTTP protocol  zur Verf�gung  						}	
{ If you have improvements please contact me at 				}
{ hartmut@eilers.net								}
{ all code is copyright by Hartmut Eilers and released under			}
{ the GNU GPL see www.gnu.org for license details				}
{ History:									}
{		12.05.2007 first raw hack					}
{		21.05.2007 should work hack					}

{$undef ZAURUS}

INTERFACE


function http_read_ports(io_port:longint):byte;
function http_write_ports(io_port:longint;byte_value:byte):byte;
function http_read_analog(io_port:longint):LongInt;
function http_hwinit(initdata:string;DeviceNumber:byte):boolean;

implementation
uses SysUtils,CommonHelper,UnixUtils
{$ifndef ZAURUS}
,http
{$endif}
;

const	
	debug		= false;

var
	R_URL,W_URL		: array[1..4] of String;
	cnt			: byte;
	DeviceIndex		: byte;
	AppName			: string;

function http_read_ports(io_port:longint):byte;

var	
	TmpVal,TmpStrg	: string;
	dev		: byte;
	

begin
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	str(io_port,TmpStrg);
	TmpStrg:=R_URL[dev]+TmpStrg;
	{$ifndef ZAURUS}
	TmpVal:=deHTML(HttpGet1(TmpStrg,AppName));
	{$endif}
	if debug then writeln('http_read_ports(',TmpStrg,') returned ',TmpVal);
	http_read_ports:=BinToInt(TmpVal);
end;


	
function http_write_ports(io_port:longint;byte_value:byte):byte;	

var	
	TmpVal,TmpStrg,Params	: string;
	dev			: byte;

begin
	{ Params= Ioport,byte_value }
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	str(io_port,TmpStrg);
	Params:=TmpStrg+',';
	str(byte_value,TmpStrg);
	Params:=Params+TmpStrg;
	{$ifndef ZAURUS}
	TmpVal:=HttpGet1(W_URL[dev]+Params,AppName);
	{$endif}
	if debug then writeln('http_write_ports: URL=',W_URL[dev]+Params);
	val(TmpVal,http_write_ports);	
end;


function http_read_analog(io_port:longint):LongInt;
var
	ReturnValue,TmpStrg		: string;
	ReturnArray			: array[1..8] of string;
	ReturnValueLength,i,k		: integer;
	wert				: LongInt;
	dev				: byte;
	cmd				: AnsiString;
	idx				: byte;
	
begin
	if debug then writeln('http_io_access io_port=',io_port);
	{ extract the device number as key to the device handle }
	str(io_port,TmpStrg);
	val(copy(TmpStrg,1,1),dev);
	
	//dev:=round(io_port/10)-DeviceIndex;
	{ extract the port }
	val(copy(TmpStrg,2,1),io_port);
	//io_port:=round(frac(io_port/10)*10);

        val(copy(TmpStrg,3,1),idx);
	
	str(io_port,TmpStrg);
	TmpStrg:=R_URL[dev]+TmpStrg;
	{$ifndef ZAURUS}
	ReturnValue:=deHTML(HttpGet1(TmpStrg,AppName));
	{$endif}
	if debug then writeln('http_read_analog(',TmpStrg,') returned ',ReturnValue);
	ReturnValueLength:=length(ReturnValue);
	if debug then writeln('http_io_access read device port: ',io_port,' ReturnValue : ',ReturnValue,' length ',ReturnValueLength);


	i:=1;			{ marker for positions }
	k:=1;			{ counter for the values }
	wert:=0;
	repeat			{ übergehe alle werte bis zum gewünschten }
		// remove leadin blank
		if ReturnValue[1]=' ' then ReturnValue:=copy(ReturnValue,2,length(ReturnValue));
		i:=pos(' ',ReturnValue);
		if (i=0) then ReturnArray[k]:=copy(ReturnValue,1,length(ReturnValue))
		else          ReturnArray[k]:=copy(ReturnValue,1,i-1);
		ReturnValue:=copy(ReturnValue,i+1,length(ReturnValue));
		if debug then writeln('ReturnValue=',ReturnValue,' ReturnArray[',k,']=',ReturnArray[k]);
		inc(k);
	until (k>idx);// or (i>ReturnValueLength);
	val(ReturnArray[idx],wert);
	if debug then writeln(' ReturnArray[',idx,']=',ReturnArray[idx],' wert=',wert);
	http_read_analog:=wert;

end;


function http_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
	delim : integer;

begin
	DeviceIndex:=DeviceNumber;
	inc(cnt);
	delim:=pos('§',initdata);
	R_URL[cnt]:=copy(initdata,1,delim-1);
	initdata:=copy(initdata,delim+2,length(initdata)-2);
	delim:=pos('§',initdata);
	W_URL[cnt]:=copy(initdata,1,delim-1);
	if debug then writeln('http_hwinit: R_URL=',R_URL[cnt],' W_URL=',W_URL[cnt]);
end;


begin
	cnt:=0;
	AppName:=ExtractFileName(ParamStr(0));
end.
