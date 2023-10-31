#!/bin/bash

#SBATCH -c 8
#SBATCH -t 4-12:00
#SBATCH --mem=96G
#SBATCH -p medium
#SBATCH -o TITR_1_%j.out
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

BASE_DIRECTORY=/n/data1/bch/genetics/lee
REF_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/refs
WORK_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/results/xTea_mosaic
CONFIG_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/benchmark/toolTest_pipeline/config

BATCH_SCRIPT="/n/data1/bch/genetics/lee/projects/SMaHT/results/xTea_mosaic/TITR_1/L1/run_xTEA_pipeline.sh"
#BATCH_SCRIPT="/n/data1/bch/genetics/lee/projects/SMaHT/results/xTea_mosaic/TITR_1/Alu/run_xTEA_pipeline.sh"

singularity run \
    -B /n/data1/bch/genetics/lee/:/n/data1/bch/genetics/lee/ \
    -B /n/scratch3/users/j/jp394/:/n/scratch3/users/j/jp394/ \
    -B /n/no_backup2/bch/lee/data/:/n/no_backup2/bch/lee/data/ \
    /n/app/singularity/containers/jp394/xtea-mosaic.sif "${BATCH_SCRIPT}"
