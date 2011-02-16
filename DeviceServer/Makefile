# make DeviceServer
#
# Copyright (c) 1999-2010 by Hartmut Eilers
# 
# to build linux x86 do: make BLD_ARCH="linux"
# to build linux arm do: make BLD_ARCH="arm"
# planned are the arch: Mac OS-X and Windows and perhaps BSD

OBJECTS=DeviceServer

# get compiler and flags for the given platform
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath

all: $(OBJECTS)

# the physical Machine access layer
DeviceServer: 	DeviceServer.pas
	$(FPC) $(FPC_FLAGS) -gl  $(UNITSEARCH) DeviceServer.pas 

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
	-mkdir /tmp/build/DeviceServer/docroot
	-mkdir /tmp/build/DeviceServer/docroot/images
	-cp docroot/images/*.jpg /tmp/build/DeviceServer/docroot/images/
	-cp docroot/images/*.png /tmp/build/DeviceServer/docroot/images/
	-cp docroot/*.html  /tmp/build/DeviceServer/docroot/
	-cp docroot/Meter* /tmp/build/DeviceServer/docroot/
	-cp DeviceServer /tmp/build/DeviceServer/
	-cp DeviceServer.cfg /tmp/build/DeviceServer/
	-cp digi*.sh /tmp/build/DeviceServer/
