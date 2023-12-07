#!/bin/bash


module load java/jdk-1.8u112 

MELT_DIR=/n/data1/bch/genetics/lee/tools/MELTv2.2.2
RESULT_DIR=/n/data1/bch/genetics/lee/projects/SMaHT/results/MELT/shortread/germline/mixedDataRetroSom/200x
REF_DIR=/n/data1/bch/genetics/lee/reference/hg38
SAMPLE_DIR=/n/no_backup2/bch/lee/data/mixedDataRetroSom/A_200x
SAMPLE_FILE=CONT_1.recal.sorted.bam

# need to align bam file to hg38

java -jar ${MELT_DIR}/MELT.jar Single \
    -a \
    -c 8 \
    -h $REF_DIR/Homo_sapiens_assembly38.fasta \
    -bamfile $SAMPLE_DIR/$SAMPLE_FILE \
    -n $MELT_DIR/add_bed_files/Hg38/Hg38.genes.bed \
    -t mei_list.txt \
    -w $RESULT_DIR/CONT_1
