#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building SerialTest
#
##############################################################

CURRENT_SUBDIR_PATH=$(pwd)

#
# Building SerialTest
#
echo "Building SerialTest"
export TOP=$(pwd)/../04-android/SOURCE
source ${TOP}/build/envsetup.sh
cp -r files/SerialTest SOURCE
cd SOURCE
mm 1>>${CURRENT_SUBDIR_PATH}/build.log 2>>${CURRENT_SUBDIR_PATH}/build.log

#
# Copy artefacts
#
cd ..
mkdir OUTPUT
cp ${TOP}/out/target/product/generic/data/app/SerialTest.apk OUTPUT/

#
# If successfull, create an empty file
#
touch .build_successful
