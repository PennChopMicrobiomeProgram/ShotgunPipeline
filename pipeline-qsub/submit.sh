#!/bin/bash
set -x
set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 JOB_PREFIX WORK_DIR"
    exit 1
fi

# Command line arguments
JOB_PREFIX="$1"
WORK_DIR="$2"

# Path to other scripts
SCRIPT_DIR=$( dirname "$0" )
DEMULTIPLEX_SCRIPT_FP="${SCRIPT_DIR}/demultiplex.sh"
PROCESS_SAMPLE_SCRIPT_FP="${SCRIPT_DIR}/process_sample.sh"

# Standard input file names
BC="${WORK_DIR}/barcodes.txt"

# Get list of samples
SAMPLES=$(cut -f 1 "$BC")

# Demultiplexing job
DEMULTIPLEX_JOBNAME="${JOB_PREFIX}-demultiplex"
if [ $NO_QSUB ]; then
    "$DEMULTIPLEX_SCRIPT_FP" "$WORK_DIR"
else
    qsub -N "$DEMULTIPLEX_JOBNAME" "$DEMULTIPLEX_SCRIPT_FP" "$WORK_DIR"
fi


# Sample processing jobs
for SAMPLE in $SAMPLES; do
    SAMPLE_JOBNAME="${JOB_PREFIX}-sample-${SAMPLE}"
    if [ $NO_QSUB ]; then
	"$PROCESS_SAMPLE_SCRIPT_FP" "$WORK_DIR" "$SAMPLE"
    else
	qsub -l h_vmem=8G -hold_jid "$DEMULTIPLEX_JOBNAME" -N "$SAMPLE_JOBNAME" "$PROCESS_SAMPLE_SCRIPT_FP" "$WORK_DIR" "$SAMPLE"
    fi
done
