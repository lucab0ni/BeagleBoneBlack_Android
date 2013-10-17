#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
#set -e

##############################################################
#
# Initializing a Build Environment
#
##############################################################

#
# Global variables
#
echo "Global variables"
export DIR_MAIN_GITHUB=$(git rev-parse --show-toplevel)


#
# Git configuration
#
echo "Git configuration"
git config --global color.ui auto


#
# Environment Setup
#
echo $DIR_MAIN_GITHUB
export DIR_SCRIPT=$DIR_MAIN_GITHUB/scripts
export DIR_TOOLS=$DIR_MAIN_GITHUB/tools
export DIR_LOG=$DIR_MAIN_GITHUB/log

export DIR_MAIN=$DIR_MAIN_GITHUB/android_bbb
export DIR_UBOOT=$DIR_MAIN/u-boot
export DIR_KERNEL=$DIR_MAIN/kernel
export DIR_ANDROID_SOURCE=$DIR_MAIN/android_source

# If the main directory doesn't exists, create it
if [ ! -d $DIR_MAIN ]
then
	mkdir $DIR_MAIN
fi

# If the log directory doesn't exists, create it
if [ ! -d $DIR_LOG ]
then
	mkdir $DIR_LOG
fi


#
# Building Bootloader and Kernel
#
if [ ! -f $DIR_MAIN/kernel.build ]
then
	echo "Building Bootloader and Kernel"
	sh $DIR_SCRIPT/bbb_build_kernel.sh
else
	echo "Skipping building of Bootloader and Kernel"
fi


#
# Building Android Source Code
#
if [ ! -f $DIR_MAIN/android.build ]
then
	echo "Building Android Source Code"
	sh $DIR_SCRIPT/bbb_build_android.sh
else
	echo "Skipping building of Android Source Code"
fi


#
# Preparing files for formating the SD-Card
#
#echo "Preparing files for formating the SD-Card"
#sh $DIR_SCRIPT/bbb_prepare_sdcard.sh


#
# Formating the SD-Card
#
#echo "Formating the SD-Card"
#sh $DIR_SCRIPT/bbb_format_sdcard.sh


