#!/bin/bash
# junseok.park@childrens.harvard.edu

usage="$(basename "$0") [-h] [-s -p -d -e -r -c -x -f -i -a -t -o -m] -- program to trim illumina adapters and low sequencing quality tails

where
    -h show help text
    -s --sample_id sample id
    -p --sample_ext_prefix sample file extension prefix, i.e. [SAMPLE_ID].recal.sorted.bam, then .recal.sorted.bam can be prefix
    -d --sample_file_directory sample file directory
    -e --reference_file_directory reference file directory
    -r --result_directory result directory 
    -c --config_file_directory configration file directory
    -x --xtea_path bin directory of xTea
    -f --xtea_script_file xTea script name to be run
    -i --platform sequence generation platform (i.e. illumina)
    -a --slurm_partition slurm partition name
    -t --slurm_time slurm allocation time
    -o --slurm_core slurm number of core
    -m --slurm_memory slurm memory allocation

"

sample_id=""
sample_ext_prefix=""
sample_file_directory=""
# base_working_directory=""
reference_file_directory=""
result_directory=""
config_file_directory=""
xtea_path=""

platform="illumina"
# default params for slurm job
slurm_partition="medium"
slurm_time="4-12:00"
slurm_core="8"
slurm_memory="64"

while getopts ":h:s:p:d:e:r:c:x:f:i:a:t:o:m:" opt; do
  case $opt in
    h) echo "$usage"
        exit 0
        ;;
    s) sample_id="$OPTARG"
        ;;
    p) sample_ext_prefix="$OPTARG"
        ;;
    d) sample_file_directory="$OPTARG"
        ;;
    b) base_working_directory="$OPTARG"
        ;;
    e) reference_file_directory="$OPTARG"
        ;;
    r) result_directory="$OPTARG"
        ;;
    c) config_file_directory="$OPTARG"
        ;;
    x) xtea_path="$OPTARG"
        ;;
    f) xtea_script_file="$OPTARG"
        ;;
    i) platform="$OPTARG"
        ;;
    a) slurm_partition="$OPTARG"
        ;;
    t) slurm_time="$OPTARG"
        ;;
    o) slurm_core="$OPTARG"
        ;;
    m) slurm_memory="$OPTARG"
        ;;
    \?) echo "Invalid option: -$OPTARG"
        exit 1
        ;;
    :)  echo "Option -$OPTARG requires an argument."
        exit 1
        ;;
  esac
done

variable_names=(
    "sample_id"
    "sample_ext_prefix"
)

directories=(
    "sample_file_directory"
    "reference_file_directory"
    "result_directory"
    "config_file_directory"
    "xtea_path"
)

option_names=("${variable_names[@]}" "${directories[@]}")

# Check for empty options
for option_name in "${option_names[@]}"; do
    if [[ -z "${!option_name}" ]]; then
        echo "Option $option_name is empty."
        $0 -h
        exit 1
    fi
done

function check_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist."
        exit 1 
    fi
}

# check directories
for directory in "${directories[@]}"; do
    check_directory ${!directory}
done


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

function run_xTea {
    local xTea_PATH="$1"
    local xTea_scriptName="$2"
    local CONFIG_DIRECTORY="$3"
    local RESULT_DIRECTORY="$4"
    local REF_DIRECTORY="$5"
    local input_sequence_platform="$6"

    WORKING_DIRECTORY=$(dirname ${RESULT_DIRECTORY})

    local command="python ${xTea_PATH}/${xTea_scriptName} \
          -i \"${CONFIG_DIRECTORY}/xtea_sample_id.txt\" \
          -b \"${CONFIG_DIRECTORY}/xtea_bam_list.txt\" \
          -x null -p \"${WORKING_DIRECTORY}\" \
          -o submit_jobs.sh \
          -l \"${REF_DIRECTORY}/rep_lib_annotation/\" \
          -r \"${REF_DIRECTORY}/hg38/Homo_sapiens_assembly38.fasta\" \
          -g \"${REF_DIRECTORY}/pangenomics/chm13.draft_v2.0.gene_annotation.gff3\" \
          --xtea \"${xTea_PATH}\" "
    
    if [ "$xTea_scriptName" == "xtea" ]; then
        # illumina germline only
        command="$command \
            -f 5907 -y 7 \
            --slurm -t ${slurm_time} -q ${slurm_partition} -n ${slurm_core} -m ${slurm_memory}
            "
    elif [ "$xTea_scriptName" == "xtea_long" ]; then
        command="python ${xTea_PATH}/${xTea_scriptName} \
          -i \"${CONFIG_DIRECTORY}/xtea_sample_id.txt\" \
          -b \"${CONFIG_DIRECTORY}/xtea_bam_list.txt\" \
          -p \"${WORKING_DIRECTORY}\" \
          -o submit_jobs.sh \
          --xtea \"${xTea_PATH}\" \
          -r \"${REF_DIRECTORY}/hg38/Homo_sapiens_assembly38.fasta\" \
          --rmsk \"${REF_DIRECTORY}/rep_lib_annotation/LINE/hg38/hg38_L1_larger_500_with_all_L1HS.out\" \
          --cns \"${REF_DIRECTORY}/rep_lib_annotation/consensus/LINE1.fa\" \
          --rep  \"${REF_DIRECTORY}/rep_lib_annotation/\" \
          -f 31 -y 15 -n ${slurm_core} -m ${slurm_memory} \
          --slurm -q ${slurm_partition} -t ${slurm_time}
          "         
    
    else
        command="$command \
            -f 5907 \
            -y 3 \
            --slurm -t ${slurm_time} -q ${slurm_partition} -n ${slurm_core} -m ${slurm_memory} \
            --nclip 2 --cr 0 --nd 1 --nfclip 1 --nfdisc 1 \
            --blacklist \"${REF_DIRECTORY}/gnomAD/2.1/gnomad_v2.1_sv.sites.bed\"
            "
    fi

    echo "Running xTEA(${xTea_scriptName}) with the following command:"
    echo "$command"

    eval "$command"

}


function run_xTea_mosaic {
    local xTea_PATH="$1"
    local CONFIG_DIRECTORY="$2"
    local RESULT_DIRECTORY="$3"
    local REF_DIRECTORY="$4"
    WORKING_DIRECTORY=$(dirname ${RESULT_DIRECTORY})

    local command="python ${xTea_PATH}/gnrt_pipeline_local_v38.py \
         -M -U -i \"${CONFIG_DIRECTORY}/xtea_sample_id.txt\" \
         -b \"${CONFIG_DIRECTORY}/xtea_bam_list.txt\" \
         -x null \
         -p \"${WORKING_DIRECTORY}\" \
         -o submit_jobs.sh \
         -l \"${REF_DIRECTORY}/rep_lib_annotation/\" \
         -r \"${REF_DIRECTORY}/hg38/Homo_sapiens_assembly38.fasta\" \
         -g \"${REF_DIRECTORY}/pangenomics/chm13.draft_v2.0.gene_annotation.gff3\" \
         --xtea \"${xTea_PATH}\" \
         -f 5907 \
         -y 3 \
         --slurm -t ${slurm_time} -q ${slurm_partition} -n ${slurm_core} -m ${slurm_memory} \
         --nclip 2 --cr 0 --nd 1 --nfclip 1 --nfdisc 1 \
         --blacklist \"${REF_DIRECTORY}/gnomAD/2.1/gnomad_v2.1_sv.sites.bed\""

    echo "Running xTEA-mosaic with the following command:"
    echo "$command"

    eval "$command"
}

# illumina data 
function run_xTea_germlin_illumina {
    local xTea_PATH="$1"
    local xTea_scriptName="$2"
    local CONFIG_DIRECTORY="$3"
    local RESULT_DIRECTORY="$4"
    local REF_DIRECTORY="$5"
    WORKING_DIRECTORY=$(dirname ${RESULT_DIRECTORY})


    local command="python ${xTea_PATH}/xtea \
          -i \"${CONFIG_DIRECTORY}/xtea_sample_id.txt\" \
          -b \"${CONFIG_DIRECTORY}/xtea_bam_list.txt\" \
          -x null -p \"${WORKING_DIRECTORY}\" \
          -o submit_jobs.sh \
          -l \"${REF_DIRECTORY}/rep_lib_annotation/\" \
          -r \"${REF_DIRECTORY}/hg38/Homo_sapiens_assembly38.fasta\" \
          -g \"${REF_DIRECTORY}/pangenomics/chm13.draft_v2.0.gene_annotation.gff3\" \
          --xtea \"${xTea_PATH}\" \
          -f 5907 -y 7 \
          --slurm -t ${slurm_time} -q ${slurm_partition} -n ${slurm_core} -m ${slurm_memory}"

    echo "Running xTEA-germline illumina with the following command:"
    echo "$command"

    eval "$command"

}


REF_DIRECTORY="$reference_file_directory" #${BASE_DIRECTORY}/projects/SMaHT/refs
CONFIG_DIRECTORY="$config_file_directory" #${BASE_DIRECTORY}/projects/SMaHT/benchmark/toolTest_pipeline/config
RESULT_DIRECTORY="$result_directory"

# Create result directory if it is not existing
if [ ! -d "${RESULT_DIRECTORY}" ]; then
    mkdir -p ${RESULT_DIRECTORY}
fi

SAMPLE_ID=${sample_id}
SAMPLE_FILE=${sample_file_directory}/${sample_id}${sample_ext_prefix}

# Create sample directory if it is not exists
if [ -d "${RESULT_DIRECTORY}/${SAMPLE_ID}" ]; then
    # Remove the directory and its contents
    rm -r ${RESULT_DIRECTORY}/${SAMPLE_ID}
    echo "Directory '${RESULT_DIRECTORY}/${SAMPLE_ID}' has been removed."
fi


echo $SAMPLE_FILE

# Change the configuration file for xTea
sample_id_and_file=("[SAMPLE_ID]=${SAMPLE_ID}" "[SAMPLE_PATH]=${SAMPLE_FILE}")

# Prepare to run 
changeStringFromTemplates sample_id_and_file[@] ${CONFIG_DIRECTORY}/xtea_bam_list.txt
changeStringFromTemplates sample_id_and_file[0] ${CONFIG_DIRECTORY}/xtea_sample_id.txt


# run xTea
#run_xTea_mosaic ${xtea_path} ${CONFIG_DIRECTORY} ${RESULT_DIRECTORY}/${SAMPLE_ID} ${REF_DIRECTORY}
run_xTea ${xtea_path} ${xtea_script_file} ${CONFIG_DIRECTORY} ${RESULT_DIRECTORY}/${SAMPLE_ID} ${REF_DIRECTORY}

# Check if the file exists
if [ ! -f "./submit_jobs.sh" ]; then
    echo "Error: submit_jobs.sh file not found."
    echo "failed to execute xTea"
    exit 1
fi


# move generated script to destination directory
mv ./submit_jobs.sh ${RESULT_DIRECTORY}/${SAMPLE_ID}

CURRENT_PWD=$(realpath .)
rm -rf ${CURRENT_PWD}/sbatch_job.sh
cp ${CURRENT_PWD}/sbatch_job.sh.template ${CURRENT_PWD}sbatch_job.sh

slurm_configs=(
    "[SLURM_CORE]=${slurm_core}" 
    "[SLURM_TIME]=${slurm_time}" 
    "[SLURM_MEMORY]=${slurm_memory}G" 
    "[SLURM_PARTITION]=${slurm_partition}"
    "[SAMPLE_ID]=${SAMPLE_ID}"
    "[RESULT_DIR]=${RESULT_DIRECTORY}" 
 
)

changeStringFromTemplates slurm_configs[@] ${CURRENT_PWD}/sbatch_job.sh

# add SVA running script to sbatch_job.sh for xTea germline
if [ "$xtea_script_file" == "xtea" ]; then
    
    start_pattern="batch_scripts\[L1\]"
    end_pattern="for"

    new_line="batch_scripts\[SVA\]=\"${SAMPLE_ID}/SVA/run_xTEA_pipeline.sh\""

    sed -i "/$start_pattern/,/$end_pattern/ { /$end_pattern/ {i\\$new_line
    }}" ${CURRENT_PWD}/sbatch_job.sh

# xTea long read is only for LINE1
elif [ "$xtea_script_file" == "xtea_long" ]; then
    sed -i "/^batch_scripts\[alu\]/d" ${CURRENT_PWD}/sbatch_job.sh

fi

mv ./sbatch_job.sh ${RESULT_DIRECTORY}/${SAMPLE_ID}
sbatch ${RESULT_DIRECTORY}/${SAMPLE_ID}/sbatch_job.sh
