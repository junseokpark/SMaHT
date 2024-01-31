#!/bin/bash

BASE_DIRECTORY="/n/data1/bch/genetics/lee/projects/SMaHT"
REF_DIRECTORY=${BASE_DIRECTORY}/refs
RESULT_DIRECTORY=${BASE_DIRECTORY}/results/xTea/shortread/mosaic/mixedDataRetroSom/Simul400x
CONFIG_DIRECTORY=${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config
SAMPLE_DIRECTORY="/n/no_backup2/bch/lee/data/mixedDataRetroSom/C_Simul400x/CONT"
SAMPLE_EXT_PREFIX=".bam"
#SAMPLES=("CONT_15" "TITR_15") 


# Read array data from file
mapfile -t SAMPLES < sample_id.list

# Print the array elements
for sample in "${SAMPLES[@]}"; do
  echo "$sample is loaded"
done

X_TEA_BIN=/n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea
X_TEA_RUN_SCRIPT=gnrt_pipeline_local_v38.py
#X_TEA_RUN_SCRIPT=xtea


# Loop through the array and process each value
for SAMPLE_ID in "${SAMPLES[@]}"; do
    ./run_xTea.sh -s ${SAMPLE_ID} \
        -p ${SAMPLE_EXT_PREFIX} \
        -d ${SAMPLE_DIRECTORY} \
        -e ${REF_DIRECTORY} \
        -r ${RESULT_DIRECTORY} \
        -c ${CONFIG_DIRECTORY} \
        -x ${X_TEA_BIN} \
        -f ${X_TEA_RUN_SCRIPT}
done
