#!/usr/bin/env bash

set -e

BIN_PATHS="/bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /usr/games"

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

function search_lib() {
	slackpkg file-search $1 | grep "uninstalled" | awk {'print $3'}
}

function print_missing_libs() {
	# Get all binaries from the paths defined in $BIN_PATHS
	BINARIES=`find $BIN_PATHS -type f -executable 2>/dev/null | sort`

	# Collect all missing shared libs in this variable for later inspection
	dep_tmp=""

	for binary in $BINARIES; do
		# Filter out every shared lib which is not found on the given binary
		res_tmp=`ldd $binary | grep "not found" | awk {'print $1'} | uniq | sed -e 's/^[[:space:]]*//'`

		# if $tmp is empty there is no missing shared lib found
		if [[ $res_tmp != "" ]]; then
			# Print out missing libs and format it nicely
			echo -e "-----> ${GREEN}${binary}${NC}"
			echo -e "${RED}${res_tmp}${NC}"

			# Add the given lib to the MISSING_DEP variable
			dep_tmp="$dep_tmp $res_tmp"

			echo
		fi
	done

	# Generate the list of missing libs and format it
	SO_LIST=`echo -e $dep_tmp | tr " " "\n" | sort | uniq`

	echo -e "${RED}Libraries which are missing:${NC}\n"
	echo $SO_LIST
	echo

	echo -e "${RED}The following packages contain the missing libraries:${NC}\n"
	IFS=" "
	for lib in $SO_LIST;do
		# Search for the given lib
		search_lib $lib
	done
	echo
}

function main() {
	print_missing_libs

	exit 0
}

main
