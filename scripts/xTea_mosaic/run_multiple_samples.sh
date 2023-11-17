#!/bin/bash

BASE_DIRECTORY=/n/data1/bch/genetics/lee
CONFIG_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/benchmark/toolTest_pipeline/config

# Define an array of values
SAMPLES=("CONT_14" "CONT_15") # "CONT_10" "CONT_11" "CONT_12" "CONT_13" "CONT_14")
# "CONT_3" "CONT_4" "CONT_5" "CONT_6")
# END_SAMPLE_NO=15

#sed -i "s/CONT_[0-9]\+/CONT_14/g" ${CONFIG_DIRECTORY}/xtea_bam_list.txt
#sed -i "s/CONT_[0-9]\+/CONT_14/g" ${CONFIG_DIRECTORY}/xtea_sample_id.txt

# Loop through the array and process each value
for CURRENT in "${SAMPLES[@]}"; do
    NUM_CURRENT="${CURRENT#CONT_}"
    NEXT=$((NUM_CURRENT + 1))
    NEXT_NO=${NEXT}
    NEXT="CONT_$NEXT"

    echo "Processing $NEXT..."
    /n/data1/bch/genetics/lee/projects/SMaHT/scripts/xTea_mosaic/run_xTea.sh $CURRENT $NEXT "xTea_mosaic_Simul50x"

    echo "Processing $NEXT done."

    if [ ${NEXT_NO} -eq ${END_SAMPLE_NO} ]; then
        echo "NUM_CURRENT is ${END_SAMPLE_NO}. Stopping the script."
        break
    fi
done
