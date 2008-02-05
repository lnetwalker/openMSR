program TimerTest;

uses dos,crt;

const OldTimerInt=103;

var   zaehler : word;
      hsec    : longint;
      ch      : char;

procedure StelleTimerEin(rout : pointer ; freq : word);

var izaehler : word;
    oldv     : pointer;

begin
     inline($FA);
     izaehler:=1193180 div freq;
     port[$43]:=$36;
     port[$40]:=lo(izaehler);
     port[$40]:=hi(izaehler);
     getintvec(8,oldv);
     setintvec(oldtimerint,oldv);
     setintvec(8,rout);
     inline($FB);
end;


procedure korrigieretimer;

var oldv : pointer;

begin
     inline($FA);
     port[$43]:=$36;
     port[$40]:=0;
     port[$40]:=0;
     getintvec(oldtimerint,oldv);
     setintvec(8,oldv);
     inline($FB);
end;


procedure neuertimer;
interrupt;

var r : registers;

begin
     dec (zaehler);
     if zaehler=0 then begin
        intr(oldtimerint,r);
        zaehler:=100 div 18;
     end
     else port[$20]:=$20;
     inc(hsec);
end;

begin
     zaehler:=1;
     stelletimerein(@neuertimer,100);
     writeln;
     writeln('Stoppuhr, druecke Taste ...');
     writeln;
     ch:=readkey;
     hsec:=0;
     repeat
           gotoxy(1,wherey);
           write((hsec div 360000):2,':',
                 (hsec div 6000 mod 60):2,':',
                 (hsec div 100 mod 60):2,'.',
                 (hsec mod 100):2);
     until keypressed;
     korrigieretimer;
     writeln;
end.
