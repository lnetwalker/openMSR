# build script for OpenLabTools
# (c) 2009 by Hartmut Eilers
# <hartmut@eilers.net>

if [ "$1" = "" ]; then
  echo " please supply a release name e.g. openlab-1.0.1"
  exit 2
else
  REL=$1
fi

mkdir build

# copy libs
mkdir build/libs
cd build/libs
cp /usr/lib/libad4.so.4.1.334 .
cp /usr/lib/libiowkit.so.1.0.5 .
cd ../..

targets="datalogger DeviceServer ObjectRecognition OpenLabDocs oszi sps"

for i in $targets; do 
  mkdir build/$i
  cd $i;
  make build;
  cd ..;
done;

cp CREDITS build/
cp README build/

mkdir $REL
mv build/* $REL
tar -czvf Releases/$REL.tar.gz $REL

rmdir build

echo "Please check directory $REL and remove it when everything is done"

