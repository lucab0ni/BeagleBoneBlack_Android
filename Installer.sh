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
	
	echo "Building subdir ${subdir}"

	cd "${subdir}"
	rm -fr SOURCE OUTPUT *.log .build_successful
	sh ./build.sh
	if [ -f .build_successful ]; then
		echo "  successful."
	else
		echo "  failed! - check logfile."
		exit 1
	fi;
	cd ..
done
