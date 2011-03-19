# build script for OpenLabTools
# (c) 2009 by Hartmut Eilers
# <hartmut@eilers.net>

if [ "$1" = "" ]; then
  echo " please supply a release name e.g. openlab-1.0.1"
  exit 2
else
  REL=$1
fi

if [ "$2" = "" ]; then
  echo " please supply a target platform [linux|arm] "
  exit 3
else
  ARCH=$2
fi

mkdir /tmp/build

# copy libs
mkdir /tmp/build/libs
pushd /tmp/build/libs
cp /usr/lib/libad4.so.4.1.334 .
cp /usr/lib/libiowkit.so.1.0.5 .
popd

targets="datalogger DeviceServer ObjectRecognition OpenLabDocs oszi sps"
for i in $targets; do 
  mkdir /tmp/build/$i
  cd $i;
  . ./environment
  export SPSVERSION=$REL
  make BLD_ARCH=$ARCH clean
  make BLD_ARCH=$ARCH
  make BLD_ARCH=$ARCH build
  cd ..;
done;

cp CREDITS /tmp/build/
cp README /tmp/build/
cp CHANGES /tmp/build/

mkdir $REL
cp -a /tmp/build/* $REL/
tar -czvf ../Releases/$REL.tar.gz $REL

rm -rf /tmp/build

echo "Please check directory $REL and remove it when everything is done"

