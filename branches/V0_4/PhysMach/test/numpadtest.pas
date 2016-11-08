program numpadtest;

var
	numpad 	: Text;
	keys	: String;

begin
	assign(numpad,'/dev/input/by-id/usb-04d9_USB_Keyboard-event-kbd');
	reset(numpad);
	repeat
		write('>');
		read (numpad,keys);
		writeln (keys);
	until False;
end.

