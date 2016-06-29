# make ObjectRecognition
#
# Copyright (c) 1999-2009 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

# ToDo:
# make it crosscompilable for linux i386,x64 and arm
# just copy info stuff for win32 !

OBJECTS=ObjRec ObjectRecognition

all: $(OBJECTS)


# the physical Machine access layer
ObjectRecognition: 	main.cpp ObjRec.cpp
	c++ main.cpp ObjRec.cpp webcam.cpp -Wno-deprecated -L/usr/lib/X11 -lX11  -o ObjectRecognition

ObjRec: 	ObjRec.cpp
	c++ -c ObjRec.cpp -Wno-deprecated -fPIC
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
