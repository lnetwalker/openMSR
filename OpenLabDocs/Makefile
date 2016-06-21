# make Documentation
#
# Copyright (c) 1999-2009 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 

build:

ifeq ($(BLD_ARCH),linuxfree)
	-cp  LabTools-UserGuide.pdf /tmp/$(USER)/build/OpenLabDocs/
	-cp  DeviceServerAPI-english.pdf  /tmp/$(USER)/build/OpenLabDocs/ 
	-cp  OpenMSR-GUI.pdf /tmp/$(USER)/build/OpenLabDocs/
else
	-cp  LabTools-UserGuide-full.pdf /tmp/$(USER)/build/OpenLabDocs/
endif
