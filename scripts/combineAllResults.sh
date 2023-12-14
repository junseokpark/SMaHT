#!/bin/bash

SAMPLE_TYPE=$1
TE_TYPE=$2
VCF_FILE_PATTERN="vcf"


vcf_files=($(find ./ -type d -name "${SAMPLE_TYPE}_*" -exec find {} -type f -name "*${TE_TYPE}.${VCF_FILE_PATTERN}" \;))


#rename 'final_comp.vcf' 'vcf' *.final_comp.vcf

for file in "${vcf_files[@]}"; do
    echo "Processing file: $file"
    
    # Use bcftools view to filter records with FILTER=PASS
    SAMPLE_ID=$(dirname $file | sed 's|^\./||')
    PASS_FILE_NAME=${SAMPLE_ID}.pass.vcf
    bcftools view -i 'FILTER="PASS"' "$file" -o "${PASS_FILE_NAME}"

    # Count the number of PASS records
    pass_count=$(bcftools view -H -i 'FILTER="PASS"' "$file" | wc -l)
    echo "Number of PASS records: $pass_count"

    # Concatenate the PASS records to the output file
    bcftools concat $PASS_FILE_NAME -o ${SAMPLE_TYPE}.${TE_TYPE}.${VCF_FILE_PATTERN}

    # Optionally, remove the temporary PASS-filtered VCF file
    rm "${PASS_FILE_NAME}"

done

echo "show result counts"
bcftools view -H ${SAMPLE_TYPE}.${TE_TYPE}.${VCF_FILE_PATTERN} | wc -l
