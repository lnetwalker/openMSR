program armgpiotest2;

{Demo application for GPIO on Raspberry Pi}
{Inspired by the Python input/output demo application by Gareth Halfacree}
{written for the Raspberry Pi User Guide, ISBN 978-1-118-46446-5}

{$mode objfpc}{$H+}

uses
  crt,Classes, SysUtils,Unix, BaseUnix;


const
  PIN_17: PChar = '17';
  PIN_ON: PChar = '1';
  PIN_OFF: PChar = '0';
  OUT_DIRECTION: PChar = 'out';

var
  gReturnCode: longint; {stores the result of the IO operation}
  fileDesc: integer;

{ TForm1 }

begin
  { Prepare SoC pin 17 (pin 11 on GPIO port) for access: }
  try
    fileDesc := fpopen('/sys/class/gpio/export', O_WrOnly);
    gReturnCode := fpwrite(fileDesc, PIN_17[0], 2);
    writeln(gReturnCode);
  finally
    gReturnCode := fpclose(fileDesc);
    writeln(gReturnCode);
  end;
  { Set SoC pin 17 as output: }
  try
    fileDesc := fpopen('/sys/class/gpio/gpio17/direction', O_WrOnly);
    gReturnCode := fpwrite(fileDesc, OUT_DIRECTION[0], 3);
    writeln(gReturnCode);
  finally
    gReturnCode := fpclose(fileDesc);
    writeln(gReturnCode);
  end;
  { Swith SoC pin 17 on: }
  try
    fileDesc := fpopen('/sys/class/gpio/gpio17/value', O_WrOnly);
    gReturnCode := fpwrite(fileDesc, PIN_ON[0], 1);
    writeln(gReturnCode);
  finally
    gReturnCode := fpclose(fileDesc);
    writeln(gReturnCode);
  end;
  delay(1000);
  { Switch SoC pin 17 off: }
  try
    fileDesc := fpopen('/sys/class/gpio/gpio17/value', O_WrOnly);
    gReturnCode := fpwrite(fileDesc, PIN_OFF[0], 1);
    writeln(gReturnCode);
  finally
    gReturnCode := fpclose(fileDesc);
    writeln(gReturnCode);
  end;
  { Free SoC pin 17: }
  try
    fileDesc := fpopen('/sys/class/gpio/unexport', O_WrOnly);
    gReturnCode := fpwrite(fileDesc, PIN_17[0], 2);
    writeln(gReturnCode);
  finally
    gReturnCode := fpclose(fileDesc);
    writeln(gReturnCode);
  end;

end.
