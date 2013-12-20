Unit gnublin_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf			} 
{ die im GNUBLIN Board eingebaute Hardware				}
{ zur Verfügung							}

{ If you have improvements please contact me at 			}
{ hartmut@eilers.net							}
{ all code is copyright by Hartmut Eilers and released under		}
{ the GNU GPL see www.gnu.org for license details			}

{ $Id: gnublin_io_access.pas 756 2011-03-19 20:21:24Z hartmut $ }

{$mode objfpc}

{ Belegung der GPIOs:
  GPIO3...........LED1
  GPIO11..........X4-2
  GPIO13..........
  GPIO14..........X4-3
  GPIO15..........X4-4 }

{ Belegung der Analogen Eingänge
modul lpc313x_adc muss geladen sein
devicefile /dev/lpc313x_adc

ADC10B_GPA0........J5-1
ADC10B_GPA1........J5-2 (auch auf X4-1)
ADC10B_GPA3........J5-3 }

{ Belegung PWM Ausgang
 module lpc313x_pwm muss geladen sein
 devicefile /dev/lpc313x_pwm
 echo <lowbyte> <highbyte> > /dev/lpc313x_pwm
 Wert zwischen 0 und 4095
 PWM_DATA des LPC3131 ist auf J5-4 h }

{
  programming reference:
  http://wiki.freepascal.org/Lazarus_on_Raspberry_Pi/de#Schalten_eines_Ger.C3.A4tes_.C3.BCber_den_GPIO-Port
  http://wiki.gnublin.org/index.php/GPIO11
  http://wiki.gnublin.org/index.php/AD-Wandler
  http://wiki.gnublin.org/index.php/PWM
}

INTERFACE

{ public functions to init the hardware and read and write ports }

function gnublin_hwinit(initstring:string;DeviceNumber:byte):boolean;
function gnublin_read_ports(io_port:longint):byte;
function gnublin_read_analog(io_port:longint):longint;
function gnublin_write_ports(io_port:longint;byte_value:byte):byte;
function gnublin_close(initstring:string):boolean;

IMPLEMENTATION
uses 
  Classes, SysUtils, baseunix;

const
	debug      	= false;
	power   	: array[0..7] of byte =(1,2,4,8,16,32,64,128);

var
	gpiodirection	: string;


function gnublin_close(initstring:string):boolean;

begin
  // Dummy must be filled !
  gnublin_close:=true;
end;



function gnublin_read_ports(io_port:longint):byte;
var	
  i			: byte;
  value			: String[1] = '1';
  returnvalue		: byte;
  fileDesc		: INTEGER;
  gpiodevicenumber	: String;
  gReturnCode		: Byte;

begin
  returnvalue:=0;
  { leave off the  GPIO 3 it is fixed output }
  for i:= 2 to 5 do begin { the first val of gpiodirection is always o its gpio3 ( LED) }
    if ( gpiodirection[i]='i') then begin 
	if ( i=2 ) then  
	  gpiodevicenumber:='11'
	else
	  gpiodevicenumber:=IntToStr(10+i);

	try
	  fileDesc := fpopen('/sys/class/gpio/gpio' + gpiodevicenumber + '/value', O_RdOnly);
	  gReturnCode := fpread(fileDesc, value[1], 1);
	finally
	  gReturnCode := fpclose(fileDesc);
	end;
	if ( value = '1' ) then
	  returnvalue:=returnvalue+power[i-1];
    end;
  end;
  gnublin_read_ports:=returnvalue;
end;




function gnublin_write_ports(io_port:longint;byte_value:byte):byte;
var i			: byte;
    out 		: PChar;
    fileDesc		: integer;
    gpiodevicenumber	: String;
    gReturnCode	: Byte;

const
    PIN_ON: PChar = '1';
    PIN_OFF: PChar = '0';

begin
  { the ioport is currently ignored }
  for i:=7 downto 0 do begin
    { check for value of bit }
    if byte_value>=power[i] then begin
      byte_value:=byte_value-power[i];
      out:=PIN_ON
    end
    else
      out:=PIN_OFF;
    
    { if one of the implemented GPIO Lines }
    if ( i=7 ) then begin
      { this one is always out, it's the red led on board }
      { assign devices depending on bit }
      try
	fileDesc := fpopen('/sys/class/gpio/gpio3/value', O_WrOnly);
	gReturnCode := fpwrite(fileDesc, out[0], 1);
      finally
	gReturnCode := fpclose(fileDesc);
      end;
    end
    else if ( i < 4 ) then
      { if the programmed direction is out }
      if ( gpiodirection[i+2]='o' ) then begin
	{ assign devices depending on bit }
	if ( i=0 ) then
	  gpiodevicenumber:='11'
	else
	  gpiodevicenumber:=IntToStr(12+i);
	try
	  fileDesc := fpopen('/sys/class/gpio/gpio' + gpiodevicenumber + '/value', O_WrOnly);
	  gReturnCode := fpwrite(fileDesc, out[0], 1);
	finally
	  gReturnCode := fpclose(fileDesc);
	end;
      end;
    gnublin_write_ports:=0;
  end;
end;




function gnublin_read_analog(io_port:longint):longint;
	// currently the io_port must be between 0 and 3 !
var
    ad_wert 		: Integer;
    fileDesc		: integer;
    gReturnCode	: Byte;
    value		: String[5] = '1';
    out 		: PChar;
    bytecnt		: byte;
    Code		: word;

begin
  out:= PChar(IntToStr(io_port));
  bytecnt:= length(IntToStr(io_port));
  //writeln ('ADC: ', io_port, ' out: ',out[0],' cnt: ',bytecnt);
  // choose the adc channel
  try
    fileDesc := fpopen('/dev/lpc313x_adc',O_RdWr);
    gReturnCode := fpwrite(fileDesc, out[0], bytecnt);
  finally
    gReturnCode := fpclose(fileDesc);
  end;
  // read the selected adc channel
  try
    fileDesc := fpopen('/dev/lpc313x_adc',O_RdOnly);
    gReturnCode := fpread(fileDesc, value[0], 5);
  finally
    gReturnCode := fpclose(fileDesc);
  end;
  Val (value,ad_wert,Code);
  //writeln ( 'String: ',value,' Zahl: ',ad_wert,' Fehler: ',Code);

  gnublin_read_analog:=ad_wert;
end;




function gnublin_hwinit(initstring:string;DeviceNumber:byte):boolean;
var i 			: byte;
    fileDesc		: integer;
    gpiodevicenumber 	: PChar;
    gReturnCode	: Byte;

const
    OUT_DIRECTION: PChar = 'out';
    IN_DIRECTION:  PChar = 'in';

begin
  { initstring is 4 chars each one i or o for in and out 	}
  { representing the gpio 11, 13, 14, 15			}
  { assigned as bits 0-3					}
  { gio3 is fixed set to output and assigned as highest bit	}
  { and added in front of initstring 				}
  { DeviceNumber is currently not used			}
  gpiodirection:='o' + initstring;
  for i:= 1 to 5 do begin
    { enable the GPIO line }
    { build the devicefile number }
    if ( i=1 ) then
	gpiodevicenumber:=PChar('3')
    else if ( i=2 ) then
	    gpiodevicenumber:=PChar('11')
	  else
	    gpiodevicenumber:=PChar(IntToStr(10+i));

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
      if ( gpiodirection[i] = 'i' ) then 
	gReturnCode := fpwrite(fileDesc, IN_DIRECTION[0], 2)
      else
	gReturnCode := fpwrite(fileDesc, OUT_DIRECTION[0], 3);
    finally
      gReturnCode := fpclose(fileDesc);
    end;

  end;
end;


begin

end.