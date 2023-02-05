#!/usr/bin/env bash

set -e

PRG_NAME='slackdep'
PRG_VER='0.1'

BIN_PATHS="/bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /usr/games"
SLACKPKG="/usr/sbin/slackpkg"

EXIT_OK=0
EXIT_FAIL=1

ARG=$1

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

function usage() {
	echo "USAGE: $PRG_NAME [-h|-v]"
	echo "   -h Show this help"
	echo "   -v Show version"
	echo "written by jhx (2023)"
	exit $EXIT_OK
}

function version() {
	echo "$PRG_NAME v${PRG_VER}"
	exit $EXIT_OK
}

function error() {
	echo -e "${RED}[Error]${NC} ${GREEN}$1${NC} - $2"
	exit $EXIT_FAIL
}

function msg() {
	echo -e "${RED}[${GREEN}Info${RED}]${NC} $1"
}

function init() {
	if [[ "$ARG" == "-h" ]]; then
		usage
	fi

	if [[ "$ARG" == "-v" ]]; then
		version
	fi

	msg "Checking for Slackpkg..."
	if [[ ! -f $SLACKPKG ]]; then
		error "init()" "Not found, aborting. Please install slackpkg!"
	fi
	msg "Slackpkg found."
}

function search_lib() {
	$SLACKPKG file-search $1 | grep "uninstalled" | awk {'print $3'}
}

function print_missing_libs() {
	msg "Running Slackdep..."

	# Get all binaries from the paths defined in $BIN_PATHS
	BINARIES=`find $BIN_PATHS -type f -executable 2>/dev/null | sort`

	# Collect all missing shared libs in this variable for later inspection
	dep_tmp=""

	for binary in $BINARIES; do
		# Filter out every shared lib which is not found on the given binary
		res_tmp=`ldd $binary 2>/dev/null | grep "not found" | awk {'print $1'} | uniq | sed -e 's/^[[:space:]]*//'`

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

	msg "Done!"
}

function main() {
	init

	print_missing_libs

	exit $EXIT_OK
}

main
