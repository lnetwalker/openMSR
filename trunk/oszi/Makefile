# make Oszi for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=oszi

# get compiler and flags for the given platform
include ./make_macros/$(BLD_ARCH)_macros

FPC=fpc

#FPC=/usr/local/bin/fpc

all: $(OBJECTS)


# the oszi runtime module	
oszi:	oszi.pas
	$(FPC) $(FPC_FLAGS) -Fu../HelperLibs -Fu../divLibs/pwu-1.6.0.2-src/main/ -Fu../gtk+/qgtk2.pas-0.9 -Fu../PhysMach oszi 

clear: 
	-rm oszi
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)

build:
	-cp oszi /tmp/build/oszi/
	-cp .oszi.cfg /tmp/build/oszi/
