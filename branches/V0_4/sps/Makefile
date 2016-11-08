# make SPS for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make BLD_ARCH=[arm|linux|win32|osx]  all", and, when you're finished,
# a "make BLD_ARCH=[arm|linux|win32|osx] clean". 
# to remake a part do "make BLD_ARCH=[arm|linux|win32|osx] sps" for the ide
# and a "make BLD_ARCH=[arm|linux|win32|osx] run_sps" for the runtime modules

OBJECTS=sps run_sps

# get compiler and flags for the given platform
include ../build/make_includes/$(BLD_ARCH)
include ./make_macros/$(BLD_ARCH)_macros
include ../build/make_includes/unit-searchpath

all: $(OBJECTS)


# the sps IDE
sps: 	sps.pas edit.pas fileserv.pas info.pas popmenu.pas run_awl.pas sps.h awl_interpreter.pas run_awl.h
	$(FPC) $(FPC_FLAGS)  -gl $(UNITSEARCH) sps.pas

# the SPS runtime module	
run_sps:	run_sps.pas awl_interpreter.pas run_awl.h
		$(FPC) $(FPC_FLAGS)  -gl $(UNITSEARCH) run_sps.pas

clean:
	-rm run_sps
			

	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
	-rm *.exe
	
build :
	-mkdir /tmp/$(USER)/build/sps/awls
	-mkdir /tmp/$(USER)/build/sps/awls/WerkzeugmaschineNT
	-cp awls/WerkzeugmaschineNT/werkzeugmaschine2.pdf /tmp/$(USER)/build/sps/awls/WerkzeugmaschineNT/
	-cp awls/WerkzeugmaschineNT/werkzeugmaschine2.sps /tmp/$(USER)/build/sps/awls/WerkzeugmaschineNT/
	-cp awls/* /tmp/$(USER)/build/sps/awls/
	-cp LICENSE /tmp/$(USER)/build/sps/
	-cp README /tmp/$(USER)/build/sps/
ifeq ($(BLD_ARCH),win32)
	-cp sps.exe /tmp/$(USER)/build/sps
	-cp run_sps.exe /tmp/$(USER)/build/sps
else
	-cp sps /tmp/$(USER)/build/sps/
	-cp run_sps /tmp/$(USER)/build/sps/
endif
	-cp .run_sps.cfg /tmp/$(USER)/build/sps/
	-cp sps.cfg /tmp/$(USER)/build/sps/
	-cp sps.doc /tmp/$(USER)/build/sps/
	-cp sps-d.doc /tmp/$(USER)/build/sps/
	-cp sps-e.doc /tmp/$(USER)/build/sps/

