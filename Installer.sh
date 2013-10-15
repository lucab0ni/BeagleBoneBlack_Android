#/bin/bash

export BBB_ANDROID_PATH=$PWD

# http://askubuntu.com/questions/67909/how-do-i-install-oracle-jdk-6
echo
echo "Installing the JDK"
echo
sudo add-apt-repository ppa:ferramroberto/java
sudo apt-get update
sudo apt-get install sun-java6-jdk

echo
echo "Java version installed:"
java -version


echo
echo "Installing required packages"
echo
sudo apt-get install git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc
sudo ln -s /usr/lib32/mesa/libGL.so.1 /usr/lib32/mesa/libGL.so

echo
echo "Installing Repo"
echo
mkdir ~/bin
PATH=~/bin:$PATH
curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
chmod a+x ~/bin/repo

echo
echo "Using a separate output directory"
echo
export OUT_DIR_COMMON_BASE=$HOME/JellyBean_4.3

echo
echo "Checkout Android source code tree"
echo
mkdir $BBB_ANDROID_PATH/rowboat-android
cd rowboat-android
repo init -u git://gitorious.org/rowboat/manifest.git -m rowboat-jb-am335x.xml
repo sync

# http://www.eewiki.net/display/linuxonarm/BeagleBone+Black#BeagleBoneBlack-LinuxKernel
echo
echo "Checkout and build of Linux Kernel"
echo
sudo apt-get update
sudo apt-get install device-tree-compiler lzop uboot-mkimage

cd $BBB_ANDROID_PATH
git clone git://github.com/RobertCNelson/linux-dev.git
cd linux-dev/
git checkout origin/am33x-v3.12 -b tmp
./build_kernel.sh

echo
echo "Checkout and build the Bootloader"
echo
cd $BBB_ANDROID_PATH
git clone git://git.denx.de/u-boot.git
cd u-boot/
git checkout v2013.04 -b tmp
wget https://raw.github.com/eewiki/u-boot-patches/master/v2013.04/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch

cd $BBB_ANDROID_PATH/u-boot/
make ARCH=arm CROSS_COMPILE=$BBB_ANDROID_PATH/linux-dev/dl/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin/arm-linux-gnueabihf- distclean
make ARCH=arm CROSS_COMPILE=$BBB_ANDROID_PATH/linux-dev/dl/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin/arm-linux-gnueabihf- am335x_evm_config
make ARCH=arm CROSS_COMPILE=$BBB_ANDROID_PATH/linux-dev/dl/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin/arm-linux-gnueabihf-

echo
echo "Build the Filesystem (Rowboat)"
echo
cd $BBB_ANDROID_PATH/rowboat-android
mv kernel kernel.backup
ln -s $BBB_ANDROID_PATH/linux-dev/KERNEL kernel
cp Makefile Makefile.backup
# Modify Makefile according to http://icculus.org/~hendersa/android/ chapter Android::Build("Filesystem")
make TARGET_PRODUCT=beagleboneblack OMAPES=4.x -j4 droid

cd out/target/product/beagleboneblack
mkdir android_rootfs
cp -r root/* android_rootfs
cp -r system android_rootfs
cd android_rootfs/system
tar -xvzf $BBB_ANDROID_PATH/linux-dev/deploy/*modules.tar.gz

cd $BBB_ANDROID_PATH/rowboat-android
cd out/target/product/beagleboneblack
cp android_rootfs/init.rc android_rootfs/init.rc.backup
# Modify init.rc according to http://icculus.org/~hendersa/android/ chapter Android::Build("Filesystem")

cp android_rootfs/fstab.am335xevm android_rootfs/fstab.am335xevm.backup
# Modify fstab.am335xevm according to http://icculus.org/~hendersa/android/ chapter Android::Build("Filesystem")

cp android_rootfs/system/build.prop android_rootfs/system/build.prop.backup
# Modify fstab.am335xevm according to http://icculus.org/~hendersa/android/ chapter Android::Build("Filesystem")

sudo ../../../../build/tools/mktarball.sh ../../../host/linux-x86/bin/fs_get_stats android_rootfs . rootfs rootfs.tar.bz2

echo
echo "Install Android on the SD Card"
echo
cd $BBB_ANDROID_PATH
mkdir image
cp rowboat-android/external/ti_android_utilities/am335x/mk-mmc/* image
cp rowboat-android/out/target/product/beagleboneblack/rootfs.tar.bz2 image
cp u-boot/MLO image
cp u-boot/u-boot.img image
cp linux-dev/KERNEL/arch/arm/boot/zImage image
cp linux-dev/KERNEL/arch/arm/boot/dts/am335x-boneblack.dtb image

cd /media/boot
sudo mv uImage zImage
sudo cp /home/user/image/am335x-boneblack.dtb .
sync

echo
echo "Install Eclipse"
echo
wget http://mirror.switch.ch/eclipse/technology/epp/downloads/release/kepler/SR1/eclipse-standard-kepler-SR1-linux-gtk-x86_64.tar.gz
ln -s $HOME/eclipse/eclipse $HOME/Desktop/eclipse

# Download the ADT plugin
# https://dl-ssl.google.com/android/eclipse/

# Creating an Android project
# http://developer.android.com/training/basics/firstapp/creating-project.html


