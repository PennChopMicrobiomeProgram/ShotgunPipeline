#!/bin/bash
set -x

# Input directory
DECONTAM_OUTPUT_DIR="decontam_results"

# Logging
log () {
    echo "$(date "+%Y-%m-%d %H:%M:%S") ${1}" >> time.log
}

# Output dirs
SUMMARY_DIR="summary"
mkdir -p $SUMMARY_DIR

for R1_FILE in ${DECONTAM_OUTPUT_DIR}/*_R1.fastq; do
    SAMPLE_R1=${R1_FILE##*/}
    SAMPLE_R2=${SAMPLE_R1/_R1.fastq/_R2.fastq}
    SAMPLE_NAME=${SAMPLE_R1%%_R1.fastq}
    echo $SAMPLE_NAME

    ## Taxonomic assignment
    log "START:PhyloProfiler ${SAMPLE_NAME}"
    PHYLO_SUMMARY="${SUMMARY_DIR}/summary-phylo_${SAMPLE_NAME}.json"
    PHYLO_OUTPUT_DIR="phyloprofiler_results"
    phyloprofiler.py \
	--forward-reads ${DECONTAM_OUTPUT_DIR}/$SAMPLE_R1 \
	--reverse-reads ${DECONTAM_OUTPUT_DIR}/$SAMPLE_R2 \
	--summary-file $PHYLO_SUMMARY \
	--output-dir $PHYLO_OUTPUT_DIR
    log "FINISH:PhyloProfiler ${SAMPLE_NAME}"

    ## Functional assignment
    log "START:PathFinder ${SAMPLE_NAME}"
    PATHWAY_SUMMARY="${SUMMARY_DIR}/summary-pathway_${SAMPLE_NAME}.json"
    PATHWAY_OUTPUT_DIR="pathfinder_results"
    pathfinder.py \
	--forward-reads ${DECONTAM_OUTPUT_DIR}/$SAMPLE_R1 \
	--reverse-reads ${DECONTAM_OUTPUT_DIR}/$SAMPLE_R2 \
	--summary-file $PATHWAY_SUMMARY \
	--output-dir $PATHWAY_OUTPUT_DIR
    log "FINISH:PathFinder ${SAMPLE_NAME}"

done

