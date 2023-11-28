#!/bin/bash
#SBATCH -c 32
#SBATCH -t 4-12:00
#SBATCH --mem=128G
#SBATCH -p medium
#SBATCH -J cutesv-HG003
#SBATCH -o /n/data1/bch/genetics/lee/projects/SMaHT/results/CuteSV/germline/GIAB/HG003/HG003_%j.out
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

CONDA_HOME=$HOME/miniforge3
. $CONDA_HOME/etc/profile.d/conda.sh

conda activate cutesv

# ref: https://github.com/tjiangHIT/cuteSV 

BASE_DIRECTORY=/n/data1/bch/genetics/lee
REF_DIRECTORY=${BASE_DIRECTORY}/reference/hg38
WORK_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/results/CuteSV/germline/GIAB
RESULT_DIRECTORY=${WORK_DIRECTORY}/HG003
SOURCE_DIRECTORY=${BASE_DIRECTORY}/data/GIAB

REFERENCE_FILE=${REF_DIRECTORY}/Homo_sapiens_assembly38.fasta
OUTPUT_FILE=${RESULT_DIRECTORY}/HG003-cutesv.vcf
BAM_FILE=${SOURCE_DIRECTORY}/HG003_NA24149_father/UCSC_Ultralong_OxfordNanopore_Promethion/HG003_GRCh38_ONT-UL_UCSC_20200508.bam

cuteSV --thread 32 \
    --max_cluster_bias_INS 100 \
	--diff_ratio_merging_INS 0.3 \
	--max_cluster_bias_DEL 100 \
	--diff_ratio_merging_DEL 0.3 \
    $BAM_FILE \
    $REFERENCE_FILE \
    $OUTPUT_FILE \
    $RESULT_DIRECTORY

# > For PacBio CLR data:
# 	--max_cluster_bias_INS		100
# 	--diff_ratio_merging_INS	0.3
# 	--max_cluster_bias_DEL	200
# 	--diff_ratio_merging_DEL	0.5

# > For PacBio CCS(HIFI) data:
# 	--max_cluster_bias_INS		1000
# 	--diff_ratio_merging_INS	0.9
# 	--max_cluster_bias_DEL	1000
# 	--diff_ratio_merging_DEL	0.5

# > For ONT data:
# 	--max_cluster_bias_INS		100
# 	--diff_ratio_merging_INS	0.3
# 	--max_cluster_bias_DEL	100
# 	--diff_ratio_merging_DEL	0.3
# > For force calling:
# 	--min_mapq 			10