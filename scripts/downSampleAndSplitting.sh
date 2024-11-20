#!/bin/bash

#SBATCH -c 8
#SBATCH -t 3-23:00:00
#SBATCH --mem=64GB
#SBATCH -p medium
#SBATCH -J case-400x
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

numThreads=8
fractionOfReads=0.17 #300X: 0.75 # 200X: 0.5 100X: 0.25 # 50x: 0.13
seed=12345

numberOfSplit=8

OUTPUT_FILE_NAME="HapMapMix"
DEPTH="400x"


# author: Junseok Park (junseok.park@childrens.harvard.edu)
sample_file="/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_HapMap/illuminaNovaseq_bulkWgs_400x/${DEPTH}/${OUTPUT_FILE_NAME}.bam"
result_dir="/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_HapMap/illuminaNovaseq_bulkWgs_400x/${DEPTH}"

# load conda env
CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

#OUTPUT_FILE_NAME="HapMapMix"

conda activate SMaTH

# Check if the file is a regular file (not a directory)
if [ -f "$sample_file" ]; then
    # Extract the filename from the path using parameter expansion
    bam_filename="${sample_file##*/}"
    echo "Processing $bam_filename..."

    cd $result_dir;

    samtools view -b --threads $numThreads --subsample $fractionOfReads --subsample-seed $seed $sample_file > ${result_dir}/${OUTPUT_FILE_NAME}.bam
    samtools index --threads $numThreads ${result_dir}/${OUTPUT_FILE_NAME}.bam

    INPUT_BAM=${result_dir}/${OUTPUT_FILE_NAME}.bam

    mkdir -p $result_dir/${OUTPUT_FILE_NAME}-split

    conda activate gatk4
    gatk SplitSamByNumberOfReads --INPUT $INPUT_BAM --SPLIT_TO_N_FILES $numberOfSplit --OUTPUT $result_dir/${OUTPUT_FILE_NAME}-split --CREATE_INDEX True

    bash /n/data1/bch/genetics/lee/projects/SMaHT/scripts/changeFileNames.sh HapMapMix ${DEPTH}

fi
