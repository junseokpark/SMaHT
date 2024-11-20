#!/bin/bash

#SBATCH -c 8                               # Request one core
#SBATCH -t 2-00:00                         # Runtime in D-HH:MM format
#SBATCH -p medium
#SBATCH -J ONT-downsample
#SBATCH -A lee_el114                       # Partition to run in
#SBATCH --mem=32G                          # Memory total in MiB (for all cores)
#SBATCH -o ONT-downsample_%j.out                 # File to which STDOUT will be written, including job ID (%j)
#SBATCH -e ONT-downsample_%j.err                 # File to which STDERR will be written, including job ID (%j) # You can change the filenames given with -o and -e to any filenames you'd like

VENV="SMaHT-3.9"
CONDA_HOME=$HOME/miniforge3

. $CONDA_HOME/etc/profile.d/conda.sh
. $CONDA_HOME/etc/profile.d/mamba.sh

conda activate ${VENV}

PATH=/n/data1/bch/genetics/lee/tools/minimap2:$PATH 
#SAMPLE_DIR=/n/data1/hms/dbmi/park-smaht_dac/DATA/GCC_BCM/HapMap_Mixture/ontStd_r10_bulkWgs/seq_data
SAMPLE_DIR=/n/data1/hms/dbmi/park-smaht_dac/DATA/GCC_BCM/HapMap_Mixture/pacbioHifi_bulkWgs/seq_data
#OUTPUT_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_HapMap/ontStd_r10_bulkWgs
OUTPUT_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_HapMap/pacbioHifi_bulkWgs
CORES=8

DEPTH="30x"
fraction=0.26

## ONT 0.66 (90x), 0.44 (60x), 0.22 (30x)
## Pacbio 0.78 (90x), 0.52 (60x), 0.26 (30x)


PROGRAM_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/scripts


# Combine Files if 100x is not existing
cd ${OUTPUT_DIR}


FILE_NAME="HapMapMix_ONT"


calculate_bam_metrics() {
    local bam_file="$1"
    local CORE="$2"

    # Check if bam_file and CORE are provided
    if [[ -z "$bam_file" || -z "$CORE" ]]; then
        echo "Usage: calculate_bam_metrics <bam_file> <CORE>"
        return 1
    fi

    # Calculate covered depth
    samtools depth --threads "$CORE" "$bam_file" 2>&1 | tee "${bam_file}.covered.depth"
    samtools depth --threads "$CORE" "$bam_file" | awk '{sum+=$3} END { print "Average = ",sum/NR}' 2>&1 | tee "${bam_file}.covered.avg.depth"

    # Calculate all depth
    samtools depth --threads "$CORE" -a "$bam_file" 2>&1 | tee "${bam_file}.all.depth"
    samtools depth --threads "$CORE" -a "$bam_file" | awk '{sum+=$3} END { print "Average = ",sum/NR}' 2>&1 | tee "${bam_file}.all.avg.depth"

    # Calculate total size
    samtools view --threads "$CORE" -H "$bam_file" | grep -P '^@SQ' | cut -f 3 -d ':' | awk '{sum+=$1} END {print sum}' 2>&1 | tee "${bam_file}.total.size"

    # Calculate coverage
    samtools coverage "$bam_file" 2>&1 | tee "${bam_file}.coverage"

    # Generate flagstat report
    samtools flagstat -@ "$CORE" "$bam_file" > "${bam_file}.flagstat"
}

if [ ! -e "${OUTPUT_DIR}/100x/${FILE_NAME}.bam" ]; then
    echo "Merged sample file is not existing."
    echo "Generate it"

    # samtools merge -@ $CORES \
    #     ${SAMPLE_DIR}/SMAFIBT8WCXG.bam \
    #     ${SAMPLE_DIR}/SMAFIF7CG4YZ.bam \
    #     ${SAMPLE_DIR}/SMAFIPF11BMW.bam \
    #     -o ${OUTPUT_DIR}/100x/${FILE_NAME}.bam 

    # PacBio
    #samtools merge -@ $CORES \
    #    ${SAMPLE_DIR}/SMAFI5XI2KWA.bam \
    #    ${SAMPLE_DIR}/SMAFIA3UVATP.bam \
    #    ${SAMPLE_DIR}/SMAFIGJIKM6M.bam \
    #    -o ${OUTPUT_DIR}/100x/${FILE_NAME}.bam

    #samtools index -@ $CORES ${OUTPUT_DIR}/100x/${FILE_NAME}.bam
elif [ ! -e "${OUTPUT_DIR}/100x/${FILE_NAME}.bam.covered.depth" ]; then 
    calculate_bam_metrics ${OUTPUT_DIR}/100x/${FILE_NAME}.bam 8
fi


if [ ! -e "${OUTPUT_DIR}/${DEPTH}/${FILE_NAME}.bam" ]; then

    mkdir -p ${OUTPUT_DIR}/${DEPTH}

    python ${PROGRAM_DIR}/downsample_bam.py \
        -i ${OUTPUT_DIR}/100x/${FILE_NAME}.bam \
        -f $fraction \
        -o ${OUTPUT_DIR}/${DEPTH}/${FILE_NAME}.bam

    samtools index -@ $CORES ${OUTPUT_DIR}/${DEPTH}/${FILE_NAME}.bam

    calculate_bam_metrics ${OUTPUT_DIR}/${DEPTH}/${FILE_NAME}.bam 8
fi
