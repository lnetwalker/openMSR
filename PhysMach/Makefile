# make PhysMach for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make BLD_ARCH=[arm|linux|win32|osx]  all", and, when you're finished,
# a "make BLD_ARCH=[arm|linux|win32|osx] clean".

OBJECTS=physmach

# get compiler and flags for the given platform
include ../build/make_includes/$(BLD_ARCH)
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath

all: $(OBJECTS)


# the physical Machine access layer
physmach: 	
	$(FPC) $(FPC_FLAGS) -gl  $(UNITSEARCH)  PhysMach.pas
	$(FPC) $(FPC_FLAGS) -gl  $(UNITSEARCH)  PhysMachTest.pas
	$(FPC) $(FPC_FLAGS) -gl  $(UNITSEARCH)  3rdparty/htronic/USB8-IO/testprog/serio.pas

clear:
	-rm PhysMach.ppu
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
