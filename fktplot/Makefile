# make FKTPLOT for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 
# to remake a part do "make" for the ide

OBJECTS=fktplot

all: $(OBJECTS)


# the physical Machine access layer
fktplot: 	
	fpc -gl -Fu../sps/ fktplot.pas

clear:
	-rm Pfktplot
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
