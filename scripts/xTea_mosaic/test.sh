#!/bin/bash

BASE_DIRECTORY="/n/data1/bch/genetics/lee/projects/SMaHT"

# ./run_xTea.sh -s CONT_7 \
#     -p .sorted.bam \
#     -d /n/no_backup2/bch/lee/data/mixedDataRetroSom/B_Simul100x \
#     -e ${BASE_DIRECTORY}/refs \
#     -r ${BASE_DIRECTORY}/results/xTea/mosaic/Simul100x \
#     -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
#     -x /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea

./run_xTea.sh -s CONT_7 \
    -p .sorted.bam \
    -d /n/no_backup2/bch/lee/data/mixedDataRetroSom/B_Simul100x \
    -e ${BASE_DIRECTORY}/refs \
    -r ${BASE_DIRECTORY}/results/xTea/germline/Simul100x \
    -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
    -x /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea \
    -f xtea