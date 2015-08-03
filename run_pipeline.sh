#!/bin/bash

# Thoughts:

# I think we should eliminate the loop over channels and call the
# pipeline separately for each lane.  This is a nice, broad way to
# break up the work.

# What will we do with runs where the samples are already split? I
# guess we control the demultiplexing process now, so this may be a
# moot point.

# I almost feel like we should split this into pre- and post-
# decontamination.  Post-decontamination, we will have much more
# flexibility to move files around and we can do all the tasks in
# parallel.  Before decontamination, we should be careful to keep data
# on CHOP or Penn servers, and we pretty much have to run the steps in
# sequence.

# We need to add a step for removing PhiX174 sequence.

# For the start of the pipeline, I think we should assume that we are
# starting with a copy of the raw gzipped FASTQ files.  This would
# eliminate the copy (from the pipeline code) and allow us to safely
# destroy the original files when unzipping.

# I like the parts where you write the time out to a log file.  This
# is great.  Another thing we can experiment with is adding "set -x"
# to the top of the code -- this will print out the commands as they
# are executed.

# Let's also assume that we can make a barcode file for each lane
# before the pipeline begins.  We plan to do this once the LIMS is in
# place for the sequencing lab.

# So, maybe for now, we should split the pipeline into:
# (1) Preparation steps which will hopefully be automated later, like
# copying raw data files and splitting the sample sheet.
# (2) Pre-decontamination pipeline, everything from dnabc to decontam.
# (3) Post-decontamination pipeline, which covers all the steps that
# produce tables of alignments/assignments.


# input folder
rawDataFolder="/media/THING1/Illumina/150624_D00727_0009_AC6JHHANXX/Data/Intensities/BaseCalls/Undetermined_indices"
sampleSheet="/media/THING1/Illumina/150624_D00727_0009_AC6JHHANXX/Data/Intensities/BaseCalls/SampleSheet.csv"

illqcConfig="/home/tanesc/code/illqc_config.json"
decontamConfig="/home/tanesc/code/decontam_config.json"
phyloConfig="/home/tanesc/code/phylo_config.json"
humannConfig="/home/tanesc/code/humann_config.json"
fastqcConfig="/home/tanesc/code/fastqc_config.json"

# output folders
baseFolder="/media/THING1/tanesc/run_150624_D00727_0009_AC6JHHANXX_2"
#baseFolder="/media/THING1/tanesc/temp"
mkdir $baseFolder


date
{ while read CHANNEL; do
    echo $CHANNEL
    channelFolder="${baseFolder}/lane${CHANNEL}"
    mkdir $channelFolder
    rawFolder="${channelFolder}/raw"
    mkdir $rawFolder
    summaryFolder="${channelFolder}/summary"    
    mkdir $summaryFolder

    dnabcFolder="${channelFolder}/dnabc_res"
    illqcFolder="${channelFolder}/illqc_res"
    fastqcBeforeFolder="${channelFolder}/fastqcBefore"
    fastqcAfterFolder="${channelFolder}/fastqcAfter"
    decontamFolder="${channelFolder}/decontam_res"
    phyloFolder="${channelFolder}/phylo_res"
    keggFolder="${channelFolder}/kegg_res"
    mkdir $keggFolder

    laneFolder="Sample_lane${CHANNEL}"
    rawFile="lane${CHANNEL}_Undetermined_L00${CHANNEL}_R1_001.fastq"
    time_fp="${channelFolder}/time.log"
    barcode_fp="${rawFolder}/lane${CHANNEL}_barcode.txt"
    split_samplelanes.py --sample-sheet $sampleSheet --lane $CHANNEL --output $barcode_fp

    echo -e "start\tlane${CHANNEL}\t$(date "+%Y/%m/%d\t%H.%M.%S")" > $time_fp

    ## move file over and unzip at raw
    cp $rawDataFolder/$laneFolder/$rawFile.gz $rawFolder
    gunzip $rawFolder/$rawFile.gz
    cp $rawDataFolder/$laneFolder/${rawFile/_R1_/_R2_}.gz $rawFolder
    gunzip $rawFolder/${rawFile/_R1_/_R2_}.gz
    
    ## demultiplexing
    dnabc.py --forward-reads $rawFolder/$rawFile --reverse-reads $rawFolder/${rawFile/_R1_/_R2_} --barcode-file $barcode_fp --summary-file $summaryFolder/summary-dnabc.json --output-dir $dnabcFolder
    echo -e "demultiplex\tlane${CHANNEL}\t$(date "+%Y/%m/%d\t%H.%M.%S")" >> $time_fp

    for filename in $dnabcFolder/*_R1.fastq; do
	
	baseFile=${filename##*/}
	sampleName=${baseFile%%.*}
	echo $sampleName

        ## illqc
	illqc.py --forward-reads $filename --reverse-reads ${filename/_R1/_R2} --output-dir $illqcFolder --summary-file "${summaryFolder}/summary-illqc_${sampleName}.json" --config-file $illqcConfig
	echo -e "illqc\t$sampleName\t$(date "+%Y/%m/%d\t%H.%M.%S")" >> $time_fp
        
        ## fastqcBefore
	fastqc_run.py --forward-reads $filename --reverse-reads ${filename/_R1/_R2} --output-dir $fastqcBeforeFolder --config-file $fastqcConfig --summary-file-fwd "${summaryFolder}/summary-fastqcBefore_${sampleName}.json" --summary-file-rev "${summaryFolder}/summary-fastqcBefore_${sampleName/_R1/_R2}.json"
	## fastqcAfter
	fastqc_run.py --forward-reads $illqcFolder/$baseFile --reverse-reads $illqcFolder/${baseFile/_R1/_R2} --output-dir $fastqcAfterFolder --config-file $fastqcConfig --summary-file-fwd "${summaryFolder}/summary-fastqcAfter_${sampleName}.json" --summary-file-rev "${summaryFolder}/summary-fastqcAfter_${sampleName/_R1/_R2}.json"
	echo -e "fastqc\t$sampleName\t$(date "+%Y/%m/%d\t%H.%M.%S")" >> $time_fp

        ## decontaminate
	decontaminate.py --forward-reads $illqcFolder/$baseFile --reverse-reads $illqcFolder/${baseFile/_R1/_R2} --output-dir $decontamFolder --summary-file "${summaryFolder}/summary-decontam_${sampleName}.json" --config-file $decontamConfig
	echo -e "decontam\t$sampleName\t$(date "+%Y/%m/%d\t%H.%M.%S")" >> $time_fp

        ## phylogenetic profiler
	#phyloprofiler.py --forward-reads $decontamFolder/$baseFile --reverse-reads $decontamFolder/${baseFile/_R1/_R2} --summary-file "${summaryFolder}/summary-phyloprofiler_${sampleName}.json" --output-dir $phyloFolder --config-file $phyloConfig
	#echo -e "metaphlan\t$sampleName\t$(date "+%Y/%m/%d\t%H.%M.%S")" >> $time_fp

	## pathway abundance finder
	#pathfinder.py --forward-reads $decontamFolder/$baseFile --reverse-reads $decontamFolder/${baseFile/_R1/_R2} --summary-file "${summaryFolder}/summary-kegg_${sampleName}.json" --output-dir $sampleName --config-file $humannConfig
	#echo -e "humann\t$sampleName\t$(date "+%Y/%m/%d\t%H.%M.%S")" >> $time_fp
    done
    ## per channel report generation 

    ## for illqc and decontam
    preprocess_report.py --illqc-dir $summaryFolder --decontam-dir $summaryFolder --output-fp "${channelFolder}/preprocess_summary.txt"
    fastqc_report.py --summary-dir $summaryFolder --output-fp "${channelFolder}/fastqc_summary.txt"

    ## for phylogenetic profiler

    ## for pathway abundanace finder

    date
done } < channels.txt
