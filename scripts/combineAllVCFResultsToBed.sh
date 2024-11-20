#!/bin/bash

SAMPLE_TYPE=$1
TE_TYPE=$2
BASE=$3

VCF_FILE_PATTERN="vcf"

TOOL_PATH=/n/data1/bch/genetics/lee/tools/bedops.2.4.41/bin
PATH=$TOOL_PATH:$PATH

echo "Start"
#set -x

cd $BASE

#echo $PWD
vcf_files=($(find ./ -type d -name "${SAMPLE_TYPE}_*" -exec find {} -type f -name "*${TE_TYPE}.final_comp.${VCF_FILE_PATTERN}" \;))

#rename 'final_comp.vcf' 'vcf' *.final_comp.vcf

for file in "${vcf_files[@]}"; do
    echo "Processing file: $file"
    
    SAMPLE_ID=$(dirname $file | sed 's|^\./||')
    SAMPLE_ID=$(echo "$SAMPLE_ID" | cut -d'/' -f1)

    echo $SAMPLE_ID
    rm -rf temp.vcf
    bcftools view -i 'FILTER="PASS"' $file > temp.vcf

    # Sort
    vcf2bed < temp.vcf | sort -k1,1V -k1,1 -k2,2n > ${SAMPLE_ID}_${TE_TYPE}.bed

     # Append the generated BED file to the array
    bed_files+=("${SAMPLE_ID}_${TE_TYPE}.bed")

done

# Combine all generated BED files into one single BED file
cat "${bed_files[@]}" > ${SAMPLE_TYPE}.${TE_TYPE}.bed