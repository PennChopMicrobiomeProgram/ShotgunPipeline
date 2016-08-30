#!/bin/bash
set -x
set -e
set -u

if [ $# -ne 2 ]; then
    echo "Usage: $0 WORK_DIR SAMPLE"
    exit 1
fi

## These two lines are respublica specific. Consider moving these to a config file!
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH-}:/cm/shared/apps/gcc/4.7.0/lib:/cm/shared/apps/gcc/4.7.0/lib64
export PATH=${PATH-}:"${HOME}/.virtualenvs/shotgun-pipeline/bin:${HOME}/.local/bin"
export PYTHONPATH=${PYTHONPATH-}:"${HOME}/.virtualenvs/shotgun-pipeline/lib/python2.7/site-packages/:${HOME}/.local/lib/python2.7/site-packages"

# Command line arguments
WORK_DIR="$1"
SAMPLE="$2"

# Standard input file names
DNABC_OUTPUT_DIR="${WORK_DIR}/dnabc_results"

# Standard output file names
SUMMARY_DIR="${WORK_DIR}/summary"
ILLQC_SUMMARY="$SUMMARY_DIR/summary-illqc_${SAMPLE}.json"
DECONTAM_HOST_SUMMARY="${SUMMARY_DIR}/summary-decontam_host_${SAMPLE}.json"
DECONTAM_PHIX_SUMMARY="${SUMMARY_DIR}/summary-decontam_phix_${SAMPLE}.json"
PHYLO_SUMMARY="${SUMMARY_DIR}/summary-phylo_${SAMPLE}.json"
PATHWAY_SUMMARY="${SUMMARY_DIR}/summary-pathway_${SAMPLE}.json"
ILLQC_OUTPUT_DIR="${WORK_DIR}/illqc_results"
ILLQC_QC_OUTPUT_DIR="${WORK_DIR}/illqc_reports"
DECONTAM_HOST_OUTPUT_DIR="${WORK_DIR}/decontam_host_results"
DECONTAM_PHIX_OUTPUT_DIR="${WORK_DIR}/decontam_phix_results"
PHYLO_OUTPUT_DIR="${WORK_DIR}/phyloprofiler_results"
PATHWAY_OUTPUT_DIR="${WORK_DIR}/pathfinder_results"

# Make the summary directory
mkdir -p $SUMMARY_DIR

# Filenames for forward and reverse FASTQ files
R1="PCMP_${SAMPLE}_R1.fastq"
R2="PCMP_${SAMPLE}_R2.fastq"

## Quality control
illqc.py \
    --forward-reads "${DNABC_OUTPUT_DIR}/${R1}" \
    --reverse-reads "${DNABC_OUTPUT_DIR}/${R2}" \
    --output-dir $ILLQC_OUTPUT_DIR \
    --qc-output-dir $ILLQC_QC_OUTPUT_DIR \
    --summary-file $ILLQC_SUMMARY

# We are done with the dnabc results and could delete them now
# rm "${DNABC_OUTPUT_DIR}/${R1}"
# rm "${DNABC_OUTPUT_DIR}/${R2}"

## Decontamination phix
decontaminate.py \
    --forward-reads "${ILLQC_OUTPUT_DIR}/${R1}" \
    --reverse-reads "${ILLQC_OUTPUT_DIR}/${R2}" \
    --output-dir $DECONTAM_PHIX_OUTPUT_DIR \
    --summary-file $DECONTAM_PHIX_SUMMARY \
    --organism phix

## Decontamination human
decontaminate.py \
    --forward-reads "${DECONTAM_PHIX_OUTPUT_DIR}/${R1}" \
    --reverse-reads "${DECONTAM_PHIX_OUTPUT_DIR}/${R2}" \
    --output-dir $DECONTAM_HOST_OUTPUT_DIR \
    --summary-file $DECONTAM_HOST_SUMMARY \
    --organism host

# We are done with the illqc results and could delete them now
# rm "${ILLQC_OUTPUT_DIR}/${R1}"
# rm "${ILLQC_OUTPUT_DIR}/${R2}"

## Taxonomic assignment
phyloprofiler.py \
    --forward-reads "${DECONTAM_HOST_OUTPUT_DIR}/${R1}" \
    --reverse-reads "${DECONTAM_HOST_OUTPUT_DIR}/${R2}" \
    --output-dir $PHYLO_OUTPUT_DIR \
    --summary-file $PHYLO_SUMMARY

## Functional assignment
pathfinder.py \
    --forward-reads "${DECONTAM_HOST_OUTPUT_DIR}/${R1}" \
    --reverse-reads "${DECONTAM_HOST_OUTPUT_DIR}/${R2}" \
    --output-dir $PATHWAY_OUTPUT_DIR \
    --summary-file $PATHWAY_SUMMARY

