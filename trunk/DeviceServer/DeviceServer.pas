program DeviceServer;
{$mode objfpc}

{$M 12048,12048}

{$ifdef MacOSX}
	{$define Linux}
{$endif}

uses 
{$IFDEF Linux} cthreads,BaseUnix,
{$endif}
{$ifdef Windows}
Windows,
{$endif}
PhysMach,webserver,telnetserver,classes,crt,CommonHelper;


{$ifdef MacOSX}
	{$linklib libad4.dylib}
{$endif}
	

{ $Id$ }

{ This software is copyright (c) 2008 by Hartmut Eilers <hartmut@eilers.net> 	}
{ It is distributed under the terms of the GNU GPL V2 see http://www.gnu.org 	}

{ 20.02.2008		Start of project					}
{ 08.03.2008		changed to start one thread per device			}
{ 18.07.2008		added comments,code clearing				}
{ 23.07.2009		DeliverDigitalInputValues accepts more than one IOGroup }
{ 27.05.2010		Port to Mac OS X PowerPC }

const
	Forever=false;
	MaxThreads=25;
	TimeOut=500;

var
	i		: LongInt;
	ThreadHandle	: array[1..MaxThreads] of TThreadId;
	ThreadName	: array[1..MaxThreads] of string;
	ThreadCnt	: array[1..MaxThreads] of LongInt;
	ThreadRPMs	: array[1..MaxThreads] of LongInt;
	shutdown	: Boolean;
	Counter		: LongInt;
	IOGroup		: LongInt;
	ByteValue	: Byte;
	ProtectParams	: TRTLCriticalSection;
	Power		: array [1..8] of byte =(1,2,4,8,16,32,64,128);
	DeviceList	: DeviceTypeArray;
	DeviceCnt,
	NumOfThreads	: LongInt ;
	connectionclose	: boolean;
	DebugOutput	: TRTLCriticalSection;
	SendAsync	: TRTLCriticalSection;
	debug		: boolean;


procedure DSdebugLOG(msg:string);
// This is a wrapper around debugLOG to ensure
// that no debug Messages are crippled due to
// more threads spit out things at the same time
begin
	EnterCriticalSection(DebugOutput);
	debugLOG(msg);
	LeaveCriticalSection(DebugOutput);
end;

// telnet stuff

Procedure TelnetInterpreter;

{ callback procedure for the telnet interpreter }
{ this is the telnet shell of the device server }
{ it's not possible to handover any data	}

var
	Line		: String;
	cmd,hw		: Char;
	pa,va		: LongInt;
	StrVal,RPMs	: String;
	AddrStr		: String;
	i		: Integer;

begin
	Line:=TelnetGetData;
	line:=upcase(line);
	cmd:=line[1];
	hw:=line[3];
	val(copy(line,5,2),pa);
	if length(line)>=7 then
		val(copy(line,7,length(line)-6),va);
	if debug then DSdebugLOG('pa=' + IntToStr(pa) + ' va=' + IntToStr(va));
	case cmd of
		{ read command, next param is a counter input or output }
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
									DSdebugLOG('E[' + IntToStr(pa) + ']=');
								if (eingang[pa])then
									TelnetWriteAnswer('1'+chr(10)+'>')
								else
									TelnetWriteAnswer('0'+chr(10)+'>');
							end;
						'O' :	begin
								if debug then
									DSdebugLOG('A[' + IntToStr(pa) + ']=');
								if (ausgang[pa])then
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
		{ write command, next param is digital or analog output }
		'W' :	begin
				case hw of
					'O' :	begin
							if debug then debugLOG ('O' + IntToStr(pa) + ' ' + IntToStr(va));
							if va=0 then ausgang[pa]:=false
							else ausgang[pa]:=true;
							TelnetWriteAnswer(chr(10)+'>');
						end;
					'I' :	begin
							if debug then debugLOG ('I' + IntToStr(pa) + ' ' + IntToStr(va));
							if va=0 then eingang[pa]:=false
							else eingang[pa]:=true;
							TelnetWriteAnswer(chr(10)+'>');
						end;
					'A' :	begin
						end;
				end;
			end;
		{ help command, issue some ... }
		'H' :	begin
				TelnetWriteAnswer('cmd lines are build like this'+chr(10));
				TelnetWriteAnswer('cmd hardware number [value]'+chr(10));
				TelnetWriteAnswer('cmd=[R|W|H|E|C|S] for read, write, help, end, config and stats'+chr(10));
				TelnetWriteAnswer('hardware=[C|I|O|A] for counter, input, output, analog values'+chr(10));
				TelnetWriteAnswer('Number = Number of line'+chr(10));
				TelnetWriteAnswer('Value= value needed when writing lines'+chr(10));
				TelnetWriteAnswer(chr(10)+'>');
			end;
		{ dump the configuration }
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
		{ status output }
		'S' :	begin
				for i:=1 to NumOfThreads do begin
					str(ThreadCnt[i],StrVal);
					str(ThreadRPMs[i],RPMs);
					TelnetWriteAnswer(ThreadName[i]+'  '+StrVal+'='+RPMs+' loops/second'+chr(10));
				end;
				TelnetWriteAnswer(chr(10)+'>');
			end
		{ unknown kommand }
		else TelnetWriteAnswer('?'+chr(10)+'>'); { unknown command issue ?}
	end;

end;


function TelnetThread(p: pointer):LongInt;
{ this is the telnet thread, setup the interpreter function }
{ and check for incomming requests }

var 
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	DSdebugLOG('started Telnet Thread..' + IntToStr(MySelf));
	TelnetInit(0,'./telnet.log');
	repeat
		connectionclose:=false;
		TelnetSetupInterpreter(@TelnetInterpreter);
		repeat
			TelnetServeRequest('Welcome to Device Server Monitor, use "close" to quit'+chr(10)+'>');	
			delay(100);
			inc(ThreadCnt[MySelf]);
		until connectionclose;
	until shutdown=true;
	TelnetShutDown;
	DSdebugLOG('Telnet Handler going down..' + IntToStr(MySelf));
	TelnetThread:=0;
end;


// the devicehandler - for each configured device one thread to serve it is started

function DeviceHandler(p: pointer):LongInt;
var 
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	DSdebugLOG('started Device Handler Thread..' + IntToStr(MySelf));
	repeat
		PhysMachIOByDevice(DeviceList[MySelf]);
		inc(ThreadCnt[MySelf]);
	until shutdown=true;
	DSdebugLOG('Device Handler going down..' + IntToStr(MySelf));
	DeviceHandler:=0;
end;

// the functions needed for webserver functionality

procedure embeddedWebReadParams;
{ handles any parameters in this case the prameter is always the io_group and maybe a byte_value }
var 
	Url,Params 	: String;
	Trenner		: Byte;

begin
//	EnterCriticalSection(SendAsync);
	Url:=GetURL;

	{ Fragezeichen Abschneiden, daher ab position 2 params lesen }
	Params:=copy(GetParams,2,Length(GetParams));;

	if (pos(',',Params) = 0 ) then begin
		val(params,IOGroup);
		ByteValue:=0;
	end
	else begin
		Trenner:=pos(',',Params);
		val(copy(Params,1,Trenner-1),IOGroup);
		val(copy(Params,Trenner+1,Length(Params)),ByteValue);
	end;



	if debug then begin
		DSdebugLOG('embeddedWeb:> Got Parameters');
		DSdebugLOG('URL=' + Url + ' Parameters=' + Params + ' ' + IntToStr(IOGroup) + ' ' + IntToStr(ByteValue));
	end;
//	LeaveCriticalSection(SendAsync);
end;


// the callbacks for the special URLs 

procedure DeliverAnalogValues;
{ called whenever the analog read page is called }
var
	ValueString,SeitenStart,SeitenEnde,Seite,Values	: string;
	AddressBase					: word;

begin
//	EnterCriticalSection(SendAsync);
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';

	AddressBase:=IOGroup*8-8;

	for i:=1 to 8 do begin
		str(analog_in[AddressBase+i],ValueString);
		Values:=Values+' '+ValueString;
	end;

	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then DSdebugLOG('embeddedWeb:>Sending Page');

	SendPage(100,Seite);
	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
//	LeaveCriticalSection(SendAsync);
end;


procedure WriteAnalogValues;
{ called whenever an analog write request occurs }
var
	SeitenStart,SeitenEnde,Seite,Values,
	Params					: string;
	AddressBase				: word;
	Trenner,i,ValStart			: integer;
	
begin
//	EnterCriticalSection(SendAsync);
	if debug then DSdebugLOG('WriteAnalogValues called....');
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';
	
	{ Parameter auswerten, Fragezeichen ist das erste Zeichen, daher ab pos 2 }
	Params:=copy(GetParams,2,Length(GetParams));
	if debug then DSdebugLOG('WriteAnalogValues->reading params....' + Params);
	{ Der erste Parameter ist der Array Index des 1. Wertes }
	ValStart:=pos(',',Params)+1;
	val(copy(Params,1,ValStart-2),AddressBase);
	{ den ersten Wert wegschneiden }
	Params:=copy(Params,ValStart,Length(Params));
	if debug then DSdebugLOG('WriteAnalogValues->got data: AdrBase: ' + IntToStr(AddressBase) + ' Params: ' + Params);
	i:=0;
	{ Werte lesen und Ausgänge schreiben }
	repeat
	    Trenner:=pos(',',Params);
	    if Trenner=0 then begin
		val(copy(Params,1,Length(Params)),analog_in[AddressBase+i]);
		if debug then DSdebugLOG('WriteAnalogValues->params: ' + Params + ' Trenner ' + IntToStr(Trenner) + ' written ' + IntToStr(analog_in[AddressBase+i]));
	    end
	    else begin
	        val(copy(Params,1,Trenner-1),analog_in[AddressBase+i]);
		Params:=copy(Params,Trenner+1,Length(Params));
		if debug then DSdebugLOG('WriteAnalogValues->params: ' + Params + ' Trenner ' + IntToStr(Trenner) + ' written ' + IntToStr(analog_in[AddressBase+i]));
	    end;
	    inc(i);
	until ( Trenner=0 );

	{ return something usefull }	
	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then DSdebugLOG('embeddedWeb:>Sending Page');
	SendPage(101,Seite);
//	LeaveCriticalSection(SendAsync);
	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
end;


procedure DeliverDigitalInputValues;
{ this procedure reads the corresponding inputs and delivers the values via html }
var
	SeitenStart,SeitenEnde,Seite,Values,
	Params					: string;
	AddressBase				: word;
	Bits,Trenner,Loops,i			: byte;
	IOGroupList				: array [1..64] of byte;

begin
//	EnterCriticalSection(SendAsync);
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';
	Loops:=1;
	
	{ more than one parameter means, that more IO Groups are read }
	//if ( ByteValue <> 0 ) then begin
		{ first we need to reread the parameter List }
		Params:=copy(GetParams,2,Length(GetParams));
		repeat

			if debug then DSdebugLOG('DeliverDigitalValues  Params=' + Params);

			Trenner:=pos(',',Params);
			if (Trenner = 0 ) then Trenner:=1		// read the last param correctly
			else Trenner:=Trenner-1; 
			val(copy(Params,1,Trenner),IOGroupList[Loops]);
			inc(Loops);
			Params:=copy(Params,Trenner+2,Length(Params));
		until ( length(Params)  = 0 );
	//end
	//else
	//	IOGroupList[1]:=IOGroup;
	
	for i:=1 to Loops-1 do begin
		IOGroup:=IOGroupList[i];
	      
		AddressBase:=IOGroup*8-8;

		if debug then DSdebugLOG('DeliverDigitalValues AddressBAse=' + IntToStr(AddressBase));

		for Bits:=1 to 8 do
			if eingang[AddressBase+Bits] then Values:=Values+' '+'1'
			else Values:=Values+' '+'0';

	end;
	Seite:=SeitenStart+Values+SeitenEnde;

	if debug then DSdebugLOG('embeddedWeb:>Sending Page');
	SendPage(102,Seite);
//	LeaveCriticalSection(SendAsync);

	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
end;



procedure DeliverDigitalOutputValues;
{ this procedure reads the corresponding outputs and delivers the values via html }
var
	SeitenStart,SeitenEnde,Seite,Values,
	Params					: string;
	AddressBase				: word;
	Bits,Trenner,Loops,i			: byte;
	IOGroupList				: array [1..64] of byte;

begin
//	EnterCriticalSection(SendAsync);
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';
	Loops:=1;
	
	{ more than one parameter means, that more IO Groups are read }
	//if ( ByteValue <> 0 ) then begin
		{ first we need to reread the parameter List }
		Params:=copy(GetParams,2,Length(GetParams));
		repeat

			if debug then DSdebugLOG('DeliverDigitalOutputValues  Params=' + Params);

			Trenner:=pos(',',Params);
			if (Trenner = 0 ) then Trenner:=1		// read the last param correctly
			else Trenner:=Trenner-1; 
			val(copy(Params,1,Trenner),IOGroupList[Loops]);
			inc(Loops);
			Params:=copy(Params,Trenner+2,Length(Params));
		until ( length(Params)  = 0 );
	//end
	//else
	//	IOGroupList[1]:=IOGroup;
	
	for i:=1 to Loops-1 do begin
		IOGroup:=IOGroupList[i];
	      
		AddressBase:=IOGroup*8-8;

		if debug then DSdebugLOG('DeliverDigitalOutputValues AddressBAse=' + IntToStr(AddressBase));

		for Bits:=1 to 8 do
			if ausgang[AddressBase+Bits] then Values:=Values+' '+'1'
			else Values:=Values+' '+'0';

	end;
	Seite:=SeitenStart+Values+SeitenEnde;

	if debug then DSdebugLOG('embeddedWeb:>Sending Page');
	SendPage(103,Seite);
//	LeaveCriticalSection(SendAsync);

	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
end;




procedure WriteInputValues;
// this procedure writes the values to the corresponding inputs
var
	SeitenStart,SeitenEnde,Seite,Values	: string;
	AddressBase				: word;
	Bits					: byte;

begin
//	EnterCriticalSection(SendAsync);
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';

	{ set the bits in the ausgang[n] array in respect of io_group}
	AddressBase:=IOGroup*8-8;

	for Bits:=8 downto 1 do begin
		if (ByteValue-Power[Bits])>=0 then begin
			Eingang[AddressBase+Bits]:=true;
			ByteValue:=ByteValue-Power[Bits];
			Values:=Values+' 1';
		end
		else begin
			Eingang[AddressBase+Bits]:=false;
			Values:=Values+' 0';
		end;
	end;

	{ return something usefull }	
	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then DSdebugLOG('embeddedWeb:>Sending Page');
	SendPage(104,Seite);
//	LeaveCriticalSection(SendAsync);
	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
end;





procedure WriteOutputValues;
// This procedure writes the values to the corresponding outputs
var
	SeitenStart,SeitenEnde,Seite,Values	: string;
	AddressBase				: word;
	Bits					: byte;

begin
//	EnterCriticalSection(SendAsync);
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';
	DSdebugLOG(' DS:WriteOutputValues, got ' + IntToStr(ByteValue) + ' for Address ' + IntToStr(IOGroup) );
	{ set the bits in the ausgang[n] array in respect of io_group}
	AddressBase:=IOGroup*8-8;

	for Bits:=8 downto 1 do begin
		if (ByteValue-Power[Bits])>=0 then begin
			Ausgang[AddressBase+Bits]:=true;
			ByteValue:=ByteValue-Power[Bits];
			Values:=Values+' 1';
		end
		else begin
			Ausgang[AddressBase+Bits]:=false;
			Values:=Values+' 0';
		end;
	end;

	{ return something usefull }	
	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then DSdebugLOG('embeddedWeb:>Sending Page');
	SendPage(105,Seite);
//	LeaveCriticalSection(SendAsync);
	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
end;



function WebserverThread(p: Pointer):LongInt;
{ the real serving thread }
var 
	MySelf		: LongInt;
	

begin
	MySelf:=longint(p);
	DSdebugLOG('started Webserver Thread, going to start Server...');
	{ start the webserver with IP, Port, Document Root and Logfile }
	{ start on all available interfaces }
	start_server('0.0.0.0',10080,BLOCKED,'docroot','./pwserver.log',NONBLOCKED,debug);
	DSdebugLOG('Webserver started, ready to serve');

	{ register the variable handler }
	SetupVariableHandler(@embeddedWebReadParams);
	
	{ register special URL for content generated by this program }
	SetupSpecialURL('/analog/read.html',@DeliverAnalogValues );
	SetupSpecialURL('/analog/write.html',@WriteAnalogValues );
	SetupSpecialURL('/digital/ReadOutputValues.html',@DeliverDigitalOutputValues );
	SetupSpecialURL('/digital/ReadInputValues.html',@DeliverDigitalInputValues );
	SetupSpecialURL('/digital/WriteOutputValues.html',@WriteOutputValues);
	SetupSpecialURL('/digital/WriteInputValues.html',@WriteInputValues);

	repeat
//		EnterCriticalSection(ProtectParams);
		    serve_request;
//		LeaveCriticalSection(ProtectParams);
		if debug then DSdebugLOG('Webserver served Client...');
		inc(ThreadCnt[MySelf]);
//		delay(100);
	until Shutdown=true;

	DSdebugLOG('Webserver going down..');
	WebserverThread:=0;
	TelnetShutDown;
end;					{ Webserver Thread end }


function StatisticsThread(p: pointer):LongInt;
// claculates the number of threadruns for each thread

var
time1,time2,TimeDiff	: Cardinal;
OldThreadCnt		: array[1..MaxThreads] of LongInt;
i			: byte;
MySelf			: LongInt;
{$ifdef Windows}
      st 		: systemtime;
{$endif}


begin
	MySelf:=longint(p);
	DSdebugLOG('started Statistics Thread...' + IntToStr(MySelf));
	repeat
		// get the current time in seconds and save the counter for each thread
		{$ifdef Linux}
		  time1:=fpTime;
		{$endif}
		{$ifdef Windows}
		  getlocaltime( st );
		  time1:= st.wsecond;
		{$endif}
		for i:=1 to MaxThreads do OldThreadCnt[i]:=ThreadCnt[i];
		delay(6000);	// wait some time
		// check new time and counters
		{$ifdef Linux}
		  time2:=fpTime;
		{$endif}
		{$ifdef Windows}
		  getlocaltime( st );
		  time2:= st.wsecond;
		{$endif}
		TimeDiff:=time2-time1;
		// calculate how much loops each thread did in one second
		if TimeDiff > 0 then
			for i:=1 to MaxThreads do
				ThreadRPMs[i]:=round((ThreadCnt[i]-OldThreadCnt[i])/TimeDiff);
		inc(ThreadCnt[MySelf]);
	until Shutdown=true;
	DSdebugLOG('stopping Statistic Thread ');
	StatisticsThread:=0;
end;


function TimeControlThread(p: pointer):LongInt;
// thread to change Input and Output variables time dependend
var 
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	DSdebugLOG('started Time Control Thread...' + IntToStr(MySelf));
	repeat
		delay(10000);
		inc(ThreadCnt[MySelf]);
	until Shutdown=true;
	DSdebugLOG('stopping Thread Time Control');
	TimeControlThread:=0;
end;



// the Main program

begin					{ Main program }
	// initialize Hardware
	PhysMachInit;
	PhysMachloadCfg('DeviceServer.cfg');
	writeln('detected Hardware: ',HWPlatform);
	PhysMachWriteDigital;
	// get list of installed devices
	DeviceList:=PhysMachGetDevices;

	// commandline parameters
	if ( paramcount > 0 ) then begin
		if (paramstr(1)='d') then debug:=true
		else debug:=false;
	end;

	Counter:=0;
	InitCriticalSection(ProtectParams);
	InitCriticalSection(DebugOutput);
	InitCriticalSection(SendAsync);

	// start threads, for every configured device one thread
	// the device servers need to be started as first threads,
	// because they use the threadpointer as pointer to the 
	// device list index
	NumOfThreads:=1;
	for DeviceCnt:=1 to DeviceTypeMax do begin
		if DeviceList[DeviceCnt]<>'-' then begin
			DSdebugLOG('starting DeviceHandler for Device:' + DeviceList[DeviceCnt]);
			ThreadName[NumOfThreads]:='DeviceHandler '+DeviceList[DeviceCnt];
			ThreadHandle[NumOfThreads]:=BeginThread(@DeviceHandler,pointer(NumOfThreads));
			ThreadCnt[NumOfThreads]:=0;
			inc(NumOfThreads);
		end;
	end;

	// start the webserver thread
	DSdebugLOG('Starting Webserver Thread...');
	ThreadName[NumOfThreads]:='Webserver';
	ThreadHandle[NumOfThreads]:=BeginThread(@WebserverThread,pointer(NumOfThreads));

	// start the telnet thread 
	inc(NumOfThreads);
	DSdebugLOG('Starting Telnet Thread...');
	ThreadName[NumOfThreads]:='Telnet Thread';
	ThreadHandle[NumOfThreads]:=BeginThread(@TelnetThread,pointer(NumOfThreads));

	// start the TimeControl thread
	inc(NumOfThreads);
	DSdebugLOG('Starting TimeControl Thread...');
	ThreadName[NumOfThreads]:='TimeCtrl Thread';
	ThreadHandle[NumOfThreads]:=BeginThread(@TimeControlThread,pointer(NumOfThreads));

	// start the statistic thread
	inc(NumOfThreads);
	DSdebugLOG('Starting Statistics Thread...');
	ThreadName[NumOfThreads]:='Stats Thread';
	ThreadHandle[NumOfThreads]:=BeginThread(@StatisticsThread,pointer(NumOfThreads));

	// fool around and wait for the end
	repeat
		repeat
			delay(10*TimeOut);
			if debug then DSdebugLOG('idleloop...');
		until keypressed;
	until readkey='e';

	// stop threads
	shutdown:=true;

	// wait for threads to finish
	DSdebugLOG('waiting for threads to finish...');
	for i:=1 to NumOfThreads do begin
		DSdebugLOG(' Waiting for ' + ThreadName[i] + ' to finish');
		WaitForThreadTerminate(ThreadHandle[i],TimeOut);
		DSdebugLOG( ThreadName[i] + ' ended');
	end;

end.
