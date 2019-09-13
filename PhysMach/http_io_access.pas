Unit http_io_access;

{ diese Unit stellt Funktionen zum I/O Access via				}
{ HTTP protocol  zur Verf�gung  						}
{ If you have improvements please contact me at 				}
{ hartmut@eilers.net								}
{ all code is copyright by Hartmut Eilers and released under			}
{ the GNU GPL see www.gnu.org for license details				}
{ $Id$ }
{ History:									}
{		12.05.2007 first raw hack					}
{		21.05.2007 should work hack					}


INTERFACE


function http_read_ports(io_port:longint):byte;
function http_write_ports(io_port:longint;byte_value:byte):byte;
function http_read_analog(io_port:longint):LongInt;
function http_write_analog(io_port:longint;analog_value:integer):byte;
function http_hwinit(initdata:string;DeviceNumber:byte):boolean;
function http_close():boolean;

implementation
uses SysUtils,CommonHelper,classes,
{$ifdef Linux}
UnixUtil,
{$endif}
httpsend
;

const
	debug		= false;

var
	R_URL,W_URL		: array[1..4] of String;
	cnt			: byte;
	DeviceIndex		: byte;
	AppName			: string;


function http_close():boolean;
begin
    http_close:=true;
end;


function http_read_ports(io_port:longint):byte;

var
	TmpVal,TmpStrg	: string;
	dev		: byte;
	HTTP		: THTTPSend;
	response	: tstringlist;


begin
	HTTP := THTTPSend.Create;
	HTTP.UserAgent:='Mozilla/4.0 (' + AppName + ')';
	response := TStringList.create;
 	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	str(io_port,TmpStrg);
	TmpStrg:=R_URL[dev]+TmpStrg;
	if not HTTP.HTTPMethod('GET', TmpStrg) then begin
		writeln('ERROR');
		writeln(Http.Resultcode);
	end
	else begin
		response.loadfromstream(Http.Document);
		TmpVal:=deHTML(response.text);
	end;
	if debug then writeln('http_read_ports(',TmpStrg,') returned ',TmpVal);
	HTTP.Free;
	response.free;
	http_read_ports:=BinToInt(TmpVal);
end;



function http_write_ports(io_port:longint;byte_value:byte):byte;

var
	TmpVal,TmpStrg,Params	: string;
	dev			: byte;
	HTTP			: THTTPSend;
	response		: tstringlist;

begin
	HTTP := THTTPSend.Create;
	HTTP.UserAgent:='Mozilla/4.0 (' + AppName + ')';
	response := TStringList.create;
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	str(io_port,TmpStrg);
	Params:=TmpStrg+',';
	str(byte_value,TmpStrg);
	Params:=Params+TmpStrg;
	TmpStrg:= W_URL[dev]+Params;
	if not HTTP.HTTPMethod('GET', TmpStrg) then begin
		writeln('ERROR');
		writeln(Http.Resultcode);
	end
	else begin
		response.loadfromstream(Http.Document);
		TmpVal:=deHTML(response.text);
	end;
	if debug then writeln('http_write_ports: URL=',W_URL[dev]+Params);
	HTTP.Free;
	response.free;
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
	HTTP				: THTTPSend;
	response			: tstringlist;

begin
	HTTP := THTTPSend.Create;
	HTTP.UserAgent:='Mozilla/4.0 (' + AppName + ')';
	response := TStringList.create;
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
	if not HTTP.HTTPMethod('GET', TmpStrg) then begin
		writeln('ERROR');
		writeln(Http.Resultcode);
	end
	else begin
		response.loadfromstream(Http.Document);
		ReturnValue:=deHTML(response.text);
	end;
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
	HTTP.Free;
	response.free;
	http_read_analog:=wert;

end;

function http_write_analog(io_port:longint;analog_value:integer):byte;
	var
		ReturnValue,TmpStrg		: string;
		dev										: byte;
		HTTP									: THTTPSend;
		response							: tstringlist;
		AnalogURL							: String;

	begin
		HTTP := THTTPSend.Create;
		HTTP.UserAgent:='Mozilla/4.0 (' + AppName + ')';
		response := TStringList.create;
		if debug then writeln('http_io_access io_port=',io_port);
		{ extract the device number as key to the device handle }
		str(io_port,TmpStrg);
		val(copy(TmpStrg,1,1),dev);
		val(copy(TmpStrg,2,1),io_port);
		str(io_port,TmpStrg);
		AnalogURL:=R_URL[dev]+TmpStrg;

		str(analog_value,TmpStrg);
		AnalogURL:=AnalogURL+','+TmpStrg;

		if not HTTP.HTTPMethod('GET', AnalogURL) then begin
			writeln('ERROR');
			writeln(Http.Resultcode);
		end
		else begin
			response.loadfromstream(Http.Document);
			ReturnValue:=deHTML(response.text);
		end;
		http_write_analog:=1; // dummy return value
	end;


function http_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
	delim : integer;

begin
	DeviceIndex:=DeviceNumber;
	inc(cnt);
	if debug then writeln('http_hwinit: cnt=',cnt,' Initdata=',initdata);
	delim:=pos('§',initdata);
	R_URL[cnt]:=copy(initdata,1,delim-1);
	W_URL[cnt]:=copy(initdata,delim+1,length(initdata));
	if debug then writeln('http_hwinit: R_URL=',R_URL[cnt],' W_URL=',W_URL[cnt]);
end;


begin
	cnt:=0;
	AppName:=ExtractFileName(ParamStr(0));
end.
