#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building Kernel
#
##############################################################

#
# Install dependencies
#
echo "Install dependencies"
sudo apt-get install -y -qq lib32ncurses5-dev libncurses5-dev meld lzop

#
# ARM Cross Compiler
#
echo "Install ARM Cross Compiler"
sudo apt-get install -y -qq gcc-arm-linux-gnueabi


#
# Downloading and patching uBoot
#
echo "Downloading and patching uBoot"
cd $DIR_MAIN
git clone git://git.denx.de/u-boot.git
cd $DIR_UBOOT
git checkout v2013.07 -b tmp
wget https://raw.github.com/eewiki/u-boot-patches/master/v2013.07/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch

#
# uBoot mkimage
#
make tools
sudo install tools/mkimage /usr/local/bin

#
# Building uBoot
#
echo "Building uBoot"
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- am335x_evm_config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4

#
# Downloading and building the Linux Kernel
#    https://github.com/beagleboard/kernel/tree/3.8
#
echo "Downloading and building the Linux Kernel"
cd $DIR_MAIN
git clone git://github.com/beagleboard/kernel.git
cd $DIR_KERNEL
git checkout 3.8

# This step may take 10 minutes or longer
./patch.sh

cp $DIR_SCRIPT/files/beaglebone_android_defconfig kernel/arch/arm/configs/

# Download pre-compiled power management firmware
wget http://arago-project.org/git/projects/?p=am33x-cm3.git\;a=blob_plain\;f=bin/am335x-pm-firmware.bin\;hb=HEAD -O kernel/firmware/am335x-pm-firmware.bin
cd kernel
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- beaglebone_android_defconfig
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- menuconfig

# This step builds the kernel and may take 15-20 minutes or longer
#   => output available in arch/arm/boot/uImage
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage dtbs -j4

# This step builds the kernel for the BBB
#   => output available in arch/arm/boot/uImage-dtb.am335x-boneblack
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage-dtb.am335x-boneblack -j4

# This builds the kernel modules and may take 20 minutes or longer
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- modules -j4
<<<<<<< HEAD

# install modules
mkdir ../modules_out
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- INSTALL_MOD_PATH=../modules_out modules_install
=======


#
# If successfull, create an empty file
#
#touch $DIR_MAIN/kernel.build
>>>>>>> 0e021565c62c349c2ada23ef851704079557d21a

