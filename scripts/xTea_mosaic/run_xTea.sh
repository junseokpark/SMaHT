#!/bin/bash


BASE_DIRECTORY=/n/data1/bch/genetics/lee
REF_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/refs
#WORK_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/results/xTea_mosaic
CONFIG_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/benchmark/toolTest_pipeline/config

## omitted --fakeroot
#singularity shell \
#    -B /n/data1/bch/genetics/lee/:/n/data1/bch/genetics/lee/ \
#    -B /n/scratch3/users/j/jp394/:/n/scratch3/users/j/jp394/ \
#    -B /n/no_backup2/bch/lee/data/:/n/no_backup2/bch/lee/data/ \
#    /n/app/singularity/containers/jp394/xtea-mosaic.sif


## xTEA-germline


# Change sample ID
#CURRENT="TITR_3"
#NEXT="TITR_2"

# Accept user input for CURRENT and NEXT
#read -p "Enter the current value: " CURRENT
#read -p "Enter the next value: " NEXT

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <CURRENT> <NEXT> <RESULT_DIR>"
    exit 1
fi

CURRENT="$1"
NEXT="$2"
RESULT_DIR="$3"
WORK_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/results/${RESULT_DIR}

if [ ! -d "${WORK_DIRECTORY}" ]; then
    mkdir -p ${WORK_DIRECTORY}
fi


sed -i "s/${CURRENT}/${NEXT}/g" ${CONFIG_DIRECTORY}/xtea_bam_list.txt
sed -i "s/${CURRENT}/${NEXT}/g" ${CONFIG_DIRECTORY}/xtea_sample_id.txt

cat ${CONFIG_DIRECTORY}/xtea_bam_list.txt
cat ${CONFIG_DIRECTORY}/xtea_sample_id.txt

if [ -d "${WORK_DIRECTORY}/${NEXT}" ]; then
    # Remove the directory and its contents
    rm -r ${WORK_DIRECTORY}/${NEXT}
    echo "Directory '${WORK_DIRECTORY}/${NEXT}' has been removed."
fi


## xTEA-mosaic
python /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea/gnrt_pipeline_local_v38.py \
         -M -U -i ${CONFIG_DIRECTORY}/xtea_sample_id.txt \
         -b ${CONFIG_DIRECTORY}/xtea_bam_list.txt \
         -x null \
         -p ${WORK_DIRECTORY}/ \
         -o submit_jobs.sh \
         -l ${REF_DIRECTORY}/rep_lib_annotation/ \
         -r ${REF_DIRECTORY}/hg38/Homo_sapiens_assembly38.fasta \
         -g ${REF_DIRECTORY}/pangenomics/chm13.draft_v2.0.gene_annotation.gff3 \
         --xtea ${BASE_DIRECTORY}/tools/xTea-mosaic/xtea/ \
         -f 5907 \
         -y 3 \
         --slurm -t 4-12:00 -q medium -n 8 -m 96 \
         --nclip 2 --cr 0 --nd 1 --nfclip 1 --nfdisc 1 \
         --blacklist ${REF_DIRECTORY}/gnomAD/2.1/gnomad_v2.1_sv.sites.bed

mv ./submit_jobs.sh ${WORK_DIRECTORY}/$NEXT

rm -rf sbatch_job.sh
cp sbatch_job.sh.template sbatch_job.sh

sed -i "s/\[SAMPLE_ID\]/${NEXT}/g" sbatch_job.sh
sed -i "s/\[RESULT_DIR\]/${RESULT_DIR}/g" sbatch_job.sh

sbatch /n/data1/bch/genetics/lee/projects/SMaHT/scripts/xTea_mosaic/sbatch_job.sh
