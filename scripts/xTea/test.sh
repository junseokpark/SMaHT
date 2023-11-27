#!/bin/bash

BASE_DIRECTORY="/n/data1/bch/genetics/lee/projects/SMaHT"

# Mosaic
./run_xTea.sh -s HG002 \
    -p .GRCh38.300x.bam \
    -d /n/data1/bch/genetics/lee/data/GIAB/HG002_NA24385_son/NIST_HiSeq_HG002_Homogeneity-10953946/NHGRI_Illumina300X_AJtrio_novoalign_bams \
    -e ${BASE_DIRECTORY}/refs \
    -r ${BASE_DIRECTORY}/results/xTea/shortread/mosaic/GIAB/Illumina300x \
    -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
    -x /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea \
    -f gnrt_pipeline_local_v38.py \
    -o 16 \
    -m 128

# Germline
# ./run_xTea.sh -s HG003 \
#     -p .GRCh38.300x.bam \
#     -d /n/data1/bch/genetics/lee/data/GIAB/HG003_NA24149_father/NIST_HiSeq_HG003_Homogeneity-12389378/NHGRI_Illumina300X_AJtrio_novoalign_bams \
#     -e ${BASE_DIRECTORY}/refs \
#     -r ${BASE_DIRECTORY}/results/xTea/shortread/germline/GIAB/Illumina300x \
#     -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
#     -x /n/data1/bch/genetics/lee/tools/xTea/xtea \
#     -f xtea \
#     -o 16 \
#     -m 128

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

