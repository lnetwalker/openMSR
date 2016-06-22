# build script for OpenLabTools
# (c) 2009 by Hartmut Eilers
# <hartmut@eilers.net>

# error handling stuff
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }


if [ "$1" = "" ]; then
  echo " please supply a build Id"
  exit 2
else
  BUILDID=$1
fi
 
if [ "$2" = "" ]; then
  echo " please supply a release name e.g. openlab-1.0.1"
  exit 2
else
  REL=$2
fi

if [ "$3" = "" ]; then
  echo " please supply a target platform [linuxarm|linux386|linux64|win32|gnublin|linuxfree] "
  exit 2
else
  ARCH=$3
fi
 
RELEASE=$REL-$BUILDID-$ARCH

BUILD_DIR=/tmp/$USER/build
mkdir -p $BUILD_DIR

# copy libs
mkdir $BUILD_DIR/libs
if [ "$ARCH" = "linuxfree" ]; then
  cp extLib/free/i386/* $BUILD_DIR/libs
else
  cp -a extLib/* $BUILD_DIR/libs
fi

echo "cleaning up sources for old stuff"
find . -name "*.ppu" -exec rm -f {} \;
find . -name "*.exe" -exec rm -f {} \;
find . -name "*.o" -exec rm -f {} \;
find . -name "*.a" -exec rm -f {} \;
find . -name "*.s" -exec rm -f {} \;


# build the targets
targets="datalogger DeviceServer oszi sps fktplot FunkIO OpenLabDocs LogicSim2.4 ObjectRecognition"
#targets="datalogger DeviceServer oszi sps fktplot"
for i in $targets; do 
  echo "************** building target $i *******************"
  mkdir -p $BUILD_DIR/$i
  cd $i;
  if [ -e ./environment ]; then
    . ./environment
  fi
  export SPSVERSION=$REL
  make BLD_ARCH=$ARCH clean
  make BLD_ARCH=$ARCH
  if [ $? != 0 ]; then
    echo "error: in build of $i"
    exit 1
  fi

  make BLD_ARCH=$ARCH build
  cd ..;
done;

echo "************ all targets done, copying stuff ****************"
cp CREDITS $BUILD_DIR/
cp README $BUILD_DIR/
cp CHANGES $BUILD_DIR/

# remove .svn stuff
find $BUILD_DIR -name ".svn" -exec rm -rf {} \;

mkdir $RELEASE
cp -a $BUILD_DIR/* $RELEASE/
tar -czvf /home/hartmut/daten/src/Releases/$RELEASE.tar.gz $RELEASE

rm -rf $BUILD_DIR

echo "Please check directory $RELEASE and remove it when everything is done"

