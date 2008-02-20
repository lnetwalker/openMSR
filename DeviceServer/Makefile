# make DeviceServer
#
# Copyright (c) 1999-2008 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=DeviceServer

all: $(OBJECTS)


# the physical Machine access layer
DeviceServer: 	
	fpc -gl -Fu../webserver -Fu../PhysMach DeviceServer.pas

clear:
	-rm *.ppu
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
