# make PhysMach for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=physmach

all: $(OBJECTS)

FPC=/usr/local/bin/fpc
FPC_FLAGS= -dLINUX -dnewio


# the physical Machine access layer
physmach: 	
	$(FPC) $(FPC_FLAGS) -gl -Futest/libad4 -Fu../divLibs/pwu-1.6.0.2-src/main/ -Fu../HelperLibs PhysMach.pas

clear:
	-rm PhysMach.ppu
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
