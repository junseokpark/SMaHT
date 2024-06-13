#!/bin/bash

#SBATCH -c 8
#SBATCH -t 2-00:00:00
#SBATCH --mem=32GB
#SBATCH -p medium
#SBATCH -J depthCalculation
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu


# author: Junseok Park (junseok.park@childrens.harvard.edu)
sample_dir="/n/data1/bch/genetics/lee/projects/SMaHT/data/SMaHT_DAC_HapMap/illuminaNovaseq_bulkWgs_400x/500x_WashU"
CORE=8

# load conda env
CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate SMaTH

#for bam_file in "$sample_dir"/*.bam; do
for bam_file in $(find "$sample_dir" -type f -name "*.bam"); do
    # Check if the file is a regular file (not a directory)
    if [ -f "$bam_file" ]; then
        echo "Processing $bam_file..."
        
        samtools depth --threads $CORE $bam_file 2>&1 | tee $bam_file.covered.depth
        samtools depth --threads $CORE $bam_file | awk '{sum+=$3} END { print "Average = ",sum/NR}' 2>&1 | tee $bam_file.covered.avg.depth

        samtools depth --threads $CORE -a $bam_file 2>&1 | tee $bam_file.all.depth
        samtools depth --threads $CORE -a $bam_file | awk '{sum+=$3} END { print "Average = ",sum/NR}' 2>&1 | tee $bam_file.all.avg.depth

        samtools view --threads $CORE -H $bam_file | grep -P '^@SQ' | cut -f 3 -d ':' | awk '{sum+=$1} END {print sum}'  2>&1 | tee $bam_file.total.size
        samtools coverage $bam_file  2>&1 | tee $bam_file.coverage

        samtools flagstat -@ $CORE "${bam_file}" > ${bam_file}.flagstat

    fi
done
