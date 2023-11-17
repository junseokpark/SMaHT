#!/bin/bash

BASE_DIRECTORY=/Users/junseokpark/Dropbox/Development/scripts/smath_dac

./run_xTea.sh -s CONT_7 \
    -p .sorted.bam \
    -d /n/no_backup2/bch/lee/data/mixedDataRetroSom/A_200x \
    -e ${BASE_DIRECTORY}/refs \
    -r ${BASE_DIRECTORY}/results/xTea/mosaic/Simul100x \
    -c ${BASE_DIRECTORY}/benchmark/toolTest_pipeline/config \
    -x /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea