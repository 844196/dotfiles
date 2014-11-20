#!/bin/bash
#
#   Usage:
#       brewbundle.sh [file]
#
#   Author:
#       @84____ (Masaya Tk.)
#

base=${0##*/}
OLD_IFS=${IFS}
IFS=","

_error() {
    echo "${base%.sh}: invaild argument" 1>&2
    exit 1
}

if [ -z "${1}" ]; then _error; fi

brewfile=(`cat ${1} | grep -v -e '^$' -e '^#' | tr -s "\n" ','`)

for command in ${brewfile[@]}; do
    brew ${command}
done

IFS=${OLD_IFS}
