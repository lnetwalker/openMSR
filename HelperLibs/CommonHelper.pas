unit CommonHelper;

{ $Id$ }

{ diese Unit stellt Hilfsunktionen zur Verfügung		}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}


INTERFACE

function RunCommand(Command: AnsiString):String;
function BinToInt(binval:string):Integer;
function deHTML(page:AnsiString):AnsiString;
procedure debugLOG(msg:string);
function IntToStr(value:LongInt):String;

implementation

uses
{$ifdef Linux}
	baseunix,unix,
{$endif}
{$ifdef Windows}
	Classes, SysUtils, Process,
{$endif}
crt;

const
	debug=false;

var
	LOG	: text;

procedure debugLOG(msg:string);
begin
	gotoxy(1,WhereY);
	writeln(msg);
	writeln(LOG,msg);
end;


function IntToStr(value:LongInt):String;
var dummy : string;

begin
	str(value,dummy);
	IntToStr:=dummy;
end;


function RunCommand(Command: Ansistring):String;
{ execute external command and capture last line of output of command }
var
{$ifdef Linux}
	fin,fout 	: text;
{$endif}
	S		: AnsiString;
	Params		: Array[1..10] of AnsiString;
{$ifdef Windows}
	AProcess	: TProcess;
	Buffer		: string;
	BytesAvailable	: DWord;
	BytesRead	: LongInt;
{$endif}

begin
{$ifdef Windows}
	AProcess := TProcess.Create(nil);
	// Gibt an, welcher Befehl vom Prozess ausgeführt werden soll
	AProcess.CommandLine := Command;

	// Wir definieren eine Option, wie das Programm
	// ausgeführt werden soll. Dies stellt sicher, dass
	// unser Programm nicht vor Beendigung des aufgerufenen
	// Programmes fortgesetzt wird. Außerdem geben wir an,
	// dass wir die Ausgabe lesen wollen
	AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];

	try
		try
			// Startet den Prozess nachdem die Parameter entsprechend
			// gesetzt sind
			AProcess.Execute;

			// Folgendes wird erst nach Beendigung von AProcess ausgeführt

			// Die Ausgabe wird nun  gelesen
			BytesAvailable := AProcess.Output.NumBytesAvailable;
			BytesRead := 0;
			while BytesAvailable>0 do begin
				SetLength(Buffer, BytesAvailable);
				BytesRead := AProcess.OutPut.Read(Buffer[1], BytesAvailable);
				S := S + copy(Buffer,1, BytesRead);
				BytesAvailable := AProcess.Output.NumBytesAvailable;
			end;
		except
			writeln('executing command failed: ',Command);
		end;
	finally
		// TProcess freigeben.
		AProcess.Free;
	end;
{$endif}

{$ifdef Linux}
	{$i-}
	AssignStream(fin,fout,Command,Params);
	{$i+}
	if ( IOResult <> 0 ) then writeln ('CommonHelper: RunCommand - Error assigning stream ! ');
	//popen(fin,Command,'r');
	if debug then writeln('Command=',Command,' returned : ',fpgeterrno);
	if fpgeterrno<0 then
		writeln ('error from POpen : errno : ', fpgeterrno);


	while not eof (fin) do 			// only read the last line
		readln (fin,S);


	pclose(fout);
	pclose(fin);
{$endif}
	if debug then writeln('S=',S);

	RunCommand:=S;
end;


function BinToInt(binval:string):Integer;
{ converts a string with 8 Binary values to the appropriate integer }
{ LSB first, MSB last }

var
	i,k,wert	: Integer;
	power		: array [1..8] of byte =(1,2,4,8,16,32,64,128);

begin
	i:=1;
	k:=1;
	wert:=0;
	while i <= length(binval) do begin				{ wert errechnen }

		if debug then writeln('exec_io_access exec_read_ports Loop: char_pointer=',i,' BinCalcPointer=',k,' Value=',wert);

		case binval[i] of
			'1' : 	begin			{ 1 speichern }
					wert:=wert+power[k];
					inc(k);
				end;
			'0' :	inc(k);			{ 0 merken }
			' ' :	if debug then writeln('blank detected ');	{ blanks ignorieren }
		else							{ fehlerhafter return wert }
			if debug then writeln('exec_io_access ERROR: wrong return value ',binval);
		end;
		inc(i);
	end;
	BinToInt:=wert;
end;



{ removes all HTML tags from a document }
function deHTML(page:AnsiString):AnsiString;
var
	htmlfree		: AnsiString;
	EndTag,StartTag		: LongInt;

begin
	htmlfree:=page;
	if debug then writeln('deHTML original page: ',page);
	{ HTML header wegwerfen }
	EndTag:=pos('>',htmlfree);
	htmlfree:=copy(htmlfree,EndTag+1,length(htmlfree)-EndTag);
	repeat
		StartTag:=pos('<',htmlfree);
		EndTag:=pos('>',htmlfree);
		htmlfree:=copy(htmlfree,1,StartTag-1)+copy(htmlfree,EndTag+1,length(htmlfree));
	until (pos('<',htmlfree)=0);
	if debug then writeln('deHTML`ed page: ',htmlfree);
	deHTML:=htmlfree;
end;



begin
	{$ifdef WIN32}
  assign(LOG,'\temp\debug.log');
  {$endif}
  {$ifdef Linux}
	assign(LOG,'/tmp/debug.log');
	{$endif}
	{$I-}rewrite(LOG);{$I+}
	if (IOResult <> 0 ) then writeln('CommonHelper: Error open logfile');
end.
