#!/bin/bash
#===============================================================================
# Filename:  buildql.sh
# Author:    Philip Barnes
# Copyright: (c) Copyright 2012 Philip Barnes
#===============================================================================
# Changes:
# 
# Use huuskpes boost build (supports 1.51.0), QuantLib 1.2.1 and xcode 4.5.1
#===============================================================================
#
# Builds a quantlib framework for iOS
# Creates a set of universal libraries that can be used on an iPad/iPhone and
# in the iPad/iPhone simulator.
#
# Requires a pre-built version of boost built using the boost.sh script by
# Pete Goodliffe. The structure of this script is based on Pete's boost.sh.
#
# This takes a brute-force approach to the build and builds the arm6, arm7 and
# i386 versions of quantlib one after the other. It makes clean between builds.
#
# To configure the script, change the variables below to point to the build of
# boost
#===============================================================================

: ${BOOST_HOME:=$HOME/tmp/huuskpes-boostoniphone}
: ${BOOST_SRC:=$BOOST_HOME/src/boost_1_51_0}

#===============================================================================
# The number of jobs for make to run. On a 2.8 Mac Pro 8 core it takes around
# 31 minutes with 9 jobs to build all the libraries and framework.
#===============================================================================

: ${JOBS:=9}

#===============================================================================
# No need to change these variables.
# Xcode 4.5.1 is used to build the libraries. This now resides in
# /Applications/Xcode.app/Contents rather than /Developer
#===============================================================================

: ${ARM_DEV_DIR:=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer}
: ${SIM_DEV_DIR:=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer}

: ${SRCDIR:=`pwd`/src}
: ${BUILDDIR:=`pwd`/build}
: ${PREFIXDIR:=`pwd`/prefix}
: ${FRAMEWORKDIR:=`pwd`/framework}

#===============================================================================
# Utility functions for reporting
#===============================================================================

displayConfiguration()
{
    echo
    echo "    ================================================================="
    echo
    echo "    Configuration"
    echo "    SRCDIR       :" $SRCDIR
    echo "    BUILDDIR     :" $BUILDDIR
    echo "    PREFIXDIR    :" $PREFIXDIR
    echo "    FRAMEWORKDIR :" $FRAMEWORKDIR
    echo
    echo "    BOOST_HOME   :" $BOOST_HOME
    echo "    BOOST_SRC    :" $BOOST_SRC
    echo
    echo "    JOBS         :" $JOBS
    echo
    echo "    ARM_DEV_DIR  :" $ARM_DEV_DIR
    echo "    SIM_DEV_DIR  :" $SIM_DEV_DIR
}

displayMessage()
{
    echo
    echo "    ================================================================="
    echo "    $@"
    echo
}

doneSection()
{
    echo
    echo "    ================================================================="
    echo "    Done"
    echo
}

abort()
{
    echo
    echo "Aborted: $@"
    exit 1
}

#===============================================================================
# Prepare the directory structures
#===============================================================================

cleanEverythingReadyToStart()
{
    displayMessage "Cleaning everything ready to start"

    rm -rf $BUILDDIR
    rm -rf $PREFIXDIR
    rm -rf $FRAMEWORKDIR

    doneSection
}

#===============================================================================
# Prepare the directory structures
#===============================================================================

createDirectoryStructure()
{
    displayMessage "Creating directory structure"

    [ -d $BUILDDIR ]     || mkdir -p $BUILDDIR
    [ -d $PREFIXDIR ]    || mkdir -p $PREFIXDIR
    [ -d $FRAMEWORKDIR ] || mkdir -p $FRAMEWORKDIR

    doneSection
}

#===============================================================================
# Build the armv6 quantlib libraries
#===============================================================================

buildArmv6()
{
    displayMessage "Configuring Armv6 libraries"

    ./configure --with-boost-include=$BOOST_SRC \
    --with-boost-lib=$BOOST_HOME/target/armv6 \
    --host=arm-apple-darwin10 \
    --target=arm-apple-darwin10 \
    --prefix="$PREFIXDIR"/armv6 \
    CPP=/usr/bin/cpp \
    CXXCPP=/usr/bin/cpp \
    CXXFLAGS="-march=armv6 -mno-thumb -gdwarf-2 -fmessage-length=0 -fvisibility=hidden -pipe -isysroot $ARM_DEV_DIR/SDKs/iPhoneOS6.0.sdk" \
    CXX=$ARM_DEV_DIR/usr/bin/arm-apple-darwin10-llvm-g++-4.2 \
    CC=$ARM_DEV_DIR/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
    AR=$ARM_DEV_DIR/usr/bin/ar \
    CFLAGS="-march=armv6 -pipe -std=c99 -Wno-trigraphs -fpascal-strings -Wreturn-type -Wunused-variable -fmessage-length=0 -fvisibility=hidden -gdwarf-2 -mno-thumb \
    -isysroot $ARM_DEV_DIR/SDKs/iPhoneOS6.0.sdk" \
    --disable-shared --enable-static

    displayMessage "Making Armv6 libraries"

    make -j $JOBS clean
    make -j $JOBS install

    doneSection
}

#===============================================================================
# Build the armv7 quantlib libraries
#===============================================================================

buildArmv7()
{
    displayMessage "Configuring Armv7 libraries"

    ./configure --with-boost-include=$BOOST_SRC \
    --with-boost-lib=$BOOST_HOME/target/armv7 \
    --host=arm-apple-darwin10 \
    --target=arm-apple-darwin10 \
    --prefix=$PREFIXDIR/armv7 \
    CPP=/usr/bin/cpp \
    CXXCPP=/usr/bin/cpp \
    CXXFLAGS="-march=armv7 -mthumb -gdwarf-2 -fmessage-length=0 -fvisibility=hidden -pipe -isysroot $ARM_DEV_DIR/SDKs/iPhoneOS6.0.sdk" \
    CXX=$ARM_DEV_DIR/usr/bin/arm-apple-darwin10-llvm-g++-4.2 \
    CC=$ARM_DEV_DIR/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
    AR=$ARM_DEV_DIR/usr/bin/ar \
    CFLAGS="-march=armv7 -pipe -std=c99 -Wno-trigraphs -fpascal-strings -Wreturn-type -Wunused-variable -fmessage-length=0 -fvisibility=hidden -gdwarf-2 -mthumb \
    -isysroot $ARM_DEV_DIR/SDKs/iPhoneOS6.0.sdk" \
    --disable-shared --enable-static

    displayMessage "making Armv7 libraries"

    make -j $JOBS clean
    make -j $JOBS install

    doneSection
}

#===============================================================================
# Build the armv7 quantlib libraries
#===============================================================================

buildArmv7s()
{
    displayMessage "Configuring Armv7 libraries"

    ./configure --with-boost-include=$BOOST_SRC \
    --with-boost-lib=$BOOST_HOME/target/armv7s \
    --host=arm-apple-darwin10 \
    --target=arm-apple-darwin10 \
    --prefix=$PREFIXDIR/armv7s \
    CPP=/usr/bin/cpp \
    CXXCPP=/usr/bin/cpp \
    CXXFLAGS="-march=armv7s -mthumb -gdwarf-2 -fmessage-length=0 -fvisibility=hidden -pipe -isysroot $ARM_DEV_DIR/SDKs/iPhoneOS6.0.sdk" \
    CXX=$ARM_DEV_DIR/usr/bin/arm-apple-darwin10-llvm-g++-4.2 \
    CC=$ARM_DEV_DIR/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
    AR=$ARM_DEV_DIR/usr/bin/ar \
    CFLAGS="-march=armv7s -pipe -std=c99 -Wno-trigraphs -fpascal-strings -Wreturn-type -Wunused-variable -fmessage-length=0 -fvisibility=hidden -gdwarf-2 -mthumb \
    -isysroot $ARM_DEV_DIR/SDKs/iPhoneOS6.0.sdk" \
    --disable-shared --enable-static

    displayMessage "making Armv7s libraries"

    make -j $JOBS clean
    make -j $JOBS install

    doneSection
}

#===============================================================================
# Build the i386 quantlib libraries
#===============================================================================

buildi386()
{
    displayMessage "Configuring i386 libraries"

    ./configure --with-boost-include=$BOOST_SRC \
    --with-boost-lib=$BOOST_HOME/target/i386 \
    --prefix=$PREFIXDIR/i386 \
    CPP=/usr/bin/cpp \
    CXXCPP=/usr/bin/cpp \
    CXXFLAGS="-march=i386 -pipe -isysroot $SIM_DEV_DIR/SDKs/iPhoneSimulator6.0.sdk" \
    CXX=$SIM_DEV_DIR/usr/bin/i686-apple-darwin11-llvm-g++-4.2 \
    CC=$SIM_DEV_DIR/usr/bin/i686-apple-darwin11-llvm-gcc-4.2 \
    AR=$SIM_DEV_DIR/usr/bin/ar \
    CFLAGS="-march=i386 -pipe"

    displayMessage "Building i386 libraries"

    make -j $JOBS clean
    make -j $JOBS install

    doneSection
}

#===============================================================================
# Build the framework
#
# Unlike the boost build by Pete Goodliffe, all the libraries are created
# individually and so do not need to be unpacked and scrunched together.
#
# Create the framework libraries in-situ
#===============================================================================

VERSION_TYPE=Alpha
FRAMEWORK_NAME=ql
FRAMEWORK_VERSION=A

FRAMEWORK_CURRENT_VERSION=1.2
FRAMEWORK_COMPATIBILITY_VERSION=1.2

buildFramework()
{
    FRAMEWORK_BUNDLE=$FRAMEWORKDIR/$FRAMEWORK_NAME.framework

    rm -rf $FRAMEWORK_BUNDLE

    displayMessage "Framework: Setting up directories..."

    mkdir -p $FRAMEWORK_BUNDLE
    mkdir -p $FRAMEWORK_BUNDLE/Versions
    mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION
    mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Resources
    mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Headers
    mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Documentation

    displayMessage "Framework: Creating symlinks..."
    ln -s $FRAMEWORK_VERSION               $FRAMEWORK_BUNDLE/Versions/Current
    ln -s Versions/Current/Headers         $FRAMEWORK_BUNDLE/Headers
    ln -s Versions/Current/Resources       $FRAMEWORK_BUNDLE/Resources
    ln -s Versions/Current/Documentation   $FRAMEWORK_BUNDLE/Documentation
    ln -s Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_BUNDLE/$FRAMEWORK_NAME

    FRAMEWORK_INSTALL_NAME=$FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/$FRAMEWORK_NAME

    displayMessage "Framework: Lipoing library into $FRAMEWORK_INSTALL_NAME"

    /Applications/Xcode.app/Contents//Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/lipo \
        -create \
        -arch armv7 "$PREFIXDIR/armv7/lib/libQuantLib.a" \
        -arch armv7s "$PREFIXDIR/armv7s/lib/libQuantLib.a" \
        -arch i386  "$PREFIXDIR/i386/lib/libQuantLib.a" \
        -o          "$FRAMEWORK_INSTALL_NAME" \
    || abort "Lipo $1 failed"

    displayMessage "Framework: Copying includes..."
    cp -r $PREFIXDIR/i386/include/ql/*  $FRAMEWORK_BUNDLE/Headers/

    displayMessage "Framework: Creating plist..."
    cat > $FRAMEWORK_BUNDLE/Resources/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleExecutable</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>org.boost</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>${FRAMEWORK_CURRENT_VERSION}</string>
</dict>
</plist>
EOF
    doneSection
}


#===============================================================================
# Execution starts here
#===============================================================================

displayConfiguration
cleanEverythingReadyToStart
createDirectoryStructure
buildArmv6
buildArmv7
buildArmv7s
buildi386
buildFramework

displayMessage "Completed successfully"
