#!/bin/bash

DIR_TYPES=("200x" "Simul50x" "Simul100x")
SAMPLE_TYPES=("CONT" "TITR")
TE_TYPES=("ALU" "LINE1")


BASE_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/results/MELT/shortread/germline/mixedDataRetroSom

for DIR_TYPE in "${DIR_TYPES[@]}"; do

    echo $DIR_TYPE

    for SAMPLE_TYPE in "${SAMPLE_TYPES[@]}"; do
        echo $SAMPLE_TYPE

        for TE_TYPE in "${TE_TYPES[@]}"; do
            echo $TE_TYPE
            ./combineAllVCFResultsToBed.sh $SAMPLE_TYPE $TE_TYPE $BASE_DIR/$DIR_TYPE

        done

    done

done