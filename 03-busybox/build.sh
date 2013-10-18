#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building Busybox
#
##############################################################

CURRENT_SUBDIR_PATH=$(pwd)

#
# Downloading and patching Busybox
#
echo "Downloading Busybox"
wget http://www.busybox.net/downloads/busybox-1.21.1.tar.bz2
tar xf busybox-1.21.1.tar.bz2
rm busybox-1.21.1.tar.bz2
mv busybox-1.21.1 SOURCE

#
# Building BusyBox
#
echo "Building BusyBox"
cd SOURCE
make CROSS_COMPILE=arm-linux-gnueabi- defconfig 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log
make CROSS_COMPILE=arm-linux-gnueabi- CFLAGS="-static" LDFLAGS="-static" busybox -j4 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log

#
# Copy artefacts
#
cd ..
mkdir OUTPUT
cp SOURCE/busybox OUTPUT/

#
# If successfull, create an empty file
#
touch .build_successful
