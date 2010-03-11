# make FKTPLOT for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 
# to remake a part do "make" for the ide

OBJECTS=fktplot OpenLabCalc

all: $(OBJECTS)

OpenLabCalc:	OpenLabCalc.pas FunctionSolver.pas
	fpc -gl -Fu../gtk+/qgtk2.pas-0.9/ -Fu../PhysMach -Fu../divLibs/pwu-1.6.0.2-src/main/ OpenLabCalc
	
# the physical Machine access layer
fktplot:	fktplot.pas FunctionSolver.pas
	fpc -gl -Fu../gtk+/qgtk2.pas-0.9/ fktplot

clear:
	-rm fktplot
	-rm OpenLabCalc
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)

build:
	-mkdir ../build/OpenLabCalc
	-cp OpenLabCalc ../build/OpenLabCalc
	-cp OpenLabCalc.cfg ../build/OpenLabCalc