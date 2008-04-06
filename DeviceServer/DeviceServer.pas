program DeviceServer;
{$mode objfpc}
uses PhysMach,webserver,telnetserver,cthreads,classes,crt;

{ $Id$ }

{ This software is copyright (c) 2008 by Hartmut Eilers <hartmut@eilers.net> 	}
{ It is distributed under the terms of the GNU GPL V2 see http://www.gnu.org 	}

{ 20.02.2008		Start of project					}
{ 08.03.2008		changed to start one thread per device			}



const
	Forever=false;
	MaxThreads=25;
	BLOCKED=true;
	NOTBLOCKED=false;
	debug=false;
	TimeOut=500;

var
	i		: LongInt;
	ThreadHandle	: array[1..MaxThreads] of LongInt;
	ThreadName	: array[1..MaxThreads] of string;
	ThreadCnt	: array[1..MaxThreads] of LongInt;
	shutdown	: Boolean;
	Counter		: LongInt;
	IOGroup		: LongInt;
	ByteValue	: Byte;
	ProtectParams	: TRTLCriticalSection;
	Power		: array [1..8] of byte =(1,2,4,8,16,32,64,128);
	DeviceList	: DeviceTypeArray;
	DeviceCnt,
	NumOfThreads	: LongInt ;


Procedure interpreter;
var
	Line		: String;
	cmd,hw		: Char;
	pa,va		: LongInt;
	StrVal		: String;
	AddrStr,TypStr	: String;
	i		: Integer;

begin
	Line:=TelnetGetData;
	line:=upcase(line);
	cmd:=line[1];
	hw:=line[3];
	val(copy(line,5,2),pa);
	if length(line)>=7 then
		val(copy(line,7,length(line)-6),va);
	if debug then writeln('pa=',pa,' va=',va);
	case cmd of
		'R' : 	begin
				case hw of
						'C' :	begin
								if (Zust[pa]) then
									TelnetWriteAnswer('1'+chr(10)+'>')
								else
									TelnetWriteAnswer('0'+chr(10)+'>');
							end;
						'I' :	begin
								if debug then
									write('E[',pa,']=');
								if (eingang[pa])then
									TelnetWriteAnswer('1'+chr(10)+'>')
								else
									TelnetWriteAnswer('0'+chr(10)+'>');
							end;
						'A' :	begin
								str(analog_in[pa],StrVal);
								TelnetWriteAnswer(StrVal+chr(10)+'>');
							end;
				end;
			
			end;
		'W' :	begin
				case hw of
					'O' :	begin
							if debug then writeln (pa,' ',va);
							if va=0 then ausgang[pa]:=false
							else ausgang[pa]:=true;
							TelnetWriteAnswer(chr(10)+'>');
						end;
					'A' :	begin
						end;
				end;
			end;
		'H' :	begin
				TelnetWriteAnswer('cmd lines are build like this'+chr(10));
				TelnetWriteAnswer('cmd hardware number [value]'+chr(10));
				TelnetWriteAnswer('cmd=[R|W|H|E|C|S] for read, write, help, end, config and stats'+chr(10));
				TelnetWriteAnswer('hardware=[C|I|O|A] for counter, input, output, analog values'+chr(10));
				TelnetWriteAnswer('Number = Number of line'+chr(10));
				TelnetWriteAnswer('Value= value needed when writing lines'+chr(10));
				TelnetWriteAnswer(chr(10)+'>');
			end;
		'C' :	begin
				// dump the configuration data
				for i:=1 to group_max do begin
					str(i,StrVal);
					if (i_devicetype[i]<>'-') then begin
						str(i_address[i],AddrStr);
						TelnetWriteAnswer('InputGroup '+StrVal+' Type '+i_devicetype[i]+' Address '+AddrStr+chr(10));
					end;
					if (o_devicetype[i]<>'-') then begin
						str(o_address[i],AddrStr);
						TelnetWriteAnswer('OutputGroup '+StrVal+' Type '+o_devicetype[i]+' Address '+AddrStr+chr(10));
					end;
					if (c_devicetype[i]<>'-') then begin
						str(c_address[i],AddrStr);
						TelnetWriteAnswer('CounterGroup '+StrVal+' Type '+c_devicetype[i]+' Address '+AddrStr+chr(10));
					end;
					if (a_devicetype[i]<>'-') then begin
						str(a_address[i],AddrStr);
						TelnetWriteAnswer('AnalogGroup '+StrVal+' Type '+a_devicetype[i]+' Address '+AddrStr+chr(10));
					end;
				end;
				TelnetWriteAnswer(chr(10)+'>');
			end;
		'S' :	begin
				for i:=1 to NumOfThreads do begin
					str(ThreadCnt[i],StrVal);
					TelnetWriteAnswer(ThreadName[i]+'  '+StrVal+chr(10));
				end;
				TelnetWriteAnswer(chr(10)+'>');
			end;
	end;

end;


function TelnetThread(p: pointer):LongInt;
var 
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	writeln('started Telnet Thread..',MySelf);
	TelnetInit('./telnet.log');
	TelnetSetupInterpreter(@interpreter);
	repeat
		TelnetServeRequest('Welcome to Device Server Monitor'+chr(10)+'>');	
		delay(100);
		inc(ThreadCnt[MySelf]);
	until shutdown=true;
	writeln('Telnet Handler going down..',MySelf);
end;


function DeviceHandler(p: pointer):LongInt;
var 
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	writeln('started Device Handler Thread..',MySelf);
	repeat
		if debug then writeln('call PhysMachIOByDevice(DeviceList[MySelf])=',DeviceList[MySelf],' MySelf=',MySelf);
		PhysMachIOByDevice(DeviceList[MySelf]);
		delay(100);
		inc(ThreadCnt[MySelf]);
	until shutdown=true;
	writeln('Device Handler going down..',MySelf);
end;



procedure embeddedWebReadParams;
{ handles any parameters in this case the prameter is always the io_group and maybe a byte_value }
var 
	Url,Params 	: String;
	Trenner		: Byte;

begin
	Url:=GetURL;

	{ Fragezeichen Abschneiden }
	Params:=copy(GetParams,2,Length(GetParams));;

	if (pos(',',Params) = 0 ) then begin
		val(params,IOGroup);
		ByteValue:=0;
	end
	else begin
		Trenner:=pos(',',Params);
		val(copy(Params,1,Trenner-1),IOGroup);
		val(copy(Params,Trenner+1,Length(Params)-Trenner),ByteValue);
	end;



	if debug then begin
		writeln('embeddedWeb:> Got Parameters');
		writeln('URL=',Url,' Parameters=',Params,' ',IOGroup,' ',ByteValue);
	end;
end;



procedure DeliverAnalogValues;
{ called whenever the analog special page is called }
var
	ValueString,SeitenStart,SeitenEnde,Seite,Values	: string;

begin
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';

	for i:=1 to 8 do begin
		str(analog_in[i],ValueString);
		Values:=Values+' '+ValueString;
	end;

	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then writeln('embeddedWeb:>Sending Page');

	SendPage(Seite);
	if debug then writeln('embeddedWeb:>Page Send, finished');
end;


procedure DeliverDigitalValues;
{ called whenever the digital special page is called }
var
	SeitenStart,SeitenEnde,Seite,Values	: string;
	AddressBase				: word;
	Bits					: byte;

begin
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';

	AddressBase:=IOGroup*8-8+1;

	if debug then writeln('DeliverDigitalValues AddressBAse=',AddressBase);

	for Bits:=1 to 8 do
		if eingang[AddressBase+Bits-1] then Values:=Values+' '+'1'
		else Values:=Values+' '+'0';

	Seite:=SeitenStart+Values+SeitenEnde;

	if debug then writeln('embeddedWeb:>Sending Page');
	SendPage(Seite);

	if debug then writeln('embeddedWeb:>Page Send, finished');
end;


procedure SaveDigitalValues;
var
	SeitenStart,SeitenEnde,Seite,Values	: string;
	AddressBase				: word;
	Bits					: byte;

begin
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';

	{ set the bits in the ausgang[n] array in respect of io_group}
	AddressBase:=IOGroup*8-8+1;

	for Bits:=8 downto 1 do begin
		if (ByteValue-Power[Bits])>=0 then begin
			Ausgang[AddressBase+Bits-1]:=true;
			ByteValue:=ByteValue-Power[Bits];
			Values:=Values+' 1';
		end
		else begin
			Ausgang[AddressBase+Bits-1]:=false;
			Values:=Values+' 0';
		end;
	end;

	{ return something usefull }	
	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then writeln('embeddedWeb:>Sending Page');
	SendPage(Seite);
	if debug then writeln('embeddedWeb:>Page Send, finished');
end;



function WebserverThread(p: Pointer):LongInt;
{ the real serving thread }
var 
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	writeln('started Webserver Thread, going to start Server...');
	{ start the webserver with IP, Port, Document Root and Logfile }
	start_server('127.0.0.1',10080,BLOCKED,'./docroot/','./pwserver.log');
	writeln('Webserver started, ready to serve');

	{ register the variable handler }
	SetupVariableHandler(@embeddedWebReadParams);
	
	{ register special URL for content generated by this program }
	SetupSpecialURL('/analog/read.html',@DeliverAnalogValues );
	SetupSpecialURL('/digital/read.html',@DeliverDigitalValues );
	SetupSpecialURL('/digital/write.html',@SaveDigitalValues);

	repeat
		EnterCriticalSection(ProtectParams);
		serve_request;
		LeaveCriticalSection(ProtectParams);
		delay(100);
		inc(ThreadCnt[MySelf]);
	until Shutdown=true;

	writeln('Webserver going down..');
	WebserverThread:=0;

end;					{ Webserver Thread end }


begin					{ Main program }
	// initialize Hardware
	PhysMachInit;
	PhysMachloadCfg('DeviceServer.cfg');
	writeln('detected Hardware: ',HWPlatform);
	PhysMachWriteDigital;
	// get list of installed devices
	DeviceList:=PhysMachGetDevices;

	Counter:=0;
	InitCriticalSection(ProtectParams);

	// start threads for every configured device one thread
	// the device servers need to be started as first thread,
	// because of the device list index
	NumOfThreads:=1;
	for DeviceCnt:=1 to DeviceTypeMax do begin
		if DeviceList[DeviceCnt]<>'-' then begin
			writeln('starting DeviceHandler for Device:',DeviceList[DeviceCnt]);
			ThreadName[NumOfThreads]:='DeviceHandler '+DeviceList[DeviceCnt];
			ThreadHandle[NumOfThreads]:=BeginThread(@DeviceHandler,pointer(NumOfThreads));
			ThreadCnt[NumOfThreads]:=0;
			inc(NumOfThreads);
		end;
	end;

	writeln('Starting Webserver Thread...');
	ThreadName[NumOfThreads]:='Webserver';
	ThreadHandle[NumOfThreads]:=BeginThread(@WebserverThread,pointer(NumOfThreads));

	// start the telnet thread 
	inc(NumOfThreads);
	writeln('Starting Telnet Thread...');
	ThreadName[NumOfThreads]:='Telnet Thread';
	ThreadHandle[NumOfThreads]:=BeginThread(@TelnetThread,pointer(NumOfThreads));

	// fool around and wait for the end
	repeat
		delay(TimeOut);
		repeat
		until keypressed;
	until readkey='e';

	// stop threads
	shutdown:=true;

	// wait for threads to finish

	for i:=1 to NumOfThreads do
		WaitForThreadTerminate(ThreadHandle[i],TimeOut);

	DoneCriticalSection(ProtectParams);

end.
