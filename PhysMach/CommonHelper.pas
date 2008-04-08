unit CommonHelper;

{ $Id$ }

{ diese Unit stellt Hilfsunktionen zur Verfügung		}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details		}


INTERFACE

function RunCommand(Command: AnsiString):String;
function BinToInt(binval:string):Integer;
function deHTML(page:AnsiString):AnsiString;


implementation

uses baseunix,unix;

const
	debug=false;


function RunCommand(Command: Ansistring):String;
{ execute external command and capture output of command }
var
	fin,fout 	: text;
	S		: AnsiString;
	Params		: Array[1..10] of AnsiString;

begin
	AssignStream(fin,fout,Command,Params);
	//popen(fin,Command,'r');
	if debug then writeln('Command=',Command,' returned : ',fpgeterrno);
	if fpgeterrno<0 then
		writeln ('error from POpen : errno : ', fpgeterrno);

	
	while not eof (fin) do 
		readln (fin,S);


	pclose(fout);
	pclose(fin);

	if debug then writeln('S=',S);

	RunCommand := S;
end;


function BinToInt(binval:string):Integer;

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
end.
