Unit AVRnet_io_access;

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
function avrnet_close(initstring:string):boolean;

implementation
uses SysUtils,CommonHelper,classes,telnetsshclient,
{$ifdef Linux}
UnixUtil,
{$endif}
math
;

const	
	debug		= false;
	power   	: array[0..7] of byte =(1,2,4,8,16,32,64,128);

var
	SERVER,PORT		: array[1..4] of String;
	cnt			: byte;
	DeviceIndex		: byte;


function avrnet_close(initstring:string):boolean;
begin
    avrnet_close:=true;
end;


function avrnet_read_ports(io_port:longint):byte;

var	
	TmpStrg				: string;
	wert				: LongInt;
	dev				: byte;
	cmd				: AnsiString;
	CON				: TTelnetSSHClient;
	Result				: byte;
	i				: byte;

begin
	{ extract the device number as key to the device handle }
	str(io_port,TmpStrg);
	val(copy(TmpStrg,1,1),dev);
	{ extract the port }
	val(copy(TmpStrg,2,1),io_port);

	Result:=0;
	
	CON:= TTelnetSSHClient.Create;
	CON.HostName:=SERVER[dev];		// IP or name of device
	CON.TargetPort:=PORT[dev];		// port of selected device
	CON.ProtocolType:=Telnet;		// Telnet or SSH
	if debug then writeln(CON.Connect); 	// Show result of connection
	if CON.Connected then begin
	  if debug then writeln(CON.WelcomeMessage);
	  for i:=1 to 4 do begin
	    cmd:='GETPORT ' + IntToStr(i);
	    val(CON.CommandResult(cmd),wert);
	    if wert = 1 then Result:=Result + 2**i;
	  end;  
	end  
	else 
	  if debug then begin
	    writeln('Connection to ' +
	    CON.HostName + ':' +
	    CON.TargetPort + ' failed.');
	  end;
	CON.Free;
	avrnet_read_ports:=Result;
end;

    
	
function avrnet_write_ports(io_port:longint;byte_value:byte):byte;	

var	
	TmpStrg			: string;
	dev			: byte;
	CON			: TTelnetSSHClient;
	response		: string;	
	i			: byte;
	cmd			: string;
	bit_value		: char;

begin
	{ extract the device number as key to the device handle }
	str(io_port,TmpStrg);
	val(copy(TmpStrg,1,1),dev);
	{ extract the port ( must be 1 ! ) }
	val(copy(TmpStrg,2,1),io_port);
	if debug then writeln('avrnet_io_write_ports: ',byte_value);
	CON:= TTelnetSSHClient.Create;
	CON.HostName:= SERVER[dev];		// IP or name of device
	CON.TargetPort:=PORT[dev];		// port of selected device
	CON.ProtocolType:=Telnet;		// Telnet or SSH
	if debug then writeln(CON.Connect); 	// Show result of connection
	if CON.Connected then begin
	  if debug then writeln(CON.WelcomeMessage);
	  for i:=7 downto 0 do begin
	    // now set the bits one after another
	    if ( (byte_value - power[i]) >= 0 ) then begin
	      bit_value:='1';
	      byte_value:=byte_value-power[i];
	    end
	    else
	      bit_value:='0';
	    // generate a string from the PORT
	    cmd:='SETPORT ' + IntToStr(i+1) + '.' + bit_value;
	    response:=CON.CommandResult(cmd);
	    if debug then
	      writeln('Response from TELNET WritePort: ',response);
	      if ( response = 'NAK' ) then 
		writeln('Setting PORT ' + IntToStr(i+1) + '.' + bit_value + ' failed')
	      else
		writeln('Setting PORT ' + IntToStr(i+1) + '.' + bit_value + ' success');
	  end;
	end  
	else 
	  if debug then begin
	    writeln('Connection to ' +
	    CON.HostName + ':' +
	    CON.TargetPort + ' failed.');
	  end;
	CON.Free;

end;


function avrnet_read_analog(io_port:longint):LongInt;
var
	TmpStrg				: string;
	wert				: LongInt;
	dev				: byte;
	cmd				: AnsiString;
	CON				: TTelnetSSHClient;
	ADCPORT				: String;
	
begin
	{ extract the device number as key to the device handle }
	str(io_port,TmpStrg);
	val(copy(TmpStrg,1,1),dev);
	{ extract the port }
	val(copy(TmpStrg,2,1),io_port);
	// generate a string from the PORT
	ADCPORT:=TmpStrg;

	CON := TTelnetSSHClient.Create;
	CON.HostName:= SERVER[dev];		// IP or name of device
	CON.TargetPort:=PORT[dev];		// port of selected device
	CON.ProtocolType:=Telnet;		// Telnet or SSH
	if debug then writeln(CON.Connect); 	// Show result of connection
	if CON.Connected then begin
	  if debug then writeln(CON.WelcomeMessage);
	  cmd:='GETADC ' + ADCPORT;
	  val(CON.CommandResult(cmd),wert);
	end  
	else 
	  if debug then begin
	    writeln('Connection to ' +
	    CON.HostName + ':' +
	    CON.TargetPort + ' failed.');
	  end;
	CON.Free;
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
