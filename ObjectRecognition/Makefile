# make ObjectRecognition
#
# Copyright (c) 1999-2009 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

# ToDo:
# make it crosscompilable for linux i386,x64 and arm
# just copy info stuff for win32 !

OBJECTS=ObjRec ObjectRecognition

# get compiler and flags for the given platform
include ../build/make_includes/$(BLD_ARCH)
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath

all: $(OBJECTS)


# the physical Machine access layer
ObjectRecognition: 	main.cpp ObjRec.cpp webcam.cpp
	$(CC) main.cpp ObjRec.cpp webcam.cpp $(CFLAGS) -Wno-deprecated -Llib/X11 -lX11  -o ObjectRecognition.$(PLATFORM) $(EXTRA_FLAGS)

ObjRec: 	ObjRec.cpp
	$(CC) -c ObjRec.cpp -Wno-deprecated -fPIC
clear:
			
clean :

	-rm *~
	-rm $(OBJECTS)
	-rm ObjRec.o

build:
	-cp README /tmp/build/ObjectRecognition/
	-cp main.cpp /tmp/build/ObjectRecognition/
	-cp Makefile /tmp/build/ObjectRecognition/
	-cp ObjRec /tmp/build/ObjectRecognition/
	-cp ObjectRecognitionUsingLinux.pdf /tmp/build/ObjectRecognition/
