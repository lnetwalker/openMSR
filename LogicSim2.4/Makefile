# make Logicsim for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=LogicSim.jar

# get compiler and flags for the given platform
#include ../build/make_includes/$(BLD_ARCH)
include ./make_macros/$(BLD_ARCH)_macros
#include ../build/make_includes/unit-searchpath

JAVAC=$(JAVA_HOME)/bin/javac
JAR=$(JAVA_HOME)/bin/jar

all: $(OBJECTS)


# the Logic Simulator
LogicSim.jar:	
	$(JAVAC) -Xlint:deprecation -Xlint:unchecked logicsim/*.java
	$(JAR) -cvfm LogicSim.jar manifest.txt logicsim/*.class logicsim/images/
	-cp LogicSim.jar ./LogicSim.$(BLD_ARCH).jar



clear: 
	-rm LogicSim.jar
			
clean:
	-rm logicsim/*.class
	-rm *.jar

build:
	-mkdir /tmp/$(USER)/build/LogicSim2.4/languages
	-mkdir /tmp/$(USER)/build/LogicSim2.4/modules
	-cp logicsim.cfg /tmp/$(USER)/build/LogicSim2.4/
	-cp LogicSim.jar /tmp/$(USER)/build/LogicSim2.4/LogicSim.$(BLD_ARCH).jar
	-cp LogicSim.jar ./LogicSim.$(BLD_ARCH).jar
	-cp modules/*    /tmp/$(USER)/build/LogicSim2.4/modules/
	-cp languages/*  /tmp/$(USER)/build/LogicSim2.4/languages/
