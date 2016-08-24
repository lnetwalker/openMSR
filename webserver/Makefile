# make DeviceServer
#
# Copyright (c) 1999-2010 by Hartmut Eilers
# 
# to build linux x86 do: make BLD_ARCH="linux"
# to build linux arm do: make BLD_ARCH="arm"
# planned are the arch: Mac OS-X and Windows and perhaps BSD

OBJECTS=pwserver

# get compiler and flags for the given platform
#include ../build/make_includes/$(BLD_ARCH)
#include ./make_macros/$(BLD_ARCH)_macros
#include ../build/make_includes/unit-searchpath


FPC_FLAGS= -dLINUX -dLinux64
FPC=/usr/lib/fpc/2.4.4/ppcx64
BASEPATH=~/daten/src/openmsr/trunk
BASEPATH=..
UNITSEARCH=-Fu$(BASEPATH)/HelperLibs -Fu$(BASEPATH)/webserver -Fu$(BASEPATH)/PhysMach -Fu$(BASEPATH)/divLibs/pwu-1.6.0.2-src/main/ -Fu$(BASEPATH)/divLibs/synapseTCP/source/lib/ -Fu$(BASEPATH)/PhysMach/3rdparty/codemercs/linux/ -Fu$(BASEPATH)/PhysMach/3rdparty/bmcm/linux/libad/ -Fu$(BASEPATH)/divLibs/gtk/qgtk2.pas-0.9/ -Fu$(BASEPATH)/divLibs/pxl-v101/Source/ -Fu$(BASEPATH)/HelperLibs/


all: $(OBJECTS)

# the physical Machine access layer
pwserver: 	pwserver.pas webserver.pas ../HelperLibs/CommonHelper.pas
	$(FPC) $(FPC_FLAGS) -gl  $(UNITSEARCH) pwserver.pas

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
	-cp digi*.sh /tmp/$(USER)/build/DeviceServer/
