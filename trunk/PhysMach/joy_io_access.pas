Unit joy_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf		} 
{ den Joystick zur Verf�gung                              	}	
{ If you have improvements please contact me at 		}
{ hartmut@eilers.net						}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}
{ History:							}
{		13.09.2005 first raw hack			}
{		11.04.2006 start with the real thing		}

{ on Debian Systems you need the package 'joystick'		}
{ see /usr/share/doc/joystick/input/joystick-api.txt.gz		}
{ for Informations regarding the programming			}

INTERFACE   

function joy_read_ports(io_port:longint):byte;
function joy_read_ports(io_port:LongInt; axis : byte):integer;
function joy_write_ports(io_port:longint;byte_value:byte):byte;
function joy_hwinit(initdata:string;DeviceNumber:byte):boolean;


implementation

const	
	JoyDevStr       = '/dev/js';
	debug           = false;
	buttondata      = 129;              { these are the values for JoyType 			}
	axisdata        = 130;

type
	JoyEvent  = record                  { the data structure read from device		}
		JoyTime         : LongInt;      { the time when we read the event 		}
		JoyValue        : Integer;      { the value (0/1 for bottons)			}
		JoyType         : Byte;     	{ 129 buttons 130 axis				}
		JoyNumber       : Byte;         { corresponding axis or button ( normaly 0-3 )	}
	end;

var
	f           : file of JoyEvent;
	axisvalue   : array [0..3] of integer;

function joy_read_ports(io_port:longint):byte;
{ the button values will be returned  }
var
	JoyDev      : String;
	i           : byte;
	buttonvalue : byte;
	JoyStick    : JoyEvent;
	DevStr      : string;

begin   
	buttonvalue:=0;
	str(io_port,DevStr);
	JoyDev:=JoyDevStr+DevStr;
	if debug then writeln('Buttons lesen: Device: ',JoyDev,'*');
	reset(f);
	for i:=0 to 3 do begin
		repeat
			read(f,JoyStick);
		until (( JoyStick.JoyType = buttondata ) and ( JoyStick.JoyNumber = i ));
		if debug then writeln('Counter: ',i,'JoyStick.JoyType : ',JoyStick.JoyType,'JoyStick.JoyNumber : ',JoyStick.JoyNumber,' JoyStick.JoyValue : ',JoyStick.JoyValue);
		//if (JoyStick.JoyValue = 1) then buttonvalue:=buttonvalue+2**i;
	end;
	if debug then writeln('ButtonValue : ',buttonvalue);
	buttonvalue:=buttonvalue or $F0;
	joy_read_ports:=buttonvalue;
end;

function joy_read_ports(io_port:LongInt; axis : byte):integer;
{ read the analog ports , ioport defines which joystick interface }
{ and axis to read }
var 
	i         : byte;
	JoyDev    : String;
	JoyStick  : JoyEvent;
	DevStr    : string;

begin
	if ( axis=0 ) then begin  { if the wanted axis is 0 read the values from device }
    	reset(f);
    	for i:=0 to 3 do begin
			repeat 
				read(f,JoyStick);
			until (( JoyStick.JoyType = axisdata ) and ( JoyStick.JoyNumber = i ));
			if debug then writeln('Counter: ',i,'JoyStick.JoyType : ',JoyStick.JoyType,'JoyStick.JoyNumber : ',JoyStick.JoyNumber,' JoyStick.JoyValue : ',JoyStick.JoyValue);
			axisvalue[i]:=JoyStick.JoyValue;
    	end;
	end;
	joy_read_ports:=axisvalue[axis];
end;
	
function joy_write_ports(io_port:longint;byte_value:byte):byte;	
{ the joystick interface has no outputs, so this is a dummy which does nothing }
begin
	joy_write_ports:=0;
end;

function joy_hwinit(initdata:string;DeviceNumber:byte):boolean;
{ initialize everything , initdata is the FQN of the device file }
begin
	assign(f,initdata);
	reset(f);
	joy_hwinit:=true;
end;


begin

end.
