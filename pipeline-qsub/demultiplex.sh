#!/bin/bash
set -x
set -e
set -u

if [ $# -ne 1 ]; then
    echo "Usage: $0 WORK_DIR"
    exit 1
fi

# Command line arguments
WORK_DIR="$1"

SCRIPT_DIR="${HOME}/.virtualenvs/shotgun-pipeline/bin"

# Standard input file names
FWD="${WORK_DIR}/small_R1.fastq"
REV="${WORK_DIR}/small_R2.fastq"
BC="${WORK_DIR}/barcodes.txt"

# Standard output file names
SUMMARY_DIR="${WORK_DIR}/summary"
DNABC_SUMMARY="${SUMMARY_DIR}/summary-dnabc.json"
DNABC_OUTPUT_DIR="${WORK_DIR}/dnabc_results"

# Make the summary directory
mkdir -p $SUMMARY_DIR

## Demultiplexing
"${SCRIPT_DIR}/dnabc.py" \
    --forward-reads $FWD \
    --reverse-reads $REV \
    --barcode-file $BC \
    --summary-file $DNABC_SUMMARY \
    --output-dir $DNABC_OUTPUT_DIR
