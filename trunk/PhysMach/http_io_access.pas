Unit http_io_access;

{ diese Unit stellt Funktionen zum I/O Access via				} 
{ HTTP protocol  zur Verf�gung  						}	
{ If you have improvements please contact me at 				}
{ hartmut@eilers.net								}
{ all code is copyright by Hartmut Eilers and released under			}
{ the GNU GPL see www.gnu.org for license details				}
{ History:									}
{		12.05.2007 first raw hack					}
{		21.05.2007 should work hack					}

{$undef ZAURUS}

INTERFACE


function http_read_ports(io_port:longint):byte;
//function http_read_ports(io_port:longint;byte_value:byte):integer;
function http_write_ports(io_port:longint;byte_value:byte):byte;
function http_hwinit(initdata:string):boolean;

implementation
uses linux
{$ifndef ZAURUS}
,http
{$endif}
;

const	
	debug		= false;

var
	R_URL,W_URL		: string;
	power	: array [1..8] of byte =(1,2,4,8,16,32,64,128);



function BinToInt(binval:string):Integer;
var
	i,k,wert	: Integer;
begin
	i:=1;
	k:=1;
	wert:=0;
	while i <= length(binval) do begin				{ wert errechnen }

		if debug then writeln('html_io_access exec_read_ports Loop: char_pointer=',i,' BinCalcPointer=',k,' Value=',wert);
 
		case binval[i] of
			'1' : 	begin			{ 1 speichern }
					wert:=wert+power[k];
					inc(k);
				end;
			'0' :	inc(k);			{ 0 merken }
			' ' :	if debug then writeln('blank detected ');	{ blanks ignorieren }
		else							{ fehlerhafter return wert }
			if debug then writeln('html_io_access ERROR: wrong return value ',binval);
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


	
function http_read_ports(io_port:longint):byte;

var	
	TmpVal,TmpStrg	: string;
	

begin
	str(io_port,TmpStrg);
	TmpStrg:=R_URL+TmpStrg;
	{$ifndef ZAURUS}
	TmpVal:=deHTML(HttpGet(TmpStrg));
	{$endif}
	if debug then writeln('http_read_ports(',TmpStrg,') returned ',TmpVal);
	http_read_ports:=BinToInt(TmpVal);
end;

{
function http_read_ports(io_port:longint;byte_value:byte):integer;
var	
	TmpVal,TmpStrg	: string;

begin
	str(io_port,TmpStrg);
	TmpStrg:=R_URL+TmpStrg;
}	{$ifndef ZAURUS}
{	TmpVal:=HttpGet(TmpStrg);
}	{$endif}
{	if debug then writeln('http_read_ports(',TmpStrg,') returned ',TmpVal);
	val(TmpVal,http_read_ports);	
end;
}

	
function http_write_ports(io_port:longint;byte_value:byte):byte;	

var	
	TmpVal,TmpStrg,Params	: string;

begin
	{ Params= Ioport,byte_value }
	str(io_port,TmpStrg);
	Params:=TmpStrg+',';
	str(byte_value,TmpStrg);
	Params:=Params+TmpStrg;
	{$ifndef ZAURUS}
	TmpVal:=HttpGet(W_URL+Params);
	{$endif}
	val(TmpVal,http_write_ports);	
end;


function http_hwinit(initdata:string):boolean;
var
	delim : integer;

begin
	delim:=pos('§',initdata);
	R_URL:=copy(initdata,1,delim-1);
	W_URL:=copy(initdata,delim+2,length(initdata)-1-delim-2);
	if debug then writeln('http_hwinit: R_URL=',R_URL,' W_URL=',W_URL);
end;


begin
end.
