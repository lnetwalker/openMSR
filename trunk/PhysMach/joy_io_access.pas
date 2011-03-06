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
function joy_read_aports(io_port:LongInt):integer;
function joy_write_ports(io_port:longint;byte_value:byte):byte;
function joy_hwinit(initdata:string;DeviceNumber:byte):boolean;


implementation

const	
	debug           = false;
	buttondata      = 129;              	{ these are the values for JoyType 		}
	axisdata        = 130;

type
	JoyEvent  = record                  	{ the data structure read from device		}
		JoyTime         : LongInt;      { the time when we read the event 		}
		JoyValue        : Integer;      { the value (0/1 for bottons)			}
		JoyType         : Byte;     	{ 129 buttons 130 axis				}
		JoyNumber       : Byte;         { corresponding axis or button ( normaly 0-3 )	}
	end;

var
	AxisValue   	: array [0..3] of integer;
	Joystick    	: array [1..4] of String;
	JoystickCounter	: byte;
	JoystickData	: JoyEvent;
	power           : array [0..7] of byte =(1,2,4,8,16,32,64,128);
	

function joy_read_ports(io_port:longint):byte;
{ the button values will be returned  }
var
	dev		: byte;
	ButtonCnt	: byte;
	ButtonValue	: byte;
	f           	: file of JoyEvent;

begin   
	ButtonValue:=0;
	{ extract the device number as key to device handle }
	dev:=round(io_port/16);
	if debug then writeln('dev=',dev);

	assign(f,Joystick[dev]);
	{$I-}
	reset(f);
	{$I+}
	if IOResult <> 0 then 
	    writeln('Error reading Joystick ',Joystick[dev]);

	if debug then writeln('Buttons lesen: Device: ',dev);

	for ButtonCnt:=0 to 7 do begin
		repeat
			read(f,JoystickData);
		until (( JoystickData.JoyType = buttondata ) and ( JoystickData.JoyNumber = ButtonCnt ));
		if debug then writeln('Counter: ',ButtonCnt,'JoyStick.JoyType : ',JoystickData.JoyType,'JoyStick.JoyNumber : ',JoystickData.JoyNumber,' JoyStick.JoyValue : ',JoystickData.JoyValue);
		if (JoystickData.JoyValue = 1) then ButtonValue:=ButtonValue+Power[ButtonCnt];
		
	end;
	if debug then writeln('ButtonValue : ',ButtonValue);
	close(f);
	//buttonvalue:=buttonvalue or $F0;
	joy_read_ports:=ButtonValue;
end;


function joy_read_aports(io_port:LongInt):integer;
{ read the analog ports , ioport defines which joystick interface }
{ and axis to read }
var 
	AxisCnt         : byte;
	Axis		: byte;
	dev		: byte;
	f           	: file of JoyEvent;

begin
	{ extract the device number as key to device handle }
	dev:=round(io_port/16);
	if debug then writeln('dev=',dev);

	assign(f,Joystick[dev]);
	{$I-}
	reset(f);
	{$I+}
	if IOResult <> 0 then 
	    writeln('Error reading Joystick ',Joystick[dev]);

	{ extract the port }
	axis:=io_port-(dev*16);
	if debug then writeln ('axis=',axis);

	if ( axis=0 ) then begin  { if the wanted axis is 0 read the values from device }

	    for AxisCnt:=0 to 3 do begin
		repeat 
			read(f,JoystickData);
			if debug then writeln('Counter: ',AxisCnt,'JoyStick.JoyType : ',JoystickData.JoyType,'JoyStick.JoyNumber : ',JoystickData.JoyNumber,' JoyStick.JoyValue : ',JoystickData.JoyValue);
		until (( JoystickData.JoyType = axisdata ) and ( JoystickData.JoyNumber = AxisCnt ));
		if debug then writeln('Counter: ',AxisCnt,'JoyStick.JoyType : ',JoystickData.JoyType,'JoyStick.JoyNumber : ',JoystickData.JoyNumber,' JoyStick.JoyValue : ',JoystickData.JoyValue);
		AxisValue[AxisCnt]:=JoystickData.JoyValue;
	    end;
	end;
	close(f);
	joy_read_aports:=AxisValue[axis];
end;


function joy_write_ports(io_port:longint;byte_value:byte):byte;	
{ the joystick interface has no outputs, so this is a dummy which does nothing }
begin
	joy_write_ports:=0;
end;


function joy_hwinit(initdata:string;DeviceNumber:byte):boolean;
{ initialize everything , initdata is the FQN of the device file }

begin
	Joystick[JoystickCounter]:= initdata;
	if debug then writeln('init device ',Joystick[JoystickCounter]);
	inc(JoystickCounter);
	joy_hwinit:=true;
end;


begin
    JoystickCounter:=1;
end.
