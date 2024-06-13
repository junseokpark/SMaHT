#!/bin/bash

# load conda env
CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate SMaHT-3.9


WORK_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/scripts/COLO829-Analysis/L1
FIGURE_TITLE="xTea-COLO829-L1"
OUTPUT_DIR=${WORK_DIR}/${FIGURE_TITLE}

mkdir -p $OUTPUT_DIR

OVERLAP_RATIO=0.5
TARGET_FILE="xTea-COLO829T_LINE1"
#REMOVE_FILE="RetroSom-COLO829T_LINE1.bed"

cd $WORK_DIR

# Define an array of strings
#array=("1KGP_LINE1" "gnomAD_LINE1" "xTea-COLO829BL_LINE1" "xTea-COLO829T_LINE1" "RetroSom-COLO829T_LINE1" "xTea-mosaic-COLO829BL_LINE1")
array=("xTea-COLO829BL_LINE1" )

# Initialize an empty variable to store the concatenated string
concatenated=""

# Loop through each element in the array
for element in "${array[@]}"
do
    # Concatenate each element with a space
    concatenated+=" $element.bed"
done

concatenated+=" $TARGET_FILE.bed"

mkdir -p $OUTPUT_DIR

concatenated="${concatenated/$REMOVE_FILE}"
intervene_venn="intervene venn -i $concatenated --bedtools-options f=${OVERLAP_RATIO},r --filenames --title $FIGURE_TITLE --save-overlaps --output $OUTPUT_DIR"
echo $intervene_venn
eval $intervene_venn
concatenated+=" $REMOVE_FILE"


intervene_upset="intervene upset -i $concatenated --bedtools-options f=${OVERLAP_RATIO},r --filename --showshiny --output $OUTPUT_DIR"
echo $intervene_upset
eval $intervene_upset



conda activate SMaTH

TARGET_FILE=${TARGET_FILE}.bed
concatenated="${concatenated/$TARGET_FILE}"

bedtools_intersect="bedtools intersect -v -a "$TARGET_FILE" -b $concatenated "
echo $bedtools_intersect
eval $bedtools_intersect



