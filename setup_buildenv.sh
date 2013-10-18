#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediately
set -e

##############################################################
#
# Initializing a Build Environment
#
##############################################################

sudo apt-get update
sudo apt-get -f dist-upgrade

#
# Install dependencies for u-boot and linux
#
sudo apt-get install -y -qq lib32ncurses5-dev libncurses5-dev meld lzop

#
# ARM Cross Compiler
#
sudo apt-get install -y -qq gcc-arm-linux-gnueabi

#
# Install Java JDK 6
#   http://linuxg.net/how-to-install-oracle-java-jdk-678-on-ubuntu-13-04-12-10-12-04/
#
echo "Install Java JDK 6"
sudo add-apt-repository -y -qq ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y -qq oracle-java6-installer

#
# Install required packages for Android
#   http://source.android.com/source/initializing.html#installing-required-packages-ubuntu-1204
#
echo "Install required packages"
sudo apt-get install -y -qq git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386 python-lunch
if [ ! -f /usr/lib/i386-linux-gnu/libGL.so ]
then
	sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
fi

#
# Installing repo
#   http://source.android.com/source/downloading.html#installing-repo
#
echo "Installing repo"
if [ ! -f /usr/local/bin/repo ]
then
	#sudo wget https://dl-ssl.google.com/dl/googlesource/git-repo/repo -O /usr/local/bin/repo
	sudo wget http://commondatastorage.googleapis.com/git-repo-downloads/repo -O /usr/local/bin/repo
	sudo chmod a+x /usr/local/bin/repo
fi



