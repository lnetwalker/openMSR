# make Datalogger for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=datalogger

# get compiler and flags for the given platform
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath

all: $(OBJECTS)


# the datalogger runtime module	
datalogger:	datalogger.pas
	$(FPC) $(FPC_FLAGS) -gl $(UNITSEARCH) datalogger 

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
