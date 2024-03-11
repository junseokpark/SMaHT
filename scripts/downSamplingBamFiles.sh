#!/bin/bash

#SBATCH -c 8
#SBATCH -t 3-23:00:00
#SBATCH --mem=64GB
#SBATCH -p medium
#SBATCH -J downSampling
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu



numThreads=8
fractionOfReads=0.25
seed=12345

# author: Junseok Park (junseok.park@childrens.harvard.edu)
sample_dir="/n/data1/hms/dbmi/park-smaht_dac/analysis/GCC_UW/COLO829T/illuminaNovaseq_bulkWgs/seq_data"
result_dir="/n/data1/bch/genetics/lee/projects/SMaHT/data/SMATH_DAC_downSampled/COLO829T"

# load conda env
CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate SMaTH

for bam_file in "$sample_dir"/*.bam; do
    # Check if the file is a regular file (not a directory)
    if [ -f "$bam_file" ]; then
        # Extract the filename from the path using parameter expansion
        bam_filename="${bam_file##*/}"
        echo "Processing $bam_filename..."

        samtools view -b --threads $numThreads --subsample $fractionOfReads --subsample-seed $seed $bam_file > ${result_dir}/${bam_filename}.50x


    fi
done

