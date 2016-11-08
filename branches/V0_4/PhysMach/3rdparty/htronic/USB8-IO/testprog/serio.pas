program serio;

{
  HTRONIC USB8 A/D HB628
  Testprogram to read Analog Values from the board
  compiled from different examples from different people
  thanks to everyone making open source software
}

uses 
{$IFDEF UNIX}{$IFDEF UseCThreads}
	cthreads,
{$ENDIF}{$ENDIF}
	Classes,SysUtils,Synaser,Crt
	{ you can add units after this }
	;

	procedure RS232_connect;
	var
		ser: TBlockSerial;
		hi,lo,chk : byte;
		value: word;
	begin
		ser:=TBlockSerial.Create;
		ser.Connect('/dev/ttyACM0'); //ComPort
		Sleep(1000);
		ser.config(115000, 8, 'N', SB1, False, False);
		Write('Device: ' + ser.Device + '   Status: ' + ser.LastErrorDesc +' '+
		Inttostr(ser.LastError));
		Sleep(1000);
		repeat
			ser.SendString('c01');
			hi:=ser.RecvByte(10000);
			lo:=ser.RecvByte(10000);
			chk:=ser.RecvByte(10000);
			if ( lo + hi <> chk ) then writeln ( 'Checksum Error');
			value:= hi * 256 + lo;
			writeln ( IntToHex(hi,2), ' ' ,IntToHex(lo,2), ' ' , IntToHex(chk,2) ,' => ', value);
		until keypressed; //Important!!!
		Writeln('Serial Port will be freed...');
		ser.free;
		Writeln('Serial Port was freed successfully!');
	end;

      
begin
	RS232_connect()
end.

