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
cp ../04-android/OUTPUT/root/* SOURCE/
cp ../04-android/OUTPUT/system SOURCE/
cp ../03-busybox/OUTPUT/busybox SOURCE/system/xbin/
mkdir -p system/lib/modules
find ../02-kernel/OUTPUT/lib/modules -name \*.ko -exec cp {} SOURCE/system/lib/modules/ \;
cp -r ../02-kernel/OUTPUT/lib/firmware SOURCE/system/lib/

#
# Create tarball
#
mkdir OUTPUT
sudo ../04-android/build/tools/mktarball.sh ../04-android/out/host/linux-x86/bin/fs_get_stats SOURCE/ . rootfs ../OUTPUT/rootfs.tar.bz2

#
# If successfull, create an empty file
#
touch .build_successful
