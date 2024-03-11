#!/bin/bash

#SBATCH -c 8
#SBATCH -t 0-12:00:00
#SBATCH --mem=64GB
#SBATCH -p short
#SBATCH -J depthCalculation
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu


# author: Junseok Park (junseok.park@childrens.harvard.edu)
sample_dir="/n/data1/hms/dbmi/park-smaht_dac/analysis/GCC_UW/COLO829T/illuminaNovaseq_bulkWgs/seq_data"

# load conda env
CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate SMaTH

for bam_file in "$sample_dir"/COLO829T_Ill.bam; do
    # Check if the file is a regular file (not a directory)
    if [ -f "$bam_file" ]; then
        echo "Processing $bam_file..."
        
        #samtools depth --threads 8 $bam_file 2>&1 | tee $bam_file.covered.depth
        #samtools depth --threads 8 $bam_file | awk '{sum+=$3} END { print "Average = ",sum/NR}' 2>&1 | tee $bam_file.covered.avg.depth

        #samtools depth --threads 8 -a $bam_file 2>&1 | tee $bam_file.all.depth
        #samtools depth --threads 8 -a $bam_file | awk '{sum+=$3} END { print "Average = ",sum/NR}' 2>&1 | tee $bam_file.all.avg.depth

        #samtools view --threads 8 -H $bam_file | grep -P '^@SQ' | cut -f 3 -d ':' | awk '{sum+=$1} END {print sum}'  2>&1 | tee $bam_file.total.size
        samtools coverage $bam_file  2>&1 | tee $bam_file.coverage

    fi
done
