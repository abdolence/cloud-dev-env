#!/bin/bash

if test "$#" -lt 1; then
    echo "Illegal number of parameters. Directory must be specified"
    exit 256
fi

QUALITY=${2:-"100"}

CUR_DIR=`dirname "$0"`

echo "Converting all in: ${1}. Quality: ${QUALITY}"

find $1 -name "*.png" -exec ${CUR_DIR}/png2webp-file.sh {} ${QUALITY} \;
