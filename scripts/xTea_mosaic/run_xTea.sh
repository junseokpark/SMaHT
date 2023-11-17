#!/bin/bash
# junseok.park@childrens.harvard.edu

usage="$(basename "$0") [-h] [-s -p -d -e -r -c -x -sp -st -sc -sm] -- program to trim illumina adapters and low sequencing quality tails

where
    -h show help text
    -s --sample_id sample id
    -p --sample_ext_prefix sample file extension prefix, i.e. [SAMPLE_ID].recal.sorted.bam, then .recal.sorted.bam can be prefix
    -d --sample_file_directory sample file directory
    -e --reference_file_directory reference file directory
    -r --result_directory result directory 
    -c --config_file_directory configration file directory
    -x --xtea_path bin directory of xTea
    -sp --slurm_partition slurm partition name
    -st --slurm_time slurm allocation time
    -sc --slurm_core slurm number of core
    -sm --slurm_memory slurm memory allocation

"

sample_id=""
sample_ext_prefix=""
sample_file_directory=""
# base_working_directory=""
reference_file_directory=""
result_directory=""
config_file_directory=""
xtea_path=""

# default params for slurm job
slurm_partition="medium"
slurm_time="4-12:00"
slurm_core="4"
slurm_memory="16"

while getopts ":hs:s:p:d:e:r:c:x:sp:st:sc:sm:" opt; do
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
    sp) slurm_partition="$OPTARG"
        ;;
    st) slurm_time="$OPTARG"
        ;;
    sc) slurm_core="$OPTARG"
        ;;
    sm) slurm_memory="$OPTARG"
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
        # exit 1 for test
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

function run_xTea_mosaic {
    local xTea_PATH="$1"
    local CONFIG_DIRECTORY="$2"
    local RESULT_DIRECTORY="$3"
    local REF_DIRECTORY="$4"

    local command="python ${xTea_PATH}/gnrt_pipeline_local_v38.py \
         -M -U -i \"${CONFIG_DIRECTORY}/xtea_sample_id.txt\" \
         -b \"${RESULT_DIRECTORY}/xtea_bam_list.txt\" \
         -x null \
         -p \"${RESULT_DIRECTORY}\" \
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
run_xTea_mosaic ${xtea_path} ${CONFIG_DIRECTORY} ${RESULT_DIRECTORY}/${SAMPLE_ID} ${REF_DIRECTORY}

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
mv ./sbatch_job.sh ${RESULT_DIRECTORY}/${SAMPLE_ID}
sbatch ${RESULT_DIRECTORY}/${SAMPLE_ID}/sbatch_job.sh
