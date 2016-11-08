program iownew;

uses oldlinux,iowkit;

var 
        ioHandle: IOWKIT_HANDLE;
        serNum: array [0..8] of WideChar;
        i       : byte; 
begin
writeln (IowKitVersion);
ioHandle:=IowKitOpenDevice;
writeln ('found ',IowKitGetNumDevs,' Devices');
IowKitGetSerialNumber(ioHandle,@serNum[0]);
write ('serial #: ');
for i :=0 to 8 do 
        write(serNum[i]);
writeln;
writeln('Firmware Version of first IO Warrior: ', IowKitGetRevision(ioHandle));
end.
