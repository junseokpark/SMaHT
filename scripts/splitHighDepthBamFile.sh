#!/bin/bash

#SBATCH -c 8
#SBATCH -t 3-23:00:00
#SBATCH --mem=64GB
#SBATCH -p medium
#SBATCH -J splitfiles
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

CONDA_HOME=$HOME/miniforge3
INPUT_BAM="COLO829T_Ill.bam"
BAM_DIR="/n/data1/hms/dbmi/park-smaht_dac/analysis/GCC_UW/COLO829T/illuminaNovaseq_bulkWgs/seq_data"
OUTPUT_DIR="/n/storage_test/jp394/splited_bam_t"

. $CONDA_HOME/etc/profile.d/conda.sh

conda activate gatk4

cd $BAM_DIR; gatk SplitSamByNumberOfReads --INPUT $INPUT_BAM --SPLIT_TO_N_FILES 6 --OUTPUT $OUTPUT_DIR --CREATE_INDEX True
