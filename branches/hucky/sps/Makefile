# make SPS for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 
# to remake a part do "make sps" for the ide
# and a "make run_sps" for the runtime modules

OBJECTS=sps run_sps

all: $(OBJECTS)


# the sps IDE
sps: 	sps.pas edit.pas fileserv.pas info.pas popmenu.pas run_awl.pas sps.h awl_interpreter.pas run_awl.h
	ppc386 sps.pas

# the SPS runtime module	
run_sps:	run_sps.pas awl_interpreter.pas run_awl.h
		ppc386 run_sps.pas

clear: 
	-rm lp_io_access.ppu
	-rm run_sps
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
