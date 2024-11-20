#!/bin/bash

#SBATCH -c 8
#SBATCH -t 3-23:00:00
#SBATCH --mem=64GB
#SBATCH -p medium
#SBATCH -J copyFiles
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

# Define the source directory
#SOURCE_DIR="/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_HapMap/illuminaNovaseq_bulkWgs_400x"
SOURCE_DIR="/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_HapMap/ontStd_r10_bulkWgs"  #ontStd_r10_bulkWgs pacbioHifi_bulkWgs

# Define the destination directory
DEST_DIR="/n/data1/hms/dbmi/park-smaht_dac/tmp_LeeLab/ontStd_r10_bulkWgs"

# load conda env
CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate SMaHT-3.9

# Define the subdirectories to copy from
#DIRS=("50x" "100x" "200x" "300x")
DIRS=("30x" "60x" "90x")

# Define the list of specific files to copy
# FILES=(
#     "HG005.bam"
#     "HG005.bam.bai"
#     "HG005.bam.covered.avg.depth"
#     "HG005.bam.flagstat"
#     "HapMapMix.bam"
#     "HapMapMix.bam.bai"
#     "HapMapMix.bam.covered.avg.depth"
#     "HapMapMix.bam.flagstat"
# )

FILES=(
    "HapMapMix.bam"
    "HapMapMix.bam.bai"
)

# Create a temporary file to store the rsync commands
TEMP_FILE=$(mktemp)

# Loop through each directory
for DIR in "${DIRS[@]}"; do
    # Loop through the list of files and generate rsync commands
    for FILE in "${FILES[@]}"; do
        SRC="${SOURCE_DIR}/${DIR}/${FILE}"
        DEST="${DEST_DIR}/${DIR}/${FILE}"
        mkdir -p ${DEST_DIR}/${DIR}
        echo "rsync -av --progress ${SRC} ${DEST}" >> "${TEMP_FILE}"
    done
done

# Run the rsync commands in parallel using GNU parallel
cat "${TEMP_FILE}" | parallel -j 8

# Clean up the temporary file
rm "${TEMP_FILE}"

echo "Files have been copied successfully."