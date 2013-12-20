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
  echo " please supply a target platform [linuxarm|linux386|linux64|win32|gnublin|linuxfree] "
  exit 3
else
  ARCH=$2
fi

RELEASE=$REL-$ARCH

mkdir /tmp/build

# copy libs
mkdir /tmp/build/libs
if [ "$ARCH" = "linuxfree" ]; then
  cp extLib/free/i386/* /tmp/build/libs
else
  cp -a extLib/* /tmp/build/libs
fi

# build the targets
targets="datalogger DeviceServer ObjectRecognition OpenLabDocs oszi sps fktplot FunkIO LogicSim2.4"
for i in $targets; do 
  mkdir -p /tmp/build/$i
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

# remove .svn stuff
find /tmp/build/ -name ".svn" -exec rm -rf {} \;

mkdir $RELEASE
cp -a /tmp/build/* $RELEASE/
tar -czvf /data/hartmut/src/Releases/$RELEASE.tar.gz $RELEASE

rm -rf /tmp/build

echo "Please check directory $RELEASE and remove it when everything is done"

