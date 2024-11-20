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

RETROPATH=/n/data1/bch/genetics/lee/tools/RetroSomV3
SINGULARITY_IMAGE=/n/app/singularity/containers/shared/lee/RetroNet.sif

TMP_PATH=/n/scratch/users/j/jp394
SLURM_SHORT_ARGS="\"-p medium --mem=50gb --time=3-23:00\""
SLURM_LONG_ARGS="\"-p medium --time=3-23:00 --ntasks=1 --cpus-per-task=10 --mem-per-cpu=25gb\""


while IFS=, read -r SAMPLE_ID CONT_ID RESULT_PATH SAMPLE_DIR SAMPLE_PREFIX; do

    # Process each column
    echo "SAMPLE_ID: $SAMPLE_ID"
    echo "CONT_ID: $CONT_ID"
    echo "RESULT_PATH: $RESULT_PATH"
    echo "SAMPLE_DIR: $SAMPLE_DIR"
    echo "SAMPLE_PREFIX: $SAMPLE_PREFIX"
 
    # Create result directory if it is not existing
    if [ ! -d "${RESULT_PATH}" ]; then
        mkdir -p ${RESULT_PATH}
    fi


    # Create sample directory if it is not exists
    if [ -d "${RESULT_PATH}/${SAMPLE_ID}" ]; then
        rm -r ${RESULT_PATH}/${SAMPLE_ID}
        echo "Directory ${RESULT_PATH}/${SAMPLE_ID} has been removed."
    fi

    BAMFILE_PATH=$SAMPLE_DIR/${SAMPLE_ID}${SAMPLE_PREFIX}

    if [ -e "$BAMFILE_PATH" ]; then
        command="${RETROPATH}/Singularity_Slurm_RetroNet_setp1.sh \
            -o $RESULT_PATH \
            -i $SAMPLE_ID \
            -m $RETROPATH \
            -r 1 \
            -g hg38 \
            -t 3 \
            -n 150 \
            -p 0.1 \
            -c $BAMFILE_PATH \
            -e $CONT_ID \
            -s $SINGULARITY_IMAGE \
            -f $TMP_PATH \
            -u $SLURM_SHORT_ARGS \
            -l $SLURM_LONG_ARGS
            "
        echo $command

        eval $command
    else
        echo "$BAMFILE_PATH is not existing"
    fi

done < "sampleIds.txt"

