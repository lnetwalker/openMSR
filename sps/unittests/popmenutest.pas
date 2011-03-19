program popmenutest;
uses crt;

var cursor : boolean;
    taste  : char;

begin
	writeln ('cursor on/off test, press q to quit');
	cursor:=true;
	repeat
		repeat
	
		until keypressed;
		taste:=readkey;
		if cursor then begin
			writeln('cursor is on');
			write(#27'[?25h');
		end
		else begin
			write(#27'[?25l');
			writeln('cursor is off');
		end;
		cursor:=not(cursor);
	until taste='q';
end.
