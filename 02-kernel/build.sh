#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building Kernel
#
##############################################################

CURRENT_SUBDIR_PATH=$(pwd)

#
# Downloading and building the Linux Kernel
#    https://github.com/beagleboard/kernel/tree/3.8
#
echo "Downloading and building the Linux Kernel"
git clone git://github.com/beagleboard/kernel.git SOURCE 1>>${CURRENT_SUBDIR_PATH}/git.log
cd SOURCE
git checkout 3.8 1>>${CURRENT_SUBDIR_PATH}/git.log

# This step may take 10 minutes or longer
./patch.sh 1>>${CURRENT_SUBDIR_PATH}/patch.log 2>>${CURRENT_SUBDIR_PATH}/patch.log

cp ../files/beaglebone_android_defconfig kernel/arch/arm/configs/

# Download pre-compiled power management firmware
wget http://arago-project.org/git/projects/?p=am33x-cm3.git\;a=blob_plain\;f=bin/am335x-pm-firmware.bin\;hb=HEAD -O kernel/firmware/am335x-pm-firmware.bin
cd kernel
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- beaglebone_android_defconfig 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- menuconfig

# This step builds the kernel and may take 15-20 minutes or longer
#   => output available in arch/arm/boot/uImage
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage dtbs -j4 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log

# This step merges the device tree into the kernel for the BBB
#   => output available in arch/arm/boot/uImage-dtb.am335x-boneblack
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage-dtb.am335x-boneblack -j4 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log

# This builds the kernel modules and may take 20 minutes or longer
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- modules -j4 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log

#
# This step installs the kernel and the modules
#
mkdir ../../OUTPUT
cp arch/arm/boot/uImage-dtb.am335x-boneblack ../../OUTPUT/uImage
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- INSTALL_MOD_PATH=../../OUTPUT modules_install 1>>${CURRENT_SUBDIR_PATH}/install.log
cd ../..

#
# If successfull, create an empty file
#
touch .build_successful
