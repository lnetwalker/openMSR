# make Datalogger for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=datalogger

all: $(OBJECTS)


# the datalogger runtime module	
datalogger:	datalogger.pas
	fpc -Fu../gtk+/qgtk2.pas-0.9 -Fu../PhysMach datalogger 

clear: 
	-rm datalogger
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
