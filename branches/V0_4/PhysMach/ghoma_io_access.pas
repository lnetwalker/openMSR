Unit ghoma_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf				} 
{ die G-Homa Wifi Steckdosen zur Verfügung 						}	
{ If you have improvements please contact me at 				}
{ hartmut@eilers.net				            				}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details				}
{ $Id:$ }
{ History:									                    }
{		12.07.2016 first raw hack					            }
{ Reference 53_GHoma.pm from Klaus Witt for FHEM Project        }


INTERFACE


function ghoma_read_ports(io_port:longint):byte;
function ghoma_write_ports(io_port:longint;byte_value:byte):byte;
function ghoma_hwinit(initdata:string;DeviceNumber:byte):boolean;
function ghoma_close():boolean;

implementation
uses SysUtils,CommonHelper,classes,telnetsshclient,StringCut,
{$ifdef Linux}
UnixUtil,
{$endif}
tlntsend
;

const	
	debug		= false;
    power   	: array[0..7] of byte =(1,2,4,8,16,32,64,128);
    INIT1a       : array[1..14] of byte=($5a,$a5,$00,$07,$02,$05,$0d,$07,$05,$07,$12,$c6,$5b,$b5);
    INIT1b       : array[1..8] of byte=($5a,$a5,$00,$01,$02,$fd,$5b,$b5);
    INIT1REPLY   : array[1..4] of byte=($5A,$A5,$00,$0B);                     // discard the rest, perhaps compare the part of the MAC with the given MAC
    INIT2        : array[1..9] of byte=($5a,$a5,$00,$02,$05,$01,$f9,$5b,$b5);
    INIT2REPLY1  : array[1..4] of byte=($5A,$A5,$00,$12);                     // discard the rest
    INIT2REPLY2  : array[1..4] of byte=($5A,$A5,$00,$15);                     // discard the rest, perhaps read the state of the device
    HEARTBEAT    : array[1..4] of byte=($5A,$A5,$00,$09);                     // discard the rest
    HBREPLY      : array[1..8] of byte=($5a,$a5,$00,$01,$06,$f9,$5b,$b5)                         
    SWITCHPRE    : array[1..11] of byte=($5a,$a5,$00,$17,$10,$01,$01,$0a,$e0,$32,$23);
    SWITCHMID    : array[1..12] of byte=($ff,$fe,$00,$00,$10,$11,$00,$00,$01,$00,$00,$00);
    SWITCHON     : array[1..3] of byte=($26,$5b,$b5);
    SWITCHOFF    : array[1..3] of byte=($25,$5b,$b5);

var
    SERVER,PORT,MAC,BIT: array[1..8] of String;
	cnt                : byte;
	DeviceIndex        : byte;
	TELNET             : array[1..8] of TTelnetSSHClient;


function ghoma_close():boolean;
begin
    ghoma_close:=true;
    TELNET[cnt].Free;
end;


function ghoma_read_ports(io_port:longint):byte;

var	
	TmpVal,TmpStrg     : string;
	dev                : byte;
	HTTP               : THTTPSend;
	response           : tstringlist;

begin
    // check for heartbeat
    // reply to heartbeat
end;

    
	
function ghoma_write_ports(io_port:longint;byte_value:byte):byte;	

var	
	TmpStrg            : string;
	dev                : byte;
	response           : string;	
	i                  : byte;
	cmd                : string;
	bit_value,DIGPORT  : char;

begin
	{ extract the device number as key to the device handle }
	str(io_port,TmpStrg);
	val(copy(TmpStrg,1,1),dev);
	{ extract the port ( must be 1 ! ) }
	val(copy(TmpStrg,2,1),io_port);

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
	    response:=CommandResult(cmd);
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
	

end;



function ghoma_hwinit(initdata:string;DeviceNumber:byte):boolean;
var
    delim              : integer;
    ArrayResult        : StringArray;
begin
    { wir brauchen hier auf jeden Fall die MAC  }
    { und natürlich auch die IP-Adresse und     }
    { port Nummer sowie das Bit dem die Dose    }
    { zugeordnet ist                            }
	DeviceIndex:=DeviceNumber;
	inc(cnt);
	if debug then writeln('ghoma_hwinit: cnt=',cnt,' Initdata=',initdata);
    delim:=pos(':',initdata);
    ArrayResult:=StringSplit(initdata,":");
    MAC[cnt]:=ArrayResult[1];
    SERVER[cnt]:=ArrayResult[2];
    PORT[cnt]:=ArrayResult[3];
    BIT[cnt]:=ArrayReseult[4];
    if debug then writeln('ghoma_hwinit: MAC=',MAC[cnt],' SERVER=',SERVER[cnt],' PORT=',PORT[cnt],' BIT=',BIT[cnt]);
    { init the device }
	TELNET[cnt] := TTelnetSSHClient.Create;
	TELNET[cnt].HostName:= SERVER[cnt];	        // IP or name of device
	TELNET[cnt].TargetPort:=PORT[cnt];		    // port of selected device
	TELNET[cnt].ProtocolType:=Telnet;		    // Telnet or SSH
	if debug then writeln(TELNET[cnt].Connect);  // Show result of connection
	if TELNET[cnt].Connected then begin
        // init device
    end;
end;


begin
	cnt:=0;
end.
