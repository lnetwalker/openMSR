# make ObjectRecognition
#
# Copyright (c) 1999-2009 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

# ToDo:
# make it crosscompilable for linux i386,x64 and arm
# just copy info stuff for win32 !

OBJECTS=ObjRec

all: $(OBJECTS)


# the physical Machine access layer
ObjRec: 	main.cpp
	c++ main.cpp -Wno-deprecated -L/usr/lib/X11 -lX11  -o ObjRec

clear:
			
clean :

	-rm *~
	-rm $(OBJECTS)

build:
	-cp README /tmp/build/ObjectRecognition/
	-cp main.cpp /tmp/build/ObjectRecognition/
	-cp Makefile /tmp/build/ObjectRecognition/
	-cp ObjRec /tmp/build/ObjectRecognition/
	-cp ObjectRecognitionUsingLinux.pdf /tmp/build/ObjectRecognition/
