program iownew;

uses crt,iowkit;

var
        ioHandle: IOWKIT_HANDLE;
        serNum: array [0..8] of WideChar;
        i       : byte;
	value   : DWORD;
	Report	: IOWKIT40_IO_REPORT;
	status	: boolean;


begin
writeln (IowKitVersion);
ioHandle:=IowKitOpenDevice;
if Assigned (ioHandle) then begin
	writeln ('found ',IowKitGetNumDevs,' Devices');
	IowKitGetSerialNumber(ioHandle,@serNum[0]);
	write ('serial #: ');
	for i :=0 to 8 do
        	write(serNum[i]);
	writeln;
	writeln('Firmware Version of first IO Warrior: ', IowKitGetRevision(ioHandle));
	Report.ReportID:=0;
	Report.Value:=$FFFFFFFF;
	writeln('written ',IowKitWrite(ioHandle,IOW_PIPE_IO_PINS,@Report,IOWKIT_REPORT_SIZE), 'bytes');

	for i:=1 to 50 do begin
		IowKitReadNonBlocking(ioHandle,IOW_PIPE_IO_PINS,@Report,IOWKIT_REPORT_SIZE);
		writeln('read ',Report.Value,' from first Warrior');
		delay(1000);
	end;
end
else writeln(' error in IowKitOpenDevice');
end.


