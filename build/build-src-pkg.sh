#!/bin/bash

# { $Id$ }
# build a clean src package
# (c) 2009 by Hartmut Eilers
# <hartmut@eilers.net>

if [ "$1" = "" ]; then
  echo " please supply a release name e.g. openlab-src-1.0.1"
  exit 2
else
  REL=$1
fi


export CVSROOT=:ext:$LOGNAME@cvs.home.eilers.net:/home/cvs

# make a temporary build directory
mkdir /tmp/$REL
cd /tmp/$REL

# check out a clean src
cvs co OpenMSR

# make package
cd ..
tar -czvf /tmp/$REL.tar.gz $REL

# clean up
rm -rf /tmp/$REL

# finished inform user
echo " your package is saved as /tmp/"$REL
