#!/bin/bash

SAMPLE_DIRECTORY="/n/data1/bch/genetics/lee/projects/SMaHT/results/RetroSom/shortread/mosaic/mixedDataRetroSom/Simul50x/v2"

SAMPLE_NAME="TITR"
DIVIDER="_"
SAMPLE_NUMBERS=()
SAMPLE_START_NUMBER=15
SAMPLE_END_NUMBER=15

for (( i = $SAMPLE_START_NUMBER; i <= $SAMPLE_END_NUMBER; i++ )); do
    SAMPLE_NUMBERS+=("$i")
done

newNum=1
for SAMPLE_NUMBER in "${SAMPLE_NUMBERS[@]}"; do
    echo "${SAMPLE_NAME}${DIVIDER}${SAMPLE_NUMBER} to ${SAMPLE_NAME}-${newNum}"
    ./rename.sh $SAMPLE_DIRECTORY "${SAMPLE_NAME}${DIVIDER}${SAMPLE_NUMBER}" "${SAMPLE_NAME}-${newNum}"
    ((newNum++))
done