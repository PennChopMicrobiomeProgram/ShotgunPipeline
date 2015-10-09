#!/bin/bash
# Deploy all software necessary for ShotgunPipeline
#
# Does not (yet) build search indexes from FASTA files.
# Does not (yet) write configuration files for the pipeline.
#
# Pre-requisites not included in deployment:
# python (>= 2.7.3)
# pip

set -x
set -e
set -u

VERSION="1.0"


# Software and data directories

SOFTWARE_DIR="$HOME/software"
mkdir -p "$SOFTWARE_DIR"

BIODATA_DIR="$HOME/biodata"
mkdir -p "$BIODATA_DIR"


# Functions

download_and_unzip () {
    wget "http://hivsystemsbiology.org/files/shotgun-pipeline/${VERSION}/${1}"
    unzip "$1"
    rm "$1"
}


## STEP 1: Demultiplexing

# dnabc
pip install --upgrade \
    git+https://github.com/PennChopMicrobiomeProgram/dnabc.git


## STEP 2: Quality control

# IllQC
pip install --upgrade \
    git+https://github.com/PennChopMicrobiomeProgram/illqc.git

# Trimmomatic
pushd "$SOFTWARE_DIR"
download_and_unzip Trimmomatic-0.33.zip
popd

# FastQC
pushd "$SOFTWARE_DIR"
download_and_unzip fastqc_v0.11.3.zip
popd

# seqtk
pushd "$SOFTWARE_DIR"
download_and_unzip seqtk_4feb6e8144.zip
popd


## STEP 3: Decontamination

# decontam
pip install --upgrade \
    git+https://github.com/PennChopMicrobiomeProgram/decontam.git
pip install --upgrade pysam

# Bowtie2
pushd "$SOFTWARE_DIR"
download_and_unzip bowtie2-2.2.6-linux-x86_64.zip
popd

# Bwa
pushd "$SOFTWARE_DIR"
download_and_unzip bwa-0.7.12.zip
popd

# Human, PhiX174 genomes
pushd "$BIODATA_DIR"
download_and_unzip hg38.zip
download_and_unzip phix.zip
popd


## STEP 4: Taxonomic assignment

# PhylogeneticProfiler
pip install --upgrade \
    git+https://github.com/PennChopMicrobiomeProgram/PhylogeneticProfiler.git

# metaphlan2
pushd "$SOFTWARE_DIR"
download_and_unzip metaphlan2_61ad257cc091.zip
popd
pip install --upgrade numpy
pip install --upgrade biom-format


## STEP 5: Functional assignment

# PathwayAbundanceFinder
pip install --upgrade \
    git+https://github.com/PennChopMicrobiomeProgram/PathwayAbundanceFinder.git

# Rapsearch2
pushd "$SOFTWARE_DIR"
download_and_unzip RAPSearch2.23_64bits.zip
popd

# KEGG database
pushd "$BIODATA_DIR"
download_and_unzip kegg.zip
popd
