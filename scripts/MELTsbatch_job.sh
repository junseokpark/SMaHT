#!/bin/bash

#SBATCH -c [SLURM_CORE]
#SBATCH -t [SLURM_TIME]
#SBATCH --mem=[SLURM_MEMORY]
#SBATCH -p [SLURM_PARTITION]
#SBATCH -J MELT-[SAMPLE_ID]
#SBATCH -o [RESULT_DIR]/[SAMPLE_ID]/[SAMPLE_ID]_%j.out
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

module load java/jdk-1.8u112 

MELT_DIR=[MELT_DIR]
RESULT_DIR=[RESULT_DIR]/[SAMPLE_ID]
REF_DIR=[REF_DIR]
SAMPLE_DIR=[SAMPLE_DIR]
SAMPLE_FILE=[SAMPLE_ID][SAMPLE_EXT]


LANG=en_US.UTF-8
LANGUAGE=en_US
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC=ro_RO.UTF-8
LC_TIME=ro_RO.UTF-8
LC_COLLATE="en_US.UTF-8"
LC_MONETARY=ro_RO.UTF-8
LC_MESSAGES="en_US.UTF-8"
LC_PAPER=ro_RO.UTF-8
LC_NAME=ro_RO.UTF-8
LC_ADDRESS=ro_RO.UTF-8
LC_TELEPHONE=ro_RO.UTF-8
LC_MEASUREMENT=ro_RO.UTF-8
LC_IDENTIFICATION=ro_RO.UTF-8
LC_ALL=

VENV="SMaTH"
CONDA_HOME=$HOME/miniforge3

. $CONDA_HOME/etc/profile.d/conda.sh
. $CONDA_HOME/etc/profile.d/mamba.sh
conda activate ${VENV}

INPUT_BAM_FILE=${SAMPLE_DIR}/${SAMPLE_FILE}

if samtools view -H $INPUT_BAM_FILE | grep -q "SO:coordinate"; then
    echo "BAM file is already sorted."
else
    # If not sorted, run samtools sort

    echo "Sorting BAM file..."
    samtools sort -@ [SLURM_CORE] -o "${SAMPLE_DIR}/[SAMPLE_ID].sorted[SAMPLE_EXT]" "$INPUT_BAM_FILE"
    echo "BAM file sorted successfully."
    INPUT_BAM_FILE=${SAMPLE_DIR}/[SAMPLE_ID].sorted[SAMPLE_EXT]

    # Generate index for the sorted BAM file
    echo "Indexing sorted BAM file..."
    samtools index -@ [SLURM_CORE] "$INPUT_BAM_FILE"
    echo "Indexing complete."
fi

java -jar ${MELT_DIR}/MELT.jar Single \
    -a \
    -c [SLURM_CORE] \
    -h $REF_DIR/Homo_sapiens_assembly38.fasta \
    -bamfile $INPUT_BAM_FILE \
    -n $MELT_DIR/add_bed_files/Hg38/Hg38.genes.bed \
    -t mei_list.txt \
    -w $RESULT_DIR
