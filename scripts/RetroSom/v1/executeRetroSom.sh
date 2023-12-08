#!/bin/bash

set -x

CONDA_HOME=$HOME/anaconda3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate retrosom

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
export R_LIBS_USER="~/R-${R_VERSION}"

module load bedtools/2.27.1 picard/2.27.5 samtools/1.15.1

RetroPath=/n/data1/bch/genetics/lee/jun/RetroSom

#-g /n/data1/bch/genetics/lee/reference/hg38

SAMPLE_ID="HG00514"

RESULT_PATH=/n/data1/bch/genetics/lee/jun/RetroSom/results

if [[ ! -f $RESULT_PATH/list.txt ]]
then 
    touch $RESULT_PATH/list.txt
fi

isInFile=$(cat $RESULT_PATH/list.txt | grep -c "$SAMPLE_ID")

if [ $isInFile -eq 0 ]; then
   #string not contained in file
   echo $SAMPLE_ID >> $RESULT_PATH/list.txt
fi

./RetroSomV1.sh -o $RESULT_PATH \
-i "HG00514" \
-m $RetroPath \
-g hg38 \
-t 2 \
-c $RetroPath/samples/HG00514.alt_bwamem_GRCh38DH.20150715.CHS.high_coverage.chr21.bam \
-r 1


# g /n/data1/bch/genetics/lee/reference/hg38
