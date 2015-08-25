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

# Virtualenv, virtualenvwrapper
pip install --user --upgrade virtualenv
pip install --user --upgrade virtualenvwrapper

####################################################
## BASH CONFIG SECTION
## This section should be added to your .bashrc file

# Binary and lib paths used by pip
# On OSX, these may be different
# See http://stackoverflow.com/questions/7143077/how-can-i-install-packages-in-my-home-folder-with-pip
PIP_BIN="$HOME/.local/bin"
PIP_LIB="$HOME/.local/lib/python2.7/site-packages"

# Add the pip install directories to PATH and PYTHONPATH
export PATH="${PIP_BIN}:$PATH"
export PYTHONPATH="${PIP_LIB}:$PYTHONPATH"

# Initialize virtualenvwrapper
export WORKON_HOME="$HOME/.virtualenvs"
source "${PIP_BIN}/virtualenvwrapper.sh"

## END BASH CONFIG SECTION
####################################################


# Make a new virtual environment
# Pipeline should be executed in this virtual environment
mkvirtualenv shotgun-pipeline


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
wget \
    http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.33.zip
unzip Trimmomatic-0.33.zip
rm Trimmomatic-0.33.zip
popd

# FastQC
pushd "$SOFTWARE_DIR"
wget \
    http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.3.zip
unzip fastqc_v0.11.3.zip
rm fastqc_v0.11.3.zip
popd


## STEP 3: Decontamination

# decontam
pip install --upgrade \
    git+https://github.com/PennChopMicrobiomeProgram/illqc.git

# Bowtie2
pushd "$SOFTWARE_DIR"
wget \
    http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip
unzip bowtie2-2.2.6-linux-x86_64.zip
rm bowtie2-2.2.6-linux-x86_64.zip
popd

# Human genome
pushd "$BIODATA_DIR"
wget ftp://ftp.ccb.jhu.edu/pub/data/bowtie2_indexes/hg18.1.zip
wget ftp://ftp.ccb.jhu.edu/pub/data/bowtie2_indexes/hg18.2.zip
wget ftp://ftp.ccb.jhu.edu/pub/data/bowtie2_indexes/hg18.3.zip
popd
