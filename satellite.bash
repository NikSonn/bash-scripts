#!/usr/bin/env bash
# Copyright (C) 2019 Dmitriy Prigoda <deamon.none@gmail.com> 
# This script is free software: Everyone is permitted to copy and distribute verbatim copies of 
# the GNU General Public License as published by the Free Software Foundation, either version 3
# of the License, but changing it is not allowed.
# This scripr the client registration on satellite/katello servers.

PACKAGES=( bash )

if [[ $EUID -ne 0 ]]; then
   echo "[-] This script must be run as root" 1>&2
   exit 1
fi

function pad {
  PADDING="..............................................................."
  TITLE=$1
  printf "%s%s  " "${TITLE}" "${PADDING:${#TITLE}}"
}

# Export LANG so we get consistent results
# For instance, fr_FR uses comma (,) as the decimal separator.
export LANG=en_US.UTF-8

# initialize PRINT_* counters to zero
fail_count=0 ; success_count=0

function print_FAIL {
  echo -e "$@ \e[1;31mFAIL\e[0;39m\n"
  let fail_count++
  return 0
}

function print_SUCCESS {
  echo -e "$@ \e[1;32mSUCCESS\e[0;39m\n"
  let success_count++
  return 0
}

function print_usage {
cat <<EOF
Registration this client on Katello. 
     Options:
        -s | --server <value>               Specify server name or ip address server repository.
        -o | --organization <value>         Specify organization name on Satellite/Katello server.
                                            If no value is specified, then use: "Default_Organization"
                                            (opcional option)
        -k | --key <value>                  This activation key may be used during system registration.
        -l | --list                         Show list keys.
        -h | -?                             Show help.
    
     Example: bash $0 -s <name> -k <key> -o <organization>
EOF
exit 1
}

if [[ -z $* ]]; then
   print_usage
fi

for arg in "$@"; do
  shift
  case "$arg" in
    "--server")       set -- "$@" "-s" ;;
    "--key")          set -- "$@" "-k" ;;
    "--organization") set -- "$@" "-o" ;;
    "--list")         set -- "$@" "-l" ;;
    *)                set -- "$@" "$arg"
  esac
done

unset IDSERV IDORG IDKEY

if [[ -z ${IDORG} ]]; then
   IDORG='Default_Organization'
fi

function checkargs {
if [[ $OPTARG =~ ^-[s/k/o]$ ]]
then
echo "Not set argument for option: ${OPTION}"
exit 1
fi
}

while getopts "s:k:o::l" OPTION
do
     case $OPTION in
         s) checkargs; IDSERV=${OPTARG} ;;
         k) checkargs; IDKEY=${OPTARG} ;;
         o) checkargs; IDORG=${OPTARG} ;;
         l) LIST="list" ;;
         *) echo "Invalid option."; break;;
     esac
done

shift $(expr $OPTIND - 1)

echo ${IDSERV}; echo ${IDKEY}; echo ${IDORG}; echo ${LIST};
