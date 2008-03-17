program TestCase1;

uses PhysMach,strings;

{ $Id$ }

{ compile with /usr/bin/fpc -Fu.. -Fu../../gtk+/qgtk2.pas-0.9/ -Fu../../divLibs/pwu-1.6.0.2-src/main/ -gl PhysMachTest.pas }

{ Tests the function PhysMachGetDevices }

const
	debug	= false;

var
	i			: byte;
	ConfFile		: string;
	DeviceList		: DeviceTypeArray;

begin
	writeln('TestCase1,  test PhysMachGetDevices');
	writeln('(c) by Hartmut Eilers, 2008 - released under the GPL V2 or above');
	writeln;
	write('Config File: ');readln(ConfFile);
	if ( ConfFile='' ) then ConfFile:='TestCase1.cfg';
	// initialize Hardware
	PhysMachInit;
	PhysMachloadCfg(ConfFile);
	writeln('detected Hardware: ',HWPlatform);

	// dump the configuration data
	for i:=1 to group_max do begin
		if (i_devicetype[i]<>'-') then
			writeln('InputGroup ',i,' Type ',i_devicetype[i],' Address ',i_address[i]);
		if (o_devicetype[i]<>'-') then
			writeln('OutputGroup ',i,' Type ',o_devicetype[i],' Address ',o_address[i]);
		if (c_devicetype[i]<>'-') then
			writeln('CounterGroup ',i,' Type ',c_devicetype[i],' Address ',c_address[i]);
		if (a_devicetype[i]<>'-') then
			writeln('AnalogGroup ',i,' Type ',a_devicetype[i],' Address ',a_address[i]);
	end;

	DeviceList:=PhysMachGetDevices;
	writeln('PhysMachGetDevices found: ');
	for i:=1 to DeviceTypeMax do
		writeln('Device[',i,']=',DeviceList[i]);

	writeln('bye');
end.

