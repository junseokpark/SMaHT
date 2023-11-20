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
# ./run_xTea.sh -s CONT_8 \
#     -p .recal.sorted.bam \
#     -d /n/no_backup2/bch/lee/data/mixedDataRetroSom/B_Simul100x \
#     -e ${BASE_DIRECTORY}/refs \
#     -r ${BASE_DIRECTORY}/results/xTea/germline/Simul100x \
#     -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
#     -x /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea \
#     -f xtea

# LongRead
./run_xTea.sh -s HG002 \
    -p _GRCh38_ONT-UL_GIAB_20200122.phased \
    -d /n/data1/bch/genetics/lee/data/GIAB/Ultralong_OxfordNanopore/guppy-V3.2.4_2020-01-22 \
    -e ${BASE_DIRECTORY}/refs \
    -r ${BASE_DIRECTORY}/results/xTea/longread_germline \
    -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
    -x /n/data1/bch/genetics/lee/tools/xTea-longread/xtea_long \
    -f xtea_long