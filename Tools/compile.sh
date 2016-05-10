#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

make -j 8
#ninja -C WORK/cmake
wget http://ciscobinary.openh264.org/libopenh264-1.5.0-osx64.dylib.bz2 
bzip2 -d libopenh264-1.5.0-osx64.dylib.bz2
install_name_tool -id @rpath/libopenh264.1.dylib libopenh264-1.5.0-osx64.dylib 
mv -f  libopenh264-1.5.0-osx64.dylib  WORK/Build/linphone_package/linphone-sdk-tmp/lib/libopenh264.1.dylib 

xcodebuild -project ACE.xcodeproj -alltargets -parallelizeTargets -configuration \
 Debug build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" CODE_SIGN_ENTITLEMENTS="" 

xcodebuild -project ACE.xcodeproj -alltargets -parallelizeTargets -configuration \
 Release build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" CODE_SIGN_ENTITLEMENTS="" 

