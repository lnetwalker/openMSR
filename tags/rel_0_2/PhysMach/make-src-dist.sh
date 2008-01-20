#!/bin/bash

# this script is used to generate the src distribution tarball
# $1 is the version string

Tempdir="PhysMach-$1"
mkdir ./$Tempdir

cp *_io_access*.pas ./$Tempdir
cp iowkit.pas ./$Tempdir
cp PhysMach.pas ./$Tempdir
cp *.cfg ./$Tempdir
cp README* ./$Tempdir
cp LICENSE ./$Tempdir
cp -a docs ./$Tempdir
tar -czvf $Tempdir.tar.gz ./$Tempdir

rm -rf ./$Tempdir

