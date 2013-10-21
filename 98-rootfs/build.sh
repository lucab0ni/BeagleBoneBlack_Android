#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building rootfs
#
##############################################################

CURRENT_SUBDIR_PATH=$(pwd)

#
# Building rootfs
#
mkdir SOURCE
cp -r ../04-android/OUTPUT/root/* SOURCE/
cp -r ../04-android/OUTPUT/system SOURCE/
cp ../03-busybox/OUTPUT/busybox SOURCE/system/xbin/
cp ../05-serialtest/OUTPUT/SerialTest.apk SOURCE/system/app/
mkdir -p SOURCE/system/lib/modules
find ../02-kernel/OUTPUT/lib/modules -name \*.ko -exec cp {} SOURCE/system/lib/modules/ \;
cp -r ../02-kernel/OUTPUT/lib/firmware SOURCE/system/lib/

#
# Create tarball
#
mkdir OUTPUT
sudo ../04-android/SOURCE/build/tools/mktarball.sh ../04-android/SOURCE/out/host/linux-x86/bin/fs_get_stats SOURCE/ . rootfs OUTPUT/rootfs.tar.bz2

#
# If successfull, create an empty file
#
touch .build_successful
