# make FKTPLOT for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 
# to remake a part do "make" for the ide

OBJECTS=fktplot OpenLabCalc

# get compiler and flags for the given platform
include ../build/make_includes/$(BLD_ARCH)
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath

all: $(OBJECTS)

OpenLabCalc:	OpenLabCalc.pas FunctionSolver.pas
	$(FPC) $(FPC_FLAGS) -gl  $(UNITSEARCH) OpenLabCalc
	
# the physical Machine access layer
fktplot:	fktplot.pas FunctionSolver.pas
	$(FPC) $(FPC_FLAGS) -gl  $(UNITSEARCH) fktplot

clear:
	-rm fktplot
	-rm OpenLabCalc
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)

build:
	-rmdir /tmp/build/fktplot
	-mkdir -p /tmp/build/OpenLabCalc
ifeq ($(BLD_ARCH),win32)
	-cp OpenLabCalc.exe /tmp/build/OpenLabCalc
	-cp fktplot.exe /tmp/build/OpenLabCalc
else
	-cp OpenLabCalc /tmp/build/OpenLabCalc
	-cp fktplot /tmp/build/OpenLabCalc
endif
	-cp OpenLabCalc.cfg /tmp/build/OpenLabCalc

