program iownew;

uses linux,iowkit;

var
        ioHandle: IOWKIT_HANDLE;
        serNum: array [0..8] of WideChar;
        i       : byte;
	value   : DWORD;
	Report		: IOWKIT40_IO_REPORT;

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
	IowKitWrite(ioHandle,0,@Report,5);

	IowKitReadImmediate(ioHandle, Value);
	writeln('read ',Value,' from first Warrior');
end
else writeln(' error in IowKitOpenDevice');
end.


