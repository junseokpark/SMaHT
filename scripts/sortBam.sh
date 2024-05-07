#!/bin/bash
#SBATCH -c 20
#SBATCH -t 2-12:00
#SBATCH --mem=90G
#SBATCH -p medium
#SBATCH -o COLO829T_Ill_%j.out
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseokpark.kr@gmail.com

# load conda env
CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate SMaTH

samtools sort -@ 20 -m 4G /n/data1/hms/dbmi/park-smaht_dac/analysis/GCC_UW/COLO829T/illuminaNovaseq_bulkWgs/seq_data/COLO829T_Ill.bam -o COLO829T_Ill.sorted.bam

# samtools sort -@ 16 -m 4G /n/data1/hms/dbmi/park-smaht_dac/analysis/GCC_UW/COLO829T/illuminaNovaseq_bulkWgs/seq_data/COLO829T_Ill.bam -o COLO829T_Ill.sorted.bam
