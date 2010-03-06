# make DeviceServer
#
# Copyright (c) 1999-2010 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean.
# to build linux x86 do: make BLD_ARCH="linux"
# to build linux arm do: make BLD_ARCH="arm"
# planned are the arch: Mac OS-X and Windows and perhaps BSD

OBJECTS=DeviceServer

# get compiler and flags for the given platform
include ./make_macros/$(BLD_ARCH)_macros

all: $(OBJECTS)

# the physical Machine access layer
DeviceServer: 	DeviceServer.pas
	$(FPC) $(FPC_FLAGS) -gl -Fu../webserver -Fu../PhysMach -Fu../divLibs/pwu-1.6.0.2-src/main/ DeviceServer.pas 

clear:
	-rm *.ppu
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
	-rm *~

build:
	-mkdir ../build/DeviceServer/docroot
	-mkdir ../build/DeviceServer/docroot/images
	-cp docroot/images/*.jpg ../build/DeviceServer/docroot/images/
	-cp docroot/images/*.png ../build/DeviceServer/docroot/images/
	-cp docroot/*.html  ../build/DeviceServer/docroot/
	-cp docroot/Meter* ../build/DeviceServer/docroot/
	-cp DeviceServer ../build/DeviceServer/
	-cp DeviceServer.cfg ../build/DeviceServer/
	-cp digi*.sh ../build/DeviceServer/
