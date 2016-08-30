#!/bin/bash
set -x
set -e

if [ $# -ne 4 ]; then
    echo "Usage: $0 JOB_PREFIX WORK_DIR LANE_NUM H_VMEM"
    exit 1
fi

# Command line arguments
JOB_PREFIX="$1"
WORK_DIR="$2"
LANE_NUM="$3" # Format is lane number by itself or padded with zeros (eg. 1, 01, 001)
H_VMEM="$4" # Format is #G such as 20G

# Path to other scripts
SCRIPT_DIR=$( dirname "$0" )
DEMULTIPLEX_SCRIPT_FP="${SCRIPT_DIR}/demultiplex.sh"
PROCESS_SAMPLE_SCRIPT_FP="${SCRIPT_DIR}/process_sample.sh"
#PROCESS_SAMPLE_SCRIPT_FP="${SCRIPT_DIR}/process_sample_path.sh"


# Standard input file names
BC="${WORK_DIR}/barcodes.txt"

# Get list of samples
SAMPLES=$(cut -f 1 "$BC")

# Demultiplexing job
DEMULTIPLEX_JOBNAME="${JOB_PREFIX}-demultiplex"
if [ $NO_QSUB ]; then
    "$DEMULTIPLEX_SCRIPT_FP" "$WORK_DIR"
else
    qsub -r n -l h_vmem=$H_VMEM -N "$DEMULTIPLEX_JOBNAME" "$DEMULTIPLEX_SCRIPT_FP" "$WORK_DIR" "$LANE_NUM"
fi


# Sample processing jobs
for SAMPLE in $SAMPLES; do
    SAMPLE_JOBNAME="${JOB_PREFIX}-sample-${SAMPLE}"
    if [ $NO_QSUB ]; then
	"$PROCESS_SAMPLE_SCRIPT_FP" "$WORK_DIR" "$SAMPLE"
    else
	qsub -r n -l h_vmem=$H_VMEM -l h_core=8 -hold_jid "$DEMULTIPLEX_JOBNAME" -N "$SAMPLE_JOBNAME" "$PROCESS_SAMPLE_SCRIPT_FP" "$WORK_DIR" "$SAMPLE"
    fi
done
