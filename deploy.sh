#!/bin/bash
# Deploy all software necessary for ShotgunPipeline
#
# Pre-requisites not included in deployment:
# python (>= 2.7.3)
# pip

set -x
set -e
set -u

# Software and data directories

SOFTWARE_DIR="$HOME/software"
mkdir -p "$SOFTWARE_DIR"

BIODATA_DIR="$HOME/biodata"
mkdir -p "$BIODATA_DIR"


# Functions

download_and_unzip () {
    # Download and unzip a file into a specified directory.
    URL="$1"
    FILENAME=$( basename "$URL" )
    wget "$URL"
    unzip "$FILENAME"
    rm "$FILENAME"
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
download_and_unzip \
    http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.33.zip
popd

# FastQC
pushd "$SOFTWARE_DIR"
download_and_unzip \
    http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.3.zip
popd


## STEP 3: Decontamination

# decontam
pip install --upgrade \
    git+https://github.com/PennChopMicrobiomeProgram/decontam.git
pip install --upgrade pysam

# Bowtie2
pushd "$SOFTWARE_DIR"
download_and_unzip \
    http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip
popd

# Human, PhiX174 genomes
pushd "$BIODATA_DIR"
download_and_unzip \
    http://microb234.med.upenn.edu/shotgun-pipeline-files/hg18.zip
download_and_unzip \
    http://microb234.med.upenn.edu/shotgun-pipeline-files/phix.zip
popd


## STEP 4: Taxonomic assignment

# PhylogeneticProfiler
pip install --upgrade \
    git+https://github.com/PennChopMicrobiomeProgram/PhylogeneticProfiler.git

# metaphlan2
pushd "$SOFTWARE_DIR"
download_and_unzip https://bitbucket.org/biobakery/metaphlan2/get/default.zip
popd
pip install --upgrade numpy
pip install --upgrade biom-format


## STEP 5: Functional assignment

# PathwayAbundanceFinder
pip install --upgrade \
    https://github.com/PennChopMicrobiomeProgram/PathwayAbundanceFinder.git

# Rapsearch2
pushd "$SOFTWARE_DIR"
download_and_unzip \
    http://sourceforge.net/projects/rapsearch2/files/RAPSearch2.23_64bits.tar.gz
popd

# KEGG database
download_and_unzip \
    http://microb234.med.upenn.edu/shotgun-pipeline-files/kegg.zip

