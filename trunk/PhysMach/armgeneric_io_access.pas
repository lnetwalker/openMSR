Unit armgeneric_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ die in generischen ARM Boards eingebaute GPIO Ports			}
{ zur Verfügung								}

{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}

{ $Id:$ }

{$mode objfpc}



INTERFACE

{ public functions to init the hardware and read and write ports }

function armgeneric_hwinit(initstring:string;DeviceNumber:byte):boolean;
function armgeneric_read_ports(io_port:longint):byte;
function armgeneric_write_ports(io_port:longint;byte_value:byte):byte;
function armgeneric_close(initstring:string):boolean;
function armgeneric_gpio(adr:byte;bit:byte;gpiobit:byte):byte;
function armgeneric_gpiodir(adr:byte;io_port:byte;dir:byte):byte;

IMPLEMENTATION
uses 
  Classes, SysUtils, baseunix, StringCut;

type	
  GPIO_TYPE 		= array[0..255,0..255] of byte;
  GPIO_ADR_TYPE 	= array[0..255,0..255] of byte;
  
const
	debug      	= false;
	power   	: array[0..7] of byte =(1,2,4,8,16,32,64,128);

var
	gpiodirection	: string;
	TurnedOn	: Boolean = False;
	GPIO		: GPIO_TYPE;
	GPIO_ADR	: GPIO_ADR_TYPE;
	GPIO_DIR	: array[0..255] of byte;

function armgeneric_close(initstring:string):boolean;

begin
  // Dummy must be filled !
  armgeneric_close:=true;
end;



function armgeneric_read_ports(io_port:longint):byte;
var	
  i			: ShortInt;
  value			: String[1] = '1';
  returnvalue		: byte;
  fileDesc		: INTEGER;
  gpiodevicenumber	: String;
  gReturnCode		: Byte;

begin
  returnvalue:=0;
  for i:= 0 to 7 do begin
  	gpiodevicenumber:=IntToStr(GPIO[GPIO_ADR[0,io_port],i]);

	try
	  fileDesc := fpopen('/sys/class/gpio/gpio' + gpiodevicenumber + '/value', O_RdOnly);
	  gReturnCode := fpread(fileDesc, value[1], 1);
	finally
	  gReturnCode := fpclose(fileDesc);
	end;
	if ( value = '1' ) then
	  returnvalue:=returnvalue+power[i-1];
  end;
  armgeneric_read_ports:=returnvalue;
end;




function armgeneric_write_ports(io_port:longint;byte_value:byte):byte;
var i			: byte;
    out 		: PChar;
    fileDesc		: integer;
    gpiodevicenumber	: String;
    gReturnCode	: Byte;

const
    PIN_ON: PChar = '1';
    PIN_OFF: PChar = '0';

begin
  for i:=7 downto 0 do begin
    { check for value of bit }
    if byte_value>=power[i] then begin
      byte_value:=byte_value-power[i];
      out:=PIN_ON
    end
    else
      out:=PIN_OFF;
   
    gpiodevicenumber:=IntToStr(GPIO[GPIO_ADR[1,io_port],i]);

    try
	fileDesc := fpopen('/sys/class/gpio/gpio' + gpiodevicenumber + '/value', O_WrOnly);
	gReturnCode := fpwrite(fileDesc, out[0], 1);
    finally
	gReturnCode := fpclose(fileDesc);
    end;
  end;
  armgeneric_write_ports:=0;
end;


function armgeneric_hwinit(initstring:string;DeviceNumber:byte):boolean;
var l,b,ListCnt 	: byte;
    fileDesc		: integer;
    gpiodevicenumber 	: PChar;
    gReturnCode		: Byte;
    Liste		: StringArray;	

const
    OUT_DIRECTION: PChar = 'out';
    IN_DIRECTION:  PChar = 'in';

begin
  { initstring is a list of used adresses by this device }

  { Prepare GPIO for access: }
  Liste:=StringSplit(initstring,',');
  ListCnt:=length(Liste);
  for l:=1 to ListCnt do begin
    for b:=0 to 7 do begin
      { Set GPIO directions }
      gpiodevicenumber:=PChar(IntToStr(GPIO[StrToInt(Liste[l]),b]));

      { Prepare GPIO for access: }
      try
	fileDesc := fpopen('/sys/class/gpio/export', O_WrOnly);
        gReturnCode := fpwrite(fileDesc, gpiodevicenumber[0], 2);
      finally
        gReturnCode := fpclose(fileDesc);
      end;
      { Set GPIO directions }
      try
        fileDesc := fpopen('/sys/class/gpio/gpio' + IntToStr(ptruint(gpiodevicenumber)) + '/direction', O_WrOnly);
        if ( GPIO_DIR[l] = 0 ) then 
	  gReturnCode := fpwrite(fileDesc, IN_DIRECTION[0], 2)
        else
	  gReturnCode := fpwrite(fileDesc, OUT_DIRECTION[0], 3);
      finally
        gReturnCode := fpclose(fileDesc);
      end;
    end;
  end;
end;


function armgeneric_gpio(adr:byte;bit:byte;gpiobit:byte):byte;

begin
  GPIO[adr,bit]:=gpiobit;
end;


function armgeneric_gpiodir(adr:byte;io_port:byte;dir:byte):byte;

begin
  GPIO_ADR[dir,io_port]:=adr;
  GPIO_DIR[adr]:=dir;
end;


begin

end.
