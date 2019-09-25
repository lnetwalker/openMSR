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
	-mkdir -p tmp/build/LogicSim2_4/languages
	-mkdir -p tmp/build/LogicSim2_4/modules
	-mkdir -p tmp/build/LogicSim2_4/doc
	-mkdir -p tmp/build/LogicSim2_4/circuits
	-cp logicsim.cfg tmp/build/LogicSim2_4/
	-cp LogicSim.jar tmp/build/LogicSim2_4/LogicSim.$(BLD_ARCH).jar
	-cp LogicSim.jar ./LogicSim.$(BLD_ARCH).jar
	-cp modules/*    tmp/build/LogicSim2_4/modules/
	-cp languages/*  tmp/build/LogicSim2_4/languages/
	-cp circuits/* tmp/build/LogicSim2_4/circuits/
	-cp -a doc/* tmp/build/LogicSim2_4/doc/
	-cp liesmich.txt tmp/build/LogicSim2_4/
	-cp changes.txt tmp/build/LogicSim2_4/
	-cp gpl.txt tmp/build/LogicSim2_4/
	-cp readme.txt tmp/build/LogicSim2_4/
	tar czvf logicSim2_4.tgz tmp/build/LogicSim2_4/
	
