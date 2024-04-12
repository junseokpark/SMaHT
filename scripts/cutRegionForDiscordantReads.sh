#!/bin/bash

PATH=/n/data1/bch/genetics/lee/tools/samblaster:$PATH
#BAMFILE=/n/data1/bch/genetics/lee/projects/SMaHT/results/RetroSom/shortread/mosaic/mixedDataRetroSom/COLO829/v2/COLO829T_Ill/align/COLO829T_Ill.final.bam
#BAMFILE=/n/data1/bch/genetics/lee/projects/SMaHT/results/MELT/shortread/germline/COLO829/COLO829T_Ill/COLO829T_Ill.ALU.aligned.sorted.bam
BAMFILE=/n/data1/hms/dbmi/park-smaht_dac/analysis/GCC_UW/COLO829T/illuminaNovaseq_bulkWgs/seq_data/COLO829T_Ill.bam 


REGION="chr2:108146065-108176065"
OUTPUT_NAME="retro_alu_ex1"
#CHROM="chr2"

rm -rf ${OUTPUT_NAME}.*.sam
rm -rf ${OUTPUT_NAME}.out.*

#samtools view -h <(samtools sort <(samtools view -b $BAMFILE $REGION))

#samtools view -h <(samtools view -b $BAMFILE $REGION) 
samtools view -h $BAMFILE | samblaster -a -d ${OUTPUT_NAME}.disc.sam -s ${OUTPUT_NAME}.split.sam  
#| samtools view -@ 8 -Sb - > ${OUTPUT_NAME}.out.bam \
#&& samtools index ${OUTPUT_NAME}.out.bam


#samtools view -@ 8 -h $BAMFILE

# | samblaster -a -d ${OUTPUT_NAME}.disc.sam -s ${OUTPUT_NAME}.split.sam  | samtools view -Sb - > ${OUTPUT_NAME}.out.bam \
#&& samtools index ${OUTPUT_NAME}.out.bam


#samtools view -h <(samtools sort <(samtools view -b $BAMFILE $CHROM)) | samblaster -e -d ${OUTPUT_NAME}.disc.sam -s ${OUTPUT_NAME}.split.sam  | samtools view -Sb - > ${OUTPUT_NAME}.out.bam \
#&& samtools index ${OUTPUT_NAME}.out.bam

# samtools sort -@ 16 -m 4G /n/data1/hms/dbmi/park-smaht_dac/analysis/GCC_UW/COLO829T/illuminaNovaseq_bulkWgs/seq_data/COLO829T_Ill.bam -o COLO829T_Ill.sorted.bam

#-u ${OUTPUT_NAME}.umc.fasta 