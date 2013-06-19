Unit avrnet_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf				} 
{ das Pollin AVR-NET-IO Board							}	
{ If you have improvements please contact me at 				}
{ hartmut@eilers.net								}
{ all code is copyright by Hartmut Eilers and released under			}
{ the GNU GPL see www.gnu.org for license details				}
{ $Id:$ }
{ History:									}
{		30.11.2012 first raw hack					}


INTERFACE


function avrnet_read_ports(io_port:longint):byte;
function avrnet_write_ports(io_port:longint;byte_value:byte):byte;
function avrnet_read_analog(io_port:longint):LongInt;
function avrnet_hwinit(initdata:string;DeviceNumber:byte):boolean;
function avrnet_close():boolean;

implementation
uses SysUtils,CommonHelper,classes,telnetsshclient,
{$ifdef Linux}
UnixUtil,
{$endif}
tlntsend
;

const	
	debug		= false;
	power   	: array[0..7] of byte =(1,2,4,8,16,32,64,128);

var
	SERVER,PORT		: array[1..4] of String;
	cnt			: byte;
	DeviceIndex		: byte;


function avrnet_close():boolean;
begin
    avrnet_close:=true;
end;


function avrnet_read_ports(io_port:longint):byte;

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
	if debug then writeln('avrnet_read_ports(',TmpStrg,') returned ',TmpVal);
	HTTP.Free;
	response.free;
	avrnet_read_ports:=BinToInt(TmpVal);
end;

    
	
function avrnet_write_ports(io_port:longint;byte_value:byte):byte;	

var	
	TmpStrg			: string;
	dev			: byte;
	TELNET			: TTelnetSSHClient;
	response		: string;	
	i			: byte;
	cmd			: string;
	bit_value,DIGPORT	: char;

begin
	{ extract the device number as key to the device handle }
	str(io_port,TmpStrg);
	val(copy(TmpStrg,1,1),dev);
	{ extract the port ( must be 1 ! ) }
	val(copy(TmpStrg,2,1),io_port);

	TELNET := TTelnetSSHClient.Create;
	TELNET.HostName:= SERVER[DEV];	// IP or name of device
	TELNET.TargetPort:=PORT[dev];		// port of selected device
	TELNET.ProtocolType:=Telnet;		// Telnet or SSH
	if debug then writeln(TELNET.Connect); // Show result of connection
	if TELNET.Connected then begin
	  if debug then writeln(TELNET.WelcomeMessage);
	  for i:=7 downto 0 do begin
	    // now set the bits one after another
	    if ( (byte_value - power[i]) > 0 ) then begin
	      bit_value='1';
	      byte_value:=byte_value-power[i];
	    end
	    else
	      bit_value:='0';
	    // generate a string from the PORT
	    str(i,DIGPORT);
	    cmd:='SETPORT ' + DIGPORT + '.' + bit_value;
	    response:=CommandResult(Command),wert);
	    if debug then
	      if ( response = 'NAK' ) then 
		writeln('Setting PORT ' + DIGPORT + '.' + bit_value + ' failed')
	      else
		writeln('Setting PORT ' + DIGPORT + '.' + bit_value + ' success');
	  end;
	end  
	else 
	  if debug then begin
	    writeln('Connection to ' +
	    TELNET.HostName + ':' +
	    TELNET.TargetPort + ' failed.');
	  end;
	TELNET.Free;

end;


function avrnet_read_analog(io_port:longint):LongInt;
var
	TmpStrg				: string;
	wert				: LongInt;
	dev				: byte;
	cmd				: AnsiString;
	TELNET				: TTelnetSSHClient;
	ADCPORT				: char;
	
begin
	{ extract the device number as key to the device handle }
	str(io_port,TmpStrg);
	val(copy(TmpStrg,1,1),dev);
	{ extract the port }
	val(copy(TmpStrg,2,1),io_port);
	// generate a string from the PORT
	str(io_port,ADCPORT);

	TELNET := TTelnetSSHClient.Create;
	TELNET.HostName:= SERVER[DEV];	// IP or name of device
	TELNET.TargetPort:=PORT[dev];		// port of selected device
	TELNET.ProtocolType:=Telnet;		// Telnet or SSH
	if debug then writeln(TELNET.Connect); // Show result of connection
	if TELNET.Connected then begin
	  if debug then writeln(TELNET.WelcomeMessage);
	  cmd:='GETADC ' + ADCPORT;
	  val(TELNET.CommandResult(Command),wert);
	end  
	else 
	  if debug then begin
	    writeln('Connection to ' +
	    TELNET.HostName + ':' +
	    TELNET.TargetPort + ' failed.');
	  end;
	TELNET.Free;
	avrnet_read_analog:=wert;
end;


function avrnet_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
	delim : integer;
begin
	DeviceIndex:=DeviceNumber;
	inc(cnt);
	if debug then writeln('avrnet_hwinit: cnt=',cnt,' Initdata=',initdata);
	delim:=pos(':',initdata);
	SERVER[cnt]:=copy(initdata,1,delim-1);
	PORT[cnt]:=copy(initdata,delim+1,length(initdata));
	if debug then writeln('avrnet_hwinit: SERVER=',SERVER[cnt],' PORT=',PORT[cnt]);
end;


begin
	cnt:=0;
end.
