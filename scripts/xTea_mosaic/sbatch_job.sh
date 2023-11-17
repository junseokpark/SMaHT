#!/bin/bash

#SBATCH -c 8
#SBATCH -t 4-12:00
#SBATCH --mem=64G
#SBATCH -p medium
#SBATCH -J job-CONT_15
#SBATCH -o CONT_15_%j.out
#SBATCH --mail-type=NONE
#SBATCH --mail-user=junseok.park@childrens.harvard.edu

BASE_DIRECTORY=/n/data1/bch/genetics/lee
REF_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/refs
WORK_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/results/xTea_mosaic_Simul50x
CONFIG_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/benchmark/toolTest_pipeline/config

declare -A batch_scripts

batch_scripts[alu]="CONT_15/Alu/run_xTEA_pipeline.sh"
batch_scripts[L1]="CONT_15/L1/run_xTEA_pipeline.sh"

#BATCH_SCRIPT="/n/data1/bch/genetics/lee/projects/SMaHT/results/xTea_mosaic/TITR_1/L1/run_xTEA_pipeline.sh"
#BATCH_SCRIPT="/n/data1/bch/genetics/lee/projects/SMaHT/results/xTea_mosaic/TITR_1/Alu/run_xTEA_pipeline.sh"

for key in "${!batch_scripts[@]}"
do
  echo "Processing '$key'"
  #echo ${WORK_DIRECTORY}/${batch_scripts[$key]}
  #ls -alF ${WORK_DIRECTORY}/${batch_scripts[$key]}

  #exit

  chmod +x ${WORK_DIRECTORY}/${batch_scripts[$key]}

  singularity run \
    -B /n/data1/bch/genetics/lee/:/n/data1/bch/genetics/lee/ \
    -B /n/scratch3/users/j/jp394/:/n/scratch3/users/j/jp394/ \
    -B /n/no_backup2/bch/lee/data/:/n/no_backup2/bch/lee/data/ \
    /n/app/singularity/containers/jp394/xtea-mosaic.sif ${WORK_DIRECTORY}/${batch_scripts[$key]}

done
