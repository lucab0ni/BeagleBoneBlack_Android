#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building Bootloader
#
##############################################################

CURRENT_SUBDIR_PATH=$(pwd)

#
# Downloading and patching uBoot
#
echo "Downloading and patching uBoot"
git clone git://git.denx.de/u-boot.git SOURCE 1>>${CURRENT_SUBDIR_PATH}/git.log
cd SOURCE
git checkout v2013.07 -b tmp 1>>${CURRENT_SUBDIR_PATH}/git.log
wget https://raw.github.com/eewiki/u-boot-patches/master/v2013.07/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch

#
# uBoot mkimage
#
make tools 1>>${CURRENT_SUBDIR_PATH}/build.log
export OLDPATH=${PATH}
export PATH=$(pwd)/tools:${PATH}

#
# Building uBoot
#
echo "Building uBoot"
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- distclean 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- am335x_evm_config 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- am335x_evm_config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4

#
# Copy artefacts
#
cd ..
if [ ! -d OUTPUT ]; then
	mkdir OUTPUT
fi
cp SOURCE/MLO SOURCE/u-boot.img OUTPUT/
cp files/uEnv.txt OUTPUT/

#
# Restore original path
#
export PATH=${OLDPATH}

#
# If successfull, create an empty file
#
touch .build_successful
