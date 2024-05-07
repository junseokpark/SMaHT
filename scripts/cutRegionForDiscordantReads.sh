#!/bin/bash

PATH=/n/data1/bch/genetics/lee/tools/samblaster:$PATH
#BAMFILE=/n/data1/bch/genetics/lee/projects/SMaHT/results/RetroSom/shortread/mosaic/mixedDataRetroSom/COLO829/v2/COLO829T_Ill/align/COLO829T_Ill.final.bam
#BAMFILE=/n/data1/bch/genetics/lee/projects/SMaHT/results/MELT/shortread/germline/COLO829/COLO829T_Ill/COLO829T_Ill.ALU.aligned.sorted.bam
#BAMFILE=/n/data1/hms/dbmi/park-smaht_dac/analysis/GCC_UW/COLO829T/illuminaNovaseq_bulkWgs/seq_data/COLO829T_Ill.bam 
BAMFILE=/n/data1/bch/genetics/lee/projects/SMaHT/data/SMATH_DAC_downSampled/COLO829T/COLO829T_Ill.sorted.bam

REGION="chr2:108146065-108176065"
OUTPUT_NAME="retro_alu_ex1"
#CHROM="chr2"

rm -rf ${OUTPUT_NAME}.*.sam
rm -rf ${OUTPUT_NAME}.out.*

samtools view $BAMFILE "LH00266:46:22GM3HLT3:1:1101:11134:2474"

# samtools sort -n <(samtools view -b $BAMFILE $REGION) -o ${OUTPUT_NAME}.sorted.bam
# samtools index -@ 8 ${OUTPUT_NAME}.sorted.bam


#samtools view -h <(samtools sort -n <(samtools view -b $BAMFILE $REGION) )
#samtools view -h <(samtools view -b $BAMFILE $REGION) 
#samtools view -h $BAMFILE

# samtools view -h <(samtools sort -n <(samtools view -b $BAMFILE $REGION)) | samblaster -a -e --ignoreUnmated -d ${OUTPUT_NAME}.disc.sam -s ${OUTPUT_NAME}.split.sam | samtools view -@ 8 -Sb - > ${OUTPUT_NAME}.out.bam \
# && samtools index -@ 8 ${OUTPUT_NAME}.out.bam


#samtools view -@ 8 -h $BAMFILE

# | samblaster -a -d ${OUTPUT_NAME}.disc.sam -s ${OUTPUT_NAME}.split.sam  | samtools view -Sb - > ${OUTPUT_NAME}.out.bam \
#&& samtools index ${OUTPUT_NAME}.out.bam


#samtools view -h <(samtools sort <(samtools view -b $BAMFILE $CHROM)) | samblaster -e -d ${OUTPUT_NAME}.disc.sam -s ${OUTPUT_NAME}.split.sam  | samtools view -Sb - > ${OUTPUT_NAME}.out.bam \
#&& samtools index ${OUTPUT_NAME}.out.bam

#-u ${OUTPUT_NAME}.umc.fasta 