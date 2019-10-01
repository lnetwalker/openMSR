program DeviceServer;
{$mode objfpc}

{$M 12048,12048}

{$define enhStats}

{$ifdef MIPS}
  {$define Linux}
{$endif}

{$ifdef MacOSX}
	{$define Linux}
	{$undef enhStats}
{$endif}

{$ifdef Windows}
	{$undef enhStats}
{$endif}

{$ifdef CPU64}
	{$define Linux64}
{$endif}

uses
{$IFDEF Linux} cthreads,BaseUnix,MQTT, FieldDevice,
{$endif}
{$ifdef Win32}
Windows,
{$endif}
{$ifndef MIPS}
telnetserver,
{$endif}
PhysMach,webserver,classes,crt,CommonHelper,StringCut,INIFiles,sysutils;


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
{ 18.06.2017		MQTT Client Support }

const
	Forever=false;
	MaxThreads=25;
	TimeOut=500;

type MQTTStates = (
	                           CONNECT,
	                           WAIT_CONNECT,
	                           RUNNING,
	                           FAILING
	                          );

{$IFDEF Linux}
type
	  // Define class for the MQTT connection
	  TMQTTThread = object
	    strict
	    private
	      MQTTClient    : TMQTTClient;
	      pingCounter   : integer;
		  	pingTimer     : integer;
        state         : MQTTStates;
		  	message       : ansistring;
	      pubTimer 	    : integer;
	      connectTimer 	: integer;
	    public
        procedure setup (iniFile:string);
	      procedure run ();
	    end;
{$endif}

var
	i		: LongInt;
	ThreadHandle		: array[1..MaxThreads] of TThreadId;
	ThreadName	    : array[1..MaxThreads] of string;
	ThreadCnt	    	: array[1..MaxThreads] of LongInt;
	ThreadRPMs			: array[1..MaxThreads] of LongInt;
	shutdown				: Boolean;
	Counter					: LongInt;
	IOGroup					: LongInt;
	ByteValue, BitVal	: Byte;
	ProtectParams		: TRTLCriticalSection;
	Power						: array [1..8] of byte =(1,2,4,8,16,32,64,128);
	DeviceList			: DeviceTypeArray;
	DeviceCnt,
	NumOfThreads		: LongInt ;
	connectionclose	: boolean;
	DebugOutput			: TRTLCriticalSection;
	SendAsync				: TRTLCriticalSection;
	debug						: boolean;
	Webparams				:	StringArray;
	{$IFDEF Linux}
	MQTTThread 			: TMQTTThread;
	FieldDeviceStorage : TFieldDeviceObject;
	{$endif}
	Configfile			: String;
	paramcnt				: byte;
	DebugResult			: boolean;


procedure DSdebugLOG(msg:string);
// This is a wrapper around debugLOG to ensure
// that no debug Messages are crippled due to
// more threads spit out things at the same time
begin
	EnterCriticalSection(DebugOutput);
	debugLOG('DevSrv',2,msg);
	LeaveCriticalSection(DebugOutput);
end;

{$IFDEF Linux}
// MQTT client stuff
procedure TMQTTThread.setup(iniFile:string);
// setup the needed stuff eg server settings
// see also http://wiki.freepascal.org/Using_INI_Files/de
var
	INI							: TINIFile;
	PublishValues		: TStringList;
	Hostname				:	String;
	Port						: Word;
	MQTTAction			: TMQTTAction;
	MQTTIOType			: TDevTyp;
	INIvars					: StringArray;
	MQTTvars				: StringArray;
	loop						: byte;
	SectionLoop			: byte;
	IOSections			: array[1..6] of string = ('PublishOutput','PublishInput','PublishAnalog','SubscribeInput','SubscribeOutput','SubscribeAnalog');

begin
	// get needed Parameters from ini file
	INI := TINIFile.Create(iniFile);
	// get the MQTT Host data
	Hostname:=INI.ReadString('MQTT','Host','10.63.9.41');
	Port:=StrToInt(INI.ReadString('MQTT','Port','1883'));
	DSdebugLOG('MQTT Connecting to '+Hostname+' on Port '+IntToStr(Port));
	// get the config data for the topics
	PublishValues:= TStringList.Create;
	// go through the sections of the INI file and setup publishing and subscriptions
	DSdebugLOG('reading MQTT inifile');
	for SectionLoop:=1 to length(IOSections) do begin
		DSdebugLOG('reading Section: ' + IOSections[SectionLoop]);
		// check what action to do
		if ( Pos('Publish',IOSections[SectionLoop]) > 0 ) then
			MQTTAction:=p
		else
			MQTTAction:=s;

		// check the Devicetype
		if ( Pos('Input',IOSections[SectionLoop]) > 0 ) then
			MQTTIOType:=input
		else if ( Pos('Output',IOSections[SectionLoop]) > 0 ) then
				MQTTIOType:=output
			else
				MQTTIOType:=analog;

		INI.ReadSectionValues(IOSections[SectionLoop],PublishValues);
		// example of the output: 1=/openMSR/BinOut/1,2=/openMSR/BinOut/2
		INIvars:=StringSplit(PublishValues.CommaText,',');
		DSdebugLOG('L ' + IntToStr(GetNumberOfElements(PublishValues.CommaText,',')) + ' ');
		for loop:=1 to GetNumberOfElements(PublishValues.CommaText,',') do begin
				MQTTvars:=StringSplit(INIvars[loop],'=');
				DSdebugLOG('Inistring: ' + INIvars[loop] );
				FieldDeviceStorage.AddDevice(MQTTIOType,MQTTAction,MQTTvars[2],StrToInt(MQTTvars[1]));
				DSdebugLOG('add topic: '+MQTTvars[2]);
		end;
	end;
	// now the subscriptions
	MQTTAction:=s;
	state := CONNECT;
	MQTTClient := TMQTTClient.Create(Hostname, Port);
	DSdebugLOG('MQTT initialized ' + IntToStr(FieldDeviceStorage.GetDeviceCount()));
end;


procedure TMQTTThread.run();
// publish and receive MQTT messages on the configured topics

var
	msg : TMQTTMessage;
	ack : TMQTTMessageAck;
	DeviceTyp		: TDevTyp;
	Action			: TMQTTAction;
	workingTopic	: String;
	DeviceNumber	: Word;
	TopicCounter	: Word;
	TopicValue		: Integer;
	LastRunIN		: array[1..io_max] of boolean;
	LastRunOUT		: array[1..io_max] of boolean;
	LastRunAnalog	: array[1..analog_max] of smallint;
	publish			: boolean;
	ConvertedNumber : integer;


begin
	//write ('run..');
	//writeln(state);
	message :='remove me';

	case state of
			CONNECT :
									begin
										// Connect to MQTT server
										pingCounter := 0;
										pingTimer := 0;
										pubTimer := 0;
										connectTimer := 0;
										MQTTClient.Connect;
//										if ( not (MQTTClient.isConnected)) then begin
//											writeln (' error creating client connection ');
//										end;
										state := WAIT_CONNECT;
									end;
			WAIT_CONNECT :
									begin
										// Can only move to RUNNING state on recieving ConnAck
										connectTimer := connectTimer + 1;
										if connectTimer > 300 then begin
											DSdebugLOG('DeviceServer MQTT Error: ConnAck time out.');
											state := FAILING;
										end;
									end;
			RUNNING :
									begin
										// MQTT Publish stuff
										for TopicCounter:=1 to FieldDeviceStorage.GetDeviceCount() do begin
											FieldDeviceStorage.GetDeviceInfo(TopicCounter,DeviceTyp,Action,workingTopic,DeviceNumber);
											publish:=false;
											case DeviceTyp of
												input:
													if  ( eingang[DeviceNumber] <> LastRunIN[DeviceNumber] ) then begin
														if (eingang[DeviceNumber]) then TopicValue:=1
														else TopicValue:=0;
														publish:=true;
													end;
												output:
													if  ( ausgang[DeviceNumber] <> LastRunOUT[DeviceNumber] ) then begin
														if (ausgang[DeviceNumber]) then TopicValue:=1
														else TopicValue:=0;
														publish:=true;
													end;
												analog:
												if  ( analog_in[DeviceNumber] <> LastRunAnalog[DeviceNumber] ) then begin
													TopicValue:=analog_in[DeviceNumber];
													publish:=true;
												end;
											end;
											if pubTimer mod 1 = 0 then
												if ( publish ) then
													if not MQTTClient.Publish(workingTopic, IntToStr(TopicValue)) then begin
														DSdebugLOG('DeviceServer MQTT Error: Publish Failed.');
														state := FAILING;
													end;
										end;
										LastRunIN:=eingang;
										LastRunOUT:=ausgang;
										LastRunAnalog:=analog_in;
										pubTimer := pubTimer + 1;

										// Ping the MQTT server occasionally
										if (pingTimer mod 100) = 0 then
											begin
												// Time to PING !
												//writeln('Ping..');
												if not MQTTClient.PingReq then
													begin
														DSdebugLOG('DeviceServer MQTT Error: PingReq Failed.');
														state := FAILING;
													end;
												pingCounter := pingCounter + 1;
												// Check that pings are being answered
												if pingCounter > 3 then
													begin
														DSdebugLOG('DeviceServer MQTT Error: Ping timeout.');
														state := FAILING;
													end;
											end;
										pingTimer := pingTimer + 1;
									end;
			FAILING :
									begin
										MQTTClient.ForceDisconnect;
										state := CONNECT;
									end;
		end;

		// Read incomming MQTT messages.
		repeat
			msg := MQTTClient.getMessage;
			if Assigned(msg) then	begin
				// check the topic and get the needed data to handle the subscription
				writeln ('getMessage: ' + msg.topic + ' Payload: ' + msg.payload);
				FieldDeviceStorage.GetTopicInfo(msg.topic,DeviceTyp ,Action ,DeviceNumber);
				case DeviceTyp of
					input		:
									if ( msg.payload = '1') then
										eingang[DeviceNumber]:=true
									else
										eingang[DeviceNumber]:=false;
					output	:
									if ( msg.payload = '1') then
										ausgang[DeviceNumber]:=true
									else
										ausgang[DeviceNumber]:=false;
					analog	: begin
									writeln('DS-MQTT: received topic payload: ' ,IntegerInString(msg.payload));
									analog_in[DeviceNumber]:=IntegerInString(msg.payload);
									writeln('Saved as analog_in[',DeviceNumber,']');
									end;

				end;
				// Important to free messages here.
				msg.free;
			end;
		until not Assigned(msg);

		// Read incomming MQTT message acknowledgments
		repeat
			ack := MQTTClient.getMessageAck;
			if Assigned(ack) then begin
				case ack.messageType of
						CONNACK :
											begin
												if ack.returnCode = 0 then
													begin
														// loop over the configured MQTT devices and make MQTT subscriptions
														for TopicCounter:=1 to FieldDeviceStorage.GetDeviceCount() do begin
															FieldDeviceStorage.GetDeviceInfo(TopicCounter,DeviceTyp,Action,workingTopic,DeviceNumber);
															if ( Action = s ) then
																MQTTClient.Subscribe(workingTopic);
														end;
														// Enter the running state
														state := RUNNING;
													end
												else
													state := FAILING;
											end;
						PINGRESP :
											 begin
												 //writeln ('PING! PONG!');
												 // Reset ping counter to indicate all is OK.
												 pingCounter := 0;
											 end;
						SUBACK :
											 begin
												 //write   ('SUBACK: ');
												 //write   (ack.messageId);
												 //write   (', ');
												 //writeln (ack.qos);
											 end;
						UNSUBACK :
											 begin
												 //write   ('UNSUBACK: ');
												 //writeln (ack.messageId);
											 end;
					end;
				end;
			// Important to free messages here.
			ack.free;
		until not Assigned(ack);
		sleep(100);
end;


{$ifdef linux64}
function MQTTHandler(p: pointer):Int64;
{$else}
function MQTTHandler(p: pointer):LongInt;
{$endif}
var
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	writeln('started MQTT Handler Thread..' + IntToStr(MySelf));
	repeat
		MQTTThread.run;
		inc(ThreadCnt[MySelf]);
	until shutdown=true;
	writeln('MQTT Handler going down..' + IntToStr(MySelf));
	MQTTHandler:=0;
end;

{$endif}

// telnet stuff
{$ifndef MIPS}
Procedure TelnetInterpreter;

{ callback procedure for the telnet interpreter }
{ this is the telnet shell of the device server }
{ it's not possible to handover any data	}

var
	Line				: String;
	cmd,hw			: Char;
	pa,va				: LongInt;
	StrVal,RPMs	: String;
	AddrStr			: String;
	i						: Integer;

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
							if debug then DSdebugLOG ('O' + IntToStr(pa) + ' ' + IntToStr(va));
							if va=0 then ausgang[pa]:=false
							else ausgang[pa]:=true;
							TelnetWriteAnswer(chr(10)+'>');
						end;
					'I' :	begin
							if debug then DSdebugLOG ('I' + IntToStr(pa) + ' ' + IntToStr(va));
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

 {$ifdef linux64}
function TelnetThread(p: pointer):Int64;
 {$else}
function TelnetThread(p: pointer):LongInt;
 {$endif}
{ this is the telnet thread, setup the interpreter function }
{ and check for incomming requests }

var
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	writeln('started Telnet Thread..' + IntToStr(MySelf));
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
	Writeln('Telnet Handler going down..' + IntToStr(MySelf));
	TelnetThread:=0;
end;
{$endif} // MIPS

// the devicehandler - for each configured device one thread to serve it is started
{$ifdef linux64}
function DeviceHandler(p: pointer):Int64;
{$else}
function DeviceHandler(p: pointer):LongInt;
{$endif}
var
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	Writeln('started Device Handler Thread..' + IntToStr(MySelf));
	repeat
		PhysMachIOByDevice(DeviceList[MySelf]);
		inc(ThreadCnt[MySelf]);
	until shutdown=true;
	Writeln('Device Handler going down..' + IntToStr(MySelf));
	DeviceHandler:=0;
end;

// the functions needed for webserver functionality

procedure embeddedWebReadParams;
{ handles any parameters in this case the prameter is always the io_group and maybe a byte_value }
var
	Url,Params 	: String;
	Trenner		: Byte;
	NumberOfWebparams : Byte;

begin
//	EnterCriticalSection(SendAsync);
	Url:=GetURL;

	{ Fragezeichen Abschneiden, daher ab position 2 params lesen }
	Params:=copy(GetParams,2,Length(GetParams));;
	Webparams:=StringSplit(Params,',');
	NumberOfWebparams:=GetNumberOfElements(Params,',');

	case NumberOfWebparams of
			1: begin
					val(Webparams[1],IOGroup);
					ByteValue:=0;
					BitVal:=0;
				end;

			2: begin
					val(Webparams[1],IOGroup);
					val(Webparams[2],ByteValue);
					BitVal:=0;
				end;

			3: begin
						val(Webparams[1],IOGroup);
						val(Webparams[2],ByteValue);
						val(Webparams[3],BitVal);
				end;
	end;

	if debug then begin
		DSdebugLOG('embeddedWeb:> Got Parameters');
		DSdebugLOG('URL=' + Url + ' Parameters=' + Params + ' ' + IntToStr(IOGroup) + ' ' + IntToStr(ByteValue)+ ' ' + IntToStr(BitVal));
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
	//endprocedure
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

	{ set the bits in the eingang[n] array in respect of io_group}
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
	//DSdebugLOG(' DS:WriteOutputValues, got ' + IntToStr(ByteValue) + ' for Address ' + IntToStr(IOGroup) );
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




procedure WriteInputBit;
// this procedure writes the value to the corresponding input bit
var
	SeitenStart,SeitenEnde,Seite,Values	: string;
	AddressBase				: word;
	Bits							: byte;

begin
//	EnterCriticalSection(SendAsync);
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';

	{ set the bit in the eingang[n] array in respect of io_group and Bit number}
	AddressBase:=IOGroup*8-8;

	if BitVal=0 then
		Eingang[AddressBase+ByteValue]:=false
	else
		Eingang[AddressBase+ByteValue]:=true;

	{ return something usefull }
	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then DSdebugLOG('embeddedWeb:>Sending Page');
	SendPage(106,Seite);
//	LeaveCriticalSection(SendAsync);
	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
end;


procedure WriteOutputBit;
// This procedure writes the value to the corresponding output Bit
var
	SeitenStart,SeitenEnde,Seite,Values	: string;
	AddressBase				: word;
	Bits							: byte;

begin
//	EnterCriticalSection(SendAsync);
	inc(Counter);
	SeitenStart:='<html><body>';
	SeitenEnde:=' </body></html>';
	Values:='';
	DSdebugLOG(' DS:WriteOutputValues, got ' + IntToStr(ByteValue) + ' for Address ' + IntToStr(IOGroup) );
	{ set the bits in the ausgang[n] array in respect of io_group}
	AddressBase:=IOGroup*8-8;

	if BitVal=0 then
		Ausgang[AddressBase+ByteValue]:=false
	else
		Ausgang[AddressBase+ByteValue]:=true;

	{ return something usefull }
	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then DSdebugLOG('embeddedWeb:>Sending Page');
	SendPage(107,Seite);
//	LeaveCriticalSection(SendAsync);
	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
end;



procedure serveStats;
// shows the statistic data via web
var
	SeitenStart,
	SeitenEnde,
	StrVal,RPMs,
	zeile,
	ThreadNumber	: String;
	Values,Seite	: AnsiString;
	j		: Integer;
	F		: Text;

begin
	values:='';
{$ifdef enhStats}
	// read the /proc/cpuinfo
	values:=values + '<h2>DeviceServer CPU Information</h2><pre>';
	assign(F,'/proc/cpuinfo');
	reset(F);
	while ( not( eof(F))) do begin
	  readln(F,zeile);
	  values:=values + zeile + '<br>';
	end;
	values:=values + '</pre>';
	close(F);
{$endif}
	EnterCriticalSection(SendAsync);
	SeitenStart:='<html><title>Statistics</title><body>';
	SeitenEnde:=' </table></body></html>';
	values:=values + '<h2>DeviceServer Runtime Stats</h2>';
	str(NumOfThreads,StrVal);
	values:=values + 'Number of running Threads ' + StrVal + '<br><table border=1>';
	for j:=1 to NumOfThreads do begin
	  str(ThreadCnt[j],StrVal);
	  str(ThreadRPMs[j],RPMs);
	  str(j,ThreadNumber);
	  values:=values + '<tr><td>' + ThreadNumber + '</td><td>' + ThreadName[j] + '</td><td>' + StrVal + '</td><td>' + RPMs + ' </td><td>loops/second</td></tr>';
	end;
	{ return something usefull }
	Seite:=SeitenStart+Values+SeitenEnde;
	if debug then DSdebugLOG('embeddedWeb:>Sending Statistics Page');
	SendPage(106,Seite);
	if debug then DSdebugLOG('embeddedWeb:>Page Send, finished');
	LeaveCriticalSection(SendAsync);
end;


{$ifdef linux64}
function WebserverThread(p: Pointer):Int64;
{$else}
function WebserverThread(p: Pointer):LongInt;
{$endif}

{ the real serving thread }
var
	MySelf		: LongInt;


begin
	MySelf:=longint(p);
	Writeln('started Webserver Thread, going to start Server...');
	{ start the webserver with IP, Port, Document Root and Logfile }
	{ start on all available interfaces }
	start_server('0.0.0.0',10080,BLOCKED,'docroot','./pwserver.log',NONBLOCKED,debug);
	Writeln('Webserver started, ready to serve');

	{ register the variable handler }
	SetupVariableHandler(@embeddedWebReadParams);

	{ register special URL for content generated by this program }
	SetupSpecialURL('/analog/read.html',@DeliverAnalogValues );
	SetupSpecialURL('/analog/write.html',@WriteAnalogValues );
	SetupSpecialURL('/digital/ReadOutputValues.html',@DeliverDigitalOutputValues );
	SetupSpecialURL('/digital/ReadInputValues.html',@DeliverDigitalInputValues );
	SetupSpecialURL('/digital/WriteOutputValues.html',@WriteOutputValues);
	SetupSpecialURL('/digital/WriteInputValues.html',@WriteInputValues);
	SetupSpecialURL('/digital/SetInputBit.html',@WriteInputBit);
	SetupSpecialURL('/digital/SetOutputBit.html',@WriteOutputBit);
	SetupSpecialURL('/stats.html',@serveStats);

	repeat
//		EnterCriticalSection(ProtectParams);
		    serve_request;
//		LeaveCriticalSection(ProtectParams);
		if debug then DSdebugLOG('Webserver served Client...');
		inc(ThreadCnt[MySelf]);
//		delay(100);
	until Shutdown=true;

	writeln('Webserver going down..');
	WebserverThread:=0;
	{$ifndef MIPS}
	TelnetShutDown;
	{$endif}
end;					{ Webserver Thread end }


{$ifdef linux64}
function StatisticsThread(p: pointer):Int64;
{$else}
function StatisticsThread(p: pointer):LongInt;
{$endif}
// claculates the number of threadruns for each thread

var
time1,time2,TimeDiff	: Cardinal;
OldThreadCnt		: array[1..MaxThreads] of LongInt;
i								: byte;
MySelf					: LongInt;
{$ifdef Windows}
      st 				: systemtime;
{$endif}


begin
	MySelf:=longint(p);
	writeln('started Statistics Thread...' + IntToStr(MySelf));
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
	writeln('stopping Statistic Thread ');
	StatisticsThread:=0;
end;


{$ifdef linux64}
function TimeControlThread(p: pointer):Int64;
{$else}
function TimeControlThread(p: pointer):LongInt;
{$endif}
// thread to change Input and Output variables time dependend
var
	MySelf		: LongInt;

begin
	MySelf:=longint(p);
	writeln('started Time Control Thread...' + IntToStr(MySelf));
	repeat
		delay(10000);
		inc(ThreadCnt[MySelf]);
	until Shutdown=true;
	Writeln('stopping Thread Time Control');
	TimeControlThread:=0;
end;



// the Main program

begin					{ Main program }
	debug:=false;
	Configfile:='';
	// commandline parameters
	if ( paramcount > 0 ) then
		for paramcnt:=1 to paramcount do begin
	    if (paramstr(paramcnt)='-d') then debug:=true;
			if (paramstr(paramcnt)='-c') then begin
				Configfile:= paramstr(paramcnt+1);
			end;
		end;
	if ( debug ) then
		if (debugFilename('DevSrv.dbg')) <> 0 then begin
			writeln('Error Couldnt open debuglogfile');
			halt(1);
		end
		else
			begin
				DebugResult:=PhysMachDebug(true);
			end;
	if (Configfile='') then Configfile:='DeviceServer.cfg';
	// initialize Hardware
	PhysMachInit;
	PhysMachloadCfg(Configfile);
	writeln('detected Hardware: ',HWPlatform);
	PhysMachWriteDigital;
	// get list of installed devices
	DeviceList:=PhysMachGetDevices;

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
			Writeln('starting DeviceHandler for Device:' + DeviceList[DeviceCnt]);
			delay(500);
			ThreadName[NumOfThreads]:='DeviceHandler '+DeviceList[DeviceCnt];
			ThreadHandle[NumOfThreads]:=BeginThread(@DeviceHandler,pointer(NumOfThreads));
			ThreadCnt[NumOfThreads]:=0;
			inc(NumOfThreads);
		end;
	end;

	// start the webserver thread
	writeln('Starting Webserver Thread...');
	delay(500);
	ThreadName[NumOfThreads]:='Webserver';
	ThreadHandle[NumOfThreads]:=BeginThread(@WebserverThread,pointer(NumOfThreads));

{$ifndef MIPS}
	// start the telnet thread
	inc(NumOfThreads);
	Writeln('Starting Telnet Thread...');
	delay(500);
	ThreadName[NumOfThreads]:='Telnet Thread';
	ThreadHandle[NumOfThreads]:=BeginThread(@TelnetThread,pointer(NumOfThreads));
{$endif}

	// start the TimeControl thread
	inc(NumOfThreads);
	writeln('Starting TimeControl Thread...');
	delay(500);
	ThreadName[NumOfThreads]:='TimeCtrl Thread';
	ThreadHandle[NumOfThreads]:=BeginThread(@TimeControlThread,pointer(NumOfThreads));

	// start the statistic thread
	inc(NumOfThreads);
	writeln('Starting Statistics Thread...');
	delay(500);
	ThreadName[NumOfThreads]:='Stats Thread';
	ThreadHandle[NumOfThreads]:=BeginThread(@StatisticsThread,pointer(NumOfThreads));

{$IFDEF Linux}
	// start the MQTT thread
	if ( FileExists('MQTT.ini') ) then begin
		inc(NumOfThreads);
		MQTTThread.setup('MQTT.ini');
		writeln('Starting MQTT Thread...');
		delay(500);
		ThreadName[NumOfThreads]:='MQTT Thread';
		ThreadHandle[NumOfThreads]:=BeginThread(@MQTTHandler,pointer(NumOfThreads));
	end;
{$endif}

	// fool around and wait for the end
	repeat
		repeat
			delay(10*TimeOut);
			if debug then DSdebugLOG('idleloop...');
			// Main application loop must call this else we leak threads!
			//CheckSynchronize;
		until keypressed;
	until (( readkey='e' ) or ( readkey='q'));

	// stop threads
	shutdown:=true;
	// disable hardware
	PhysMachEnd;

	// wait for threads to finish
	Writeln('waiting for threads to finish...');
	for i:=1 to NumOfThreads do begin
		writeln(' Waiting for ' + ThreadName[i] + ' to finish');
		WaitForThreadTerminate(ThreadHandle[i],TimeOut);
		writeln( ThreadName[i] + ' ended');
	end;

end.
