#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking run_sps
/usr/bin/ld  -dynamic-linker=/lib/ld-linux.so.2  -s -L. -o run_sps link.res
if [ $? != 0 ]; then DoExitLink run_sps; fi
