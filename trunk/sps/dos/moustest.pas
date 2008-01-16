program mousetest;
uses mouse,CRT;
begin
repeat
CHECK_MOUSE(MOUSEINSTALLED);
writeln(mouseinstalled);
UNTIL KEYPRESSED
END.