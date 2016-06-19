# make Oszi for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=oszi

# get compiler and flags for the given platform
include ../build/make_includes/$(BLD_ARCH)
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath


all: $(OBJECTS)


# the oszi runtime module	
oszi:	oszi.pas
	$(FPC) $(FPC_FLAGS) -gl $(UNITSEARCH) oszi 

clear: 
	-rm oszi
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
	-rm *.exe

build:
ifeq ($(BLD_ARCH),win32)
	-cp oszi.exe /tmp/$(USER)/build/oszi/
else
	-cp oszi /tmp/$(USER)/build/oszi/
endif
	-cp .oszi.cfg /tmp/$(USER)/build/oszi/
