#!/bin/bash


# 
G_PATH="/n/data1/bch/genetics/lee/projects/SMaHT/gold_standards/RetroSomMixed/Alu/paperData"
# 0.2_NA19240.bed  0.2_NA19240_C.bed  1_HG00514.bed  1_HG00514_C.bed  1_HG00733.bed  1_HG00733_C.bed  25_NA12877.bed  25_NA12877_C.bed  5_BSMN.bed  5_BSMN_C.bed


# cat strand0/HG00514.heter.bed strand1/HG00514.heter.bed | sort -k1,1V -k1,1 -k2,2n | cut -f1-4 | awk -F'\t' 'BEGIN {OFS = FS} {$0; print}' > 1_HG00514_C.bed
cat strand0/BSMN.heter.bed strand1/BSMN.heter.bed | sort -k1,1V -k1,1 -k2,2n | cut -f1-4 | awk -F'\t' 'BEGIN {OFS = FS} {$0; print}' > 5_BSMN_C.bed


# Step #1  - Slop
#  bedtools slop -i MELT.bed -g ../../../../../refs/hg38/hg38.chrom.sizes  -b 600 > MELT_E.bed
#  bedtools slop -i RetroSom_v2.bed -g ../../../../../refs/hg38/hg38.chrom.sizes  -b 600 > RetroSom_v2_E.bed
#  bedtools slop -i xTea_mosaic.bed -g ../../../../../refs/hg38/hg38.chrom.sizes  -b 600 > xTea_mosaic_E.bed 


# bedtools slop -i MELT.bed -g ../../../../../refs/hg38/hg38.chrom.sizes  -b 600  | sort -k1,1V -k1,1 -k2,2n > MELT_E.bed

# # Step #2 - Sort
# #  sort -k1,1 -k2,2n xTea_mosaic_E.bed

# # Step #3 - Venn 

intervene venn -i RetroSom_v2_E.bed MELT_E.bed xTea_mosaic_E.bed --bedtools-options f=0.5,r --filenames --title Alu_200x

intervene venn -i ${G_PATH}/0.2_NA19240_C.bed ${G_PATH}/1_HG00514_C.bed ${G_PATH}/1_HG00733_C.bed ${G_PATH}/5_BSMN_C.bed ${G_PATH}/25_NA12877_C.bed --filenames

# # Step #4 - Upset Figure
# intervene upset -i RetroSom_v2_E.bed xTea_mosaic_E.bed MELT_E.bed temp.bed --showshiny


intervene upset -i RetroSom_v2_E.bed MELT_E.bed xTea_mosaic_E.bed ${G_PATH}/0.2_NA19240.bed --bedtools-options f=0.5,r --filename --showshiny
intervene upset -i RetroSom_v2_E.bed MELT_E.bed xTea_mosaic_E.bed ${G_PATH}/0.2_NA19240_C.bed ${G_PATH}/1_HG00514_C.bed ${G_PATH}/1_HG00733_C.bed ${G_PATH}/5_BSMN_C.bed ${G_PATH}/25_NA12877_C.bed --filename --showshiny