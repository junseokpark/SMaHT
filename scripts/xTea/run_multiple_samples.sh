#!/bin/bash

BASE_DIRECTORY="/n/data1/bch/genetics/lee/projects/SMaHT"
REF_DIRECTORY=${BASE_DIRECTORY}/refs
#RESULT_DIRECTORY=${BASE_DIRECTORY}/results/xTea/shortread/germline/HapMap/500x_WashU
#RESULT_DIRECTORY=${BASE_DIRECTORY}/results/xTea/shortread/mosaic/HapMap/500x_WashU
RESULT_DIRECTORY=${BASE_DIRECTORY}/results/xTea/shortread/mosaic/mixedDataRetroSom/Simul400x
#RESULT_DIRECTORY=${BASE_DIRECTORY}/results/xTea/shortread/germline/mixedDataRetroSom/200x

#RESULT_DIRECTORY=${BASE_DIRECTORY}/results/xTea/shortread/germline/GIAB
#RESULT_DIRECTORY=${BASE_DIRECTORY}/results/xTea/shortread/mosaic/COLO829

CONFIG_DIRECTORY=${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config
#SAMPLE_DIRECTORY="/n/no_backup2/bch/lee/data/mixedDataRetroSom/A_200x"
SAMPLE_DIRECTORY="/n/no_backup2/bch/lee/data/mixedDataRetroSom/C_Simul400x"
#SAMPLE_DIRECTORY="/n/data1/bch/genetics/lee/data/GIAB/HG004_NA24143_mother/NIST_HiSeq_HG004_Homogeneity-14572558/NHGRI_Illumina300X_AJtrio_novoalign_bams"
#SAMPLE_DIRECTORY="/n/data1/bch/genetics/lee/projects/SMaHT/data/SMATH_DAC_downSampled/COLO829T"
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

  SAMPLE_FILE=${SAMPLE_DIRECTORY}/${SAMPLE_ID}${SAMPLE_EXT_PREFIX}

  if [ -e "$SAMPLE_FILE" ]; then
    ./run_xTea.sh -s ${SAMPLE_ID} \
        -p ${SAMPLE_EXT_PREFIX} \
        -d ${SAMPLE_DIRECTORY} \
        -e ${REF_DIRECTORY} \
        -r ${RESULT_DIRECTORY} \
        -c ${CONFIG_DIRECTORY} \
        -x ${X_TEA_BIN} \
        -f ${X_TEA_RUN_SCRIPT}
  else 
    echo "$SAMPLE_FILE is not existing"
  fi
done
