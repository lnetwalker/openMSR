program DeviceServer;
{$mode objfpc}
uses PhysMach,webserver,cthreads,classes,crt;

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
	shutdown	: Boolean;
	Counter		: LongInt;
	IOGroup		: LongInt;
	ByteValue	: Byte;
	ProtectParams	: TRTLCriticalSection;
	Power		: array [1..8] of byte =(1,2,4,8,16,32,64,128);
	DeviceList	: DeviceTypeArray;
	DeviceCnt,
	NumOfThreads	: LongInt ;




function DeviceHandler(p: pointer):LongInt;
var 
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	gotoxy(1,WhereY);
	writeln('started Device Handler Thread..',MySelf);
	repeat
		PhysMachIOByDevice(DeviceList[MySelf]);
		delay(100);
	until shutdown=true;
	gotoxy(1,WhereY);
	writeln('Device Handler going down..',MySelf);
end;



procedure embeddedWebReadParams;
{ handles any parameters in this case the prameter is always the io_group and maybe a byte_value }
var 
	Url,Params 	: String;
	Trenner		: Byte;

begin
	EnterCriticalSection(ProtectParams);
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

	LeaveCriticalSection(ProtectParams);

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

begin
	gotoxy(1,WhereY);
	writeln('started Webserver Thread, going to start Server...');
	{ start the webserver with IP, Port, Document Root and Logfile }
	start_server('127.0.0.1',10080,BLOCKED,'./docroot/','./pwserver.log');
	gotoxy(1,WhereY);writeln('Webserver started, ready to serve');

	{ register the variable handler }
	SetupVariableHandler(@embeddedWebReadParams);
	
	{ register special URL for content generated by this program }
	SetupSpecialURL('/analog/read.html',@DeliverAnalogValues );
	SetupSpecialURL('/digital/read.html',@DeliverDigitalValues );
	SetupSpecialURL('/digital/write.html',@SaveDigitalValues);

	repeat
		serve_request;
		delay(100);
	until Shutdown=true;

	gotoxy(1,WhereY);writeln('Webserver going down..');
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
	NumOfThreads:=1;
	for DeviceCnt:=1 to DeviceTypeMax do begin
		if DeviceList[DeviceCnt]<>'-' then begin
			writeln('starting DeviceHandler for Device:',DeviceList[DeviceCnt]);
			ThreadName[NumOfThreads]:='DeviceHandler '+DeviceList[DeviceCnt];
			ThreadHandle[NumOfThreads]:=BeginThread(@DeviceHandler,pointer(NumOfThreads));

			inc(NumOfThreads);
		end;
	end;

	writeln('Starting Webserver Thread...');
	ThreadName[NumOfThreads]:='Webserver';
	ThreadHandle[NumOfThreads]:=BeginThread(@WebserverThread,pointer(NumOfThreads));

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
