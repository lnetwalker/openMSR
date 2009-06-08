# make SPS for Linux
#
# Copyright (c) 1999 by Hartmut Eilers
# 
# Just do a "make all", and, when you're finished, a make clean. 
# to remake a part do "make sps" for the ide
# and a "make run_sps" for the runtime modules

OBJECTS=sps

all: $(OBJECTS)


# the sps IDE
sps: 	sps.pas edit.pas fileserv.pas info.pas popmenu.pas run_awl.pas sps.h awl_interpreter.pas run_awl.h
	/usr/bin/fpc -gl -Fu../PhysMach -Fu../PhysMach/test/libad4 -Fu../divLibs/pwu-1.6.0.2-src/main/ sps.pas

# the SPS runtime module	
run_sps:	run_sps.pas awl_interpreter.pas run_awl.h
		/usr/bin/fpc -gl -Fu../PhysMach -Fu../PhysMach/test/libad4 -Fu../divLibs/pwu-1.6.0.2-src/main/ run_sps.pas

clear:
	-rm run_sps
			
clean :
	-rm *.ppu
	-rm *.a
	-rm *.o
	-rm *.s
	-rm $(OBJECTS)
	
build :
	-rm ../build/sps/awls/WerkzeugmaschineNT/*
	-rm ../build/sps/awls/*
	-rm ../build/sps/*
	-cp awls/WerkzeugmaschineNT/werkzeugmaschine2.pdf ../build/sps/awls/WerkzeugmaschineNT/
	-cp awls/WerkzeugmaschineNT/werkzeugmaschine2.sps ../build/sps/awls/WerkzeugmaschineNT/
	-cp awls/* ../build/sps/awls/
	-cp LICENSE ../build/sps/
	-cp README ../build/sps/
	-cp sps ../build/sps/
	-cp sps.cfg ../build/sps/
	-cp sps.doc ../build/sps/
	-cp sps-d.doc ../build/sps/
	-cp sps-e.doc ../build/sps/
	