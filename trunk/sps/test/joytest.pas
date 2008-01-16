program joytest;
uses crt;
{ this program is a crude test code to learn how the joystick is }
{ read under Linux. see /usr/share/doc/joystick/input/joystick-api.txt.gz }
{ for details ( you need debian package joystick) }

const
	joydev='/dev/js0';

type
	js_event = record
		JoyTime 	: LongInt;  // a time 
		JoyValue	: Integer; // the value (0/1 for bottons) 
		JoyType		: Byte; // 129 buttons 130 axis
		JoyNumber	: Byte; // corresponding axis or button ( normaly 0-3 )
	end;


var	f : file of js_event;
	Joystick : js_event;

begin
	assign(f,joydev);
	reset(f);
	while (true) do begin;
		repeat
			read(f,Joystick);
		until ((Joystick.JoyType = 129 ) or (Joystick.JoyType = 130));
		writeln('joystick event: Time=',Joystick.JoyTime,' Value=',Joystick.JoyValue,' Type=',Joystick.JoyType,' Number=',Joystick.JoyNumber);
		delay(700);
	end;
end.