program iow40_test;

(* testproggi reading/writing IO-Warrior 40 *)
(* IOW_WRITE and IOW_READ are the ioctl handles for the iowarrior 40 *) 
(* These values are from the Sample program iow40_wr_if0.c *)
(*  IOW_WRITE=1074053121 *)
(*  IOW_READ =1074053122 *)
(* This must be improved, it's bad style to use the constants *)
            
uses oldlinux,crt;

const
        IOW_WRITE = 1074053121;
        IOW_READ  = 1074053122;
        
var
        f       : LongInt;
        ovalue  : Cardinal;
        ivalue  : Cardinal;
        pvalue  : ^Cardinal;
        dummy   : char;
	counter : Cardinal;
        
begin
	counter:=0;
        writeln ('read/write IO-Warrior');
        new (pvalue);
        f:=fdOpen('/dev/usb/iowarrior0',Open_RdWr); 
        
        writeln('reading IO-Warrior - press any key to continue');
        repeat
                (* read the warrior *)
                ioctl (f,IOW_READ,pvalue);
                ivalue:=pvalue^;
                writeln('READ : ',byte (ivalue));
        until keypressed;
        dummy:=readkey;
        
        writeln('writing IO-Warrior - press any key to stop');
        repeat
                ovalue:=(counter shl 24);pvalue^:=ovalue;
		writeln (ovalue);
		ioctl (f,IOW_WRITE,pvalue);
                delay (400);
		if (counter < 2 ) then inc(counter);
                (** ovalue:=$0F0F0F0F;pvalue^:=ovalue;
                ioctl (f,IOW_WRITE,pvalue);
                delay (100);**)  
                write('.');  
        until keypressed;
        writeln;
        ovalue:=$FFFFFFFF;pvalue^:=ovalue;
        ioctl (f,IOW_WRITE,pvalue);
        fdClose(f);
end.

        
