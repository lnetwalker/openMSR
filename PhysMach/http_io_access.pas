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
	debug		= true;

var
	R_URL,W_URL		: array[1..4] of String;
	cnt			: byte;
	DeviceIndex		: byte;
	AppName			: string;
	Conn_read_ports,
	Conn_write_ports,
	Conn_read_analog,
	Conn_write_analog	: boolean;
	HTTPrp,HTTPwp			: THTTPSend;
	HTTPra,HTTPwa			: THTTPSend;
	resp_rp,resp_wp,
	resp_ra,resp_wa		: tstringlist;


function http_close():boolean;
begin
    http_close:=true;
end;


function http_read_ports(io_port:longint):byte;

var
	TmpVal,TmpStrg	: string;
	dev							: byte;

begin
	//if ( Conn_read_ports = false ) then begin
		HTTPrp := THTTPSend.Create;
		HTTPrp.UserAgent:='Mozilla/4.0 (' + AppName + ')';
		HTTPrp.Protocol:='1.0';
		resp_rp := TStringList.create;
		Conn_read_ports:=true;
		if debug then writeln('http_read_ports: opened new http connection');
	//end;
 	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	str(io_port,TmpStrg);
	TmpStrg:=R_URL[dev]+TmpStrg;
	if not HTTPra.HTTPMethod('GET', TmpStrg) then begin
		write('http_read_ports ERROR');
		writeln(HTTPra.Resultcode);
	end
	else begin
		resp_rp.loadfromstream(HTTPra.Document);
		TmpVal:=deHTML(resp_rp.text);
	end;
	if debug then writeln('http_read_ports(',TmpStrg,') returned ',TmpVal);

	//if ( HTTPra.Resultcode <> 200 ) then begin
	HTTPrp.Destroy;
		HTTPrp.Free;
		resp_rp.free;
		Conn_read_ports:=false;
		if debug then writeln('http_read_ports: closed http connection');
	//end;

	Conn_read_ports:=false;
	http_read_ports:=BinToInt(TmpVal);
end;



function http_write_ports(io_port:longint;byte_value:byte):byte;

var
	TmpVal,TmpStrg,Params	: string;
	dev										: byte;

begin
	//if ( Conn_write_ports = false ) then begin
		HTTPwp := THTTPSend.Create;
		HTTPwp.UserAgent:='Mozilla/4.0 (' + AppName + ')';
		resp_wp := TStringList.create;
		HTTPwp.Protocol:='1.0';
		Conn_write_ports:=true;
		if debug then writeln('http_write_ports: opened new http connection');
	//end;
	{ extract the device number as key to the device handle }
	dev:=round(io_port/10);
	{ extract the port }
	io_port:=round(frac(io_port/10)*10);
	str(io_port,TmpStrg);
	Params:=TmpStrg+',';
	str(byte_value,TmpStrg);
	Params:=Params+TmpStrg;
	TmpStrg:= W_URL[dev]+Params;
	if not HTTPwp.HTTPMethod('GET', TmpStrg) then begin
		write('http_write_ports ERROR');
		writeln(HTTPwp.Resultcode);
	end
	else begin
		resp_wp.loadfromstream(HTTPwp.Document);
		TmpVal:=deHTML(resp_wp.text);
	end;
	if debug then writeln('http_write_ports: URL=',W_URL[dev]+Params);

	//if ( HTTPwp.Resultcode <> 200 ) then begin
	HTTPwp.Destroy;
		HTTPwp.Free;
		resp_wp.free;
		Conn_write_ports:=false;
		if debug then writeln('http_write_ports: closed http connection');
	//end;
	val(TmpVal,http_write_ports);
end;


function http_read_analog(io_port:longint):LongInt;
var
	ReturnValue,TmpStrg			: string;
	ReturnArray							: array[1..8] of string;
	ReturnValueLength,i,k		: integer;
	wert										: LongInt;
	dev											: byte;
	cmd											: AnsiString;
	idx											: byte;

begin
	if ( Conn_read_analog = false ) then begin
		HTTPra := THTTPSend.Create;
		HTTPra.UserAgent:='Mozilla/4.0 (' + AppName + ')';
		resp_ra := TStringList.create;
		HTTPra.Protocol:='1.1';
		Conn_read_analog:=true;
	end;
	if debug then writeln('http_io_access io_port=',io_port);
	{ extract the device number as key to the device handle }
	str(io_port,TmpStrg);
	val(copy(TmpStrg,1,1),dev);

	{ extract the port }
	val(copy(TmpStrg,2,1),io_port);
  val(copy(TmpStrg,3,1),idx);

	str(io_port,TmpStrg);
	TmpStrg:=R_URL[dev]+TmpStrg;
	if not HTTPra.HTTPMethod('GET', TmpStrg) then begin
		write('http_read_analog ERROR:');
		writeln(HTTPra.Resultcode);
	end
	else begin
		resp_ra.loadfromstream(HTTPra.Document);
		ReturnValue:=deHTML(resp_ra.text);
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
	if ( HTTPra.Resultcode <> 200 ) then begin
		HTTPra.Free;
		resp_ra.free;
		Conn_read_analog:=false;
		if debug then writeln('http_read_analog: closed http connection');
	end;
	http_read_analog:=wert;

end;

function http_write_analog(io_port:longint;analog_value:integer):byte;
	var
		ReturnValue,TmpStrg		: string;
		dev										: byte;
		AnalogURL							: String;
		idx,AnalogIdx					: byte;

	begin
		if ( Conn_write_analog = false ) then begin
			HTTPwa := THTTPSend.Create;
			HTTPwa.UserAgent:='Mozilla/4.0 (' + AppName + ')';
			resp_wa := TStringList.create;
			HTTPwa.Protocol := '1.1';
			Conn_write_analog:=true;
		end;

		if debug then writeln('http_io_access->http_write_analog io_port=',io_port);
		{ extract the device number as key to the device handle }
		str(io_port,TmpStrg);
		val(copy(TmpStrg,1,1),dev);
		val(copy(TmpStrg,2,1),io_port);
		val(copy(TmpStrg,3,1),idx);
		AnalogIdx:=(io_port-1)*8+idx;
		str(AnalogIdx,TmpStrg);
		AnalogURL:=W_URL[dev]+TmpStrg;

		str(analog_value,TmpStrg);
		AnalogURL:=AnalogURL+','+TmpStrg;
		if debug then writeln('http_io_access->http_write_analog AnalogURL=',AnalogURL);
		if not HTTPwa.HTTPMethod('GET', AnalogURL) then begin
			write('http_io_access->http_write_analog ERROR:');
			writeln(HTTPwa.Resultcode);
		end
		else begin
			resp_wa.loadfromstream(HTTPwa.Document);
			ReturnValue:=deHTML(resp_wa.text);
		end;

		if ( HTTPwa.Resultcode <> 200 ) then begin
			HTTPwa.Free;
			resp_wa.free;
			Conn_write_analog:=false;
			if debug then writeln('http_write_analog: closed connection');
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
	W_URL[cnt]:=copy(initdata,delim+2,length(initdata));
	if debug then writeln('http_hwinit: R_URL=',R_URL[cnt],' W_URL=',W_URL[cnt]);
end;


begin
	cnt:=0;
	AppName:=ExtractFileName(ParamStr(0));
	Conn_read_ports:=false;
	Conn_write_ports:=false;
	Conn_read_analog:=false;
	Conn_write_analog:=false;
end.
