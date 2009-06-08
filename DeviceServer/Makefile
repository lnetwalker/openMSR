# make DeviceServer
#
# Copyright (c) 1999-2008 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=DeviceServer

all: $(OBJECTS)


# the physical Machine access layer
DeviceServer: 	DeviceServer.pas
	/usr/bin/fpc -gl -Fu../webserver -Fu../PhysMach -Fu../divLibs//pwu-1.6.0.2-src/main/ DeviceServer.pas 

clear:
	-rm *.ppu
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)

build:
	-rm ../build/DeviceServer/*
	-rm ../build/DeviceServer/docroot/*
	-rm ../build/DeviceServer/docroot/images/*
	-cp docroot/images/*.jpg ../build/DeviceServer/docroot/images/
	-cp docroot/images/*.png ../build/DeviceServer/docroot/images/
	-cp docroot/*.html  ../build/DeviceServer/docroot/
	-cp DeviceServer ../build/DeviceServer/
	-cp DeviceServer.cfg ../build/DeviceServer/
	-cp digi*.sh ../build/DeviceServer/