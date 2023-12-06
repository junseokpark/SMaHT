#!/bin/bash


module load java/jdk-1.8u112 

MELT_DIR=/n/data1/bch/genetics/lee/tools/MELTv2.2.2
RESULT_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/results/MELT/shortread/germline/mixedDataRetroSom/200x

java -version

# need to align bam file to hg38

java –jar $MELT_DIR/MELT.jar Single \
    -a \
    –b hs37d5/NC_007605 \
    –c 8 \
    –h /path/to/hs37d5.fa \
    –bamfile /path/to/NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211.bam \
    –n $MELT_DIR/add_bed_files/add_bed_files/Hg38/Hg38.genes.bed \
    –t mei_list.txt \
    –w $RESULT_DIR/
