#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# BeagleBoneBlack Building boot partition
#
##############################################################

CURRENT_SUBDIR_PATH=$(pwd)

#
# Copy artefacts
#
mkdir SOURCE
cp ../01-uboot/OUTPUT/* SOURCE/
cp ../02-kernel/OUTPUT/uImage SOURCE/

#
# Build tarball
#
mkdir OUTPUT
cd SOURCE
tar cjf ../OUTPUT/rootfs.tar.bz2 *
cd ..

#
# If successfull, create an empty file
#
touch .build_successful
