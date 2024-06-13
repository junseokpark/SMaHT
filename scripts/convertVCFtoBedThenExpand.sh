#!/bin/bash

remove_file_if_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "Removing $file..."
        rm "$file"
    else
        echo "$file does not exist."
    fi
}

SAMPLE_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/results/xTea/shortread/mosaic/COLO829/COLO829BL_Ill_230X/L1
RESULT_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/scripts/COLO829-Analysis/L1

SAMPLE_FILE_NAME=COLO829BL_Ill_230X_LINE1.vcf
RESULT_FILE_NAME=xTea-mosaic-COLO829BL_LINE1

REF_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/refs
WINDOW=600

TOOL_PATH=/n/data1/bch/genetics/lee/tools/bedops.2.4.41/bin
PATH=$TOOL_PATH:$PATH

# load conda env
CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate SMaTH

# Generate bed file
remove_file_if_exists ${RESULT_DIR}/${RESULT_FILE_NAME}.raw.bed
vcf2bed < ${SAMPLE_DIR}/$SAMPLE_FILE_NAME > ${RESULT_DIR}/${RESULT_FILE_NAME}.raw.bed

# Move the Result directory
cd $RESULT_DIR

# Extension bed file including sort bed file
remove_file_if_exists ${RESULT_FILE_NAME}_E.bed
bedtools slop -i ${RESULT_FILE_NAME}.raw.bed -g ${REF_DIR}/hg38/hg38.chrom.sizes  -b ${WINDOW}  | sort -k1,1V -k1,1 -k2,2n > ${RESULT_FILE_NAME}_E.bed

# Add chr if it is not exist
if [ $(awk '{print $1}' ${RESULT_FILE_NAME}_E.bed | grep -c 'chr') != 0 ]; then
    echo "The first column contains 'chr'."
    echo "It will go to the next step"
else
    echo "The first column does not contain 'chr'. Then add 'chr' to it"
    sed -i 's/^\(.*\)/chr\1/' ${RESULT_FILE_NAME}_E.bed
fi

# create soft link based on the last result
remove_file_if_exists ${RESULT_FILE_NAME}.bed
ln -s ${RESULT_FILE_NAME}_E.bed ${RESULT_FILE_NAME}.bed