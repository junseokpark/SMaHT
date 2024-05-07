#!/bin/bash
#$ -cwd
#SBATCH -c 2                               # Request one core
#SBATCH -t 50:00:00                         # Runtime in D-HH:MM format
#SBATCH -p medium
#SBATCH -J merge-100x
#SBATCH -A lee_el114                       # Partition to run in
#SBATCH --mem=10G                          # Memory total in MiB (for all cores)
#SBATCH -o hostname_%j.out                 # File to which STDOUT will be written, including job ID (%j)
#SBATCH -e hostname_%j.err                 # File to which STDERR will be written, including job ID (%j) # You can change the filenames given with -o and -e to any filenames you'd like

# module load gcc/9.2.0
# module load samtools/1.18

VENV="SMaTH"
CONDA_HOME=$HOME/miniforge3

. $CONDA_HOME/etc/profile.d/conda.sh
. $CONDA_HOME/etc/profile.d/mamba.sh

conda activate ${VENV}


DIR=/n/no_backup2/bch/lee/data/mixedDataRetroSom/C_Simul400x

FILE_NAME_ARRAY=("TITR")

# Iterate over the array elements
for FILE_NAME in "${FILE_NAME_ARRAY[@]}"
do
    BAM1=$DIR/${FILE_NAME}_9.recal.sorted.bam
    BAM2=$DIR/${FILE_NAME}_10.recal.sorted.bam
    BAM3=$DIR/${FILE_NAME}_11.recal.sorted.bam
    BAM4=$DIR/${FILE_NAME}_12.recal.sorted.bam
    BAM5=$DIR/${FILE_NAME}_13.recal.sorted.bam
    BAM6=$DIR/${FILE_NAME}_14.recal.sorted.bam

    # for i in {0..0};
    # do
    #     samtools index $BAM$i
    # done

    samtools merge \
    $BAM1 \
    $BAM2 \
    $BAM3 \
    $BAM4 \
    $BAM5 \
    $BAM6 \
    -o $DIR/${FILE_NAME}-1.recal.sorted.bam 

    samtools index $DIR/${FILE_NAME}-1.recal.sorted.bam

done