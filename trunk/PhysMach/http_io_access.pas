Unit http_io_access;

{ diese Unit stellt Funktionen zum I/O Access via				} 
{ HTTP protocol  zur Verf�gung  								}	
{ If you have improvements please contact me at 				}
{ hartmut@eilers.net											}
{ all code is copyright by Hartmut Eilers and released under	}
{ the GNU GPL see www.gnu.org for license details				}
{ History:														}
{		12.05.2007 first raw hack								}
{		21.05.2007 should work hack								}

{$define ZAURUS}

INTERFACE


function http_read_ports(io_port:longint):byte;
function http_read_ports(io_port:longint;byte_value:byte):integer;
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

	
function http_read_ports(io_port:longint):byte;

var	
	TmpVal,TmpStrg	: string;

begin
	str(io_port,TmpStrg);
	{$ifndef ZAURUS}
	TmpVal:=HttpGet(R_URL+TmpStrg);
	{$endif}
	val(TmpVal,http_read_ports);	
end;


function http_read_ports(io_port:longint;byte_value:byte):integer;
var	
	TmpVal,TmpStrg	: string;

begin
	str(io_port,TmpStrg);
	{$ifndef ZAURUS}
	TmpVal:=HttpGet(R_URL+TmpStrg);
	{$endif}
	val(TmpVal,http_read_ports);	
end;


	
function http_write_ports(io_port:longint;byte_value:byte):byte;	

var	
	TmpVal,TmpStrg	: string;

begin
	str(io_port,TmpStrg);
	{$ifndef ZAURUS}
	TmpVal:=HttpGet(W_URL+TmpStrg);
	{$endif}
	val(TmpVal,http_write_ports);	
end;


function http_hwinit(initdata:string):boolean;
var
		delim : integer;

begin
	delim:=pos(':',initdata);
	R_URL:=copy(initdata,1,delim-1);
	W_URL:=copy(initdata,delim+1,length(initdata));
end;


begin
end.
