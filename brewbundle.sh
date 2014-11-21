#!/bin/bash
#
#   Usage:
#       brewbundle.sh [file]
#
#   Author:
#       @84____ (Masaya Tk.)
#

base=${0##*/}
_error() {
    echo "${base%.sh}: invaild argument" 1>&2
    exit 1
}

if [ -z "${1}" ]; then _error; fi

while read line; do
    if $(echo ${line} | grep -qv -e '^$' -e '^#'); then
        brew ${line}
    fi
done < ${1}
