#!/bin/bash

LANG=en_US.UTF-8
LANGUAGE=en_US
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC=ro_RO.UTF-8
LC_TIME=ro_RO.UTF-8
LC_COLLATE="en_US.UTF-8"
LC_MONETARY=ro_RO.UTF-8
LC_MESSAGES="en_US.UTF-8"
LC_PAPER=ro_RO.UTF-8
LC_NAME=ro_RO.UTF-8
LC_ADDRESS=ro_RO.UTF-8
LC_TELEPHONE=ro_RO.UTF-8
LC_MEASUREMENT=ro_RO.UTF-8
LC_IDENTIFICATION=ro_RO.UTF-8
LC_ALL=

R_VERSION=3.5.1

module load gcc/6.2.0 R/$R_VERSION

echo 'R_LIBS_USER="~/R-'${R_VERSION}'/library"' > $HOME/.Renviron
export R_LIBS_USER="~/R-"${R_VERSION}

module load bedtools/2.27.1 picard/2.27.5 samtools/1.15.1

RESULT_PATH=/n/data1/bch/genetics/lee/projects/SMaHT/results/RetroSom/shortread/mosaic/mixedDataRetroSom/200x
SAMPLE_ID="CONT_1"
RETROPATH=/n/data1/bch/genetics/lee/jun/RetroSomV2
BAMFILE_PATH=/n/no_backup2/bch/lee/data/mixedDataRetroSom/A_200x/CONT_1.recal.sorted.bam
SINGULARITY_IMAGE=/n/app/singularity/containers/jp394/RetroSomV2.5.sif
SLURM_PARTITION=medium

if [ -d "${RESULT_PATH}/${SAMPLE_ID}" ]; then
    rm -r ${RESULT_PATH}/${SAMPLE_ID}
    echo "Directory ${RESULT_PATH}/${SAMPLE_ID} has been removed."
fi

command="${RETROPATH}/Singularity_Slurm_RetroSomV2.5.sh -o $RESULT_PATH \
    -i $SAMPLE_ID \
    -m $RETROPATH \
    -r 1
    -g hg38 \
    -t 3 \
    -c $BAMFILE_PATH \
    -s $SINGULARITY_IMAGE 
    "

echo $command

eval $command
