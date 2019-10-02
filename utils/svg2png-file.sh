#!/bin/bash

if test "$#" -lt 2; then
    echo "Illegal number of parameters. input file and quality must be specified"
    exit 256
fi

INPUT_FILE=$1
QUALITY=$2

OUTPUT_FILE="${INPUT_FILE%.*}.png"
echo "Converting ${INPUT_FILE}"

svgexport ${INPUT_FILE} ${OUTPUT_FILE} ${QUALITY}
