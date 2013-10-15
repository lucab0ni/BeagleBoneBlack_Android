##############################################################
#
# BeagleBoneBlack Building Kernel
#
##############################################################

mkdir ~/android_bbb

sudo apt-get install lib32ncurses5-dev

#
# ARM Cross Compiler
#
sudo apt-get install gcc-arm-linux-gnueabi

#
# lzop Compression
#
sudo apt-get install lzop

#
# Downloading and patching uBoot
#
cd ~/android_bbb
git clone git://git.denx.de/u-boot.git
cd u-boot/
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
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- am335x_evm_config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-

#
# Downloading and building the Linux Kernel
#    https://github.com/beagleboard/kernel/tree/3.8
#
cd ~/android_bbb
git clone git://github.com/beagleboard/kernel.git
cd kernel
git checkout 3.8

# This step may take 10 minutes or longer
./patch.sh

cp configs/beaglebone kernel/arch/arm/configs/beaglebone_defconfig

# Download pre-compiled power management firmware
wget http://arago-project.org/git/projects/?p=am33x-cm3.git\;a=blob_plain\;f=bin/am335x-pm-firmware.bin\;hb=HEAD -O kernel/firmware/am335x-pm-firmware.bin
cd kernel
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- beaglebone_defconfig -j4

# This step builds the kernel and may take 15-20 minutes or longer
#   => output available in arch/arm/boot/uImage
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage dtbs -j4

# This step builds the kernel for the BBB
#   => output available in arch/arm/boot/uImage-dtb.am335x-boneblack
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage-dtb.am335x-boneblack -j4

# This builds the kernel modules and may take 20 minutes or longer
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- modules



