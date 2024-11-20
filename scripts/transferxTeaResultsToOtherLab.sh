#!/bin/bash

#SBATCH -c 1
#SBATCH -t 10:00:00
#SBATCH --mem=4GB
#SBATCH -p short
#SBATCH -J copyfiles
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

# Define source and child directories
SOURCE_PARENT_DIRECTORIES=(
    "/n/data1/bch/genetics/lee/projects/SMaHT/results/xTea/shortread/mosaic/HapMap"
    "/n/data1/bch/genetics/lee/projects/SMaHT/results/xTea/shortread/germline/HapMap"
)
CHILD_DIRECTORIES=("200x_NYGC" "200x_UW" "400x" "500x_WashU")
DEST_DIRECTORY="/n/data1/hms/dbmi/park-smaht_dac/tmp_LeeLab"

# Loop through each source directory
for SRC_DIR in "${SOURCE_PARENT_DIRECTORIES[@]}"; do

    # Extract the second to last directory name from the source path
    DEST_NAME=$(basename $(dirname "$SRC_DIR"))

    # Create the destination directory if it doesn't exist
    mkdir -p "${DEST_DIRECTORY}/${DEST_NAME}"

    # Loop through each child directory and use rsync to copy files
    for CHR_DIR in "${CHILD_DIRECTORIES[@]}"; do
        rsync -a "${SRC_DIR}/${CHR_DIR}/" "${DEST_DIRECTORY}/${DEST_NAME}/${CHR_DIR}/"
    done

done