# make Oszi for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=oszi

all: $(OBJECTS)


# the oszi runtime module	
oszi:	oszi.pas
	fpc -Fu../gtk+/qgtk2.pas-0.9 -Fu../PhysMach oszi 

clear: 
	-rm oszi
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
