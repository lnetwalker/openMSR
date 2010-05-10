# make Datalogger for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=datalogger

# get compiler and flags for the given platform
include ./make_macros/$(BLD_ARCH)_macros

all: $(OBJECTS)


# the datalogger runtime module	
datalogger:	datalogger.pas
	$(FPC) $(FPC_FLAGS) -gl -Fu../HelperLibs -Fu../divLibs/pwu-1.6.0.2-src/main/ -Fu../gtk+/qgtk2.pas-0.9 -Fu../PhysMach datalogger 

clear: 
	-rm datalogger
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)

build :
	-cp datalogger /tmp/build/datalogger/
	-cp .datalogger.cfg /tmp/build/datalogger/
