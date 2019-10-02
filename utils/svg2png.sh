#!/bin/bash

if test "$#" -lt 1; then
    echo "Illegal number of parameters. Directory must be specified"
    exit 255
fi

QUALITY=${2:-"85%"}

CUR_DIR=`dirname "$0"`

echo "Converting all in: ${1}. Quality: ${QUALITY}"

find $1 -name "*.svg" -exec ${CUR_DIR}/svg2png-file.sh {} ${QUALITY} \;
