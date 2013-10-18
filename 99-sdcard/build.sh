#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building XXX
#
##############################################################

CURRENT_SUBDIR_PATH=$(pwd)

#
# Downloading and patching XXX
#
echo "Downloading and patching XXX"

#
# Building XXX
#
echo "Building XXX"

#
# Copy artefacts
#

#
# If successfull, create an empty file
#
touch .build_successful
