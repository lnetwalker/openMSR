# make ObjectRecognition
#
# Copyright (c) 1999-2009 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=ObjRec

all: $(OBJECTS)


# the physical Machine access layer
ObjRec: 	main.cpp
	g++ -Wno-deprecated -L/usr/X11R6/lib -lX11  main.cpp -o ObjRec

clear:
			
clean :

	-rm *~
	-rm $(OBJECTS)

build:
	-rm ../build/ObjectRecognition/*
	-cp ObjRec ../build/ObjectRecognition/
	-cp ObjectRecognitionUsingLinux.pdf ../build/ObjectRecognition/
