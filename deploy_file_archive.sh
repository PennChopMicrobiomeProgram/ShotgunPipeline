#!/bin/bash
# Create software file archive needed for shotgun pipeline deployment.
#
# At this point, does not download data files for deployment.  These
# are expected to be available from the same directory as the software
# files.
#
# Data files expected by deployment script are:
#  - hg18.zip (Human genome in FASTA format)
#  - phix.zip (Phi X 174 genome in FASTA format)
#  - kegg.zip (KEGG protein database in FASTA format)
set -x
set -e

wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.33.zip
wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.3.zip
wget http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip

# Rename the metaphlan2 file to something better than default.zip
wget https://bitbucket.org/biobakery/metaphlan2/get/default.zip
mv default.zip metaphlan2.zip

# Need to compile an re-zip the RAPSearch file.  The compilation
# method below works only for Linux.  For OSX, we need to replace the
# BOOST library files in the Src directory with ones compiled for OSX.
wget http://sourceforge.net/projects/rapsearch2/files/RAPSearch2.23_64bits.tar.gz
tar xvzf RAPSearch2.23_64bits.tar.gz
pushd RAPSearch2.23_64bits
./install
popd
zip -r RAPSearch2.23_64bits.zip RAPSearch2.23_64bits
rm RAPSearch2.23_64bits.tar.gz
rm -R RAPSearch2.23_64bits
