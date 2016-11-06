# make Documentation
#
# Copyright (c) 1999-2009 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

OBJECTS=Documentation

# get compiler and flags for the given platform
#include ../build/make_includes/$(BLD_ARCH)
#include ./make_macros/$(BLD_ARCH)_macros
#include ../build/make_includes/unit-searchpath

all: $(OBJECTS)

# the physical Machine access layer
Documentation:   LabTools-UserGuide-full.odt
	soffice --convert-to pdf LabTools-UserGuide-full.odt  --headless

clear:

clean :
	-rm *~

build:
