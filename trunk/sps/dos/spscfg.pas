program spscfg;

{ programm zur menuegefuehrten installation der sps software }

{ projektstart 20/10/92  version 0.1Beta (c) by HuSoft       }


const version   = '0.1Beta';
      datum     = '20/10/92';


var   ctrl,porta,portb,
      portc,serial       : word;
      lf,ff,pl,gr        : byte;
      reg_nam            : string[17];
      f                  : text;
      zeile              : string80;
      befehl             : char;
      i                  : byte;
      error              : integer;
      zahl               : word;




begin
     assign(f,'SPS.CFG');
     {$I-}
     reset(f);
     {$I+}
     if ioresult<>0 then neuinst:=true
     else begin
        i:=0;
        while not eof(f) do begin
           readln(f,zeile);
           inc(i);
           befehl:=upcase(zeile[1]);
           val(copy(zeile,2,length(zeile)),zahl,error);
           case befehl of
                'C'  : begin
                          if error > 0 then pio:=false;
                          ctrl:=zahl;
                       end;
                'E'  : porta         :=zahl;
                'A'  : portb         :=zahl;
                'Z'  : portc         :=zahl;
                'V'  : lf            :=zahl;
                'G'  : gr            :=zahl;
                'L'  : pl            :=zahl;
                'F'  : ff            :=zahl;
                'S'  : begin
                          val(copy(zeile,2,4),serial,error);
                          reg_nam:=copy(zeile,6,length(zeile));
                       end;
             else begin
                window(1,1,25,80);
                textbackground(black);
                textcolor(white);
                clrscr;
                writeln(#7,'Fehler beim Lesen des Configfiles');
                writeln('in Zeile ',i,' unbekannter Befehl');
                halt(1);
             end;
           end;
        end;
        close (f);
     end;
     write('Seriennummer :');readln(serial);
     if serial>1000 begin
        write('Registiriername :');readln(reg_nam);
     end;
     write('Adresse Controlport der Pio',ctrl);readln(zahl);
     if zahl<>0 then ctrl:=zahl;
     write('Adresse Port A der Pio (Eingaenge)',porta);readln(zahl);
     if zahl<>0 then porta:=zahl;
     write('Adresse Port B der Pio (Ausgaenge)',portb);readln(zahl);
     if zahl<>0 then portb:=zahl;
     write('Adresse Port C der Pio (Zaehler)',portc);readln(zahl);
     if zahl<>0 then portc:=zahl;
     write('Druckersteuercode fuer formfeed',ff);readln(zahl);
     if zahl<>0 then ff:=zahl;
     write('Druckersteuercode fuer linefeed',lf);readln(zahl);
     if zahl<>0 then lf:=zahl;
     write('Druckersteuercode fuer Grossschrift',gr);readln(zahl);
     if zahl<>0 then gr:=zahl;
     write('Seitenleange des Druckers',pl);readln(zahl);
     if zahl<>0 then pl:=zahl;
