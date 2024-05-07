#!/bin/bash


sample_file="step2_samples.txt"

slurm_partition="medium"
slurm_time="3-12:00"
slurm_core="4"
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

rm -rf ${CURRENT_PWD}/execute_RetroSomV2_step2.sh

while IFS=, read -r SAMPLE_ID CONT_ID RESULT_DIR BAM_DIR NUMBER_OF_SAMPLES; do
    slurm_configs=(
    "[SLURM_CORE]=${slurm_core}" 
    "[SLURM_TIME]=${slurm_time}" 
    "[SLURM_MEMORY]=${slurm_memory}G" 
    "[SLURM_PARTITION]=${slurm_partition}"
    "[SAMPLE_ID]=${SAMPLE_ID}"
    "[CONT_ID]=${CONT_ID}"
    "[RESULT_DIR]=${RESULT_DIR}" 
    "[BAM_DIR]=${BAM_DIR}"
    "[NUMBER_OF_BAM_FILES]=${NUMBER_OF_SAMPLES}"
    )

    CURRENT_PWD=$(realpath .)

    # Process each column
    echo "SAMPLE_ID: $SAMPLE_ID"
    echo "CONT_ID: $CONT_ID"
    echo "RESULT_DIR: $RESULT_DIR"
    echo "BAM_DIR: $BAM_DIR"
    echo "NUMBER_OF_SAMPLES: $NUMBER_OF_SAMPLES"

    changeStringFromTemplates slurm_configs[@] ${CURRENT_PWD}/execute_RetroSomV2_step2.sh

    mv ./execute_RetroSomV2_step2.sh ${RESULT_DIR}
    sbatch ${RESULT_DIR}/execute_RetroSomV2_step2.sh

done < "$sample_file"