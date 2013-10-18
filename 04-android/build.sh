#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building Android
#
##############################################################

CURRENT_SUBDIR_PATH=$(pwd)

#
# Downloading Android
#
echo "Downloading and patching Android"
mkdir SOURCE
cd SOURCE
repo init -u git://gitorious.org/rowboat/manifest.git -m rowboat-jb-am335x.xml 1>>${CURRENT_SUBDIR_PATH}/repo.log 2>>${CURRENT_SUBDIR_PATH}/repo.log
repo sync 1>>${CURRENT_SUBDIR_PATH}/repo.log 2>>${CURRENT_SUBDIR_PATH}/repo.log
rm -fr kernel
ln -s ../../02-kernel/SOURCE/kernel kernel
rm -fr device/ti/beagleboneblack
cd device/ti
git clone https://github.com/nelenkov/android_device_ti_beagleboneblack.git beagleboneblack 1>>${CURRENT_SUBDIR_PATH}/git.log
cd beagleboneblack
#sed -i~ -e 's/gpio_keys_12/gpio_keys_13/' device.mk
patch -p1 < ../../../../files/beagleboneblack.patch 1>>${CURRENT_SUBDIR_PATH}/patch.log 2>>${CURRENT_SUBDIR_PATH}/patch.log
cd ../../..

#
# Download serial port API
#
#cd packages/apps
#svn checkout http://android-serialport-api.googlecode.com/svn/trunk/android-serialport-api/project AndroidSerialportAPI

#
# Set up ccache
#   http://source.android.com/source/initializing.html#setting-up-ccache
#
if [ -f prebuilts/misc/linux-x86/ccache/ccache ]
then
	echo "Setting up ccache"
	export USE_CCACHE=1
	prebuilts/misc/linux-x86/ccache/ccache -M 50G
fi

#
# Building Android
#
echo "Building Android"
make TARGET_PRODUCT=beagleboneblack OMAPES=4.x droid 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log

#
# Copy artefact
#
cp -r out/target/product/beagleboneblack ../OUTPUT
cd ..

#
# If successfull, create an empty file
#
touch .build_successful
