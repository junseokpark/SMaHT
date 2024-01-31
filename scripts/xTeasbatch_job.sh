#!/bin/bash

#SBATCH -c [SLURM_CORE]
#SBATCH -t [SLURM_TIME]
#SBATCH --mem=[SLURM_MEMORY]
#SBATCH -p [SLURM_PARTITION]
#SBATCH -J xTea-[SAMPLE_ID]
#SBATCH -o [RESULT_DIR]/[SAMPLE_ID]/[SAMPLE_ID]_%j.out
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

BASE_DIRECTORY=/n/data1/bch/genetics/lee
REF_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/refs
WORK_DIRECTORY=[RESULT_DIR]
CONFIG_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/benchmark/toolTest_pipeline/config

declare -A batch_scripts

batch_scripts[alu]="[SAMPLE_ID]/Alu/run_xTEA_pipeline.sh"
batch_scripts[L1]="[SAMPLE_ID]/L1/run_xTEA_pipeline.sh"

for key in "${!batch_scripts[@]}"
do
  echo "Processing '$key'"

  chmod +x ${WORK_DIRECTORY}/${batch_scripts[$key]}

  singularity run \
    -B /n/data1/bch/genetics/lee/:/n/data1/bch/genetics/lee/ \
    -B /n/scratch/users/j/jp394/:/n/scratch/users/j/jp394/ \
    -B /n/no_backup2/bch/lee/data/:/n/no_backup2/bch/lee/data/ \
    /n/app/singularity/containers/jp394/xtea-mosaic.sif ${WORK_DIRECTORY}/${batch_scripts[$key]}

done
