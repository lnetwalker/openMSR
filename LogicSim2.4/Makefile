# make Logicsim for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=logicsim

# get compiler and flags for the given platform
#include ../build/make_includes/$(BLD_ARCH)
#include ./make_macros/$(BLD_ARCH)_macros
#include ../build/make_includes/unit-searchpath


all: $(OBJECTS)


# the oszi runtime module	
logicsim:	
	javac -Xlint:deprecation -Xlint:unchecked logicsim/*.java
	jar -cf LogicSim.jar MANIFEST.MF logicsim/*.class logicsim/images/


clear: 
	-rm LogicSim.jar
			
clean :
	-rm logicsim/*.class
	-rm *.jar

build:
