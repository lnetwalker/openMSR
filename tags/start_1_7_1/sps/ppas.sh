#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking sps
/usr/bin/ld  -dynamic-linker=/lib/ld-linux.so.2  -s -L. -o sps link.res
if [ $? != 0 ]; then DoExitLink sps; fi
