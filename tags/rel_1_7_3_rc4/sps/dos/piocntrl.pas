unit piocntrl;

{ piocntrl - unit zur einfachen handhabung von pios mit 8255 }
{ version 0.1beta     21/10/92  (c) by HuSoft                }

interface

type  io_ports     = record
                       ctrl,porta,portb,portc : byte;
                     end;

      pio_type     = array[1..6] of io_ports;
      bit12_type   = array[1..12] of boolean;


const power        : array[0..7] of byte = (1,2,4,8,16,32,64,128);


procedure in12bit(PioNumber:byte;PortNumber:byte;var input:bit12_type);


implementation

var   pio          : pio_type;

procedure in12bit;

{ liesst die eingaenge a1 bis a8 und c1 bis c4 der pio(PioNumber) ein }
{ und gibt sie als ergebnis vom typ bit12_type zurueck              }

var  puffer    : byte;

begin
     if PortNumber=1 then puffer:=port[pio[PioNumber].porta]
     else puffer:=port[pio[PioNumber].portb]
     input[1]  := puffer = power[0];
     input[2]  := puffer = power[1];
     input[3]  := puffer = power[2];
     input[4]  := puffer = power[3];
     input[5]  := puffer = power[4];
     input[6]  := puffer = power[5];
     input[7]  := puffer = power[6];
     input[8]  := puffer = power[7];
     puffer:=port[pio[PioNumber].portc];
     if PortNumber=1 then begin
        input[9]  := puffer = power[0];
        input[10] := puffer = power[1];
        input[11] := puffer = power[2];
        input[12] := puffer = power[3];
     end
     else begin
        input[9]  := puffer = power[4];
        input[10] := puffer = power[5];
        input[11] := puffer = power[6];
        input[12] := puffer = power[7];
     end;
end;

end.