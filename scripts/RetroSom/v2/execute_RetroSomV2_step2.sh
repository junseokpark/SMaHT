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

RESULT_PATH=/n/data1/bch/genetics/lee/projects/SMaHT/results/RetroSom/shortread/mosaic/mixedDataRetroSom/Simul50x/v2
BAMFILE_PATH=/n/no_backup2/bch/lee/data/mixedDataRetroSom/D_Simul50x
RETROPATH=/n/data1/bch/genetics/lee/jun/RetroSomV2
SINGULARITY_IMAGE=/n/app/singularity/containers/jp394/RetroSomV2.5.sif


SAMPLE_ID="TITR"
CONT_ID="CONT"

: '
-o  output folder path
-i  subject ID
-m  masterpath
-r  version control for RetroSom (default 1)
-g  reference genome (default hg38, supporting hg38, hg19 and b37)
-t  type of input (1=raw_sequencing_reads;2=BAM_to_be_realigned; 3=BAM_to_be_cleaned; 4=cleaned_BAM) 
-n  maximum number of supporting reads to be considered as a putative soamtic insertion (default 100)
-p  p_value cutoff (default p<0.1)
-e  control/normal tissue
-c  input BAM file (input==2 or 3)
-l  number of sequencing datasets
-s  singularity image file path including image file name
'

if [ -d "${RESULT_PATH}/${SAMPLE_ID}_NoModel" ]; then
        rm -r ${RESULT_PATH}/${SAMPLE_ID}_NoModel
        echo "Directory ${RESULT_PATH}/${SAMPLE_ID}_NoModel has been removed."
fi


command="${RETROPATH}/Singularity_Slurm_RetroSom.step2.sh
        -o $RESULT_PATH \
        -i $SAMPLE_ID \
        -e $CONT_ID \
        -m $RETROPATH \
        -r 1 \
        -g hg38 \
        -t 0 \
        -n 150 \
        -p 0.1 \
        -e CONT \
        -l 1 \
        -c $BAMFILE_PATH \
        -s $SINGULARITY_IMAGE 
        "

echo $command

eval $command