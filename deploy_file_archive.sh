#!/bin/bash
# Create software file archive needed for shotgun pipeline deployment.
#
# For software downloaded as source, this script creates an executable
# and re-zips the results.
#
# This script does not download data files for deployment.  The
# deployment script expects the data files to be available from the
# same directory as the software files.
#
# Data files expected by the deployment script:
#  - hg38.zip (Human genome in FASTA format)
#  - phix.zip (Phi X 174 genome in FASTA format)
#  - kegg.zip (KEGG protein database in FASTA format)
set -x
set -e


wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.33.zip
wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.3.zip
wget http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip


# MetaPhlan2
wget https://bitbucket.org/biobakery/metaphlan2/get/61ad257cc091.zip
mv 61ad257cc091.zip metaphlan2_61ad257cc091.zip


# RAPSearch2
# Note for building on OSX: the BOOST library files in the Src
# directory need to be replaced with ones compiled for OSX.  I found
# that downloading the BOOST library source code and manually building
# the library files worked best.
wget http://sourceforge.net/projects/rapsearch2/files/RAPSearch2.23_64bits.tar.gz
tar xvzf RAPSearch2.23_64bits.tar.gz
pushd RAPSearch2.23_64bits
./install
popd
zip -r RAPSearch2.23_64bits.zip RAPSearch2.23_64bits
rm RAPSearch2.23_64bits.tar.gz
rm -R RAPSearch2.23_64bits


# seqtk
wget https://github.com/lh3/seqtk/archive/4feb6e8144.zip
unzip 4feb6e8144.zip
pushd seqtk-4feb6e81444ab6bc44139dd3a125068f81ae4ad8
make
popd
zip -r seqtk_4feb6e8144.zip seqtk-4feb6e81444ab6bc44139dd3a125068f81ae4ad8
rm 4feb6e8144.zip
rm -R seqtk-4feb6e81444ab6bc44139dd3a125068f81ae4ad8


# Bwa
wget http://sourceforge.net/projects/bio-bwa/files/bwa-0.7.12.tar.bz2
tar xvjf bwa-0.7.12.tar.bz2
pushd bwa-0.7.12
make
popd
zip -r bwa-0.7.12.zip bwa-0.7.12
rm bwa-0.7.12.tar.bz2
rm -R bwa-0.7.12
