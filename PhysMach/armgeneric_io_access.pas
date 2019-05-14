Unit armgeneric_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			}
{ die in generischen ARM Boards eingebaute GPIO Ports			}
{ zur Verfügung								}

{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}

{ for reference see: http://wiki.freepascal.org/Lazarus_on_Raspberry_Pi }

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
function armgeneric_exportGPIO(adr:byte;bit:byte;gpioline:byte):byte;
IMPLEMENTATION
uses
  Classes, SysUtils, baseunix, StringCut, Unix;

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
	ListCnt 	: byte;
	Liste		: StringArray;


function armgeneric_close(initstring:string):boolean;
var l			: byte;
    fileDesc		: integer;
    gReturnCode		: Integer;
    gpioline      : PChar;

begin
  // loop over the configured GPIOs and unexport them!
  for l:=1 to ListCnt do begin
      try
        fileDesc := fpopen('/sys/class/gpio/unexport', O_WrOnly);
        gpioline:=(Liste[l]);
        gReturnCode := fpwrite(fileDesc, gpioline[0], 2);
        if ( gReturnCode = -1 ) then writeln('error unexporting ',gpioline);
      finally
	      gReturnCode := fpclose(fileDesc);
      end;
  end;
  armgeneric_close:=true;
end;


function armgeneric_exportGPIO(adr:byte;bit:byte;gpioline:byte):byte;
var
    fileDesc		: integer;
    gReturnCode		: Integer;
    gCloseCode		: Byte;
    gpiodevicenumber 	: PChar;
    cmd, basefilename			: String;

const
    OUT_DIRECTION: PChar = 'out';
    IN_DIRECTION:  PChar = 'in';


begin
    writeln(' Found GPIO Line ',gpioline,' in config file ');
    { Set GPIO directions }
    gpiodevicenumber:=PChar(IntToStr(gpioline));
    { Prepare GPIO for access: }
    try
	     write ('GPIO[',gpioline,']=',gpiodevicenumber);
	     fileDesc := fpopen('/sys/class/gpio/export', O_WrOnly);
	     gReturnCode := fpwrite(fileDesc, gpiodevicenumber[0], 2);
	     writeln (' Result : ',gReturnCode);
       if gReturnCode = -1 then   begin
         writeln('Error exporting GPIO ',gpioline);
         writeln(SysErrorMessage(fpGetErrNo));
         { try alternate way of programming GPIOs }
         cmd:='echo "'+IntToStr(gpioline)+'" > /sys/class/gpio/export';
         gReturnCode := fpsystem(cmd);
         if gReturnCode = -1 then
           writeln('alternate access to GPIO ports failed with ',gReturnCode);
           writeln(SysErrorMessage(fpGetErrNo));
       end;

    finally
	     gCloseCode := fpclose(fileDesc);
    end;
    { Set GPIO directions }
    try
      basefilename:='/sys/class/gpio/gpio' + IntToStr(gpioline) + '/direction';
      writeln('try to configure port direction for '+basefilename);
      fileDesc := fpopen(basefilename, O_WrOnly);
      write('GPIO ', gpioline ,' is ');
      if ( GPIO_DIR[adr] = 0 ) then begin
	       writeln('Input');
         gReturnCode := fpwrite(fileDesc, IN_DIRECTION[0], 2);
	    end
      else begin
	       writeln('Output');
	       gReturnCode := fpwrite(fileDesc, OUT_DIRECTION[0], 3);
      end;
    finally
      gCloseCode := fpclose(fileDesc);
    end;
    if gReturnCode = -1 then begin
      writeln ('Error setting GPIO ',gpioline,' to ',GPIO_DIR[adr],' with code ',gReturnCode);
      writeln(SysErrorMessage(fpGetErrNo));
      { TRY ALTERNATE ACCESS OPTION }
      basefilename:='/sys/class/gpio/gpio' + IntToStr(gpioline);
      if ( GPIO_DIR[adr] = 0 ) then begin
	       writeln('Input');
         gReturnCode := fpsystem('echo "in">' + basefilename +'/direction');
	    end
      else begin
	       writeln('Output');
	       gReturnCode := fpsystem('echo "out">' + basefilename +'/direction');
      end;
      if gReturnCode < 0 then begin
        writeln ('Error alternate setting GPIO ',gpioline,' to ',GPIO_DIR[adr],' with code ',gReturnCode,' failed also');
        writeln(SysErrorMessage(fpGetErrNo));
      end;
    end;
end;

function armgeneric_read_ports(io_port:longint):byte;
var
  i			: ShortInt;
  value			: String[1] = '1';
  returnvalue		: byte;
  fileDesc		: INTEGER;
  gpiodevicenumber	: String;
  gReturnCode		: Integer;

begin
  returnvalue:=0;
  for i:= 0 to 7 do begin
  	gpiodevicenumber:=IntToStr(GPIO[GPIO_ADR[0,io_port],i]);

	try
	  fileDesc := fpopen('/sys/class/gpio/gpio' + gpiodevicenumber + '/value', O_RdOnly);
	  gReturnCode := fpread(fileDesc, value[1], 1);
    //if ( gReturnCode = -1 ) then writeln('reading gpio'+gpiodevicenumber+' failed.')
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
       if ( gReturnCode = -1 ) then writeln('writing gpio'+gpiodevicenumber+' failed.')
    finally
	     gReturnCode := fpclose(fileDesc);
    end;
  end;
  armgeneric_write_ports:=0;
end;


function armgeneric_hwinit(initstring:string;DeviceNumber:byte):boolean;
var i: byte;
begin
  { initstring is a list of used GPIO Lines by this device }
  { Prepare GPIO for access: }
  Liste:=StringSplit(initstring,',');
  ListCnt:=GetNumberOfElements(initstring,',');
  Writeln('DEVICE has ',ListCnt,' GPIO lines');
  for i:=1 to ListCnt do writeln ('Liste[',i,']=',Liste[i]);
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
