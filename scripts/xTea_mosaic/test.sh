#!/bin/bash

BASE_DIRECTORY="/n/data1/bch/genetics/lee/projects/SMaHT"

# ./run_xTea.sh -s CONT_7 \
#     -p .sorted.bam \
#     -d /n/no_backup2/bch/lee/data/mixedDataRetroSom/B_Simul100x \
#     -e ${BASE_DIRECTORY}/refs \
#     -r ${BASE_DIRECTORY}/results/xTea/mosaic/Simul100x \
#     -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
#     -x /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea

# Germline
./run_xTea.sh -s HG003 \
    -p .GRCh38.300x.bam \
    -d /n/data1/bch/genetics/lee/data/GIAB/HG003_NA24149_father/NIST_HiSeq_HG003_Homogeneity-12389378/NHGRI_Illumina300X_AJtrio_novoalign_bams \
    -e ${BASE_DIRECTORY}/refs \
    -r ${BASE_DIRECTORY}/results/xTea/shortread/germline/GIAB/Illumina300x \
    -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
    -x /n/data1/bch/genetics/lee/tools/xTea/xtea \
    -f xtea \
    -o 16 \
    -m 128

# LongRead
# ./run_xTea.sh -s HG002 \
#     -p _GRCh38_ONT-UL_GIAB_20200122.phased \
#     -d /n/data1/bch/genetics/lee/data/GIAB/Ultralong_OxfordNanopore/guppy-V3.2.4_2020-01-22 \
#     -e ${BASE_DIRECTORY}/refs \
#     -r ${BASE_DIRECTORY}/results/xTea/longread_germline \
#     -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
#     -x /n/data1/bch/genetics/lee/tools/xTea-longread/xtea_long \
#     -f xtea_long \
#     -o 16 \
#     -m 128 \

