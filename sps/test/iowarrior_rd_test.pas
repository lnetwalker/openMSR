program iowarrior_rd_test;

uses dos,linux,crt;

var
        f       : file of LongInt;
        value   : LongInt;

begin
        writeln ('reading IO-Warrior');
        assign(f,'/dev/usb/iowarrior0');
        {$I-} reset (f); {$I+}
        if ioresult <> 0 then begin
                writeln (#7,'ERROR: opening /dev/usb/iowarrior0 ');
                halt(1);
        end;

        repeat
                {$I-} read(f,value);  {$I+}
                if ioresult <> 0 then begin
                        writeln (#7,'ERROR: reading from /dev/usb/iowarrior0 ');
                        halt(1);
                end;
                writeln(value);
        until keypressed;
end.

        
