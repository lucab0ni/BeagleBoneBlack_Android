#!/bin/bash
# Any subsequent commands which fail will cause the shell script to exit immediate
set -e

##############################################################
#
# Initializing a Build Environment
#
##############################################################

#
# Global variables
#
export MAIN_DIR=$(git rev-parse --show-toplevel)

SUBDIRS=$(ls -1d [0-9][0-9]-* | sort)

for subdir in ${SUBDIRS}; do
	export CURRENT_SUBDIR=${subdir}
	export CURRENT_SUBDIR_PATH="${MAIN_DIR}/${subdir}"
	
	if [ ! -x ${subdir}/build.sh ]; then
		echo "Skipping subdir ${subdir}"
	else
		echo "Building subdir ${subdir}"

		cd "${subdir}"
		rm -f *.log .build_successful
		if [ -d SOURCE ]; then
			rm -fr SOURCE
		fi
		if [ -d OUTPUT ]; then
			rm -fr OUTPUT
		fi
		sh ./build.sh
		if [ -f .build_successful ]; then
			echo "  successful."
		else
			echo "  failed! - check logfile."
			exit 1
		fi
		cd ..
	fi
done
