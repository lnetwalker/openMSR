# make DeviceServer
#
# Copyright (c) 1999-2010 by Hartmut Eilers
# 
# to build linux x86 do: make BLD_ARCH="linux"
# to build linux arm do: make BLD_ARCH="arm"
# planned are the arch: Mac OS-X and Windows and perhaps BSD

OBJECTS=DeviceServer

# get compiler and flags for the given platform
include ../build/make_includes/$(BLD_ARCH)
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath

all: $(OBJECTS)

# the physical Machine access layer
DeviceServer: 	DeviceServer.pas FieldDevice.pas
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
	-rm *.exe

build:
	-mkdir /tmp/$(USER)/build/DeviceServer/docroot
	-mkdir /tmp/$(USER)/build/DeviceServer/docroot/images
	-mkdir /tmp/$(USER)/build/DeviceServer/docroot/js
	-mkdir /tmp/$(USER)/build/DeviceServer/Agents
	-mkdir /tmp/$(USER)/build/DeviceServer/config-examples 
	-cp docroot/images/*.jpg /tmp/$(USER)/build/DeviceServer/docroot/images/
	-cp docroot/images/*.png /tmp/$(USER)/build/DeviceServer/docroot/images/
	-cp docroot/js/* /tmp/$(USER)/build/DeviceServer/docroot/js/
	-cp docroot/*.html  /tmp/$(USER)/build/DeviceServer/docroot/
	-cp docroot/Meter* /tmp/$(USER)/build/DeviceServer/docroot/
ifeq ($(BLD_ARCH),win32)
	-cp DeviceServer.exe /tmp/$(USER)/build/DeviceServer/
else
	-cp DeviceServer /tmp/$(USER)/build/DeviceServer/
endif
	-cp DeviceServer.cfg /tmp/$(USER)/build/DeviceServer/
	-cp Agents/*.sh /tmp/$(USER)/build/DeviceServer/Agents
	-cp config-examples/* /tmp/$(USER)/build/DeviceServer/config-examples 
