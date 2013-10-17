#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building Android Source Code
#
##############################################################

#
# Install Java JDK 6
#   http://linuxg.net/how-to-install-oracle-java-jdk-678-on-ubuntu-13-04-12-10-12-04/
#
echo "Install Java JDK 6"
sudo add-apt-repository -y -qq ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y -qq oracle-java6-installer

#
# Install required packages
#   http://source.android.com/source/initializing.html#installing-required-packages-ubuntu-1204
#
echo "Install required packages"
sudo apt-get install -y -qq git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386 python-lunch
if [ ! -f /usr/lib/i386-linux-gnu/libGL.so ]
then
	sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
fi

#
# Configuring USB access
#   http://source.android.com/source/initializing.html#configuring-usb-access
#
if [ ! -f /etc/udev/rules.d/51-android.rules ]
then
	echo "Configuring USB access"
	sudo cp $DIR_SCRIPT/files/51-android.rules /etc/udev/rules.d/
fi


##############################################################
#
# Downloading the Android Source Code
#
##############################################################


#
# Installing repo
#   http://source.android.com/source/downloading.html#installing-repo
#
echo "Installing repo"
# If the repo bin directory doesn't exists, create it
if [ ! -d $DIR_MAIN/bin ]
then
	mkdir $DIR_MAIN/bin
	export PATH=$DIR_MAIN/bin:$PATH
fi
if [ ! -f $DIR_MAIN/bin/repo ]
then
	#curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
	curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $DIR_MAIN/bin/repo
	chmod a+x $DIR_MAIN/bin/repo
fi


#
# Initializing a Repo client
#   http://source.android.com/source/downloading.html#initializing-a-repo-client
#
echo "Initializing a Repo client"
# If the folder where to copy the Android Source Code doesn't exists, create it
if [ ! -d $DIR_ANDROID_SOURCE ]
then
	mkdir $DIR_ANDROID_SOURCE
fi
cd $DIR_ANDROID_SOURCE
repo init -u https://android.googlesource.com/platform/manifest -b android-4.3_r1 &> $DIR_LOG/log_repo_init.txt

#
# Downloading the Android Source Tree
#   http://source.android.com/source/downloading.html#getting-the-files
#
echo "Downloading the Android Source Tree"
repo sync &> $DIR_LOG/log_repo_sync.txt

#
# Verifying Git Tags
#   http://source.android.com/source/downloading.html#verifying-git-tags
#


#
# Setting up ccache
#   http://source.android.com/source/initializing.html#setting-up-ccache
#
if [ ! -f prebuilts/misc/linux-x86/ccache/ccache ]
then
	echo "ccache doesn't exist.. exit!"
	exit
else
	echo "Setting up ccache"
	export USE_CCACHE=1
	prebuilts/misc/linux-x86/ccache/ccache -M 50G
fi

#
# Building Android Source Code as aosp_arm-userdebug
#   http://source.android.com/source/building-running.html
#
echo "Building Android Source Code as aosp_arm-userdebug"
source build/envsetup.sh
lunch aosp_arm-userdebug
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4


#
# If successfull, create an empty file
#
#touch $DIR_MAIN/android.build
