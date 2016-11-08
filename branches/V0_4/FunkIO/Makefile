# make FunkIO
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 
# to remake a part do "make" for the ide


OBJECTS=funkio

# get compiler and flags for the given platform
include ../build/make_includes/$(BLD_ARCH)
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath

all: $(OBJECTS)

funkio:	funkio.pas
	$(FPC) $(FPC_FLAGS) -gl  $(UNITSEARCH) funkio
	
clear:
	-rm funkio
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)

build:
	-mkdir /tmp/$(USER)/build/FunkIO
ifeq ($(BLD_ARCH),win32)
	-cp funkio.exe /tmp/$(USER)/build/FunkIO
else
	-cp funkio /tmp/$(USER)/build/FunkIO
endif
	-cp funkio.cfg /tmp/$(USER)/build/FunkIO

