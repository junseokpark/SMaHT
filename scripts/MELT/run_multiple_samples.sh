#!/bin/bash

MELT_DIR=/n/data1/bch/genetics/lee/tools/MELTv2.2.2
RESULT_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/results/MELT/shortread/germline/GoldStandards
REF_DIR=/n/data1/bch/genetics/lee/reference/hg38
#SAMPLE_DIR=/n/no_backup2/bch/lee/data/mixedDataRetroSom/B_Simul100x
SAMPLE_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/data/GoldStandards

#SAMPLE_DIR=/n/data1/bch/genetics/lee/data/GIAB/HG002_NA24385_son/NIST_HiSeq_HG002_Homogeneity-10953946/NHGRI_Illumina300X_AJtrio_novoalign_bams
SAMPLE_EXT_PREFIX=".final.bam"

# Read array data from file
mapfile -t SAMPLES < sampleIds.txt

# Print the array elements
for sample in "${SAMPLES[@]}"; do
  echo "$sample is loaded"
done

slurm_partition="medium"
slurm_time="4-12:00"
slurm_core="8"
slurm_memory="32"

function check_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist."
        exit 1 
    fi
}

function changeStringFromTemplates {
    local kv_pairs=("${!1}")  # Using !1 to reference the first array
    local file_path="$2"

    # Process each key-value pair
    rm -rf ${file_path}
    cp ${file_path}.template ${file_path}

    for pair in "${kv_pairs[@]}"; do
        IFS='=' read -r key value <<< "$pair"
        key=$(echo "$key" | sed 's/\[/\\[/g; s/\]/\\]/g')

        sed -i "s#$key#$value#g" ${file_path}

    done

}

# Loop through the array and process each value
for SAMPLE_ID in "${SAMPLES[@]}"; do
    slurm_configs=(
    "[SLURM_CORE]=${slurm_core}" 
    "[SLURM_TIME]=${slurm_time}" 
    "[SLURM_MEMORY]=${slurm_memory}G" 
    "[SLURM_PARTITION]=${slurm_partition}"
    "[SAMPLE_ID]=${SAMPLE_ID}"
    "[RESULT_DIR]=${RESULT_DIR}" 
    "[MELT_DIR]=${MELT_DIR}"
    "[REF_DIR]=${REF_DIR}"
    "[SAMPLE_DIR]=${SAMPLE_DIR}"
    "[SAMPLE_EXT]=${SAMPLE_EXT_PREFIX}"
    )

    # Create result directory if it is not existing
    if [ ! -d "${RESULT_DIR}" ]; then
        mkdir -p ${RESULT_DIR}
    fi

    # Create sample directory if it is not exists
    if [ -d "${RESULT_DIR}/${SAMPLE_ID}" ]; then
        # Remove the directory and its contents
        rm -r ${RESULT_DIR}/${SAMPLE_ID}
        echo "Directory '${RESULT_DIR}/${SAMPLE_ID}' has been removed."
    fi

    mkdir -p ${RESULT_DIR}/${SAMPLE_ID}

    echo $SAMPLE_ID

    CURRENT_PWD=$(realpath .)
    rm -rf ${CURRENT_PWD}/sbatch_job.sh
    cp ${CURRENT_PWD}/sbatch_job.sh.template ${CURRENT_PWD}sbatch_job.sh

    changeStringFromTemplates slurm_configs[@] ${CURRENT_PWD}/sbatch_job.sh

    mv ./sbatch_job.sh ${RESULT_DIR}/${SAMPLE_ID}
    sbatch ${RESULT_DIR}/${SAMPLE_ID}/sbatch_job.sh


done
