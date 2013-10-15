##############################################################
#
# Initializing a Build Environment
#
##############################################################


#
# Git configuration
#
git config --global color.ui auto


#
# Install Java JDK 6
#   http://linuxg.net/how-to-install-oracle-java-jdk-678-on-ubuntu-13-04-12-10-12-04/
#
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y oracle-java6-installer

#
# Install required packages
#   http://source.android.com/source/initializing.html#installing-required-packages-ubuntu-1204
#
sudo apt-get install -y git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386 python-lunch
sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

#
# Configuring USB access
#   http://source.android.com/source/initializing.html#configuring-usb-access
#
sudo cp scripts/files/51-android.rules /etc/udev/rules.d/


##############################################################
#
# Downloading the Android Source Code
#
##############################################################


#
# Installing repo
#   http://source.android.com/source/downloading.html#installing-repo
#
mkdir ~/bin
PATH=~/bin:$PATH
curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
chmod 755 ~/bin/repo

#
# Initializing a Repo client
#   http://source.android.com/source/downloading.html#initializing-a-repo-client
#
mkdir ~/android_bbb
cd ~/android_bbb
mkdir android_source
cd android_source
repo init -u https://android.googlesource.com/platform/manifest -b android-4.3_r1

#
# Downloading the Android Source Tree
#   http://source.android.com/source/downloading.html#getting-the-files
#
repo sync

#
# Verifying Git Tags
#   http://source.android.com/source/downloading.html#verifying-git-tags
#


#
# Setting up ccache
#   http://source.android.com/source/initializing.html#setting-up-ccache
#
export USE_CCACHE=1
prebuilts/misc/linux-x86/ccache/ccache -M 50G

source build/envsetup.sh
lunch aosp_arm-userdebug
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4
