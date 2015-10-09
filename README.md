Shotgun Metagenomics Analysis Pipeline
===============

The shotgun metagenomics pipeline deploys and runs individual software
components developed at the PennCHOP Microbiome program.

Prerequisites
---------------

The deployment scripts assume that python 2.7 and pip are already
installed.

Deployment
---------------

To deploy the pipeline on a fresh computer:

```bash
source deploy_virtualenv.sh
./deploy.sh
```

The first script will set up and activate a new virtual environment
named `shotgun-pipeline`.  Please see the notes inside the file
`deploy_virtualenv.sh` for help with setting up virtual environment in
future sessions.

The second script will then download and unzip the software and data
files necessary to run the pipeline.

Testing
---------------

To test the pipeline, run the command:

```bash
./test/test_qsub.sh
```

This will run the pipeline on a small dataset, and should complete in
a few minutes.

Usage
---------------

The pipeline expects a work directory to be set up with three files.
The first file, containing the forward reads in FASTQ format, must end
in `_R1.fastq`.  The second file should contain the reverse reads in
FASTQ format, and end with `_R2.fastq`.  The third file should contain
the sample names and barcode sequences, one per line, in tab-separated
format.  Rules for the barcode file are specified in the decontam
software.

The pipeline is run by a submission script, which takes two arguments:
a job ID and the work directory.  For example, to run the pipeline on
a dataset stored in the folder `/home/norf/MyData`, run the command:

```bash
/pipeline-qsub/submit.sh job1 /home/norf/MyData
```

Jobs submitted to the queue will then be prefixed by "job1-".

To run jobs without a queuing system, you may set the environment
variable `NO_QSUB` to 1.  See the file `./test/test_qsub.sh` for an
example.