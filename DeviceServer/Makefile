# make DeviceServer
#
# Copyright (c) 1999-2008 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

# for ARM ( Calao ) Linux
FPC="/usr/local/bin/ppcrossarm -CfFPA  -dUSB92 -CaARMEB -CpARMV5 -darm -dFPC_ARMEL -XP/usr/local/xtools/arm-unknown-linux-uclibc/arm-unknown-linux-uclibc/bin/ -XR/usr/local/xtools/arm-unknown-linux-uclibc/arm-unknown-linux-uclibc/ -Fl/usr/local/xtools/arm-unknown-linux-uclibc/arm-unknown-linux-uclibc/sys-root/usr/lib/"

# for X86 Linux
FPC="/usr/local/bin/fpc "

OBJECTS=DeviceServer

all: $(OBJECTS)


# the physical Machine access layer
DeviceServer: 	DeviceServer.pas
	$(FPC) -gl -Fu../webserver -Fu../PhysMach -Fu../divLibs//pwu-1.6.0.2-src/main/ DeviceServer.pas 

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
