#!/bin/bash
set -x

if [ $# -ne 2 ]; then
    echo "Usage: $0 JOB_PREFIX WORK_DIR"
    exit 1
fi

# Command line arguments
JOB_PREFIX="$1"
WORK_DIR="$2"

# Standard input file names
BC="${WORK_DIR}/barcodes.txt"

# Get list of samples
SAMPLES=$(cut -f 1 "$BC")

# Demultiplexing job
DEMULTIPLEX_JOBNAME="${JOB_PREFIX}-demultiplex"
echo qsub -N "$DEMULTIPLEX_JOBNAME" demultiplex.sh "$WORK_DIR" 

# Sample processing jobs
for SAMPLE in $SAMPLES; do
    SAMPLE_JOBNAME="${JOB_PREFIX}-sample-${SAMPLE}"
    echo qsub -N "$SAMPLE_JOBNAME" process_sample.sh "$WORK_DIR" "$SAMPLE"
done
