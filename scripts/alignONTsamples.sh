#!/bin/bash

#SBATCH -c 8                               # Request one core
#SBATCH -t 25-00:00                         # Runtime in D-HH:MM format
#SBATCH -p long
#SBATCH -J ONT-align
#SBATCH -A lee_el114                       # Partition to run in
#SBATCH --mem=32G                          # Memory total in MiB (for all cores)
#SBATCH -o ONT-align_%j.out                 # File to which STDOUT will be written, including job ID (%j)
#SBATCH -e ONT-align_%j.err                 # File to which STDERR will be written, including job ID (%j) # You can change the filenames given with -o and -e to any filenames you'd like

VENV="SMaTH"
CONDA_HOME=$HOME/miniforge3

. $CONDA_HOME/etc/profile.d/conda.sh
. $CONDA_HOME/etc/profile.d/mamba.sh

conda activate ${VENV}

PATH=/n/data1/bch/genetics/lee/tools/minimap2:$PATH 
SAMPLE_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_COLO829/ontUl_r9_r10
REF_FASTA=/n/data1/bch/genetics/lee/reference/hg38/Homo_sapiens_assembly38

SAMPLES=("COLO829BL_ontUL")
#SAMPLES=("COLO829T_ontUL")

if [ ! -e "${REF_FASTA}-ONT.mmi" ]; then
    echo "ONT Index does not exist."
    echo "Generate ONT Index file"
    minimap2 -x map-ont -d ${REF_FASTA}-ONT.mmi ${REF_FASTA}.fasta
fi
    
cd $SAMPLE_DIR

for SAMPLE in "${SAMPLES[@]}"
do
    #samtools fasta -@ 8 ${SAMPLE_DIR}/${SAMPLE}.bam > ${SAMPLE_DIR}/${SAMPLE}.fasta
    minimap2 -a ${REF_FASTA}-ONT.mmi ${SAMPLE_DIR}/${SAMPLE}.fasta > ${SAMPLE_DIR}/${SAMPLE}.aligned.sam  # alignment
    rm -rf ${SAMPLE_DIR}/${SAMPLE}.fasta
    samtools view -@ 8 -bS ${SAMPLE_DIR}/${SAMPLE}.aligned.sam > ${SAMPLE_DIR}/${SAMPLE}.aligned.bam
    rm -rf ${SAMPLE_DIR}/${SAMPLE}.aligned.sam
    samtools index -@ 8 ${SAMPLE_DIR}/${SAMPLE}.aligned.bam

done
