#!/bin/bash
set -x
set -e
set -u

if [ $# -ne 2 ]; then
    echo "Usage: $0 WORK_DIR LANE_NUM"
    exit 1
fi

# Command line arguments
WORK_DIR="$1"
LANE_NUM="$2"

## We should consider moving this to config file!
export PATH=${PATH-}:"${HOME}/.virtualenvs/shotgun-pipeline/bin:${HOME}/.local/bin"
export PYTHONPATH=${PYTHONPATH-}:"${HOME}/.virtualenvs/shotgun-pipeline/lib/python2.7/site-packages/:${HOME}/.local/lib/python2.7/site-packages"

# Standard input file names
BC="${WORK_DIR}/barcodes.txt"
FWD="${WORK_DIR}/Undetermined_S0_L$(printf "%03d" $LANE_NUM)_R1_001.fastq"
REV="${WORK_DIR}/Undetermined_S0_L$(printf "%03d" $LANE_NUM)_R2_001.fastq"

# Standard output file names
SUMMARY_DIR="${WORK_DIR}/summary"
DNABC_SUMMARY="${SUMMARY_DIR}/summary-dnabc.json"
DNABC_OUTPUT_DIR="${WORK_DIR}/dnabc_results"

# Make the summary directory
mkdir -p $SUMMARY_DIR

## Demultiplexing
dnabc.py \
    --forward-reads $FWD \
    --reverse-reads $REV \
    --barcode-file $BC \
    --summary-file $DNABC_SUMMARY \
    --output-dir $DNABC_OUTPUT_DIR
