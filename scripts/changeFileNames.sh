#!/bin/bash


#FILE_NAME="HapMapMix"
#DEPTH="100x"

FILE_NAME=$1
DEPTH=$2

WORK_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_HapMap/illuminaNovaseq_bulkWgs_400x/${DEPTH}/${FILE_NAME}-split

cd $WORK_DIR

shard_bam_files=(shard_*.bam)
#shard_bai_files=($(find . -maxdepth 1 -type f -name 'shard_[0-9]*.bai')) 
shard_bai_files=(shard_*.bai) 


if [ ${#shard_bam_files[@]} -eq 0 ]; then
    echo "No bam files found matching the pattern."
else

    for file in "${shard_bam_files[@]}"; do
        number=$(echo "$file" | sed 's/shard_\([0-9]\+\)\.bam/\1/')
        new_name="${FILE_NAME}-$(echo "$number" | sed 's/^0*//').bam"
        echo $file $new_name
        mv "$file" "$new_name"
    done
fi

if [ ${#shard_bai_files[@]} -eq 0 ]; then
    echo "No bai files found matching the pattern."
else

    for file in "${shard_bai_files[@]}"; do

        number=$(echo "$file" | sed 's/shard_\([0-9]\+\)\.bai/\1/')
        new_name="${FILE_NAME}-$(echo "$number" | sed 's/^0*//').bam.bai"
        echo $file $new_name
        mv "$file" "$new_name"
    done
fi