# make Logicsim for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=LogicSim.jar

# get compiler and flags for the given platform
#include ../build/make_includes/$(BLD_ARCH)
#include ./make_macros/$(BLD_ARCH)_macros
#include ../build/make_includes/unit-searchpath


all: $(OBJECTS)


# the Logic Simulator
LogicSim.jar:	
	javac -Xlint:deprecation -Xlint:unchecked logicsim/*.java
	jar -cvfm LogicSim.jar manifest.txt logicsim/*.class logicsim/images/



clear: 
	-rm LogicSim.jar
			
clean:
	-rm logicsim/*.class
	-rm *.jar

build:
	-mkdir /tmp/build/LogicSim2.4/languages
	-mkdir /tmp/build/LogicSim2.4/modules
	-cp logicsim.cfg /tmp/build/LogicSim2.4/
	-cp LogicSim.jar /tmp/build/LogicSim2.4/
	-cp modules/*    /tmp/build/LogicSim2.4/modules/
	-cp languages/*  /tmp/build/LogicSim2.4/languages/
